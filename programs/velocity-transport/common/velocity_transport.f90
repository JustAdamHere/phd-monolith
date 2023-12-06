program velocity_transport
    use aptofem_kernel
    use fe_solution_restart_io
    use problem_options
    use problem_options_velocity
    use problem_options_transport
    use problem_options_geometry
    use refine_region
    use velocity_bc_interface
    use bcs_transport
    use solution_storage_velocity
    use crossflow_flux
    use outflow_flux
    use outflow_transport_flux
    use integrate_transport_reaction
    use integrate_velocity_magnitude
    use integrate_one
    use integrate_slow_velocity
    use integrate_fast_velocity
    use projections
    use previous_velocity

    use matrix_rhs_transport
    use matrix_rhs_transport_ss
    use matrix_rhs_s_b_ss
    use jacobi_residual_ns_b_ss
    use jacobi_residual_ns_nsb_ss
    use jacobi_residual_nsb
    use jacobi_residual_nsb_ss
    use jacobi_residual_nsb_mm

    use coupled_sp_matrix_solvers

    ! To avoid race condition when outputting permeability/uptake fields.
    use omp_lib
#ifdef MPI
    use mpi
#endif

    implicit none

    type(aptofem_keys), pointer   :: aptofem_stored_keys
    type(mesh)                    :: mesh_data, mesh_data_orig
    type(solution)                :: solution_transport, solution_permeability, solution_uptake
    type(fe_assembly_subroutines) :: fe_solver_routines_velocity, fe_solver_routines_transport!, fe_solver_routines_uptake

    type(refinement_tree)              :: mesh_tree
    integer, dimension(:), allocatable :: refinement_marks
    integer                            :: mesh_no, no_eles, problem_dim

    class(sp_matrix_rhs), pointer   :: sp_matrix_rhs_data_velocity, sp_matrix_rhs_data_transport!, sp_matrix_rhs_data_uptake
    type(default_user_data)         :: scheme_data_velocity, scheme_data_transport!, scheme_data_uptake
    type(dirk_time_stepping_scheme) :: dirk_scheme_velocity
    real(db)                        :: norm_diff_u

    character(15), dimension(1) :: errors_format, errors_name
    real(db), dimension(1)      :: errors
    integer                     :: no_errors_velocity, no_errors_transport

    logical :: ifail

    integer :: time_step_no
    integer :: no_dofs_velocity, no_dofs_transport

    logical, dimension(20) :: mesh_smoother

    character(len=100) :: flux_file, data_file, velocity_magnitude_file, one_file, slow_velocity_file
    character(len=100) :: aptofem_run_number_string
    character(len=100) :: tsvFormat

    integer  :: reynold_step, i
    real(db) :: velocity_time_coefficient_orig, velocity_convection_coefficient_orig, ratio, min_step, max_step
    real(db), dimension(:), allocatable :: steps

    character(len=100) :: temp_string1, temp_string2

    integer :: no_command_line_arguments

    real(db) :: current_time, time_step

    integer :: thread_no

    real(db) :: one_ivs, one_everywhere, vmi_ivs, vmi_everywhere, velocity_average_ivs, velocity_average_everywhere, svp_ivs, &
        svp_everywhere, svp_0_0005_everywhere, fvp_0_001_everywhere, svp_nominal_ivs, svp_nominal_everywhere

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! COMMAND LINE ARGUMENTS !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!
    no_command_line_arguments = command_argument_count()
    if (no_command_line_arguments /= 2) then
        print *, "ERROR: Incorrect number of command line arguments."
        print *, "       Usage: ./velocity_transport.out <nsb|ns-b|ns-nsb|s-b> <placentone|placenta|placentone-3d>"
        error stop
    end if
    call get_command_argument(1, assembly_name)
    if (assembly_name /= 'nsb' .and. assembly_name /= 'ns-b' .and. assembly_name /= 'ns-nsb' .and. assembly_name /= 's-b') then
        call write_message(io_err, 'Error: assembly_name should be nsb or ns-b or ns-nsb or s-b.')
        error stop
    end if
    call get_command_argument(2, geometry_name)
    if (geometry_name /= 'placentone' .and. geometry_name /= 'placenta' .and. geometry_name /= 'placentone-3d') then
        call write_message(io_err, 'Error: geometry_name should be placentone or placenta or placentone-3d.')
        error stop
    end if

    !!!!!!!!!!!!!!!!!!!
    !! APTOFEM SETUP !!
    !!!!!!!!!!!!!!!!!!!
    call AptoFEM_initialize     (aptofem_stored_keys, 'acf_' // trim(geometry_name) // '.dat', './common/')
    call setup_velocity_bcs     (geometry_name)
    call create_mesh            (mesh_data, get_boundary_no_velocity, 'mesh_gen', aptofem_stored_keys)
    call get_user_data          ('user_data', aptofem_stored_keys)
    call get_user_data_velocity ('user_data', aptofem_stored_keys)
    call get_user_data_transport('user_data', aptofem_stored_keys)
    call set_space_type_velocity(aptofem_stored_keys)
    call initialise_geometry    (geometry_name, no_placentones)

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

    !!!!!!!!!!!!!!!!!!!!!!!!!
    !! GET MESH ATTRIBUTES !!
    !!!!!!!!!!!!!!!!!!!!!!!!!
    no_eles = mesh_data%no_eles
    problem_dim = mesh_data%problem_dim

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! OUTPUT PERMEABILITY FIELD !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if (compute_permeability) then
        call create_fe_solution(solution_permeability, mesh_data, 'fe_projection_permeability', aptofem_stored_keys, &
            anal_soln_transport, get_boundary_no_transport) ! Doesn't matter what dirichlet bc is passed.

#ifdef OPENMP        
!$OMP PARALLEL PRIVATE(thread_no)
        thread_no = omp_get_thread_num()
        if (thread_no == 0) then
            call project_function_region_id(solution_permeability, mesh_data, project_permeability)
            call write_fe_data('output_mesh_solution_permeability', aptofem_stored_keys, 0, mesh_data, solution_permeability)
        end if
!$OMP END PARALLEL
#elif MPI
    if (processor_no == 0) then
        call project_function_region_id(solution_permeability, mesh_data, project_permeability)
        call write_fe_data('output_mesh_solution_permeability', aptofem_stored_keys, 0, mesh_data, solution_permeability)
    end if
#else
    call project_function_region_id(solution_permeability, mesh_data, project_permeability)
    call write_fe_data('output_mesh_solution_permeability', aptofem_stored_keys, 0, mesh_data, solution_permeability)
#endif

        call delete_solution(solution_permeability)
    end if

    !!!!!!!!!!!!!!!!!!!!!!!!!
    !! OUTPUT UPTAKE FIELD !!
    !!!!!!!!!!!!!!!!!!!!!!!!!
    if (compute_uptake) then
        call create_fe_solution(solution_uptake, mesh_data, 'fe_projection_uptake', aptofem_stored_keys, &
            anal_soln_transport, get_boundary_no_transport) ! Doesn't matter what dirichlet bc is passed.

#ifdef OPENMP        
!$OMP PARALLEL PRIVATE(thread_no)
        thread_no = omp_get_thread_num()
        if (thread_no == 0) then
            call project_function_region_id(solution_uptake, mesh_data, project_uptake)
            call write_fe_data('output_mesh_solution_uptake', aptofem_stored_keys, 0, mesh_data, solution_uptake)
        end if
!$OMP END PARALLEL
#elif MPI
    if (processor_no == 0) then
        call project_function_region_id(solution_uptake, mesh_data, project_uptake)
        call write_fe_data('output_mesh_solution_uptake', aptofem_stored_keys, 0, mesh_data, solution_uptake)
    end if
#else
    call project_function_region_id(solution_uptake, mesh_data, project_uptake)
    call write_fe_data('output_mesh_solution_uptake', aptofem_stored_keys, 0, mesh_data, solution_uptake)
#endif

        call delete_solution(solution_uptake)
    end if

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! VELOCITY PROBLEM SETUP AND INITIAL CONDITION !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    current_time = 0.0_db
    if (no_time_steps == 0) then
        time_step = 0.0_db
    else
        time_step = final_local_time/real(no_time_steps, db)
    end if    

    if (compute_velocity) then
        call create_fe_solution(solution_velocity, mesh_data, 'fe_solution_velocity', aptofem_stored_keys, &
            dirichlet_bc_velocity)

        call set_up_newton_solver_parameters('solver_velocity', aptofem_stored_keys, scheme_data_velocity)

        call linear_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', &
            aptofem_stored_keys, sp_matrix_rhs_data_velocity, 1, scheme_data_velocity)
        call linear_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', &
            aptofem_stored_keys, sp_matrix_rhs_data_velocity, 2, scheme_data_velocity)

        solution_velocity%current_time    = current_time
        scheme_data_velocity%current_time = current_time
        scheme_data_velocity%time_step    = time_step

        call set_current_time(solution_velocity, current_time)

        no_dofs_velocity = get_no_dofs(solution_velocity)

        if (velocity_ic_from_ss) then
            if (trim(assembly_name) == 'nsb') then
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_element', &
                    jacobian_nsb_ss, 1)
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_int_bdry_face', &
                    jacobian_face_nsb_ss, 1)
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_element', &
                    element_residual_nsb_ss, 1)
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_int_bdry_face', &
                    element_residual_face_nsb_ss, 1)
            else if (trim(assembly_name) == 'ns-nsb') then
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_element', &
                    jacobian_ns_nsb_ss, 1)
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_int_bdry_face', &
                    jacobian_face_ns_nsb_ss, 1)
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_element', &
                    element_residual_ns_nsb_ss, 1)
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_int_bdry_face', &
                    element_residual_face_ns_nsb_ss, 1)
            else if (trim(assembly_name) == 'ns-b') then
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_element', &
                    jacobian_ns_b_ss, 1)
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_int_bdry_face', &
                    jacobian_face_ns_b_ss, 1)
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_element', &
                    element_residual_ns_b_ss, 1)
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_int_bdry_face', &
                    element_residual_face_ns_b_ss, 1)
            else if (trim(assembly_name) == 's-b') then
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_matrix_rhs_element', &
                    stiffness_matrix_load_vector_s_b_ss, 1)
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_matrix_rhs_face',    &
                    stiffness_matrix_load_vector_face_s_b_ss, 1)
            else
                print *, "ERROR: Unknown assembly name for velocity solver routine storage."
                error stop
            end if

            ! Set velocity amplitude.
            call Carson_velocity_amplitude(solution_velocity%current_time)

            ! if (fe_space_velocity == 'DG') then

            ! else
            !     call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_int_bdry_face', &
            !         element_residual_cg_boundary_velocity_ss, 1)

            !     !! ONLY STORED TO NOT GIVE ERROR !!
            !     !!    NOT ACTUALLY CALLED        !!
            !     call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_int_bdry_face', &
            !         jacobian_face_velocity_ss, 1)
            !     !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            ! end if
            
            ! Setup steps and ratios for Reynold number ramping.
            if (no_reynold_ramp_steps == 1) then
                allocate(steps(1))
                steps(1) = 0.0_db
                ratio    = 1.0_db
            else if (no_reynold_ramp_steps == 2) then
                allocate(steps(2))
                steps(1) = 0.0_db
                steps(2) = 1.0_db - reynold_ramp_start_ratio
                ratio    = reynold_ramp_start_ratio
            else
                ! Creates "base steps" of size 0.1 through to 0.01 between different Reynolds numbers.
                max_step = -1
                min_step = -2
                allocate(steps(no_reynold_ramp_steps))
                do i = 1, no_reynold_ramp_steps - 1
                    steps(no_reynold_ramp_steps - i + 1) = &
                        reynold_ramp_step_base**(min_step + real(i-1)*real(max_step - min_step)/(no_reynold_ramp_steps-2))
                end do
                steps(1) = 0.0_db

                ! "Normalise" the steps.
                steps = steps / sum(steps)
                steps = steps * (1 - reynold_ramp_start_ratio)

                ratio = reynold_ramp_start_ratio
            end if

            ! Loop over Reynolds number ramping steps.
            velocity_convection_coefficient_orig = velocity_convection_coefficient
            velocity_time_coefficient_orig       = velocity_time_coefficient
            do reynold_step = 1, no_reynold_ramp_steps
                ratio = ratio + steps(reynold_step)

                velocity_convection_coefficient = velocity_convection_coefficient_orig * ratio
                velocity_time_coefficient       = velocity_time_coefficient_orig       * ratio

                call write_message(io_msg, "===================================================")
                write(temp_string1, '(I5)') reynold_step
                write(temp_string2, '(I5)') no_reynold_ramp_steps
                call write_message(io_msg, "Reynolds step:" // trim(temp_string1) // " of " // trim(temp_string2))
                write(temp_string1, '(f10.3)') ratio
                call write_message(io_msg, "Current ratio: " // trim(temp_string1))
                write(temp_string1, '(f10.3)') velocity_convection_coefficient
                write(temp_string2, '(f10.3)') velocity_convection_coefficient_orig
                call write_message(io_msg, "Convection coefficient: " // trim(temp_string1) // " of " // trim(temp_string2))

                if (trim(assembly_name) == 'nsb' .or. trim(assembly_name) == 'ns-nsb' .or. trim(assembly_name) == 'ns-b') then
                    call newton_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', &
                        aptofem_stored_keys, sp_matrix_rhs_data_velocity, scheme_data_velocity, ifail)

                    if (ifail) then
                        call write_message(io_msg, "ERROR: Newton solver failed to converge.")
                        error stop
                    end if
                else if (trim(assembly_name) == 's-b') then
                    call linear_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', &
                        aptofem_stored_keys, sp_matrix_rhs_data_velocity, 3, scheme_data_velocity)
                    call linear_fe_solver(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', &
                        aptofem_stored_keys, sp_matrix_rhs_data_velocity, 4, scheme_data_velocity)
                else
                    call write_message(io_msg, "ERROR: Unknown assembly name for velocity solver.")
                    error stop
                end if

                call write_fe_data('output_mesh_solution_re_velocity_2D', aptofem_stored_keys, reynold_step, mesh_data, &
                    solution_velocity)
            end do
            deallocate(steps)

        else
            !call project_function(solution_velocity, mesh_data, solution_velocity%analytical_solution_ptr)

            solution_velocity%soln_values = 0.0_db

            call project_dirichlet_boundary_values(solution_velocity, mesh_data)
        end if
    else
        no_dofs_velocity = -1
    end if

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! VELOCITY SCREEN OUTPUT !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if (compute_velocity) then
        no_errors_velocity   = 0
        errors(1)        = 0.0_db
        errors_name(1)   = ''
        errors_format(1) = ''

        call write_message(io_msg, '========================================================')
        call write_message(io_msg, '||                 (velocity solution)                ||')
        call write_data('output_data', aptofem_stored_keys, errors, no_errors_velocity, errors_name, errors_format, mesh_data, &
            solution_velocity)
    end if

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! SAVE VELOCITY INITIAL CONDITION AND RAW SOLUTION !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if (compute_velocity) then
        call write_fe_data('output_mesh_solution_velocity_2D', aptofem_stored_keys, 0, mesh_data, solution_velocity)
        call write_solution_for_restart(solution_velocity, mesh_data, 0, 'dg_velocity-transport_velocity_' &
            // trim(geometry_name), '../../output/')
    end if

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! TRANSPORT PROBLEM SETUP AND INITIAL CONDITION !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if (compute_transport) then
        call create_fe_solution(solution_transport, mesh_data, 'fe_solution_transport', aptofem_stored_keys, &
            anal_soln_transport, get_boundary_no_transport)

        call set_current_time(solution_transport, current_time)

        call linear_fe_solver(solution_transport, mesh_data, fe_solver_routines_transport, 'solver_transport', &
            aptofem_stored_keys, sp_matrix_rhs_data_transport, 1, scheme_data_transport)
        call linear_fe_solver(solution_transport, mesh_data, fe_solver_routines_transport, 'solver_transport', &
            aptofem_stored_keys, sp_matrix_rhs_data_transport, 2, scheme_data_transport)

        ! FGMRES preconditioner for transport.
        if (linear_solver == 'petsc') then
            call set_petsc_options_fgmres()
        end if

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
    end if

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! TRANSPORT SCREEN OUTPUT !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if (compute_transport) then
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
        call write_solution_for_restart(solution_transport, mesh_data, 0, 'dg_velocity-transport_transport_' &
            // trim(geometry_name), '../../output/')
    end if

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! SETUP FOR TIME-DEPENDANCE !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if (compute_transport .and. no_time_steps > 0) then
        ! Transport routines.
        call store_subroutine_names(fe_solver_routines_transport, 'assemble_matrix_rhs_element', &
            stiffness_matrix_load_vector_transport, 1)
        call store_subroutine_names(fe_solver_routines_transport, 'assemble_matrix_rhs_face',    &
            stiffness_matrix_load_vector_face_transport, 1)

        ! Storage for transport timestepping.
        scheme_data_transport%time_step    = time_step
        scheme_data_transport%current_time = current_time
        no_dofs_transport                  = get_no_dofs(solution_transport)

        allocate(scheme_data_transport%temp_real_array(1, no_dofs_transport))

        scheme_data_transport%temp_real_array  = 0.0_db
        scheme_data_transport%dim_real_array_1 = 1
        scheme_data_transport%dim_real_array_2 = no_dofs_transport
    else
        no_dofs_transport = -1
    end if

    if (compute_velocity  .and. no_time_steps > 0) then
        ! Velocity routines.
        if (trim(assembly_name) == 'nsb') then
            if (moving_mesh) then
                ! call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_element', &
                !     jacobian_nsb_mm, 1)
                ! call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_int_bdry_face', &
                !     jacobian_face_nsb_mm, 1)
                ! call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_element', &
                !     element_residual_nsb_mm, 1)
                ! call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_int_bdry_face', &
                !     element_residual_face_nsb_mm, 1)

                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_element', &
                    jacobian_nsb_ss, 1)
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_int_bdry_face', &
                    jacobian_face_nsb_ss, 1)
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_element', &
                    element_residual_nsb_ss, 1)
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_int_bdry_face', &
                    element_residual_face_nsb_ss, 1)
            else
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_element', &
                    jacobian_nsb, 1)
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_jac_matrix_int_bdry_face', &
                    jacobian_face_nsb, 1)
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_element', &
                    element_residual_nsb, 1)
                call store_subroutine_names(fe_solver_routines_velocity, 'assemble_residual_int_bdry_face', &
                    element_residual_face_nsb, 1)
            end if
        else if (trim(assembly_name) == 's-b' .or. trim(assembly_name) == 'ns-b' .or. trim(assembly_name) == 'ns-nsb') then
            ! call store_subroutine_names(fe_solver_routines_velocity, 'assemble_matrix_rhs_element', &
            !     stiffness_matrix_load_vector_s_b, 1)
            ! call store_subroutine_names(fe_solver_routines_velocity, 'assemble_matrix_rhs_face',    &
            !     stiffness_matrix_load_vector_face_s_b, 1)
            print *, "!! WARNING: time-dependence not yet implemented !!"
            error stop
        else
            print *, "ERROR: Unknown assembly name for velocity solver."
            error stop
        end if

        ! Velocity DIRK timestepping setup.
        call set_up_dirk_timestepping('solver_velocity', aptofem_stored_keys, dirk_scheme_velocity)

        solution_velocity%current_time    = 0.0_db
        scheme_data_velocity%current_time = 0.0_db
        if (no_time_steps == 0) then
            scheme_data_velocity%time_step = 0.0_db
        else
            scheme_data_velocity%time_step = final_local_time/real(no_time_steps, db)
        end if

        call set_current_time(solution_velocity, 0.0_db)

        no_dofs_velocity = get_no_dofs(solution_velocity)

        compute_ss_flag = .false.
    end if

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! SAVE THE INTEGRAL OVER THE DOMAIN !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if (compute_velocity) then ! <- velocity required because we need the basis.
        one_ivs        = calculate_integral_one(mesh_data, solution_velocity, .true.)
        one_everywhere = calculate_integral_one(mesh_data, solution_velocity, .false.)

        write(aptofem_run_number_string, '(i10)') aptofem_run_number
        one_file = '../../output/one-integral' // '_' // 'velocity-transport' // '_' // &
            trim(geometry_name) // '_' // trim(adjustl(aptofem_run_number_string)) // '.dat'
        open(23111995, file=one_file, status='replace')
        tsvFormat = '(*(G0.6,:,"'//achar(9)//'"))'
        write(23111995, tsvFormat) 'Time step', 'Integral one (IVS)', 'Integral one (everywhere)'
        write(23111995, tsvFormat) 0, one_ivs, one_everywhere
    end if

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! SAVE INTEGRAL VELOCITY MAGNITUDE !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if (compute_velocity) then
        vmi_ivs        = calculate_integral_velocity_magnitude(mesh_data, solution_velocity, .true.)
        vmi_everywhere = calculate_integral_velocity_magnitude(mesh_data, solution_velocity, .false.)

        write(aptofem_run_number_string, '(i10)') aptofem_run_number
        velocity_magnitude_file = '../../output/velocity-magnitude-integral' // '_' // 'velocity-transport' // '_' // &
            trim(geometry_name) // '_' // trim(adjustl(aptofem_run_number_string)) // '.dat'
        open(23111996, file=velocity_magnitude_file, status='replace')
        tsvFormat = '(*(G0.6,:,"'//achar(9)//'"))'
        write(23111996, tsvFormat) 'Time step', 'Integral velocity magnitude (IVS)', 'Integral velocity magnitude (everywhere)'
        write(23111996, tsvFormat) 0, vmi_ivs, vmi_everywhere  
    end if

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! SAVE THE SLOW VELOCITY INTEGRAL !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if (compute_velocity) then
        velocity_average_ivs        = vmi_ivs       /one_ivs
        velocity_average_everywhere = vmi_everywhere/one_everywhere

        svp_ivs                 = calculate_integral_slow_velocity(mesh_data, solution_velocity, .true.,  0.35_db, &
            velocity_average_ivs)
        svp_everywhere          = calculate_integral_slow_velocity(mesh_data, solution_velocity, .false., 0.35_db, &
            velocity_average_everywhere)
        svp_0_0005_everywhere   = calculate_integral_slow_velocity(mesh_data, solution_velocity, .false., 0.35_db, 0.0005_db)
        fvp_0_001_everywhere    = calculate_integral_fast_velocity(mesh_data, solution_velocity, .false., 0.35_db, 0.001_db)
        svp_nominal_ivs         = calculate_integral_slow_velocity(mesh_data, solution_velocity, .true.,  0.35_db, 0.0026_db)
        svp_nominal_everywhere  = calculate_integral_slow_velocity(mesh_data, solution_velocity, .false., 0.35_db, 0.0026_db)

        write(aptofem_run_number_string, '(i10)') aptofem_run_number
        slow_velocity_file = '../../output/slow-velocity-integral' // '_' // 'velocity-transport' // '_' // &
            trim(geometry_name) // '_' // trim(adjustl(aptofem_run_number_string)) // '.dat'
        open(23111994, file=slow_velocity_file, status='replace')
        tsvFormat = '(*(G0.6,:,"'//achar(9)//'"))'
        write(23111994, tsvFormat) 'Time step', 'Integral slow velocity (IVS)', 'Integral slow velocity (everywhere)', &
            'Integral slow velocity (everywhere, 0.0005)', 'Integral fast velocity (everywhere, 0.001)', &
            'Integral slow velocity (IVS, nominal)', 'Integral slow velocity (everywhere, nominal)'
        write(23111994, tsvFormat) 0, svp_ivs, svp_everywhere, svp_0_0005_everywhere, fvp_0_001_everywhere, svp_nominal_ivs, &
            svp_nominal_everywhere
    end if

    !!!!!!!!!!!!!!!!!
    !! SAVE FLUXES !!
    !!!!!!!!!!!!!!!!!
    if (compute_velocity .and. compute_transport) then
        write(aptofem_run_number_string, '(i10)') aptofem_run_number
        flux_file = '../../output/flux' // '_' // 'velocity-transport' // '_' // trim(geometry_name) // '_' // &
            trim(adjustl(aptofem_run_number_string)) // '.dat'
        open(23111997, file=flux_file, status='replace')
        tsvFormat = '(*(G0.6,:,"'//achar(9)//'"))'

        call setup_outflow_fluxes(293)
        call setup_outflow_transport_fluxes(293)
        call calculate_outflow_fluxes(mesh_data, solution_velocity)
        call calculate_outflow_transport_fluxes(mesh_data, solution_velocity, solution_transport)

        call write_to_file_headers(23111997, tsvFormat)
        call write_to_file        (23111997, tsvFormat, mesh_data, solution_velocity, solution_transport, 0, 0.0_db)

        call finalise_outflow_fluxes()
        call finalise_outflow_transport_fluxes()
    end if

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! TRANSPORT REACTION TERM INTEGRAL !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if (compute_transport) then
        write(aptofem_run_number_string, '(i10)') aptofem_run_number
        flux_file = '../../output/transport-reaction-integral' // '_' // 'velocity-transport' // '_' // trim(geometry_name) // &
            '_' // trim(adjustl(aptofem_run_number_string)) // '.dat'
        open(23111998, file=flux_file, status='replace')
        write(23111998, tsvFormat) 'Time step', 'Integral'
        write(23111998, tsvFormat) 0, calculate_integral_transport_reaction(mesh_data, solution_transport)
    end if

    !!!!!!!!!!!!!!!!!!!!!!!!!!
    !! SAVE SIMULATION DATA !!
    !!!!!!!!!!!!!!!!!!!!!!!!!!
    write(aptofem_run_number_string, '(i10)') aptofem_run_number
    data_file = '../../output/simulation-data' // '_' // 'velocity-transport' // '_' // &
        trim(adjustl(aptofem_run_number_string)) // '.dat'
    open(23111999, file=data_file, status='replace')
    tsvFormat = '(*(G0.6,:,"'//achar(9)//'"))'
    write(23111999, tsvFormat) 'Velocity DoFs', 'Transport DoFs', 'Newton residiual', 'Newton iterations', 'Number of elements'
    if (compute_velocity) then
        write(23111999, tsvFormat) no_dofs_velocity, no_dofs_transport, scheme_data_velocity%newton_norm_residual, -1, no_eles
    else
        write(23111999, tsvFormat) -1, -1, -1.0_db, -1, no_eles
    end if

    !!!!!!!!!!!!!!!!!!
    !! TIMESTEPPING !!
    !!!!!!!!!!!!!!!!!!
    do time_step_no = 1, no_time_steps
        current_time = current_time + time_step

        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ! SETUP FOR NEXT TRANSPORT TIMESTEP !
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        if (compute_transport) then
            scheme_data_transport%current_time = current_time

            call get_solution_vector              (scheme_data_transport%temp_real_array(1, :), no_dofs_transport, &
                solution_transport)
            call set_current_time                 (solution_transport, current_time)
            call project_dirichlet_boundary_values(solution_transport, mesh_data)
        end if

        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ! SAVE PREVIOUS VELOCITY MESH AND SOLUTION !
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ! if (moving_mesh) then
        if (.True.) then
            call setup_previous_velocity(mesh_data, solution_velocity)
        end if

        !!!!!!!!!!!!!
        ! MOVE MESH !
        !!!!!!!!!!!!!
        if (moving_mesh) then
            ! Plus dt since t has not yet been updated.
            ! TODO: Is this right?! ^^
            ! TODO: Make a copy of the mesh (or at least do something appropriate so you can store fe_basis_info_old).
            call move_mesh(mesh_data, problem_dim, current_time + time_step, time_step)
            call update_geometry(current_time + time_step, time_step, geometry_name)
        end if

        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ! OUTPUT PERMEABILITY FIELD !
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        if (compute_permeability) then
            call create_fe_solution(solution_permeability, mesh_data, 'fe_projection_permeability', aptofem_stored_keys, &
                anal_soln_transport, get_boundary_no_transport) ! Doesn't matter what dirichlet bc is passed.

