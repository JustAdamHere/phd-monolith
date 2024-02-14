module problem_options
    use aptofem_kernel

    save

    real(db)          :: interior_penalty_parameter, final_local_time, central_cavity_transition, pipe_transition, artery_width_sm,&
        wall_height_ratio
    integer           :: no_uniform_refinements_cavity, no_uniform_refinements_everywhere, no_uniform_refinements_inlet, &
        no_time_steps, output_frequency, no_placentones
    logical           :: velocity_ss, velocity_ic_from_ss, transport_ic_from_ss, compute_velocity, compute_transport, &
        compute_permeability, compute_uptake, compute_error_norms, moving_mesh, compute_ss_flag
    character(len=30) :: geometry_name, assembly_name, linear_solver, mesh_velocity_type

    real(db), dimension(:, :), allocatable :: vessel_locations
    real(db), dimension(:), allocatable    :: central_cavity_widths, central_cavity_heights

    contains
    subroutine get_user_data(section_name, aptofem_stored_keys)
        implicit none

        character(len=*), intent(in) :: section_name
        type(aptofem_keys), pointer  :: aptofem_stored_keys

        integer :: ierr, i
        character(len=1) :: temp_integer

        call get_aptofem_key_definition('interior_penalty_parameter',        interior_penalty_parameter,        section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('no_uniform_refinements_cavity',     no_uniform_refinements_cavity,     section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('no_uniform_refinements_inlet',      no_uniform_refinements_inlet,      section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('no_uniform_refinements_everywhere', no_uniform_refinements_everywhere, section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('velocity_ss',                       velocity_ss,                       section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('velocity_ic_from_ss',               velocity_ic_from_ss,               section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('compute_velocity',                  compute_velocity,                  section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('compute_transport',                 compute_transport,                 section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('compute_permeability',              compute_permeability,              section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('compute_uptake',                    compute_uptake,                    section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('compute_error_norms',               compute_error_norms,               section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('transport_ic_from_ss',              transport_ic_from_ss,              section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('dirk_final_time',                   final_local_time,                  'solver_velocity', &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('dirk_number_of_timesteps',          no_time_steps,                     'solver_velocity', &
            aptofem_stored_keys, ierr)
        ! call get_aptofem_key_definition('central_cavity_width',              central_cavity_width,              section_name, &
        !     aptofem_stored_keys, ierr)
        ! call get_aptofem_key_definition('central_cavity_height',             central_cavity_height,             section_name, &
        !     aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('central_cavity_transition',         central_cavity_transition,         section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('pipe_transition',                   pipe_transition,                   section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('artery_width_sm',                   artery_width_sm,                   section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('no_placentones',                    no_placentones,                    section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('moving_mesh',                       moving_mesh,                       section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('output_frequency',                  output_frequency,                  section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('wall_height_ratio',                 wall_height_ratio,                 section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('linear_solver',                     linear_solver,                     'solver_velocity', &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('mesh_velocity_type',                mesh_velocity_type,                section_name, &
            aptofem_stored_keys, ierr)

        if (.not. compute_velocity .and. compute_transport) then
            print *, "Error in get_user_data. compute_transport is true but compute_velocity is false. Stopping."
            error stop
        end if

        if (no_placentones /= 1 .and. no_placentones /= 6 .and. no_placentones /= 7) then
            print *, "Error in get_user_data. no_placentones must be 1 or 6 or 7. Stopping."
            error stop
        end if

        allocate(vessel_locations(7, 3))
        do i = 1, 7
            write(temp_integer, '(I1)') i

            call get_aptofem_key_definition('vein_location_'   // temp_integer // '1', vessel_locations(i, 1), section_name, &
                aptofem_stored_keys, ierr)
            call get_aptofem_key_definition('artery_location_' // temp_integer,        vessel_locations(i, 2), section_name, &
                aptofem_stored_keys, ierr)
            call get_aptofem_key_definition('vein_location_'   // temp_integer // '2', vessel_locations(i, 3), section_name, &
                aptofem_stored_keys, ierr)
        end do

        allocate(central_cavity_widths(7))
        allocate(central_cavity_heights(7))
        do i = 1, 7
            write(temp_integer, '(I1)') i

            call get_aptofem_key_definition('central_cavity_width_'  // temp_integer, central_cavity_widths(i),  section_name, &
                aptofem_stored_keys, ierr)
            call get_aptofem_key_definition('central_cavity_height_' // temp_integer, central_cavity_heights(i), section_name, &
                aptofem_stored_keys, ierr)
        end do

        !! TODO: Why is this here?
        compute_ss_flag = .true.
    end subroutine

    subroutine finalise_user_data()
        implicit none

        deallocate(vessel_locations, central_cavity_heights, central_cavity_widths)
    end subroutine

    function smooth_tanh_function(x, steepness, x0, x2)
        use param

        implicit none

        real(db)             :: smooth_tanh_function
        real(db), intent(in) :: x, steepness, x0, x2

        real(db) :: x1

        x1 = (x0 + x2)/2

        if (x <= x0) then
            smooth_tanh_function = 0.0_db
        else if (x0 < x .and. x < x2) then
            smooth_tanh_function = &
                (tanh(steepness*(x - x1)/(x2 - x1))/tanh(steepness) + 1)/2
        else if (x2 <= x) then
            smooth_tanh_function = 1.0_db
        else
            print *, "Error in smooth_tanh_function. Missed case. Stopping."
            print *, "x0 = ", x0
            print *, "x1 = ", x1
            print *, "x2 = ", x2
            print *, "x = ", x
            print *, "steepness = ", steepness
            stop 1
        end if
    end function

end module