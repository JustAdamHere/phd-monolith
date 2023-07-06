program adam_nsku_transport
    use aptofem_kernel
    use fe_solution_restart_io
    use problem_options
    use problem_options_nsku
    use problem_options_transport
    use matrix_rhs_transport
    use matrix_rhs_transport_ss
    use jacobi_residual_nsku
    use jacobi_residual_nsku_ss
    use refine_region
    use bcs_nsku
    use bcs_transport
    use solution_storage_nsku
    use crossflow_flux
    use outflow_flux
    use outflow_transport_flux
    use program_name_module
    use integrate_transport_reaction

    implicit none

    type(aptofem_keys), pointer   :: aptofem_stored_keys
    type(mesh)                    :: mesh_data, mesh_data_orig
    type(solution)                :: solution_transport, solution_permeability, solution_uptake
    type(fe_assembly_subroutines) :: fe_solver_routines_nsku, fe_solver_routines_transport!, fe_solver_routines_uptake

    type(refinement_tree)              :: mesh_tree
    integer, dimension(:), allocatable :: refinement_marks
    integer                            :: mesh_no, no_eles

    class(sp_matrix_rhs), pointer   :: sp_matrix_rhs_data_nsku, sp_matrix_rhs_data_transport!, sp_matrix_rhs_data_uptake
    type(default_user_data)         :: scheme_data_nsku, scheme_data_transport!, scheme_data_uptake
    type(dirk_time_stepping_scheme) :: dirk_scheme_nsku
    real(db)                        :: norm_diff_u

    character(15), dimension(1) :: errors_format, errors_name
    real(db), dimension(1)      :: errors
    integer                     :: no_errors_nsku, no_errors_transport

    logical :: ifail

    integer :: time_step_no
    integer :: no_dofs_nsku, no_dofs_transport

    logical, dimension(20) :: mesh_smoother

    character(len=20) :: control_file

    character(len=100) :: flux_file
    character(len=100) :: aptofem_run_number_string
    character(len=100) :: tsvFormat

    !!!!!!!!!!!!!!!!!!!!!!
    !! SET CONTROL FILE !!
    !!!!!!!!!!!!!!!!!!!!!!
    call program_name(control_file)
    if (control_file /= 'placentone' .and. control_file /= 'placenta' .and. control_file /= 'placenta-sv4' .and. &
            control_file /= 'placentone-3d') then
        call write_message(io_err, 'Error: program_name should be placentone or placenta or placenta-sv4 or placentone-3d.')
        stop
    end if

    !!!!!!!!!!!!!!!!!!!
    !! APTOFEM SETUP !!
    !!!!!!!!!!!!!!!!!!!
    call AptoFEM_initialize     (aptofem_stored_keys, 'acf_' // trim(control_file) // '.dat', './')
    call create_mesh            (mesh_data, get_boundary_no_nsku, 'mesh_gen', aptofem_stored_keys)
    call get_user_data          ('user_data', aptofem_stored_keys)
    call get_user_data_nsku     ('user_data', aptofem_stored_keys)
    call get_user_data_transport('user_data', aptofem_stored_keys)
    call set_space_type_nsku    (aptofem_stored_keys)

    !!!!!!!!!!!!!!!!!
    !! REFINE MESH !!
    !!!!!!!!!!!!!!!!!
    do mesh_no = 1, no_uniform_refinements_everywhere
        no_eles = mesh_data%no_eles
        allocate(refinement_marks(no_eles))

        call write_message(io_msg, '========================================================')
        call write_message(io_msg, '  Refinement step ')
        call refine_region_indicator(refinement_marks, no_eles, mesh_data, 300, 599)

        ! mesh_smoother = .false.

        ! call h_refine_mesh(mesh_tree, mesh_data, mesh_data_orig, no_eles, mesh_smoother, refinement_marks)
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

        ! mesh_smoother = .false.

        ! call h_refine_mesh(mesh_tree, mesh_data, mesh_data_orig, no_eles, mesh_smoother, refinement_marks)
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

        ! mesh_smoother = .false.

        ! call h_refine_mesh(mesh_tree, mesh_data, mesh_data_orig, no_eles, mesh_smoother, refinement_marks)
        call h_mesh_adaptation('uniform_refinement', aptofem_stored_keys, mesh_tree, mesh_data, mesh_data_orig, &
            mesh_no + no_uniform_refinements_everywhere + no_uniform_refinements_cavity, no_eles, refinement_marks)
        call write_message(io_msg, '========================================================')

        deallocate(refinement_marks)

        call delete_mesh(mesh_data_orig)
    end do

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! VELOCITY PROBLEM SETUP AND INITIAL CONDITION !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    call create_fe_solution(solution_nsku, mesh_data, 'fe_solution_nsku', aptofem_stored_keys, &
        dirichlet_bc_nsku)

    call set_up_newton_solver_parameters('solver_nsku', aptofem_stored_keys, scheme_data_nsku)

    call linear_fe_solver(solution_nsku, mesh_data, fe_solver_routines_nsku, 'solver_nsku', &
        aptofem_stored_keys, sp_matrix_rhs_data_nsku, 1, scheme_data_nsku)
    call linear_fe_solver(solution_nsku, mesh_data, fe_solver_routines_nsku, 'solver_nsku', &
        aptofem_stored_keys, sp_matrix_rhs_data_nsku, 2, scheme_data_nsku)

    solution_nsku%current_time    = 0.0_db
    scheme_data_nsku%current_time = 0.0_db
    scheme_data_nsku%time_step    = 0.1_db

    call set_current_time(solution_nsku, 0.0_db)

    if (velocity_ic_from_ss) then
        call store_subroutine_names(fe_solver_routines_nsku, 'assemble_jac_matrix_element', &
            jacobian_nsku_ss, 1)
        call store_subroutine_names(fe_solver_routines_nsku, 'assemble_residual_element', &
            element_residual_nsku_ss, 1)

        ! if (fe_space_nsku == 'DG') then
            call store_subroutine_names(fe_solver_routines_nsku, 'assemble_jac_matrix_int_bdry_face', &
                jacobian_face_nsku_ss, 1)
            call store_subroutine_names(fe_solver_routines_nsku, 'assemble_residual_int_bdry_face', &
                element_residual_face_nsku_ss, 1)
        ! else
        !     call store_subroutine_names(fe_solver_routines_nsku, 'assemble_residual_int_bdry_face', &
        !         element_residual_cg_boundary_nsku_ss, 1)

        !     !! ONLY STORED TO NOT GIVE ERROR !!
        !     !!    NOT ACTUALLY CALLED        !!
        !     call store_subroutine_names(fe_solver_routines_nsku, 'assemble_jac_matrix_int_bdry_face', &
        !         jacobian_face_nsku_ss, 1)
        !     !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ! end if

        call newton_fe_solver(solution_nsku, mesh_data, fe_solver_routines_nsku, 'solver_nsku', aptofem_stored_keys, &
            sp_matrix_rhs_data_nsku, scheme_data_nsku, ifail)


    else
        !call project_function(solution_nsku, mesh_data, solution_nsku%analytical_solution_ptr)

        solution_nsku%soln_values = 0.0_db

        call project_dirichlet_boundary_values(solution_nsku, mesh_data)
    end if

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! VELOCITY SCREEN OUTPUT !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!
    no_errors_nsku   = 0
    errors(1)        = 0.0_db
    errors_name(1)   = ''
    errors_format(1) = ''

    call write_message(io_msg, '========================================================')
    call write_message(io_msg, '||                 (velocity solution)                ||')
    call write_data('output_data', aptofem_stored_keys, errors, no_errors_nsku, errors_name, errors_format, mesh_data, &
        solution_nsku)

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! SAVE VELOCITY INITIAL CONDITION AND RAW SOLUTION !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    call write_fe_data('output_mesh_solution_nsku_2D', aptofem_stored_keys, 0, mesh_data, solution_nsku)
    call write_solution_for_restart(solution_nsku, mesh_data, 0, 'dg_nsku-transport_nsku_' &
        // trim(control_file), '../../output/')

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! TRANSPORT PROBLEM SETUP AND INITIAL CONDITION !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    call create_fe_solution(solution_transport, mesh_data, 'fe_solution_transport', aptofem_stored_keys, &
        anal_soln_transport, get_boundary_no_transport)

    call set_current_time(solution_transport, 0.0_db)

    call linear_fe_solver(solution_transport, mesh_data, fe_solver_routines_transport, 'solver_transport', &
        aptofem_stored_keys, sp_matrix_rhs_data_transport, 1, scheme_data_transport)
    call linear_fe_solver(solution_transport, mesh_data, fe_solver_routines_transport, 'solver_transport', &
        aptofem_stored_keys, sp_matrix_rhs_data_transport, 2, scheme_data_transport)

    if (transport_ic_from_ss .and. compute_transport) then
        call store_subroutine_names(fe_solver_routines_transport, 'assemble_matrix_rhs_element', &
            stiffness_matrix_load_vector_transport_ss, 1)
        call store_subroutine_names(fe_solver_routines_transport, 'assemble_matrix_rhs_face',    &
            stiffness_matrix_load_vector_face_transport_ss, 1)

        call linear_fe_solver(solution_transport, mesh_data, fe_solver_routines_transport, 'solver_transport', &
            aptofem_stored_keys, sp_matrix_rhs_data_transport, 3, scheme_data_transport)
        call linear_fe_solver(solution_transport, mesh_data, fe_solver_routines_transport, 'solver_transport', &
            aptofem_stored_keys, sp_matrix_rhs_data_transport, 4, scheme_data_transport)
    else
        solution_transport%soln_values = 0.0_db

        if (compute_transport) then
            call project_dirichlet_boundary_values(solution_transport, mesh_data)
        end if
    end if

    if (compute_transport) then
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        !! TRANSPORT SCREEN OUTPUT !!
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        no_errors_transport = 0
        errors(1)           = 0.0_db
        errors_name(1)      = ''
        errors_format(1)    = ''

        call write_message(io_msg, '========================================================')
        call write_message(io_msg, '||                 (transport solution)               ||')
        call write_data('output_data', aptofem_stored_keys, errors, no_errors_transport, errors_name, errors_format, mesh_data, &
            solution_transport)

        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        !! SAVE TRANSPORT INITIAL CONDITION AND RAW SOLUTION !!
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        call write_fe_data('output_mesh_solution_transport_2D', aptofem_stored_keys, 0, mesh_data, solution_transport)
        call write_solution_for_restart(solution_transport, mesh_data, 0, 'dg_nsku-transport_transport_' &
            // trim(control_file), '../../output/')
    end if

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! SETUP FOR TIME-DEPENDANCE !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if (compute_transport) then
        ! Transport routines.
        call store_subroutine_names(fe_solver_routines_transport, 'assemble_matrix_rhs_element', &
            stiffness_matrix_load_vector_transport, 1)
        call store_subroutine_names(fe_solver_routines_transport, 'assemble_matrix_rhs_face',    &
            stiffness_matrix_load_vector_face_transport, 1)

        ! Storage for transport timestepping.
        if (no_time_steps == 0) then
            scheme_data_transport%time_step = 0.0_db
        else
            scheme_data_transport%time_step = final_local_time/real(no_time_steps, db)
        end if
        scheme_data_transport%current_time = 0.0_db
        no_dofs_transport                  = get_no_dofs(solution_transport)

        allocate(scheme_data_transport%temp_real_array(1, no_dofs_transport))

        scheme_data_transport%temp_real_array  = 0.0_db
        scheme_data_transport%dim_real_array_1 = 1
        scheme_data_transport%dim_real_array_2 = no_dofs_transport
    end if

    ! Velocity routines.
    call store_subroutine_names(fe_solver_routines_nsku,  'assemble_jac_matrix_element', &
        jacobian_nsku, 1)
    call store_subroutine_names(fe_solver_routines_nsku, 'assemble_jac_matrix_int_bdry_face', &
        jacobian_face_nsku, 1)
    call store_subroutine_names(fe_solver_routines_nsku, 'assemble_residual_element', &
        element_residual_nsku, 1)
    call store_subroutine_names(fe_solver_routines_nsku, 'assemble_residual_int_bdry_face', &
        element_residual_face_nsku, 1)

    ! Velocity DIRK timestepping setup.
    call set_up_dirk_timestepping('solver_nsku', aptofem_stored_keys, dirk_scheme_nsku)

    solution_nsku%current_time    = 0.0_db
    scheme_data_nsku%current_time = 0.0_db
    if (no_time_steps == 0) then
        scheme_data_nsku%time_step = 0.0_db
    else
        scheme_data_nsku%time_step = final_local_time/real(no_time_steps, db)
    end if

    call set_current_time(solution_nsku, 0.0_db)

    no_dofs_nsku = get_no_dofs(solution_nsku)

    !!!!!!!!!!!!!!!!!
    !! SAVE FLUXES !!
    !!!!!!!!!!!!!!!!!
    write(aptofem_run_number_string, '(i10)') aptofem_run_number
    flux_file = '../../output/flux' // '_' // 'dg_nsku_' // trim(control_file) // '_' // &
        trim(adjustl(aptofem_run_number_string)) // '.dat'
    open(23111997, file=flux_file, status='replace')
    tsvFormat = '(*(G0.6,:,"'//achar(9)//'"))'

    call setup_outflow_fluxes(243)
    call setup_outflow_transport_fluxes(243)
    call calculate_outflow_fluxes(mesh_data, solution_nsku)
    call calculate_outflow_transport_fluxes(mesh_data, solution_nsku, solution_transport)

    call write_to_file_headers(23111997, tsvFormat)
    call write_to_file        (23111997, tsvFormat, mesh_data, solution_nsku, solution_transport, 0, 0.0_db)

    call finalise_outflow_fluxes()
    call finalise_outflow_transport_fluxes()

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! TRANSPORT REACTION TERM INTEGRAL !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    write(aptofem_run_number_string, '(i10)') aptofem_run_number
    flux_file = '../../output/transport-reaction-integral' // '_' // 'dg_nsku_' // trim(control_file) // '_' // &
        trim(adjustl(aptofem_run_number_string)) // '.dat'
    open(23111998, file=flux_file, status='replace')
    write(23111998, tsvFormat) 'Time step', 'Integral'
    write(23111998, tsvFormat) 0, calculate_integral_transport_reaction(mesh_data, solution_transport)

    !!!!!!!!!!!!!!!!!!
    !! TIMESTEPPING !!
    !!!!!!!!!!!!!!!!!!
    do time_step_no = 1, no_time_steps
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ! SETUP FOR NEXT TRANSPORT TIMESTEP !
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        if (compute_transport) then
            scheme_data_transport%current_time = scheme_data_transport%current_time + scheme_data_transport%time_step

            call get_solution_vector              (scheme_data_transport%temp_real_array(1, :), no_dofs_transport, &
                solution_transport)
            call set_current_time                 (solution_transport, scheme_data_transport%current_time)
            call project_dirichlet_boundary_values(solution_transport, mesh_data)
        end if

        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ! ASSEMBLE AND SOLVE THIS TIMESTEP !
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        if (.not. velocity_ss) then
            call dirk_single_time_step(solution_nsku, mesh_data, fe_solver_routines_nsku, 'solver_nsku', aptofem_stored_keys, &
                sp_matrix_rhs_data_nsku, scheme_data_nsku, dirk_scheme_nsku, scheme_data_nsku%current_time, &
                scheme_data_nsku%time_step, no_dofs_nsku, time_step_no, .false., norm_diff_u)

            call set_current_time(solution_nsku, solution_nsku%current_time + &
                scheme_data_nsku%time_step)
        end if

        if (compute_transport) then
            call linear_fe_solver(solution_transport, mesh_data, fe_solver_routines_transport, 'solver_transport', &
                aptofem_stored_keys, sp_matrix_rhs_data_transport, 3, scheme_data_transport)
            call linear_fe_solver(solution_transport, mesh_data, fe_solver_routines_transport, 'solver_transport', &
                aptofem_stored_keys, sp_matrix_rhs_data_transport, 4, scheme_data_transport)
        end if

        !!!!!!!!!!!!!!!!!
        ! SCREEN OUTPUT !
        !!!!!!!!!!!!!!!!!
        no_errors_nsku      = 0
        no_errors_transport = 0
        errors(1)           = 0.0_db
        errors_name(1)      = ''
        errors_format(1)    = ''

        if (.not. velocity_ss) then
            call write_message(io_msg, '========================================================')
            call write_message(io_msg, '||                (velocity solution)                 ||')
            call write_data   ('output_data', aptofem_stored_keys, errors, no_errors_nsku, errors_name,&
                errors_format, mesh_data, solution_nsku)
        end if

        if (compute_transport) then
            call write_message(io_msg, '========================================================')
            call write_message(io_msg, '||                (transport solution)                ||')
            call write_data   ('output_data', aptofem_stored_keys, errors, no_errors_transport, errors_name,&
                errors_format, mesh_data, solution_transport)
        end if

        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ! VTK AND RAW SOLUTION OUTPUT !
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        if (mod(time_step_no, 10) == 0) then
            if (.not. velocity_ss) then
                call write_fe_data('output_mesh_solution_nsku_2D', aptofem_stored_keys, time_step_no, mesh_data, solution_nsku)
                call write_solution_for_restart(solution_nsku, mesh_data, time_step_no, 'dg_nsku-transport_nsku_' &
                    // trim(control_file), '../../output/')
            end if
            if (compute_transport) then
                call write_fe_data('output_mesh_solution_transport_2D', aptofem_stored_keys, time_step_no, mesh_data, &
                    solution_transport)
                call write_solution_for_restart(solution_transport, mesh_data, time_step_no, 'dg_nsku-transport_transport_' &
                    // trim(control_file), '../../output/')
            end if
        end if

        !!!!!!!!!!!!!!!
        ! FLUX OUTPUT !
        !!!!!!!!!!!!!!!
        call setup_outflow_fluxes(243)
        call setup_outflow_transport_fluxes(243)
        call calculate_outflow_fluxes(mesh_data, solution_nsku)
        call calculate_outflow_transport_fluxes(mesh_data, solution_nsku, solution_transport)
        call write_to_file(23111997, tsvFormat, mesh_data, solution_nsku, solution_transport, time_step_no, &
            scheme_data_transport%current_time)
        call finalise_outflow_fluxes()
        call finalise_outflow_transport_fluxes()

        !!!!!!!!!!!!!!!!!!!!!
        ! REACTION INTEGRAL !
        !!!!!!!!!!!!!!!!!!!!!
        write(23111998, tsvFormat) time_step_no, calculate_integral_transport_reaction(mesh_data, solution_transport)
    end do

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! OUTPUT PERMEABILITY FIELD !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    call create_fe_solution(solution_permeability, mesh_data, 'fe_projection_permeability', aptofem_stored_keys, &
        anal_soln_transport, get_boundary_no_transport) ! Doesn't matter what dirichlet bc is passed.

    call project_function(solution_permeability, mesh_data, project_permeability_300)
    call write_fe_data('output_mesh_solution_permeability', aptofem_stored_keys, 300, mesh_data, solution_permeability)

    call project_function(solution_permeability, mesh_data, project_permeability_400)
    call write_fe_data('output_mesh_solution_permeability', aptofem_stored_keys, 400, mesh_data, solution_permeability)

    call project_function(solution_permeability, mesh_data, project_permeability_500)
    call write_fe_data('output_mesh_solution_permeability', aptofem_stored_keys, 500, mesh_data, solution_permeability)

    call delete_solution(solution_permeability)

    !!!!!!!!!!!!!!!!!!!!!!!!!
    !! OUTPUT UPTAKE FIELD !!
    !!!!!!!!!!!!!!!!!!!!!!!!!
    call create_fe_solution(solution_uptake, mesh_data, 'fe_projection_uptake', aptofem_stored_keys, &
        anal_soln_transport, get_boundary_no_transport) ! Doesn't matter what dirichlet bc is passed.

    call project_function(solution_uptake, mesh_data, project_uptake_300)
    call write_fe_data('output_mesh_solution_uptake', aptofem_stored_keys, 300, mesh_data, solution_uptake)

    call project_function(solution_uptake, mesh_data, project_uptake_400)
    call write_fe_data('output_mesh_solution_uptake', aptofem_stored_keys, 400, mesh_data, solution_uptake)

    call project_function(solution_uptake, mesh_data, project_uptake_500)
    call write_fe_data('output_mesh_solution_uptake', aptofem_stored_keys, 500, mesh_data, solution_uptake)

    call delete_solution(solution_uptake)

    !!!!!!!!!!!!!!
    !! CLEAN UP !!
    !!!!!!!!!!!!!!
    close(23111998)
    close(23111997)

    if (compute_transport) then
        deallocate(scheme_data_transport%temp_real_array)
    end if

    call linear_fe_solver(solution_transport, mesh_data, fe_solver_routines_transport, 'solver_transport', &
        aptofem_stored_keys, sp_matrix_rhs_data_transport, 5, scheme_data_transport)
    call linear_fe_solver(solution_nsku,      mesh_data, fe_solver_routines_nsku,      'solver_nsku', &
        aptofem_stored_keys, sp_matrix_rhs_data_nsku,      5, scheme_data_nsku)

    call delete_solution (solution_transport)
    call delete_solution (solution_nsku)
    call delete_mesh     (mesh_data)
    call AptoFEM_finalize(aptofem_stored_keys)
end program

! subroutine write_to_file_headers(file_no, tsvFormat)
!     integer, intent(in)            :: file_no
!     character(len=100), intent(in) :: tsvFormat

!     write(file_no, tsvFormat) 'Time step', &
!         'Time', &
!         'Placentone 1 to 2', &
!         'Placentone 2 to 3', &
!         'Placentone 3 to 4', &
!         'Placentone 4 to 5', &
!         'Placentone 5 to 6', &
!         'Inlet 1', &
!         'Inlet 2', &
!         'Inlet 3', &
!         'Inlet 4', &
!         'Inlet 5', &
!         'Inlet 6', &
!         'Outlet 1L', &
!         'Outlet 1R', &
!         'Outlet 2L', &
!         'Outlet 2R', &
!         'Outlet 3L', &
!         'Outlet 3R', &
!         'Outlet 4L', &
!         'Outlet 4R', &
!         'Outlet 5L', &
!         'Outlet 5R', &
!         'Outlet 6L', &
!         'Outlet 6R', &
!         'Corner L', &
!         'Corner R', &
!         'Septa 1', &
!         'Septa 2', &
!         'Septa 3', &
!         'Septa 4', &
!         'Inlet 1 transport', &
!         'Inlet 2 transport', &
!         'Inlet 3 transport', &
!         'Inlet 4 transport', &
!         'Inlet 5 transport', &
!         'Inlet 6 transport', &
!         'Outlet 1L transport', &
!         'Outlet 1R transport', &
!         'Outlet 2L transport', &
!         'Outlet 2R transport', &
!         'Outlet 3L transport', &
!         'Outlet 3R transport', &
!         'Outlet 4L transport', &
!         'Outlet 4R transport', &
!         'Outlet 5L transport', &
!         'Outlet 5R transport', &
!         'Outlet 6L transport', &
!         'Outlet 6R transport', &
!         'Corner L transport', &
!         'Corner R transport', &
!         'Septa 1 transport', &
!         'Septa 2 transport', &
!         'Septa 3 transport', &
!         'Septa 4 transport', &
!         'Norm velocity L2', &
!         'Norm pressure L2', &
!         'Norm velocity-pressure L2', &
!         'Norm velocity-pressure DG', &
!         'Norm velocity div', &
!         'Norm transport L2', &
!         'Norm transport H1', &
!         'Norm transport DG', &
!         'Norm transport H2'

!     flush(file_no)

! end subroutine

! subroutine write_to_file(file_no, tsvFormat, mesh_data, solution_nsku, solution_transport, timestep_no, current_time)
!     use param
!     use fe_mesh
!     use fe_solution
!     use crossflow_flux
!     use outflow_flux
!     use outflow_transport_flux

!     integer, intent(in)        :: file_no
!     character(len=100)         :: tsvFormat
!     type(mesh), intent(inout)  :: mesh_data
!     type(solution), intent(in) :: solution_nsku, solution_transport
!     integer, intent(in)        :: timestep_no
!     real(db), intent(in)       :: current_time

!     write(file_no, tsvFormat) timestep_no, &
!         current_time, &
!         calculate_crossflow_flux       (mesh_data, solution_nsku, 301, 302), &
!         calculate_crossflow_flux       (mesh_data, solution_nsku, 302, 303), &
!         calculate_crossflow_flux       (mesh_data, solution_nsku, 303, 304), &
!         calculate_crossflow_flux       (mesh_data, solution_nsku, 304, 305), &
!         calculate_crossflow_flux       (mesh_data, solution_nsku, 305, 306), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 111), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 112), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 113), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 114), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 115), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 116), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 211), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 212), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 213), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 214), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 215), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 216), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 217), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 218), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 219), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 220), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 221), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 222), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 230), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 231), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 240), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 241), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 242), &
!         calculate_outflow_flux         (mesh_data, solution_nsku, 243), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 111), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 112), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 113), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 114), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 115), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 116), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 211), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 212), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 213), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 214), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 215), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 216), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 217), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 218), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 219), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 220), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 221), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 222), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 230), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 231), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 240), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 241), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 242), &
!         calculate_outflow_transport_flux(mesh_data, solution_nsku, solution_transport, 243)

