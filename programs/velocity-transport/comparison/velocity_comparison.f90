program velocity_transport
    use aptofem_kernel
    use fe_solution_restart_io
    use problem_options
    use problem_options_velocity
    use problem_options_geometry
    use velocity_bc_interface
    
    use matrix_rhs_s_b_ss
    use jacobi_residual_ns_b_ss
    use jacobi_residual_ns_nsb_ss
    use jacobi_residual_nsb_ss
    
    implicit none
    
    type(aptofem_keys), pointer                 :: aptofem_stored_keys
    type(mesh)                                  :: mesh_data, mesh_data_orig
    type(solution), dimension(4)                :: solution_velocity
    type(solution)                              :: solution_difference
    type(fe_assembly_subroutines), dimension(4) :: fe_solver_routines_velocity
    
    type(refinement_tree)              :: mesh_tree
    integer, dimension(:), allocatable :: refinement_marks
    integer                            :: mesh_no, no_eles

    type array_sp_matrix_rhs
        class(sp_matrix_rhs), pointer :: p
    end type array_sp_matrix_rhs
    
    type(array_sp_matrix_rhs), dimension(4)       :: sp_matrix_rhs_data_velocity
    type(default_user_data), dimension(4)         :: scheme_data_velocity
    type(dirk_time_stepping_scheme), dimension(4) :: dirk_scheme_velocity
    
    real(db), dimension(5) :: norms
    
    logical :: ifail

    integer :: no_command_line_arguments

    character(len=100) :: flux_file
    character(len=100) :: aptofem_run_number_string
    character(len=100) :: tsvFormat

    integer :: i, j

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! COMMAND LINE ARGUMENTS !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!
    no_command_line_arguments = command_argument_count()
    if (no_command_line_arguments /= 1) then
        print *, "ERROR: Incorrect number of command line arguments."
        print *, "       Usage: ./velocity_comparison.out <placentone|placenta|placentone-3d>"
        error stop
    end if
    call get_command_argument(1, geometry_name)
    if (geometry_name /= 'placentone' .and. geometry_name /= 'placenta' .and. geometry_name /= 'placentone-3d') then
        call write_message(io_err, 'Error: geometry_name should be placentone or placenta or placentone-3d.')
        error stop
    end if
    
    !!!!!!!!!!!!!!!!!!!
    !! APTOFEM SETUP !!
    !!!!!!!!!!!!!!!!!!!
    call AptoFEM_initialize     (aptofem_stored_keys, 'aptofem_control_file.dat', './common/')
    call setup_velocity_bcs     (geometry_name)
    call create_mesh            (mesh_data, get_boundary_no_velocity, 'mesh_gen', aptofem_stored_keys)
    call get_user_data          ('user_data', aptofem_stored_keys)
    call get_user_data_velocity ('user_data', aptofem_stored_keys)
    call set_space_type_velocity(aptofem_stored_keys)
    call initialise_geometry    (geometry_name, no_placentones)
    
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! VELOCITY PROBLEM SETUPS !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    call create_fe_solution(solution_velocity(1), mesh_data, 'fe_solution_velocity', aptofem_stored_keys, &
        dirichlet_bc_velocity)
    call create_fe_solution(solution_velocity(2), mesh_data, 'fe_solution_velocity', aptofem_stored_keys, &
        dirichlet_bc_velocity)
    call create_fe_solution(solution_velocity(3), mesh_data, 'fe_solution_velocity', aptofem_stored_keys, &
        dirichlet_bc_velocity)
    call create_fe_solution(solution_velocity(4), mesh_data, 'fe_solution_velocity', aptofem_stored_keys, &
        dirichlet_bc_velocity)
    
    call set_up_newton_solver_parameters('solver_velocity', aptofem_stored_keys, scheme_data_velocity(2))
    call set_up_newton_solver_parameters('solver_velocity', aptofem_stored_keys, scheme_data_velocity(3))
    call set_up_newton_solver_parameters('solver_velocity', aptofem_stored_keys, scheme_data_velocity(4))
    
    call linear_fe_solver(solution_velocity(1), mesh_data, fe_solver_routines_velocity(1), 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity(1)%p, 1, scheme_data_velocity(1))
    call linear_fe_solver(solution_velocity(2), mesh_data, fe_solver_routines_velocity(2), 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity(2)%p, 1, scheme_data_velocity(2))
    call linear_fe_solver(solution_velocity(3), mesh_data, fe_solver_routines_velocity(3), 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity(3)%p, 1, scheme_data_velocity(3))
    call linear_fe_solver(solution_velocity(4), mesh_data, fe_solver_routines_velocity(4), 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity(4)%p, 1, scheme_data_velocity(4))
    
    call linear_fe_solver(solution_velocity(1), mesh_data, fe_solver_routines_velocity(1), 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity(1)%p, 2, scheme_data_velocity(1))
    call linear_fe_solver(solution_velocity(2), mesh_data, fe_solver_routines_velocity(2), 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity(2)%p, 2, scheme_data_velocity(2))
    call linear_fe_solver(solution_velocity(3), mesh_data, fe_solver_routines_velocity(3), 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity(3)%p, 2, scheme_data_velocity(3))
    call linear_fe_solver(solution_velocity(4), mesh_data, fe_solver_routines_velocity(4), 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity(4)%p, 2, scheme_data_velocity(4))
    
    solution_velocity(1)%current_time = 0.0_db
    solution_velocity(2)%current_time = 0.0_db
    solution_velocity(3)%current_time = 0.0_db
    solution_velocity(4)%current_time = 0.0_db

    scheme_data_velocity(1)%current_time = 0.0_db
    scheme_data_velocity(2)%current_time = 0.0_db
    scheme_data_velocity(3)%current_time = 0.0_db
    scheme_data_velocity(4)%current_time = 0.0_db

    scheme_data_velocity(1)%time_step = 0.1_db
    scheme_data_velocity(2)%time_step = 0.1_db
    scheme_data_velocity(3)%time_step = 0.1_db
    scheme_data_velocity(4)%time_step = 0.1_db
    
    call set_current_time(solution_velocity(1), 0.0_db)
    call set_current_time(solution_velocity(2), 0.0_db)
    call set_current_time(solution_velocity(3), 0.0_db)
    call set_current_time(solution_velocity(4), 0.0_db)

    call store_subroutine_names(fe_solver_routines_velocity(1), 'assemble_matrix_rhs_element', &
        stiffness_matrix_load_vector_s_b_ss, 1)
    call store_subroutine_names(fe_solver_routines_velocity(1), 'assemble_matrix_rhs_face',    &
        stiffness_matrix_load_vector_face_s_b_ss, 1)

    call store_subroutine_names(fe_solver_routines_velocity(2), 'assemble_jac_matrix_element', &
        jacobian_ns_b_ss, 1)
    call store_subroutine_names(fe_solver_routines_velocity(2), 'assemble_jac_matrix_int_bdry_face', &
        jacobian_face_ns_b_ss, 1)
    call store_subroutine_names(fe_solver_routines_velocity(2), 'assemble_residual_element', &
        element_residual_ns_b_ss, 1)
    call store_subroutine_names(fe_solver_routines_velocity(2), 'assemble_residual_int_bdry_face', &
        element_residual_face_ns_b_ss, 1)

    call store_subroutine_names(fe_solver_routines_velocity(3), 'assemble_jac_matrix_element', &
        jacobian_ns_nsb_ss, 1)
    call store_subroutine_names(fe_solver_routines_velocity(3), 'assemble_jac_matrix_int_bdry_face', &
        jacobian_face_ns_nsb_ss, 1)
    call store_subroutine_names(fe_solver_routines_velocity(3), 'assemble_residual_element', &
        element_residual_ns_nsb_ss, 1)
    call store_subroutine_names(fe_solver_routines_velocity(3), 'assemble_residual_int_bdry_face', &
        element_residual_face_ns_nsb_ss, 1)
    
    call store_subroutine_names(fe_solver_routines_velocity(4), 'assemble_jac_matrix_element', &
        jacobian_nsb_ss, 1)
    call store_subroutine_names(fe_solver_routines_velocity(4), 'assemble_jac_matrix_int_bdry_face', &
        jacobian_face_nsb_ss, 1)
    call store_subroutine_names(fe_solver_routines_velocity(4), 'assemble_residual_element', &
        element_residual_nsb_ss, 1)
    call store_subroutine_names(fe_solver_routines_velocity(4), 'assemble_residual_int_bdry_face', &
        element_residual_face_nsb_ss, 1)
    
    !!!!!!!!!!!!!!!!!!!!!
    !! VELOCITY SOLVES !!
    !!!!!!!!!!!!!!!!!!!!!
    call linear_fe_solver(solution_velocity(1), mesh_data, fe_solver_routines_velocity(1), 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity(1)%p, 3, scheme_data_velocity(1))
    call linear_fe_solver(solution_velocity(1), mesh_data, fe_solver_routines_velocity(1), 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity(1)%p, 4, scheme_data_velocity(1))
    call newton_fe_solver(solution_velocity(2), mesh_data, fe_solver_routines_velocity(2), 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity(2)%p, scheme_data_velocity(2), ifail)
    call newton_fe_solver(solution_velocity(3), mesh_data, fe_solver_routines_velocity(3), 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity(3)%p, scheme_data_velocity(3), ifail)
    call newton_fe_solver(solution_velocity(4), mesh_data, fe_solver_routines_velocity(4), 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity(4)%p, scheme_data_velocity(4), ifail)        
    
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! SAVE VELOCITY AND RAW SOLUTION !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    call write_fe_data('output_mesh_solution_velocity_2D', aptofem_stored_keys, 1, mesh_data, solution_velocity(1))
    call write_solution_for_restart(solution_velocity(1), mesh_data, 1, 'dg_velocity-transport_velocity_' &
        // trim(geometry_name), '../../output/')
    call write_fe_data('output_mesh_solution_velocity_2D', aptofem_stored_keys, 2, mesh_data, solution_velocity(2))
    call write_solution_for_restart(solution_velocity(2), mesh_data, 2, 'dg_velocity-transport_velocity_' &
        // trim(geometry_name), '../../output/')
    call write_fe_data('output_mesh_solution_velocity_2D', aptofem_stored_keys, 3, mesh_data, solution_velocity(3))
    call write_solution_for_restart(solution_velocity(3), mesh_data, 3, 'dg_velocity-transport_velocity_' &
        // trim(geometry_name), '../../output/')
    call write_fe_data('output_mesh_solution_velocity_2D', aptofem_stored_keys, 4, mesh_data, solution_velocity(4))
    call write_solution_for_restart(solution_velocity(4), mesh_data, 4, 'dg_velocity-transport_velocity_' &
        // trim(geometry_name), '../../output/')

    !!!!!!!!!!!!!!!!!!!!!!
    !! OPEN OUTPUT FILE !!
    !!!!!!!!!!!!!!!!!!!!!!
    write(aptofem_run_number_string, '(i10)') aptofem_run_number
    flux_file = '../../output/norms' // '_' // 'velocity' // '_' // trim(geometry_name) // '_' // &
        trim(adjustl(aptofem_run_number_string)) // '.dat'
    open(23111997, file=flux_file, status='replace')
    tsvFormat = '(*(G0.6,:,"'//achar(9)//'"))'
    write(23111997, tsvFormat) 'solution_1', 'solution_2', 'u_L2', 'p_L2', 'up_L2', 'DG', 'div_L2'

    !!!!!!!!!!!!!!!!!!!!!
    !! CALCULATE NORMS !!
    !!!!!!!!!!!!!!!!!!!!!
    call create_fe_solution(solution_difference, mesh_data, 'fe_solution_velocity', aptofem_stored_keys, &
        dirichlet_bc_velocity) ! Just picking one for Dirichlet BCs.
    do i = 1, 4
        do j = i, 4
            solution_difference%soln_values = solution_velocity(i)%soln_values - solution_velocity(j)%soln_values

            norms = 0.0_db
            call error_norms(norms, mesh_data, solution_difference, solution_velocity(1))
            write(23111997, tsvFormat) i, j, norms(1), norms(2), norms(3), norms(4), norms(5)

            call write_fe_data('output_mesh_solution_velocity_2D', aptofem_stored_keys, i*10 + j, mesh_data, solution_difference)
        end do
    end do
    call delete_solution(solution_difference)
    
    !!!!!!!!!!!!!!
    !! CLEAN UP !!
    !!!!!!!!!!!!!!
    close(23111997)
    
    call linear_fe_solver(solution_velocity(1), mesh_data, fe_solver_routines_velocity(1), 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity(1)%p, 5, scheme_data_velocity(1))
    call linear_fe_solver(solution_velocity(2), mesh_data, fe_solver_routines_velocity(2), 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity(2)%p, 5, scheme_data_velocity(2))
    call linear_fe_solver(solution_velocity(3), mesh_data, fe_solver_routines_velocity(3), 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity(3)%p, 5, scheme_data_velocity(3))
    call linear_fe_solver(solution_velocity(4), mesh_data, fe_solver_routines_velocity(4), 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_velocity(4)%p, 5, scheme_data_velocity(4))
    
    call delete_solution (solution_velocity(1))
    call delete_solution (solution_velocity(2))
    call delete_solution (solution_velocity(3))
    call delete_solution (solution_velocity(4))
    call delete_mesh     (mesh_data)
    call AptoFEM_finalize(aptofem_stored_keys)
end program

!------------------------------------------------------------------
! PURPOSE:
!   Compute norms. Includes "hack" to get penalisation parameter.
!
!   errors(1) = || u_h ||_L_2
!   errors(2) = || p_h ||_L_2
!   errors(3) = || u_h,p_h ||_L_2
!   errors(4) = || u_h,p_h ||_DG
!   errors(5) = || div(u_h) ||_L_2
!
! AUTHOR:
!   P.Houston, A.Blakey
!--------------------------------------------------------------------

subroutine error_norms(errors, mesh_data, soln_data, soln_for_dg_penalisation)

    use param
    use fe_mesh
    use fe_solution
    use basis_fns_storage_type
    use aptofem_fe_matrix_assembly
    use problem_options

    implicit none

    real(db), dimension(5), intent(out) :: errors
    type(mesh), intent(inout) :: mesh_data
    type(solution), intent(inout) :: soln_data,soln_for_dg_penalisation

    ! Local variables

    type(basis_storage) :: fe_basis_info
    character(len=aptofem_length_key_def) :: control_parameter
    integer :: no_eles,no_nodes,no_faces,problem_dim,no_pdes, &
    i,j,k,qk,iv,no_quad_points,npinc, &
    no_quad_points_volume_max,no_quad_points_face_max, &
    bdry_face,dim_soln_coeff,iv2
    real(db), dimension(:,:), allocatable :: global_points_ele
    real(db), dimension(:), allocatable :: quad_weights_ele,jacobian
    real(db), dimension(:,:), allocatable :: gradient_u,gradient_uh
    real(db), dimension(:), allocatable :: u,uh,uh1,uh2
    real(db) :: full_dispenal,div_uh,grad_e
    real(db), dimension(:), allocatable :: quad_weights_face,face_jacobian, &
    dispenal
    real(db), dimension(:,:), allocatable :: global_points_face,face_normals
    integer, dimension(:,:), allocatable :: global_dof_numbers1,global_dof_numbers2, &
    global_dof_numbers
    integer, dimension(2) :: neighbors,loc_face_no
    integer, dimension(:), allocatable :: no_dofs_per_variable1, &
    no_dofs_per_variable2,no_dofs_per_variable

    dim_soln_coeff = get_dim_soln_coeff(soln_data)
    no_pdes = get_no_pdes(soln_data)

    call get_mesh_info(no_eles,no_nodes,no_faces,problem_dim, &
    mesh_data)

    npinc = 4
    call compute_max_no_quad_points(no_quad_points_volume_max, &
    no_quad_points_face_max,mesh_data,soln_data,npinc)

    control_parameter = 'fo_deriv_uh_ele'
    call initialize_fe_basis_storage(fe_basis_info,control_parameter,soln_data, &
    problem_dim,no_quad_points_volume_max,no_quad_points_face_max)

    allocate(gradient_u(no_pdes,problem_dim))
    allocate(gradient_uh(no_pdes,problem_dim))
    allocate(u(no_pdes))
    allocate(uh(no_pdes))
    allocate(no_dofs_per_variable(dim_soln_coeff))
    allocate(global_points_ele(problem_dim,no_quad_points_volume_max))
    allocate(jacobian(no_quad_points_volume_max))
    allocate(quad_weights_ele(no_quad_points_volume_max))
    allocate(global_dof_numbers(dim_soln_coeff,no_ele_dofs_per_var_max))

    do k = 1,no_eles

      call element_integration_info(dim_soln_coeff,problem_dim,mesh_data, &
      soln_data,k,npinc,no_quad_points_volume_max, &
      no_quad_points,global_points_ele,jacobian,quad_weights_ele, &
      global_dof_numbers,no_dofs_per_variable,fe_basis_info)

      do qk = 1,no_quad_points

        ! Determine analytical solution

        uh = uh_element(fe_basis_info,no_pdes,qk)

        errors(1) = errors(1) + jacobian(qk)*quad_weights_ele(qk) &
        *dot_product(uh(1:problem_dim), uh(1:problem_dim))

        errors(2) = errors(2) + jacobian(qk)*quad_weights_ele(qk) &
        *(uh(problem_dim+1))**2

        errors(3) = errors(3) + jacobian(qk)*quad_weights_ele(qk) &
        *dot_product(uh(1:problem_dim+1), uh(1:problem_dim+1))

        do iv = 1,problem_dim
          gradient_uh(iv,:) = grad_uh_element(fe_basis_info,problem_dim,iv,qk,1)
        end do

        div_uh = 0.0_db
        grad_e = 0.0_db
        do iv = 1,problem_dim
          div_uh = div_uh+gradient_uh(iv,iv)
          do iv2 = 1,problem_dim
            grad_e = grad_e+(gradient_uh(iv,iv2))**2
          end do
        end do

        errors(4) = errors(4) + jacobian(qk)*quad_weights_ele(qk) &
        *(grad_e+(uh(problem_dim+1))**2)

        errors(5) = errors(5) + jacobian(qk)*quad_weights_ele(qk)*div_uh**2


      end do

    end do

    call delete_fe_basis_storage(fe_basis_info)

    deallocate(gradient_u,gradient_uh,u,uh,no_dofs_per_variable, &
    global_points_ele,jacobian,quad_weights_ele,global_dof_numbers)

    control_parameter = 'uh_face'
    call initialize_fe_basis_storage(fe_basis_info,control_parameter,soln_data, &
    problem_dim,no_quad_points_volume_max,no_quad_points_face_max)

    allocate(global_points_face(problem_dim,no_quad_points_face_max))
    allocate(face_jacobian(no_quad_points_face_max))
    allocate(face_normals(problem_dim,no_quad_points_face_max))
    allocate(quad_weights_face(no_quad_points_face_max))
    allocate(no_dofs_per_variable1(dim_soln_coeff))
    allocate(no_dofs_per_variable2(dim_soln_coeff))
    allocate(dispenal(dim_soln_coeff))
    allocate(global_dof_numbers1(dim_soln_coeff,no_ele_dofs_per_var_max))
    allocate(global_dof_numbers2(dim_soln_coeff,no_ele_dofs_per_var_max))
    allocate(uh1(no_pdes))
    allocate(uh2(no_pdes))
    allocate(u(no_pdes))

    do k = 1,no_faces

      call face_integration_info(dim_soln_coeff,problem_dim,mesh_data,soln_data, &
      k,neighbors,loc_face_no,npinc,no_quad_points_face_max, &
      no_quad_points,global_points_face,face_jacobian,face_normals, &
      quad_weights_face,global_dof_numbers1,no_dofs_per_variable1, &
      bdry_face,global_dof_numbers2,no_dofs_per_variable2, &
      fe_basis_info)

      call aptofem_dg_penalisation(dispenal,k,neighbors, &
      mesh_data,soln_for_dg_penalisation,problem_dim,dim_soln_coeff)

      full_dispenal = interior_penalty_parameter*dispenal(1)

      if (bdry_face > 0) then

        ! Boundary face

        do qk = 1,no_quad_points
          uh1 = uh_face1(fe_basis_info,no_pdes,qk)
          errors(4) = errors(4)+full_dispenal*face_jacobian(qk)*quad_weights_face(qk) &
          *dot_product(uh1(1:problem_dim), uh1(1:problem_dim))
        end do

      else

        ! Interior face

        do qk = 1,no_quad_points
          uh1 = uh_face1(fe_basis_info,no_pdes,qk)
          uh2 = uh_face2(fe_basis_info,no_pdes,qk)
          errors(4) = errors(4)+full_dispenal*face_jacobian(qk)*quad_weights_face(qk) &
          *dot_product(uh2(1:problem_dim)-uh1(1:problem_dim), &
          uh2(1:problem_dim)-uh1(1:problem_dim))
        end do

      end if

    end do

    deallocate(global_points_face,face_jacobian,face_normals,quad_weights_face, &
    no_dofs_per_variable1,no_dofs_per_variable2,dispenal, &
    global_dof_numbers1,global_dof_numbers2,u,uh1,uh2)

    call delete_fe_basis_storage(fe_basis_info)

    errors = sqrt(errors)

  end subroutine