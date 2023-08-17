module problem_options
    use aptofem_kernel

    save

    real(db) :: interior_penalty_parameter
    integer  :: no_uniform_refinements_cavity, no_uniform_refinements_everywhere, no_uniform_refinements_inlet
    logical  :: velocity_ss, velocity_ic_from_ss, transport_ic_from_ss, compute_transport
    real(db) :: final_local_time, artery_location, central_cavity_width, central_cavity_transition, pipe_transition
    integer  :: no_time_steps
    integer  :: no_placentones

    contains
    subroutine get_user_data(section_name, aptofem_stored_keys)
        implicit none

        character(len=*), intent(in) :: section_name
        type(aptofem_keys), pointer  :: aptofem_stored_keys

        integer :: ierr

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
        call get_aptofem_key_definition('transport_ic_from_ss',              transport_ic_from_ss,              section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('dirk_final_time',                   final_local_time,                  'solver_velocity', &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('dirk_number_of_timesteps',          no_time_steps,                     'solver_velocity', &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('compute_transport',                 compute_transport,                 section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('artery_location',                   artery_location,                   section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('central_cavity_width',              central_cavity_width,              section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('central_cavity_transition',         central_cavity_transition,         section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('pipe_transition',                   pipe_transition,                   section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('no_placentones',                    no_placentones,                    section_name, &
            aptofem_stored_keys, ierr)

        if (no_placentones /= 1 .and. no_placentones /= 6 .and. no_placentones /= 7) then
            print *, "Error in get_user_data. no_placentones must be 1 or 6 or 7. Stopping."
            stop 1
        end if
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

    function calculate_placentone_cavity_transition(global_point, problem_dim, element_region_id, steepness)
        use param

        implicit none

        real(db)                                     :: calculate_placentone_cavity_transition
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: element_region_id
        real(db), intent(in)                         :: steepness

        real(db)               :: x, y, r, r0, r1, r2, theta
        real(db)               :: a0, b0, a1, b1, a2, b2
        real(db), dimension(2) :: centre

        x = global_point(1)
        y = global_point(2)

        ! Centre of ellipse.
        centre(1) = artery_location
        centre(2) = 0.0_db

        ! Angle and radius from ellipse centre to point.
        theta = atan2(y - centre(2), x - centre(1))
        r     = sqrt((x - centre(1))**2 + (y - centre(2))**2)

        ! Semi-major and semi-minor axes for all 3 ellipses.
        a2 = (central_cavity_width + central_cavity_transition)/2
        b2 = a2*2

        a0 = a2 -   central_cavity_transition
        a1 = a2 -   central_cavity_transition/2
        b0 = b2 - 2*central_cavity_transition
        b1 = b2 - 2*central_cavity_transition/2

        ! Scaled "radius" for ellispe.
        r0 = a0*b0/sqrt(a0**2*sin(theta)**2 + b0**2*cos(theta)**2)
        r1 = a1*b1/sqrt(a1**2*sin(theta)**2 + b1**2*cos(theta)**2)
        r2 = a2*b2/sqrt(a2**2*sin(theta)**2 + b2**2*cos(theta)**2)

        ! Smooth tanh transition.
        calculate_placentone_cavity_transition = smooth_tanh_function(r, steepness, r0, r2)
    end function

    function calculate_placentone_pipe_transition(global_point, problem_dim, element_region_id, steepness)
        use param

        implicit none

        real(db)                                     :: calculate_placentone_pipe_transition
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: element_region_id
        real(db), intent(in)                         :: steepness

        real(db) :: y, y0, y2

        y = global_point(2)

        y2 = 0.0_db
        y0 = y2 - pipe_transition

        ! Smooth tanh transition.
        calculate_placentone_pipe_transition = smooth_tanh_function(y, steepness, y0, y2)
    end function

    function translate_placenta_to_placentone_point(problem_dim, placenta_point, element_region_id)
        use param

        implicit none

        real(db), dimension(problem_dim)             :: translate_placenta_to_placentone_point
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: placenta_point
        integer, intent(in)                          :: element_region_id

        real(db)               :: placentone_width, wall_width, placenta_width, pipe_width, wall_height
        real(db)               :: x_centre, y_centre, radius
        real(db), dimension(2) :: centre_top
        real(db)               :: translate_angle
        real(db), dimension(no_placentones) :: placentone_widths, cumulative_placentone_widths
        integer                :: i

        placentone_width = 1.0_db                            ! 40 mm
        wall_width       = 0.075_db*placentone_width         ! 3  mm
        !placenta_width   = 6*placentone_width + 5*wall_width ! 255mm
        placenta_width   = 5.5_db
        ! pipe_width       = 0.05_db*placentone_width          ! 2  mm
        ! wall_height      = 0.6_db*placentone_width           ! 24 mm

        x_centre = placenta_width/2
        ! y_centre = sqrt(2*x_centre**2)
        y_centre = 2.5_db*(2.0_db*x_centre**2)**0.5_db
        radius   = y_centre

        if (no_placentones == 6) then
            placentone_widths(1) = 0.716209_db
            placentone_widths(2) = 0.846291_db
            placentone_widths(3) = 1.000000_db
            placentone_widths(4) = 1.000000_db
            placentone_widths(5) = 0.846291_db
            placentone_widths(6) = 0.716209_db
        else if (no_placentones == 7) then
            placentone_widths(1) = 0.543255_db
            placentone_widths(2) = 0.665787_db
            placentone_widths(3) = 0.815958_db
            placentone_widths(4) = 1.000000_db
            placentone_widths(5) = 0.815958_db
            placentone_widths(6) = 0.665787_db
            placentone_widths(7) = 0.543255_db
        end if

        cumulative_placentone_widths(1) = 0.0_db
        do i = 2, no_placentones
            cumulative_placentone_widths(i) = cumulative_placentone_widths(i-1) + placentone_widths(i-1) + wall_width
        end do

        if (element_region_id == 401) then
            translate_angle = pi
        else if (element_region_id == 402) then
            translate_angle = 0.0_db
        else if (element_region_id == 411) then
            centre_top(1)   = cumulative_placentone_widths(1) + 0.2*placentone_widths(1)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 412) then
            centre_top(1)   = cumulative_placentone_widths(1) + 0.5*placentone_widths(1)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 413) then
            centre_top(1)   = cumulative_placentone_widths(1) + 0.8*placentone_widths(1)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 421) then
            centre_top(1)   = cumulative_placentone_widths(2) + 0.2*placentone_widths(2)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 422) then
            centre_top(1)   = cumulative_placentone_widths(2) + 0.5*placentone_widths(2)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 423) then
            centre_top(1)   = cumulative_placentone_widths(2) + 0.8*placentone_widths(2)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 431) then
            centre_top(1)   = cumulative_placentone_widths(3) + 0.2*placentone_widths(3)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 432) then
            centre_top(1)   = cumulative_placentone_widths(3) + 0.5*placentone_widths(3)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 433) then
            centre_top(1)   = cumulative_placentone_widths(3) + 0.8*placentone_widths(3)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 441) then
            centre_top(1)   = cumulative_placentone_widths(4) + 0.2*placentone_widths(4)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle =     - atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 442) then
            centre_top(1)   = cumulative_placentone_widths(4) + 0.5*placentone_widths(4)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle =     - atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 443) then
            centre_top(1)   = cumulative_placentone_widths(4) + 0.8*placentone_widths(4)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle =     - atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 451) then
            centre_top(1)   = cumulative_placentone_widths(5) + 0.2*placentone_widths(5)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle =     - atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 452) then
            centre_top(1)   = cumulative_placentone_widths(5) + 0.5*placentone_widths(5)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle =     - atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 453) then
            centre_top(1)   = cumulative_placentone_widths(5) + 0.8*placentone_widths(5)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle =     - atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 461) then
            centre_top(1)   = cumulative_placentone_widths(6) + 0.2*placentone_widths(6)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle =     - atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 462) then
            centre_top(1)   = cumulative_placentone_widths(6) + 0.5*placentone_widths(6)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle =     - atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 463) then
            centre_top(1)   = cumulative_placentone_widths(6) + 0.8*placentone_widths(6)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle =     - atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 471) then
            centre_top(1)   = cumulative_placentone_widths(7) + 0.2*placentone_widths(7)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle =     - atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 472) then
            centre_top(1)   = cumulative_placentone_widths(7) + 0.5*placentone_widths(7)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle =     - atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 473) then
            centre_top(1)   = cumulative_placentone_widths(7) + 0.8*placentone_widths(7)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle =     - atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 471) then
            centre_top = 0.0_db
            translate_angle = 0.0_db
        else if (element_region_id == 472) then
            centre_top = 0.0_db
            translate_angle = 0.0_db
        else if (element_region_id == 473) then
            centre_top = 0.0_db
            translate_angle = 0.0_db
        else if (element_region_id == 474) then
            centre_top = 0.0_db
            translate_angle = 0.0_db
        else if (element_region_id == 475) then
            centre_top = 0.0_db
            translate_angle = 0.0_db
        else if (element_region_id == 476) then
            centre_top = 0.0_db
            translate_angle = 0.0_db
        else if (element_region_id == 481) then
            centre_top = 0.0_db
            translate_angle = 0.0_db
        else if (element_region_id == 482) then
            centre_top = 0.0_db
            translate_angle = 0.0_db
        else if (element_region_id == 483) then
            centre_top = 0.0_db
            translate_angle = 0.0_db
        else if (element_region_id == 484) then
            centre_top = 0.0_db
            translate_angle = 0.0_db
        else if (element_region_id == 485) then
            centre_top = 0.0_db
            translate_angle = 0.0_db
        else if (element_region_id == 486) then
            centre_top = 0.0_db
            translate_angle = 0.0_db
        else if (element_region_id == 491) then
            centre_top = 0.0_db
            translate_angle = 0.0_db
        else if (element_region_id == 492) then
            centre_top = 0.0_db
            translate_angle = 0.0_db
        else if (element_region_id == 493) then
            centre_top = 0.0_db
            translate_angle = 0.0_db
        else if (element_region_id == 494) then
            centre_top = 0.0_db
            translate_angle = 0.0_db
        else if (element_region_id == 495) then
            centre_top = 0.0_db
            translate_angle = 0.0_db
        else if (element_region_id == 496) then
            centre_top = 0.0_db
            translate_angle = 0.0_db
        else if (element_region_id == 501 .or. element_region_id == 511 .or. element_region_id == 521) then
            centre_top(1)   = cumulative_placentone_widths(1) + artery_location*placentone_widths(1)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 502 .or. element_region_id == 512 .or. element_region_id == 522) then
            centre_top(1)   = cumulative_placentone_widths(2) + artery_location*placentone_widths(2)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 503 .or. element_region_id == 513 .or. element_region_id == 523) then
            centre_top(1)   = cumulative_placentone_widths(3) + artery_location*placentone_widths(3)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 504 .or. element_region_id == 514 .or. element_region_id == 524) then
            centre_top(1)   = cumulative_placentone_widths(4) + artery_location*placentone_widths(4)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 505 .or. element_region_id == 515 .or. element_region_id == 525) then
            centre_top(1)   = cumulative_placentone_widths(5) + artery_location*placentone_widths(5)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 506 .or. element_region_id == 516 .or. element_region_id == 526) then
            centre_top(1)   = cumulative_placentone_widths(6) + artery_location*placentone_widths(6)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else if (element_region_id == 507 .or. element_region_id == 517 .or. element_region_id == 527) then
            centre_top(1)   = cumulative_placentone_widths(7) + artery_location*placentone_widths(7)
            centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
            translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
        else
            print *, "Error in translate_placenta_to_placentone_point. Missed case."
            print *, "element_region_id = ", element_region_id
            stop
        end if

        translate_placenta_to_placentone_point(1) =   (placenta_point(1) - x_centre)*sin(translate_angle) &
            + (placenta_point(2) - y_centre)*cos(translate_angle) + artery_location
        translate_placenta_to_placentone_point(2) = - (placenta_point(1) - x_centre)*cos(translate_angle) &
            + (placenta_point(2) - y_centre)*sin(translate_angle) + y_centre
    end function

    function translate_placentone_3d_to_placentone_point(problem_dim, placenta_point, element_region_id)
        use param

        implicit none

        real(db), dimension(2)                       :: translate_placentone_3d_to_placentone_point
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: placenta_point
        integer, intent(in)                          :: element_region_id

        real(db) :: x, y, z
        real(db) :: r

        x = placenta_point(1)
        y = placenta_point(2)
        z = placenta_point(3)

        r = sqrt((x-0.5_db)**2 + z**2)

        translate_placentone_3d_to_placentone_point(1) = r + 0.5_db
        translate_placentone_3d_to_placentone_point(2) = y
    end function

end module