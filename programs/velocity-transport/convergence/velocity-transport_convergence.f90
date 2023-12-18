program velocity_transport_convergence
  use aptofem_kernel
  use problem_options
  use problem_options_velocity
  use problem_options_transport
  use problem_options_geometry
  use solution_storage_velocity
  use previous_velocity
  use velocity_bc_interface
  use bcs_transport
  use error_norms
  
  use matrix_rhs_transport
  use matrix_rhs_transport_ss
  use matrix_rhs_s_b_ss
  use jacobi_residual_ns_b_ss
  use jacobi_residual_ns_nsb_ss
  use jacobi_residual_nsb
  use jacobi_residual_nsb_ss
  use jacobi_residual_nsb_mm

  implicit none

  ! Basic variables.
  type(aptofem_keys), pointer   :: aptofem_stored_keys
  type(mesh)                    :: mesh_data, mesh_data_orig
  type(solution)                :: solution_transport, solution_transport_orig, solution_velocity_orig
  type(fe_assembly_subroutines) :: fe_solver_routines_velocity, fe_solver_routines_transport
  logical                       :: ifail

  ! Mesh refinement variables.
  type(refinement_tree)              :: mesh_tree
  integer, dimension(:), allocatable :: refinement_marks
  integer                            :: mesh_no, no_eles, problem_dim, no_meshes
  character(3)                       :: no_meshes_string

  ! Time stepping variables.
  class(sp_matrix_rhs), pointer   :: sp_matrix_rhs_data_velocity, sp_matrix_rhs_data_transport
  type(default_user_data)         :: scheme_data_velocity, scheme_data_transport
  type(dirk_time_stepping_scheme) :: dirk_scheme_velocity
  real(db)                        :: current_time, time_step, norm_diff_u
  integer                         :: time_step_no

  ! Norm storage.
  character(30), dimension(5) :: errors_format, errors_name
  real(db), dimension(5)      :: errors
  integer                     :: no_errors_velocity, no_errors_transport

  ! Norm output.
  integer            :: velocity_dofs
  character(len=100) :: norm_file, aptofem_run_number_string, tsv_format

  ! CLA variables.
  integer       :: no_command_line_arguments
  character(50) :: test_type

  !!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !! COMMAND LINE ARGUMENTS !!
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!
  no_command_line_arguments = command_argument_count()
  if (no_command_line_arguments /= 3) then
      print *, "ERROR: Incorrect number of command line arguments."
      print *, "       Usage: ./velocity-transport.out <nsb|ns-b|ns-nsb|s-b> <test_type> <no_meshes>"
      error stop
  end if
  call get_command_argument(1, assembly_name)
  if (assembly_name /= 'nsb' .and. assembly_name /= 'ns-b' .and. assembly_name /= 'ns-nsb' .and. assembly_name /= 's-b') then
      call write_message(io_err, 'Error: assembly_name should be nsb or ns-b or ns-nsb or s-b.')
      error stop
  end if
  call get_command_argument(2, test_type)
  if (.false.) then
    call write_message(io_err, 'Error: assembly_name should be [TODO].')
    error stop
  end if
  call get_command_argument(3, no_meshes_string)
  read(no_meshes_string, *) no_meshes

  geometry_name = 'square'

  !!!!!!!!!!!!!!!!!!!
  !! APTOFEM SETUP !!
  !!!!!!!!!!!!!!!!!!!
  call AptoFEM_initialize     (aptofem_stored_keys, 'aptofem_control_file.dat', './common/')
  call setup_velocity_bcs     (geometry_name)
  call create_mesh            (mesh_data, get_boundary_no_velocity, 'mesh_gen', aptofem_stored_keys)
  call get_user_data          ('user_data', aptofem_stored_keys)
  call get_user_data_velocity ('user_data', aptofem_stored_keys)
  call get_user_data_transport('user_data', aptofem_stored_keys)
  call set_space_type_velocity(aptofem_stored_keys)
  ! call initialise_geometry    (geometry_name)

  !!!!!!!!!!!!!!!!!!!!!!!
  !! SETUP NORM OUTPUT !!
  !!!!!!!!!!!!!!!!!!!!!!!
  write(aptofem_run_number_string, '(i10)') aptofem_run_number
  norm_file = '../../output/norms' // '_' // 'velocity-transport_convergence' // '_' // &
    trim(geometry_name) // '_' // trim(adjustl(aptofem_run_number_string)) // '.dat'
  open(23111997, file=norm_file, status='replace')
  tsv_format = '(*(G0.6,:,"'//achar(9)//'"))'
  
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !! VELOCITY STEADY-STATE SPATIAL CONVERGENCE !!
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  if (trim(test_type) == 'ss_velocity_space') then
    ! Setup velocity solution.
    call create_fe_solution(solution_velocity, mesh_data, 'fe_solution_velocity', aptofem_stored_keys, dirichlet_bc_velocity)

    ! Store appropriate assembly routines.
    if (assembly_name == 'nsb') then
      call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_element',       jacobian_nsb_ss, 1)
      call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_int_bdry_face', jacobian_face_nsb_ss, 1)
      call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_element',         element_residual_nsb_ss, 1)
      call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_int_bdry_face',   element_residual_face_nsb_ss, 1)
    else
      call write_message(io_err, 'Error: not implemented for other assemblies other than nsb.')
      error stop
    end if

    ! Setup error outputting.
    errors_format  = '(g15.5)'
    errors_name(1) = '||u-u_h||_L_2'
    errors_name(2) = '||p-p_h||_L_2'
    errors_name(3) = '||u-u_h,p-p_h||_L_2'
    errors_name(4) = '||u-u_h,p-p_h||_DG'
    errors_name(5) = '||div(u-u_h)||_L_2'

    write(23111997, tsv_format) 'no_timesteps', 'mesh_no', 'dofs', 'L2_u', 'L2_p', 'L2_up', 'DG_up', 'L2_div_u'

    ! Loop over meshes.
    do mesh_no = 1, no_meshes
      ! Setup and solve for this mesh.
      call set_up_newton_solver_parameters('solver_velocity', aptofem_stored_keys, scheme_data_velocity)
      call linear_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', aptofem_stored_keys, &
        sp_matrix_rhs_data_velocity, 1, scheme_data_velocity)
      call linear_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', aptofem_stored_keys, &
        sp_matrix_rhs_data_velocity, 2, scheme_data_velocity)
      call newton_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', aptofem_stored_keys, &
        sp_matrix_rhs_data_velocity, scheme_data_velocity, ifail)

      ! Get DoFs.
      velocity_dofs = get_no_dofs(solution_velocity)

      ! Norms and output.
      call error_norms_velocity(errors, mesh_data, solution_velocity)
      call write_data   ('output_data', aptofem_stored_keys, errors, 5, errors_name, errors_format, mesh_data, &
        solution_velocity)
      call write_fe_data('output_mesh_solution_velocity_2D', aptofem_stored_keys, mesh_no, mesh_data, solution_velocity)
      write(23111997, tsv_format) 0, mesh_no, velocity_dofs, errors(1), errors(2), errors(3), errors(4), errors(5)

      ! Clean up solver storage.
      call linear_fe_solver(solution_velocity,  mesh_data, fe_solver_routines_velocity,  'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity,  5, scheme_data_velocity)

      ! Refine the mesh uniformly.
      if (mesh_no < no_meshes) then
        call hp_mesh_adapt_uniform_refinement('uniform_refinement', aptofem_stored_keys, mesh_tree, mesh_data, &
          solution_velocity, mesh_data_orig, solution_velocity_orig, mesh_no)

        call delete_mesh(mesh_data_orig)
        call delete_solution(solution_velocity_orig)
      end if
    end do

    call delete_solution(solution_velocity)

  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !! VELOCITY TIME-DEPENDENT SPATIAL CONVERGENCE !!
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  else if (trim(test_type) == 'velocity_space') then
    ! Setup velocity solution.
    call create_fe_solution(solution_velocity, mesh_data, 'fe_solution_velocity', aptofem_stored_keys, dirichlet_bc_velocity)

    ! Setup error outputting.
    errors_format  = '(g15.5)'
    errors_name(1) = '||u-u_h||_L_2'
    errors_name(2) = '||p-p_h||_L_2'
    errors_name(3) = '||u-u_h,p-p_h||_L_2'
    errors_name(4) = '||u-u_h,p-p_h||_DG'
    errors_name(5) = '||div(u-u_h)||_L_2'

    write(23111997, tsv_format) 'no_timesteps', 'mesh_no', 'dofs', 'L2_u', 'L2_p', 'L2_up', 'DG_up', 'L2_div_u'

    ! Loop over meshes.
    do mesh_no = 1, no_meshes
      ! Reset timestepping.
      solution_velocity%current_time    = 0.0_db
      scheme_data_velocity%current_time = 0.0_db
      scheme_data_velocity%time_step    = final_local_time/real(no_time_steps, db)
      call set_current_time(solution_velocity, 0.0_db)

      ! Store steady-state assembly for initial condition.
      if (assembly_name == 'nsb') then
        call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_element',       jacobian_nsb_ss, 1)
        call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_int_bdry_face', jacobian_face_nsb_ss, 1)
        call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_element',         element_residual_nsb_ss, 1)
        call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_int_bdry_face',   element_residual_face_nsb_ss,&
          1)
      else
        call write_message(io_err, 'Error: not implemented for other assemblies other than nsb.')
        error stop
      end if

      ! Setup and solve steady-state problem.
      call set_up_newton_solver_parameters('solver_velocity', aptofem_stored_keys, scheme_data_velocity)
      call linear_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', aptofem_stored_keys, &
        sp_matrix_rhs_data_velocity, 1, scheme_data_velocity)
      call linear_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', aptofem_stored_keys, &
        sp_matrix_rhs_data_velocity, 2, scheme_data_velocity)
      call newton_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', aptofem_stored_keys, &
        sp_matrix_rhs_data_velocity, scheme_data_velocity, ifail)
      call linear_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', aptofem_stored_keys, &
        sp_matrix_rhs_data_velocity,  5, scheme_data_velocity)

      ! Store appropriate time-dependent assembly routines.
      if (assembly_name == 'nsb') then
        call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_element',       jacobian_nsb, 1)
        call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_int_bdry_face', jacobian_face_nsb, 1)
        call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_element',         element_residual_nsb, 1)
        call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_int_bdry_face',   element_residual_face_nsb, 1)
      else
        call write_message(io_err, 'Error: not implemented for other assemblies other than nsb.')
        error stop
      end if

      ! Setup DIRK timestepping.
      call set_up_dirk_timestepping('solver_velocity', aptofem_stored_keys, dirk_scheme_velocity)

      ! Setup for this mesh.
      call set_up_newton_solver_parameters('solver_velocity', aptofem_stored_keys, scheme_data_velocity)
      call linear_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', aptofem_stored_keys, &
        sp_matrix_rhs_data_velocity, 1, scheme_data_velocity)
      call linear_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', aptofem_stored_keys, &
        sp_matrix_rhs_data_velocity, 2, scheme_data_velocity)

      ! Get DoFs.
      velocity_dofs = get_no_dofs(solution_velocity)

      ! Timestep and solve.
      do time_step_no = 1, no_time_steps
        call dirk_single_time_step(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', &
          aptofem_stored_keys, sp_matrix_rhs_data_velocity, scheme_data_velocity, dirk_scheme_velocity, &
          scheme_data_velocity%current_time, scheme_data_velocity%time_step, velocity_dofs, time_step_no, .false., &
          norm_diff_u)
      end do

      ! Norms and output.
      call error_norms_velocity(errors, mesh_data, solution_velocity)
      call write_data   ('output_data', aptofem_stored_keys, errors, 5, errors_name, errors_format, mesh_data, &
        solution_velocity)
      call write_fe_data('output_mesh_solution_velocity_2D', aptofem_stored_keys, mesh_no, mesh_data, solution_velocity)
      write(23111997, tsv_format) no_time_steps, mesh_no, velocity_dofs, errors(1), errors(2), errors(3), errors(4), errors(5)

      ! Clean up solver storage.
      call linear_fe_solver(solution_velocity,  mesh_data, fe_solver_routines_velocity,  'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity,  5, scheme_data_velocity)

      ! Refine the mesh uniformly.
      if (mesh_no < no_meshes) then
        call hp_mesh_adapt_uniform_refinement('uniform_refinement', aptofem_stored_keys, mesh_tree, mesh_data, &
          solution_velocity, mesh_data_orig, solution_velocity_orig, mesh_no)

        call delete_mesh(mesh_data_orig)
        call delete_solution(solution_velocity_orig)
      end if
    end do

    call delete_solution(solution_velocity)
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !! VELOCITY TIME-DEPENDENT SPATIAL CONVERGENCE !!
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  else if (trim(test_type) == 'velocity_time') then
    ! Setup velocity solution.
    call create_fe_solution(solution_velocity, mesh_data, 'fe_solution_velocity', aptofem_stored_keys, dirichlet_bc_velocity)

    ! Setup error outputting.
    errors_format  = '(g15.5)'
    errors_name(1) = '||u-u_h||_L_2'
    errors_name(2) = '||p-p_h||_L_2'
    errors_name(3) = '||u-u_h,p-p_h||_L_2'
    errors_name(4) = '||u-u_h,p-p_h||_DG'
    errors_name(5) = '||div(u-u_h)||_L_2'

    write(23111997, tsv_format) 'no_timesteps', 'mesh_no', 'dofs', 'L2_u', 'L2_p', 'L2_up', 'DG_up', 'L2_div_u'

    ! Loop over meshes.
    do mesh_no = 1, no_meshes
      ! Reset timestepping.
      solution_velocity%current_time    = 0.0_db
      scheme_data_velocity%current_time = 0.0_db
      scheme_data_velocity%time_step    = final_local_time/real(no_time_steps, db)
      call set_current_time(solution_velocity, 0.0_db)

      ! Store steady-state assembly for initial condition.
      if (assembly_name == 'nsb') then
        call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_element',       jacobian_nsb_ss, 1)
        call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_int_bdry_face', jacobian_face_nsb_ss, 1)
        call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_element',         element_residual_nsb_ss, 1)
        call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_int_bdry_face',   element_residual_face_nsb_ss,&
          1)
      else
        call write_message(io_err, 'Error: not implemented for other assemblies other than nsb.')
        error stop
      end if

      ! Setup and solve steady-state problem.
      call set_up_newton_solver_parameters('solver_velocity', aptofem_stored_keys, scheme_data_velocity)
      call linear_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', aptofem_stored_keys, &
        sp_matrix_rhs_data_velocity, 1, scheme_data_velocity)
      call linear_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', aptofem_stored_keys, &
        sp_matrix_rhs_data_velocity, 2, scheme_data_velocity)
      call newton_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', aptofem_stored_keys, &
        sp_matrix_rhs_data_velocity, scheme_data_velocity, ifail)
      call linear_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', aptofem_stored_keys, &
        sp_matrix_rhs_data_velocity,  5, scheme_data_velocity)

      ! Store appropriate time-dependent assembly routines.
      if (assembly_name == 'nsb') then
        call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_element',       jacobian_nsb, 1)
        call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_int_bdry_face', jacobian_face_nsb, 1)
        call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_element',         element_residual_nsb, 1)
        call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_int_bdry_face',   element_residual_face_nsb, 1)
      else
        call write_message(io_err, 'Error: not implemented for other assemblies other than nsb.')
        error stop
      end if

      ! Setup DIRK timestepping.
      call set_up_dirk_timestepping('solver_velocity', aptofem_stored_keys, dirk_scheme_velocity)

      ! Setup for this mesh.
      call set_up_newton_solver_parameters('solver_velocity', aptofem_stored_keys, scheme_data_velocity)
      call linear_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', aptofem_stored_keys, &
        sp_matrix_rhs_data_velocity, 1, scheme_data_velocity)
      call linear_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', aptofem_stored_keys, &
        sp_matrix_rhs_data_velocity, 2, scheme_data_velocity)

      ! Get DoFs.
      velocity_dofs = get_no_dofs(solution_velocity)

      ! Timestep and solve.
      do time_step_no = 1, no_time_steps
        call dirk_single_time_step(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', &
          aptofem_stored_keys, sp_matrix_rhs_data_velocity, scheme_data_velocity, dirk_scheme_velocity, &
          scheme_data_velocity%current_time, scheme_data_velocity%time_step, velocity_dofs, time_step_no, .false., &
          norm_diff_u)
      end do

      ! Norms and output.
      call error_norms_velocity(errors, mesh_data, solution_velocity)
      call write_data   ('output_data', aptofem_stored_keys, errors, 5, errors_name, errors_format, mesh_data, &
        solution_velocity)
      call write_fe_data('output_mesh_solution_velocity_2D', aptofem_stored_keys, mesh_no, mesh_data, solution_velocity)
      write(23111997, tsv_format) no_time_steps, mesh_no, velocity_dofs, errors(1), errors(2), errors(3), errors(4), errors(5)

      ! Clean up solver storage.
      call linear_fe_solver(solution_velocity,  mesh_data, fe_solver_routines_velocity,  'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity,  5, scheme_data_velocity)

      ! Refine the timestep.
      if (mesh_no < no_meshes) then
        no_time_steps = 2*no_time_steps
      end if
    end do

    call delete_solution(solution_velocity)
  else
    call write_message(io_err, 'Error: unknown test_type.')
    error stop
  end if

  !!!!!!!!!!!!!!
  !! CLEAN UP !!
  !!!!!!!!!!!!!!
  close(23111997)
  call delete_mesh(mesh_data)
  call finalise_user_data()
  call AptoFEM_finalize  (aptofem_stored_keys)
end program