#ifdef OPENMP        
!$OMP PARALLEL PRIVATE(thread_no)
            thread_no = omp_get_thread_num()
            if (thread_no == 0) then                
                call project_function_region_id(solution_permeability, mesh_data, project_permeability)
                call write_fe_data('output_mesh_solution_permeability', aptofem_stored_keys, time_step_no, mesh_data, &
                    solution_permeability)
            end if
!$OMP END PARALLEL
#elif MPI
            if (processor_no == 0) then
                call project_function_region_id(solution_permeability, mesh_data, project_permeability)
                call write_fe_data('output_mesh_solution_permeability', aptofem_stored_keys, time_step_no, mesh_data, &
                    solution_permeability)
            end if
#else
            call project_function_region_id(solution_permeability, mesh_data, project_permeability)
            call write_fe_data('output_mesh_solution_permeability', aptofem_stored_keys, time_step_no, mesh_data, &
                solution_permeability)
#endif                

            call delete_solution(solution_permeability)
        end if

        !!!!!!!!!!!!!!!!!!!!!!!
        ! OUTPUT UPTAKE FIELD !
        !!!!!!!!!!!!!!!!!!!!!!!
        if (compute_uptake) then
            call create_fe_solution(solution_uptake, mesh_data, 'fe_projection_uptake', aptofem_stored_keys, &
                anal_soln_transport, get_boundary_no_transport) ! Doesn't matter what dirichlet bc is passed.