!     flush(file_no)

! end subroutine

subroutine write_to_file_headers(file_no, tsvFormat)
    integer, intent(in)            :: file_no
    character(len=100), intent(in) :: tsvFormat

    write(file_no, tsvFormat) 'Time step', &
    'Time', &
    'Placentone 1 to 2', &
    'Placentone 2 to 3', &
    'Placentone 3 to 4', &
    'Placentone 4 to 5', &
    'Placentone 5 to 6', &
    'Inlet 1', &
    'Inlet 2', &
    'Inlet 3', &
    'Inlet 4', &
    'Inlet 5', &
    'Inlet 6', &
    'Outlet 1L', &
    'Outlet 1R', &
    'Outlet 2L', &
    'Outlet 2R', &
    'Outlet 3L', &
    'Outlet 3R', &
    'Outlet 4L', &
    'Outlet 4R', &
    'Outlet 5L', &
    'Outlet 5R', &
    'Outlet 6L', &
    'Outlet 6R', &
    'Corner L', &
    'Corner R', &
    'Septa 1', &
    'Septa 2', &
    'Septa 3', &
    'Septa 4', &
    'Inlet 1 transport', &
    'Inlet 2 transport', &
    'Inlet 3 transport', &
    'Inlet 4 transport', &
    'Inlet 5 transport', &
    'Inlet 6 transport', &
    'Outlet 1L transport', &
    'Outlet 1R transport', &
    'Outlet 2L transport', &
    'Outlet 2R transport', &
    'Outlet 3L transport', &
    'Outlet 3R transport', &
    'Outlet 4L transport', &
    'Outlet 4R transport', &
    'Outlet 5L transport', &
    'Outlet 5R transport', &
    'Outlet 6L transport', &
    'Outlet 6R transport', &
    'Corner L transport', &
    'Corner R transport', &
    'Septa 1 transport', &
    'Septa 2 transport', &
    'Septa 3 transport', &
    'Septa 4 transport', &
    'Norm velocity L2', &
    'Norm pressure L2', &
    'Norm velocity-pressure L2', &
    'Norm velocity-pressure DG', &
    'Norm velocity div', &
    'Norm transport L2', &
    'Norm transport H1', &
    'Norm transport DG', &
    'Norm transport H2', &
    'Sum velocity flux', &
    'Sum transport flux'

    flush(file_no)

