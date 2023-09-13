module problem_options_geometry
    use aptofem_kernel
    use problem_options
    
    save
    
    real(db)                               :: placentone_width, wall_width, placenta_width, placenta_height, wall_height, &
    artery_width_sm, artery_length, ms_pipe_width, x_centre, y_centre, boundary_radius
    real(db), dimension(:), allocatable    :: placentone_widths, cumulative_placentone_widths
    real(db), dimension(:, :, :), allocatable :: vessel_tops
    real(db), dimension(:, :), allocatable    :: vessel_angles
    
    contains
    
    subroutine initialise_geometry(control_file, no_placentones)
        implicit none
        
        character(len=20), intent(in) :: control_file
        integer, intent(in)           :: no_placentones
        
        integer :: i, j, problem_dim, no_vessels
        
        placentone_width = 1.0_db                        ! 40 mm
        artery_width_sm = 0.0125_db*placentone_width     ! 0.5mm
        artery_length   = 0.25_db*placentone_width       ! 10mm
        if (trim(control_file) == 'placenta') then
            wall_width       = 0.075_db*placentone_width ! 3  mm
            placenta_width   = 5.5_db                    ! 220mm
            placenta_height  = 0.9065_db                 ! 36.26mm
            wall_height      = 0.6_db*placentone_width   ! 24 mm
            ms_pipe_width   = 0.075_db                   ! 3mm
            
            x_centre = placenta_width/2
            y_centre = (placenta_height - ms_pipe_width)/2.0_db + x_centre**2/(2.0_db*(placenta_height - ms_pipe_width))
            
            boundary_radius = y_centre
            
            ! Store placentone widths.
            allocate(placentone_widths(no_placentones))
            allocate(cumulative_placentone_widths(no_placentones))
            
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
            else
                print *, "Error: no_placentones not supported", no_placentones
                error stop
            end if
            
            cumulative_placentone_widths(1) = 0.0_db
            do i = 2, no_placentones
                cumulative_placentone_widths(i) = cumulative_placentone_widths(i-1) + placentone_widths(i-1) + wall_width
            end do
            
            ! Stores coordinates of the tops of arteries and veins.
            no_vessels = 3
            problem_dim = 2
            allocate(vessel_tops(no_placentones, no_vessels, problem_dim))
            allocate(vessel_angles(no_placentones, no_vessels))
            
            do i = 1, no_placentones
                do j = 1, no_vessels
                    vessel_tops(i, j, 1) = cumulative_placentone_widths(i) + vessel_locations(i, j)*placentone_widths(i)
                    vessel_tops(i, j, 2) = y_centre - (boundary_radius**2 - (vessel_tops(i, j, 1) - x_centre)**2)**0.5
                    vessel_angles(i, j) = -atan2((vessel_tops(i, j, 2)-y_centre), (vessel_tops(i, j, 1)-x_centre))
                end do
            end do
        else
            ! Stores coordinates of the tops of arteries and veins.
            no_vessels = 3
            problem_dim = 2
            allocate(vessel_tops(1, no_vessels, problem_dim))
            allocate(vessel_angles(1, no_vessels))
            
            do j = 1, no_vessels
                vessel_tops(1, j, 1) = vessel_locations(1, j)
                vessel_tops(1, j, 2) = 0.0_db
                vessel_angles(1, j)  = 0.0_db
            end do
        end if
    end subroutine
    
    subroutine finalise_geometry(control_file)
        implicit none
        
        character(len=20), intent(in) :: control_file
        
        if (trim(control_file) == 'placenta') then
            deallocate(placentone_widths, cumulative_placentone_widths, vessel_tops)
        end if
    end subroutine
    
    subroutine move_mesh(mesh_data, problem_dim, mesh_time, time_step)
        use param
        
        implicit none
        
        type(mesh), intent(inout) :: mesh_data
        integer, intent(in)       :: problem_dim
        real(db), intent(in)      :: mesh_time, time_step
        
        integer                          :: no_nodes, i
        real(db), dimension(problem_dim) :: mesh_velocity
        
        no_nodes = mesh_data%no_nodes
        
        do i = 1, no_nodes
            mesh_velocity = calculate_mesh_velocity(mesh_data%coords(:, i), problem_dim, mesh_time)
            
            mesh_data%coords(:, i) = mesh_data%coords(:, i) + mesh_velocity*time_step
        end do
    end subroutine
    
    function calculate_mesh_velocity(coord, problem_dim, mesh_time)
        use param
        
        implicit none
        
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: coord
        real(db), intent(in)                         :: mesh_time
        real(db), dimension(problem_dim)             :: calculate_mesh_velocity
        
        real(db) :: x, y
        
        x = coord(1) - x_centre
        y = coord(2) - placenta_height/2.0_db
        
        calculate_mesh_velocity(1) = x*cos(2.0_db*pi*mesh_time)
        calculate_mesh_velocity(2) = y*cos(2.0_db*pi*mesh_time)
        
    end function
    
    subroutine update_geometry(mesh_time, time_step)
        implicit none
        
        real(db), intent(in) :: mesh_time, time_step
        
        real(db), dimension(2) :: radius_velocity, coord
        
        coord(1) = x_centre
        coord(2) = boundary_radius - y_centre
        
        radius_velocity = calculate_mesh_velocity(coord, 2, mesh_time)
        
        print *, "boundary_radius OLD = ", boundary_radius
        
        boundary_radius = boundary_radius + radius_velocity(2)*time_step
        
        print *, "boundary_radius NEW = ", boundary_radius
    end subroutine
    
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
        centre(1) = vessel_locations(1, 2)
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
        
        real(db) :: radius
        real(db) :: translate_angle
        integer  :: i, placentone_no, vessel_no
        
        radius   = y_centre
        
        if (element_region_id == 401) then
            placentone_no = 1
            translate_angle = pi
        else if (element_region_id == 402) then
            placentone_no = 1
            translate_angle = 0.0_db
        else if (411 <= element_region_id .and. element_region_id <= 473) then
            placentone_no = (element_region_id-400)/10
            vessel_no     = mod(element_region_id-400, 10)
            translate_angle = vessel_angles(placentone_no, vessel_no)
            ! TODO: SEPTAL VEINS.
        else if (471 <= element_region_id .and. element_region_id <= 496) then
            placentone_no = 1
            translate_angle = 0.0_db
        else if (501 <= element_region_id .and. element_region_id <= 527) then
            placentone_no = mod(element_region_id-500, 10)
            vessel_no     = 2 ! Always on artery.
            translate_angle = vessel_angles(placentone_no, vessel_no)
        else
            print *, "Error in translate_placenta_to_placentone_point. Missed case."
            print *, "element_region_id = ", element_region_id
            stop
        end if
        
        translate_placenta_to_placentone_point(1) =   (placenta_point(1) - x_centre)*sin(translate_angle) &
        + (placenta_point(2) - y_centre)*cos(translate_angle) + vessel_locations(placentone_no, 2)
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