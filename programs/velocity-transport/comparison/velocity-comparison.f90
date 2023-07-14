program velocity_transport
    use aptofem_kernel
    use fe_solution_restart_io
    use problem_options
    use problem_options_velocity
    use refine_region
    use bcs_velocity
    use solution_storage_velocity
    use crossflow_flux
    use outflow_flux
    use outflow_transport_flux
    use program_name_module
    use assembly_name_module
    
    use matrix_rhs_s_b_ss
    use jacobi_residual_ns_b_ss
    use jacobi_residual_ns_nsb_ss
    use jacobi_residual_nsb_ss
    
    implicit none
    
    type(aptofem_keys), pointer   :: aptofem_stored_keys
    type(mesh)                    :: mesh_data, mesh_data_orig
    type(solution)                :: solution_s_b, solution_ns_b, solution_ns_nsb, solution_nsb
    type(fe_assembly_subroutines) :: fe_solver_routines_s_b, fe_solver_routines_ns_b, fe_solver_routines_ns_nsb, &
    fe_solver_routines_nsb
    
    type(refinement_tree)              :: mesh_tree
    integer, dimension(:), allocatable :: refinement_marks
    integer                            :: mesh_no, no_eles
    
    class(sp_matrix_rhs), pointer   :: sp_matrix_rhs_data_s_b, sp_matrix_rhs_data_ns_b, sp_matrix_rhs_data_ns_nsb, &
    sp_matrix_rhs_data_nsb
    type(default_user_data)         :: scheme_data_s_b, scheme_data_ns_b, scheme_data_ns_nsb, scheme_data_nsb
    type(dirk_time_stepping_scheme) :: dirk_scheme_s_b, dirk_scheme_ns_b, dirk_scheme_ns_nsb, dirk_scheme_nsb
    
    !   character(15), dimension(1) :: errors_format, errors_name
    !   real(db), dimension(1)      :: errors
    !   integer                     :: no_errors_velocity, no_errors_transport
    
    logical :: ifail
    
    character(len=20) :: control_file

    integer :: i, j
    
    !!!!!!!!!!!!!!!!!!!!!!
    !! SET CONTROL FILE !!
    !!!!!!!!!!!!!!!!!!!!!!
    call program_name(control_file, .true.)
    if (control_file /= 'placentone' .and. control_file /= 'placenta' .and. control_file /= 'placentone-3d') then
        call write_message(io_err, 'Error: program_name should be placentone or placenta or placentone-3d.')
        stop
    end if
    
    !!!!!!!!!!!!!!!!!!!
    !! APTOFEM SETUP !!
    !!!!!!!!!!!!!!!!!!!
    call AptoFEM_initialize     (aptofem_stored_keys, 'acf_' // trim(control_file) // '.dat', './common/')
    call create_mesh            (mesh_data, get_boundary_no_velocity, 'mesh_gen', aptofem_stored_keys)
    call get_user_data          ('user_data', aptofem_stored_keys)
    call get_user_data_velocity ('user_data', aptofem_stored_keys)
    call set_space_type_velocity(aptofem_stored_keys)
    
    !!!!!!!!!!!!!!!!!
    !! REFINE MESH !!
    !!!!!!!!!!!!!!!!!
    do mesh_no = 1, no_uniform_refinements_everywhere
        no_eles = mesh_data%no_eles
        allocate(refinement_marks(no_eles))
        
        call write_message(io_msg, '========================================================')
        call write_message(io_msg, '  Refinement step ')
        call refine_region_indicator(refinement_marks, no_eles, mesh_data, 300, 599)
        
        call h_mesh_adaptation('uniform_refinement', aptofem_stored_keys, mesh_tree, mesh_data, mesh_data_orig, &
        mesh_no, no_eles, refinement_marks)
        call write_message(io_msg, '========================================================')
        
        deallocate(refinement_marks)
        
        call delete_mesh(mesh_data_orig)
    end do
    
    do mesh_no = 1, no_uniform_refinements_cavity
        no_eles = mesh_data%no_eles
        allocate(refinement_marks(no_eles))
        
        call write_message(io_msg, '========================================================')
        call write_message(io_msg, '  Refinement step ')
        call refine_region_indicator(refinement_marks, no_eles, mesh_data, 500, 599)
        
        call h_mesh_adaptation('uniform_refinement', aptofem_stored_keys, mesh_tree, mesh_data, mesh_data_orig, &
        mesh_no + no_uniform_refinements_everywhere, no_eles, refinement_marks)
        call write_message(io_msg, '========================================================')
        
        deallocate(refinement_marks)
        
        call delete_mesh(mesh_data_orig)
    end do
    
    do mesh_no = 1, no_uniform_refinements_inlet
        no_eles = mesh_data%no_eles
        allocate(refinement_marks(no_eles))
        
        call write_message(io_msg, '========================================================')
        call write_message(io_msg, '  Refinement step ')
        call refine_region_indicator(refinement_marks, no_eles, mesh_data, 400, 499)
        
        call h_mesh_adaptation('uniform_refinement', aptofem_stored_keys, mesh_tree, mesh_data, mesh_data_orig, &
        mesh_no + no_uniform_refinements_everywhere + no_uniform_refinements_cavity, no_eles, refinement_marks)
        call write_message(io_msg, '========================================================')
        
        deallocate(refinement_marks)
        
        call delete_mesh(mesh_data_orig)
    end do
    
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! VELOCITY PROBLEM SETUPS !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    call create_fe_solution(solution_s_b,    mesh_data, 'fe_solution_velocity', aptofem_stored_keys, &
        dirichlet_bc_velocity)
    call create_fe_solution(solution_ns_b,   mesh_data, 'fe_solution_velocity', aptofem_stored_keys, &
        dirichlet_bc_velocity)
    call create_fe_solution(solution_ns_nsb, mesh_data, 'fe_solution_velocity', aptofem_stored_keys, &
        dirichlet_bc_velocity)
    call create_fe_solution(solution_nsb,    mesh_data, 'fe_solution_velocity', aptofem_stored_keys, &
        dirichlet_bc_velocity)
    
    call set_up_newton_solver_parameters('solver_velocity', aptofem_stored_keys, scheme_data_ns_b)
    call set_up_newton_solver_parameters('solver_velocity', aptofem_stored_keys, scheme_data_ns_nsb)
    call set_up_newton_solver_parameters('solver_velocity', aptofem_stored_keys, scheme_data_nsb)
    
    call linear_fe_solver(solution_s_b, mesh_data, fe_solver_routines_s_b, 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_s_b, 1, scheme_data_s_b)
    call linear_fe_solver(solution_ns_b, mesh_data, fe_solver_routines_ns_b, 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_ns_b, 1, scheme_data_ns_b)
    call linear_fe_solver(solution_ns_nsb, mesh_data, fe_solver_routines_ns_nsb, 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_ns_nsb, 1, scheme_data_ns_nsb)
    call linear_fe_solver(solution_nsb, mesh_data, fe_solver_routines_nsb, 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_nsb, 1, scheme_data_nsb)
    
    call linear_fe_solver(solution_s_b, mesh_data, fe_solver_routines_s_b, 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_s_b, 2, scheme_data_s_b)
    call linear_fe_solver(solution_ns_b, mesh_data, fe_solver_routines_ns_b, 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_ns_b, 2, scheme_data_ns_b)
    call linear_fe_solver(solution_ns_nsb, mesh_data, fe_solver_routines_ns_nsb, 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_ns_nsb, 2, scheme_data_ns_nsb)
    call linear_fe_solver(solution_nsb, mesh_data, fe_solver_routines_nsb, 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_nsb, 2, scheme_data_nsb)
    
    solution_s_b%current_time    = 0.0_db
    solution_ns_b%current_time   = 0.0_db
    solution_ns_nsb%current_time = 0.0_db
    solution_nsb%current_time    = 0.0_db

    scheme_data_s_b%current_time    = 0.0_db
    scheme_data_ns_b%current_time   = 0.0_db
    scheme_data_ns_nsb%current_time = 0.0_db
    scheme_data_nsb%current_time    = 0.0_db

    scheme_data_s_b%time_step    = 0.1_db
    scheme_data_ns_b%time_step   = 0.1_db
    scheme_data_ns_nsb%time_step = 0.1_db
    scheme_data_nsb%time_step    = 0.1_db
    
    call set_current_time(solution_s_b, 0.0_db)
    call set_current_time(solution_ns_b, 0.0_db)
    call set_current_time(solution_ns_nsb, 0.0_db)
    call set_current_time(solution_nsb, 0.0_db)

    call store_subroutine_names(fe_solver_routines_s_b, 'assemble_matrix_rhs_element', &
        stiffness_matrix_load_vector_s_b_ss, 1)
    call store_subroutine_names(fe_solver_routines_s_b, 'assemble_matrix_rhs_face',    &
        stiffness_matrix_load_vector_face_s_b_ss, 1)

    call store_subroutine_names(fe_solver_routines_ns_b, 'assemble_jac_matrix_element', &
        jacobian_ns_b_ss, 1)
    call store_subroutine_names(fe_solver_routines_ns_b, 'assemble_jac_matrix_int_bdry_face', &
        jacobian_face_ns_b_ss, 1)
    call store_subroutine_names(fe_solver_routines_ns_b, 'assemble_residual_element', &
        element_residual_ns_b_ss, 1)
    call store_subroutine_names(fe_solver_routines_ns_b, 'assemble_residual_int_bdry_face', &
        element_residual_face_ns_b_ss, 1)

    call store_subroutine_names(fe_solver_routines_ns_nsb, 'assemble_jac_matrix_element', &
        jacobian_ns_nsb_ss, 1)
    call store_subroutine_names(fe_solver_routines_ns_nsb, 'assemble_jac_matrix_int_bdry_face', &
        jacobian_face_ns_nsb_ss, 1)
    call store_subroutine_names(fe_solver_routines_ns_nsb, 'assemble_residual_element', &
        element_residual_ns_nsb_ss, 1)
    call store_subroutine_names(fe_solver_routines_ns_nsb, 'assemble_residual_int_bdry_face', &
        element_residual_face_ns_nsb_ss, 1)
    
    call store_subroutine_names(fe_solver_routines_nsb, 'assemble_jac_matrix_element', &
        jacobian_nsb_ss, 1)
    call store_subroutine_names(fe_solver_routines_nsb, 'assemble_jac_matrix_int_bdry_face', &
        jacobian_face_nsb_ss, 1)
    call store_subroutine_names(fe_solver_routines_nsb, 'assemble_residual_element', &
        element_residual_nsb_ss, 1)
    call store_subroutine_names(fe_solver_routines_nsb, 'assemble_residual_int_bdry_face', &
        element_residual_face_nsb_ss, 1)
    
    !!!!!!!!!!!!!!!!!!!!!
    !! VELOCITY SOLVES !!
    !!!!!!!!!!!!!!!!!!!!!
    call linear_fe_solver(solution_s_b, mesh_data, fe_solver_routines_s_b, 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_s_b, 3, scheme_data_s_b)
    call linear_fe_solver(solution_s_b, mesh_data, fe_solver_routines_s_b, 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_s_b, 4, scheme_data_s_b)

    call newton_fe_solver(solution_ns_b, mesh_data, fe_solver_routines_ns_b, 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_ns_b, scheme_data_ns_b, ifail)
    call newton_fe_solver(solution_ns_nsb, mesh_data, fe_solver_routines_ns_nsb, 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_ns_nsb, scheme_data_ns_nsb, ifail)
    call newton_fe_solver(solution_nsb, mesh_data, fe_solver_routines_nsb, 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_nsb, scheme_data_nsb, ifail)        
    
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! SAVE VELOCITY INITIAL CONDITION AND RAW SOLUTION !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    call write_fe_data('output_mesh_solution_velocity_2D', aptofem_stored_keys, 0, mesh_data, solution_s_b)
    call write_solution_for_restart(solution_s_b, mesh_data, 0, 'dg_velocity-transport_velocity_' &
        // trim(control_file), '../../output/')
    call write_fe_data('output_mesh_solution_velocity_2D', aptofem_stored_keys, 1, mesh_data, solution_ns_b)
    call write_solution_for_restart(solution_ns_b, mesh_data, 1, 'dg_velocity-transport_velocity_' &
        // trim(control_file), '../../output/')
    call write_fe_data('output_mesh_solution_velocity_2D', aptofem_stored_keys, 2, mesh_data, solution_ns_nsb)
    call write_solution_for_restart(solution_ns_nsb, mesh_data, 2, 'dg_velocity-transport_velocity_' &
        // trim(control_file), '../../output/')
    call write_fe_data('output_mesh_solution_velocity_2D', aptofem_stored_keys, 3, mesh_data, solution_ns_nsb)
    call write_solution_for_restart(solution_ns_nsb, mesh_data, 3, 'dg_velocity-transport_velocity_' &
        // trim(control_file), '../../output/')

    !!!!!!!!!!!!!!!!!!!!!
    !! CALCULATE NORMS !!
    !!!!!!!!!!!!!!!!!!!!!
    do i = 1, 4
        do j = 1, 4

        end do
    end do
    
    !!!!!!!!!!!!!!
    !! CLEAN UP !!
    !!!!!!!!!!!!!!
    close(23111997)
    
    call linear_fe_solver(solution_s_b, mesh_data, fe_solver_routines_s_b, 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_s_b, 5, scheme_data_s_b)
    call linear_fe_solver(solution_ns_b, mesh_data, fe_solver_routines_ns_b, 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_ns_b, 5, scheme_data_ns_b)
    call linear_fe_solver(solution_ns_nsb, mesh_data, fe_solver_routines_ns_nsb, 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_ns_nsb, 5, scheme_data_ns_nsb)
    call linear_fe_solver(solution_nsb, mesh_data, fe_solver_routines_nsb, 'solver_velocity', &
        aptofem_stored_keys, sp_matrix_rhs_data_nsb, 5, scheme_data_nsb)
    
    call delete_solution (solution_s_b)
    call delete_solution (solution_ns_b)
    call delete_solution (solution_ns_nsb)
    call delete_solution (solution_nsb)
    call delete_mesh     (mesh_data)
    call AptoFEM_finalize(aptofem_stored_keys)
end program

!------------------------------------------------------------------
! PURPOSE:
!   Compute errors
!
!   errors(1) = || u-u_h ||_L_2
!   errors(2) = || p-p_h ||_L_2
!   errors(3) = || u-u_h,p-p_h ||_L_2
!   errors(4) = || u-u_h,p-p_h ||_DG
!   errors(5) = || div(u-u_h) ||_L_2
!
! AUTHOR:
!   P.Houston
!--------------------------------------------------------------------

subroutine error_norms_navier_stokes_brinkman(errors,mesh_data,soln_data,soln_for_dg_penalisation)

    use param
    use fe_mesh
    use fe_solution
    use basis_fns_storage_type
    use aptofem_fe_matrix_assembly
    use problem_options
    use bcs_navier_stokes_brinkman

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

        call anal_soln_navier_stokes_brinkman(u,global_points_ele(:,qk),problem_dim,no_pdes,0,0.0_db,-1)
        call anal_soln_navier_stokes_brinkman_1(gradient_u,global_points_ele(:,qk),problem_dim,no_pdes,0.0_db,-1)
        uh = uh_element(fe_basis_info,no_pdes,qk)

        errors(1) = errors(1) + jacobian(qk)*quad_weights_ele(qk) &
        *dot_product(u(1:problem_dim)-uh(1:problem_dim), &
        u(1:problem_dim)-uh(1:problem_dim))

        errors(2) = errors(2) + jacobian(qk)*quad_weights_ele(qk) &
        *(u(problem_dim+1)-uh(problem_dim+1))**2

        errors(3) = errors(3) + jacobian(qk)*quad_weights_ele(qk) &
        *dot_product(u(1:problem_dim+1)-uh(1:problem_dim+1), &
        u(1:problem_dim+1)-uh(1:problem_dim+1))

        do iv = 1,problem_dim
          gradient_uh(iv,:) = grad_uh_element(fe_basis_info,problem_dim,iv,qk,1)
        end do

        div_uh = 0.0_db
        grad_e = 0.0_db
        do iv = 1,problem_dim
          div_uh = div_uh+gradient_uh(iv,iv)
          do iv2 = 1,problem_dim
            grad_e = grad_e+(gradient_u(iv,iv2)-gradient_uh(iv,iv2))**2
          end do
        end do

        errors(4) = errors(4) + jacobian(qk)*quad_weights_ele(qk) &
        *(grad_e+(u(problem_dim+1)-uh(problem_dim+1))**2)

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
          call anal_soln_navier_stokes_brinkman(u,global_points_face(:,qk),problem_dim,no_pdes,0,0.0_db,-1)
          errors(4) = errors(4)+full_dispenal*face_jacobian(qk)*quad_weights_face(qk) &
          *dot_product(u(1:problem_dim)-uh1(1:problem_dim), &
          u(1:problem_dim)-uh1(1:problem_dim))
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