end subroutine

subroutine write_to_file(file_no, tsvFormat, mesh_data, solution_nsku, solution_transport, timestep_no, current_time)
    use param
    use fe_mesh
    use fe_solution
    use crossflow_flux
    use outflow_flux
    use outflow_transport_flux

    integer, intent(in)        :: file_no
    character(len=100)         :: tsvFormat
    type(mesh), intent(inout)  :: mesh_data
    type(solution), intent(in) :: solution_nsku, solution_transport
    integer, intent(in)        :: timestep_no
    real(db), intent(in)       :: current_time

    write(file_no, tsvFormat) timestep_no, &
    current_time, &
    calculate_crossflow_flux(mesh_data, solution_nsku, 301, 302), &
    calculate_crossflow_flux(mesh_data, solution_nsku, 302, 303), &
    calculate_crossflow_flux(mesh_data, solution_nsku, 303, 304), &
    calculate_crossflow_flux(mesh_data, solution_nsku, 304, 305), &
    calculate_crossflow_flux(mesh_data, solution_nsku, 305, 306), &
    outflow_fluxes(111), &
    outflow_fluxes(112), &
    outflow_fluxes(113), &
    outflow_fluxes(114), &
    outflow_fluxes(115), &
    outflow_fluxes(116), &
    outflow_fluxes(211), &
    outflow_fluxes(212), &
    outflow_fluxes(213), &
    outflow_fluxes(214), &
    outflow_fluxes(215), &
    outflow_fluxes(216), &
    outflow_fluxes(217), &
    outflow_fluxes(218), &
    outflow_fluxes(219), &
    outflow_fluxes(220), &
    outflow_fluxes(221), &
    outflow_fluxes(222), &
    outflow_fluxes(230), &
    outflow_fluxes(231), &
    outflow_fluxes(240), &
    outflow_fluxes(241), &
    outflow_fluxes(242), &
    outflow_fluxes(243), &
    outflow_transport_fluxes(111), &
    outflow_transport_fluxes(112), &
    outflow_transport_fluxes(113), &
    outflow_transport_fluxes(114), &
    outflow_transport_fluxes(115), &
    outflow_transport_fluxes(116), &
    outflow_transport_fluxes(211), &
    outflow_transport_fluxes(212), &
    outflow_transport_fluxes(213), &
    outflow_transport_fluxes(214), &
    outflow_transport_fluxes(215), &
    outflow_transport_fluxes(216), &
    outflow_transport_fluxes(217), &
    outflow_transport_fluxes(218), &
    outflow_transport_fluxes(219), &
    outflow_transport_fluxes(220), &
    outflow_transport_fluxes(221), &
    outflow_transport_fluxes(222), &
    outflow_transport_fluxes(230), &
    outflow_transport_fluxes(231), &
    outflow_transport_fluxes(240), &
    outflow_transport_fluxes(241), &
    outflow_transport_fluxes(242), &
    outflow_transport_fluxes(243), &
    0, &
    0, &
    0, &
    0, &
    0, &
    0, &
    0, &
    0, &
    0, &
    sum_nonzero_fluxes(), &
    sum_nonzero_transport_fluxes()

    flush(file_no)

end subroutine