#ifdef OPENMP
!$OMP PARALLEL PRIVATE(thread_no)
            thread_no = omp_get_thread_num()
            if (thread_no == 0) then
                call project_function_region_id(solution_uptake, mesh_data, project_uptake)
                call write_fe_data('output_mesh_solution_uptake', aptofem_stored_keys, time_step_no, mesh_data, &
                    solution_uptake)
            end if
!$OMP END PARALLEL
#elif MPI
            if (processor_no == 0) then
                call project_function_region_id(solution_uptake, mesh_data, project_uptake)
                call write_fe_data('output_mesh_solution_uptake', aptofem_stored_keys, time_step_no, mesh_data, &
                    solution_uptake)
            end if
#else
            call project_function_region_id(solution_uptake, mesh_data, project_uptake)
            call write_fe_data('output_mesh_solution_uptake', aptofem_stored_keys, time_step_no, mesh_data, solution_uptake)
#endif

            call delete_solution(solution_uptake)
        end if

        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ! ASSEMBLE AND SOLVE THIS TIMESTEP !
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        if (.not. velocity_ss .and. compute_velocity) then
            ! Set velocity amplitude.
            ! call Carson_velocity_amplitude(current_time)
            ! current_velocity_amplitude = 1.0_db

            ! Reset preconditioner to one specified in file.
            if (linear_solver == 'petsc') then
                call pop_petsc_options()
            end if

            !! TODO: Need to think about how we pass through fe_basis_info_old

            call dirk_single_time_step(solution_velocity, mesh_data, fe_solver_routines_velocity, 'solver_velocity', &
                aptofem_stored_keys, sp_matrix_rhs_data_velocity, scheme_data_velocity, dirk_scheme_velocity, &
                scheme_data_velocity%current_time, scheme_data_velocity%time_step, no_dofs_velocity, time_step_no, .false., &
                norm_diff_u)

            call set_current_time(solution_velocity, solution_velocity%current_time + &
                scheme_data_velocity%time_step)
        end if

        if (compute_transport) then
            ! FGMRES preconditioner for transport.
            if (linear_solver == 'petsc') then
                call set_petsc_options_fgmres()
            end if

            call linear_fe_solver(solution_transport, mesh_data, fe_solver_routines_transport, 'solver_transport', &
                aptofem_stored_keys, sp_matrix_rhs_data_transport, 3, scheme_data_transport)
            call linear_fe_solver(solution_transport, mesh_data, fe_solver_routines_transport, 'solver_transport', &
                aptofem_stored_keys, sp_matrix_rhs_data_transport, 4, scheme_data_transport)
        end if

        !!!!!!!!!!!!!!!!!
        ! SCREEN OUTPUT !
        !!!!!!!!!!!!!!!!!
        no_errors_velocity      = 0
        no_errors_transport = 0
        errors(1)           = 0.0_db
        errors_name(1)      = ''
        errors_format(1)    = ''

        if (.not. velocity_ss .and. compute_velocity) then
            call write_message(io_msg, '========================================================')
            call write_message(io_msg, '||                (velocity solution)                 ||')
            call write_data   ('output_data', aptofem_stored_keys, errors, no_errors_velocity, errors_name,&
                errors_format, mesh_data, solution_velocity)
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
        if (mod(time_step_no, output_frequency) == 0) then
            if (.not. velocity_ss .and. compute_velocity) then
                call write_fe_data('output_mesh_solution_velocity_2D', aptofem_stored_keys, time_step_no, mesh_data, &
                    solution_velocity)
                call write_solution_for_restart(solution_velocity, mesh_data, time_step_no, 'dg_velocity-transport_velocity_' &
                    // trim(geometry_name), '../../output/')
            end if
            if (compute_transport) then
                call write_fe_data('output_mesh_solution_transport_2D', aptofem_stored_keys, time_step_no, mesh_data, &
                    solution_transport)
                call write_solution_for_restart(solution_transport, mesh_data, time_step_no, 'dg_velocity-transport_transport_' &
                    // trim(geometry_name), '../../output/')
            end if
        end if

        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ! SAVE INTEGRAL VELOCITY MAGNITUDE !
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        if (compute_velocity) then
            write(23111996, tsvFormat) time_step_no, calculate_integral_velocity_magnitude(mesh_data, solution_velocity, .true.), &
                calculate_integral_velocity_magnitude(mesh_data, solution_velocity, .false.)
        end if

        !!!!!!!!!!!!!!!
        ! FLUX OUTPUT !
        !!!!!!!!!!!!!!!
        if (compute_transport .and. compute_velocity) then
            call setup_outflow_fluxes(293)
            call setup_outflow_transport_fluxes(293)
            call calculate_outflow_fluxes(mesh_data, solution_velocity)
            call calculate_outflow_transport_fluxes(mesh_data, solution_velocity, solution_transport)
            call write_to_file(23111997, tsvFormat, mesh_data, solution_velocity, solution_transport, time_step_no, &
                scheme_data_transport%current_time)
            call finalise_outflow_fluxes()
            call finalise_outflow_transport_fluxes()
        end if

        !!!!!!!!!!!!!!!!!!!!!
        ! REACTION INTEGRAL !
        !!!!!!!!!!!!!!!!!!!!!
        if (compute_transport) then
            write(23111998, tsvFormat) time_step_no, calculate_integral_transport_reaction(mesh_data, solution_transport)
        end if

        !!!!!!!!!!!!!!!!!!!
        ! SIMULATION DATA !
        !!!!!!!!!!!!!!!!!!!
        write(23111999, tsvFormat) no_dofs_velocity, no_dofs_transport, scheme_data_velocity%newton_norm_residual, -1, no_eles

        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ! CLEANUP PREVIOUS VELOCITY MESH AND SOLUTION !
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        if (moving_mesh) then
            call finalise_previous_velocity()
        end if
    end do

    !!!!!!!!!!!!!!
    !! CLEAN UP !!
    !!!!!!!!!!!!!!
    close(23111999)
    if (compute_velocity) then
        close(23111994)
        close(23111995)
        close(23111996)
    end if
    if (compute_velocity .and. compute_transport) then
        close(23111997)
    end if
    if (compute_transport) then
        close(23111998)
        call linear_fe_solver(solution_transport, mesh_data, fe_solver_routines_transport, 'solver_transport', &
            aptofem_stored_keys, sp_matrix_rhs_data_transport, 5, scheme_data_transport)
        call delete_solution   (solution_transport)
        if (no_time_steps > 0) then
            deallocate(scheme_data_transport%temp_real_array)
        end if
    end if
    if (compute_velocity) then
        call linear_fe_solver(solution_velocity,  mesh_data, fe_solver_routines_velocity,  'solver_velocity', &
            aptofem_stored_keys, sp_matrix_rhs_data_velocity,  5, scheme_data_velocity)
        call delete_solution   (solution_velocity)
    end if
    
    call delete_mesh       (mesh_data)
    call finalise_geometry (geometry_name)
    call finalise_user_data()
    call AptoFEM_finalize  (aptofem_stored_keys)
end program

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

subroutine write_to_file(file_no, tsvFormat, mesh_data, solution_velocity, solution_transport, timestep_no, current_time)
    use param
    use fe_mesh
    use fe_solution
    use crossflow_flux
    use outflow_flux
    use outflow_transport_flux

    integer, intent(in)        :: file_no
    character(len=100)         :: tsvFormat
    type(mesh), intent(inout)  :: mesh_data
    type(solution), intent(in) :: solution_velocity, solution_transport
    integer, intent(in)        :: timestep_no
    real(db), intent(in)       :: current_time

    write(file_no, tsvFormat) timestep_no, &
    current_time, &
    calculate_crossflow_flux(mesh_data, solution_velocity, 301, 302), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 302, 303), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 303, 304), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 304, 305), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 305, 306), &
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