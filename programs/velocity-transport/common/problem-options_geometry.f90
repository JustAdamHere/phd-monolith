module problem_options_geometry
    use aptofem_kernel
    use problem_options
    
    save
    
    type(solution)                         :: solution_moving_mesh
    real(db)                               :: placentone_width, wall_width, placenta_width, placenta_height, &
        artery_length, ms_pipe_width, x_centre, y_centre, boundary_radius, inflation_ratio
    real(db), dimension(:), allocatable    :: placentone_widths, cumulative_placentone_widths, central_cavity_ratios, wall_angles, &
        wall_heights, placenta_bottom, placenta_top, move_mesh_centre
    real(db), dimension(:, :, :), allocatable :: vessel_tops, cavity_tops, cavity_sides, placentone_sides, wall_tops, artery_sides
    real(db), dimension(:, :), allocatable    :: vessel_angles, left_marginal_sinus_tops, right_marginal_sinus_tops
    !real(db), dimension(:), allocatable       :: central_cavity_widths, central_cavity_heights

    abstract interface
        function if_calculate_mesh_velocity(coord, problem_dim, mesh_time)
            use param
            implicit none
            
            integer, intent(in)                          :: problem_dim
            real(db), dimension(problem_dim), intent(in) :: coord
            real(db), intent(in)                         :: mesh_time
            real(db), dimension(problem_dim)             :: if_calculate_mesh_velocity
        end function
    end interface

    procedure(if_calculate_mesh_velocity), pointer :: calculate_mesh_velocity => null()
    
    contains

    subroutine initialise_simple_geometry(mesh_data, aptofem_stored_keys)
        implicit none

        type(mesh), intent(inout)   :: mesh_data
        type(aptofem_keys), pointer :: aptofem_stored_keys

        integer :: problem_dim

        problem_dim = mesh_data%problem_dim
        allocate (move_mesh_centre(problem_dim))
        move_mesh_centre = 0.5_db

        if (trim(mesh_velocity_type) == 'zero') then
            calculate_mesh_velocity => calculate_mesh_velocity_zero
        else if (trim(mesh_velocity_type) == 'interior') then
            calculate_mesh_velocity => calculate_mesh_velocity_interior
        else if (trim(mesh_velocity_type) == 'interior_ti') then
            calculate_mesh_velocity => calculate_mesh_velocity_interior_ti
        else if (trim(mesh_velocity_type) == 'shear') then
            calculate_mesh_velocity => calculate_mesh_velocity_shear
        else if (trim(mesh_velocity_type) == 'constant_up') then
            calculate_mesh_velocity => calculate_mesh_velocity_constant_up
        else if (trim(mesh_velocity_type) == 'circular') then
            calculate_mesh_velocity => calculate_mesh_velocity_circular
        else if (trim(mesh_velocity_type) == 'incompressible') then
            calculate_mesh_velocity => calculate_mesh_velocity_incompressible
        else if (trim(mesh_velocity_type) == 'incompressible2') then
            calculate_mesh_velocity => calculate_mesh_velocity_incompressible2
        else if (trim(mesh_velocity_type) == 'oscillating_sine') then
            calculate_mesh_velocity => calculate_mesh_velocity_oscillating_sine
        else
            print *, "Error: mesh_velocity_type not supported: ", trim(mesh_velocity_type)
            error stop
        end if

        call create_fe_solution(solution_moving_mesh, mesh_data, 'fe_projection_moving_mesh', aptofem_stored_keys, &
            anal_soln_moving_mesh, get_boundary_no_moving_mesh)
    end subroutine

    subroutine initialise_geometry(control_file, mesh_data, aptofem_stored_keys)
        use aptofem_kernel

        implicit none
        
        character(len=20), intent(in) :: control_file
        type(mesh), intent(inout)     :: mesh_data
        type(aptofem_keys), pointer   :: aptofem_stored_keys
        
        integer  :: i, j, problem_dim, no_vessels
        real(db) :: x, y, r

        calculate_mesh_velocity => calculate_mesh_velocity_oscillating_sine

        call create_fe_solution(solution_moving_mesh, mesh_data, 'fe_projection_moving_mesh', aptofem_stored_keys, &
            anal_soln_moving_mesh, get_boundary_no_moving_mesh)
        
        ! TODO: THIS NEEDS TO CHANGE BASED ON USER INPUT.
        placentone_width = 1.0_db                        ! 40 mm
        artery_length    = 0.25_db*placentone_width      ! 10mm
        problem_dim      = 2
        if (trim(control_file) == 'placenta') then
            !!!!!!!!!!!!!!!!!!!!!!!!!
            !! PLACENTA PARAMETERS !!
            !!!!!!!!!!!!!!!!!!!!!!!!!
            wall_width       = 0.075_db*placentone_width ! 3  mm
            placenta_width   = 5.5_db                    ! 220mm
            placenta_height  = 0.9065_db                 ! 36.26mm
            ms_pipe_width    = 0.075_db                  ! 3mm
            
            x_centre = placenta_width/2
            y_centre = (placenta_height - ms_pipe_width)/2.0_db + x_centre**2/(2.0_db*(placenta_height - ms_pipe_width))
            
            boundary_radius = y_centre

            allocate(placenta_bottom(problem_dim))
            placenta_bottom(1) = placenta_width/2.0_db
            placenta_bottom(2) = 0.0_db

            allocate(placenta_top(problem_dim))
            placenta_top(1) = placenta_width/2.0_db
            placenta_top(2) = placenta_height

            allocate(move_mesh_centre(problem_dim))
            move_mesh_centre(1) = x_centre
            move_mesh_centre(2) = placenta_height/2.0_db

            allocate(left_marginal_sinus_tops (2, problem_dim))            
            left_marginal_sinus_tops(1, 1) = -ms_pipe_width
            left_marginal_sinus_tops(1, 2) = placenta_height
            left_marginal_sinus_tops(2, 1) = 0.0_db
            left_marginal_sinus_tops(2, 2) = placenta_height

            allocate(right_marginal_sinus_tops(2, problem_dim))
            right_marginal_sinus_tops(1, 1) = placenta_width
            right_marginal_sinus_tops(1, 2) = placenta_height
            right_marginal_sinus_tops(2, 1) = placenta_width + ms_pipe_width
            right_marginal_sinus_tops(2, 2) = placenta_height
            
            !!!!!!!!!!!!!!!!!!!!!!!
            !! PLACENTONE WIDTHS !!
            !!!!!!!!!!!!!!!!!!!!!!!
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

            !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            !! PLACENTONE SIDES FOR MEASURING PLACENTONE WIDTHS !!
            !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            allocate(placentone_sides(no_placentones, 2, problem_dim))
            do i = 1, no_placentones
                placentone_sides(i, 1, 1) = cumulative_placentone_widths(i)
                placentone_sides(i, 1, 2) = y_centre - sqrt((boundary_radius**2 - (placentone_sides(i, 1, 1) - x_centre)**2))
                placentone_sides(i, 2, 1) = cumulative_placentone_widths(i) + placentone_widths(i)
                placentone_sides(i, 2, 2) = y_centre - sqrt((boundary_radius**2 - (placentone_sides(i, 2, 1) - x_centre)**2))
            end do

            !!!!!!!!!!!!!!!!!
            !! WALL ANGLES !!
            !!!!!!!!!!!!!!!!!
            allocate(wall_angles(no_placentones-1))
            do i = 1, no_placentones-1
                x = cumulative_placentone_widths(i) + placentone_widths(i) + wall_width/2.0_db
                y = y_centre - sqrt((boundary_radius**2 - (x - x_centre)**2))
                wall_angles(i) = -atan2(y - y_centre, x - x_centre)
            end do

            !!!!!!!!!!!!!!!!!!
            !! WALL HEIGHTS !!
            !!!!!!!!!!!!!!!!!!
            allocate(wall_heights(no_placentones-1))
            
            if (no_placentones == 6) then
                wall_heights(1) = 0.1725_db  * wall_height_ratio
                wall_heights(2) = 0.35175_db * wall_height_ratio
                wall_heights(3) = 0.1725_db  * wall_height_ratio
                wall_heights(4) = 0.35175_db * wall_height_ratio
                wall_heights(5) = 0.1725_db  * wall_height_ratio
            else if (no_placentones == 7) then
                wall_heights(1) = 0.1725_db * wall_height_ratio
                wall_heights(2) = 0.1725_db * wall_height_ratio
                wall_heights(3) = 0.1725_db * wall_height_ratio
                wall_heights(4) = 0.1725_db * wall_height_ratio
                wall_heights(5) = 0.1725_db * wall_height_ratio
                wall_heights(6) = 0.1725_db * wall_height_ratio
            else
                print *, "Error: no_placentones not supported", no_placentones
                error stop
            end if

            allocate(wall_tops(no_placentones-1, 2, problem_dim))
            do i = 1, no_placentones-1
                wall_tops(i, 1, 1) = placentone_sides(i,   2, 1) + wall_heights(i)*sin(wall_angles(i))
                wall_tops(i, 1, 2) = placentone_sides(i,   2, 2) - wall_heights(i)*cos(wall_angles(i))
                wall_tops(i, 2, 1) = placentone_sides(i+1, 1, 1) - wall_heights(i)*sin(wall_angles(i))
                wall_tops(i, 2, 2) = placentone_sides(i+1, 1, 2) + wall_heights(i)*cos(wall_angles(i))
            end do
            
            !!!!!!!!!!!!!!!!!!!!!!!!!!!!
            !! VESSEL TOPS AND ANGLES !!
            !!!!!!!!!!!!!!!!!!!!!!!!!!!!
            no_vessels = 3
            allocate(vessel_tops(no_placentones, no_vessels, problem_dim))
            allocate(vessel_angles(no_placentones, no_vessels))
            
            do i = 1, no_placentones
                do j = 1, no_vessels
                    vessel_tops(i, j, 1) = cumulative_placentone_widths(i) + vessel_locations(i, j)*placentone_widths(i)
                    vessel_tops(i, j, 2) = y_centre - (boundary_radius**2 - (vessel_tops(i, j, 1) - x_centre)**2)**0.5
                    vessel_angles(i, j) = -atan2((vessel_tops(i, j, 2)-y_centre), (vessel_tops(i, j, 1)-x_centre))
                end do
            end do

            !!!!!!!!!!!!!!!!!!
            !! ARTERY SIDES !!
            !!!!!!!!!!!!!!!!!!
            allocate(artery_sides(no_placentones, 2, 2))
            do i = 1, no_placentones
                r = boundary_radius + artery_length

                artery_sides(i, 1, 1) = x_centre + r*cos(vessel_angles(i, 2) - artery_width_sm/r)
                artery_sides(i, 1, 2) = y_centre - (r**2 - (artery_sides(i, 1, 1) - x_centre)**2)**0.5

                artery_sides(i, 2, 1) = x_centre + r*cos(vessel_angles(i, 2) + artery_width_sm/r)
                artery_sides(i, 2, 2) = y_centre - (r**2 - (artery_sides(i, 2, 1) - x_centre)**2)**0.5
            end do

            ! Recalculated here to help with the boundary conditions being consistent between timesteps.
            artery_width_sm = sqrt((artery_sides(1, 1, 1) - artery_sides(1, 2, 1))**2 + &
                (artery_sides(1, 1, 2) - artery_sides(1, 2, 2))**2)/2.0_db

            x = (artery_sides(1, 1, 1) + artery_sides(1, 2, 1))/2.0_db
            y = (artery_sides(1, 1, 2) + artery_sides(1, 2, 2))/2.0_db
            artery_length = sqrt((x - vessel_tops(1, 2, 1))**2 + (y - vessel_tops(1, 2, 2))**2)

        else if (trim(control_file) == 'placentone') then
            !!!!!!!!!!!!!!!!!!!!!!!!!!!
            !! PLACENTONE PARAMETERS !!
            !!!!!!!!!!!!!!!!!!!!!!!!!!!
            allocate(move_mesh_centre(problem_dim))
            move_mesh_centre = 0.5_db

            allocate(placentone_sides(1, 2, problem_dim))
            placentone_sides(1, 1, 1) = 0.0_db
            placentone_sides(1, 1, 2) = 0.0_db

            placentone_sides(1, 2, 1) = 1.0_db
            placentone_sides(1, 2, 2) = 0.0_db

            allocate(placentone_widths(1))
            placentone_widths(1) = 1.0_db

            allocate(cumulative_placentone_widths(1))
            cumulative_placentone_widths(1) = 0.0_db

            !!!!!!!!!!!!!!!!!!!!!!!!!!!!
            !! VESSEL TOPS AND ANGLES !!
            !!!!!!!!!!!!!!!!!!!!!!!!!!!!
            no_vessels = 3
            allocate(vessel_tops(1, no_vessels, problem_dim))
            allocate(vessel_angles(1, no_vessels))

            do j = 1, no_vessels
                vessel_tops(1, j, 1) = vessel_locations(1, j)
                vessel_tops(1, j, 2) = 0.0_db
                vessel_angles(1, j)  = 0.0_db
            end do

            !!!!!!!!!!!!!!!!!!!
            !! ARTERTY SIDES !!
            !!!!!!!!!!!!!!!!!!!
            allocate(artery_sides(1, 2, problem_dim))
            artery_sides(1, 1, 1) = vessel_locations(1, 2) - artery_width_sm/2.0_db
            artery_sides(1, 1, 2) = -artery_length

            artery_sides(1, 2, 1) = vessel_locations(1, 2) + artery_width_sm/2.0_db
            artery_sides(1, 2, 2) = -artery_length

            !!!!!!!!!!!!!!!!!!!!!!!!!!
            !! CAVITY LENGTH RATIOS !!
            !!!!!!!!!!!!!!!!!!!!!!!!!!
            allocate(central_cavity_ratios(1))
            central_cavity_ratios(1) = central_cavity_heights(1)/central_cavity_widths(1)

            !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            !! CAVITY TRANSITION POINTS !!
            !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            !  cavity_tops(1, 1, :) = lower cavity top
            !  cavity_tops(1, 2, :) = middle cavity top
            !  cavity_tops(1, 3, :) = upper cavity top
            allocate(cavity_tops(1, 3, problem_dim))
            cavity_tops(1, 1, 1) = vessel_tops(1, 2, 1) - &
                (central_cavity_heights(1)/2 - central_cavity_transition*central_cavity_ratios(1)/2)
            cavity_tops(1, 1, 2) = vessel_tops(1, 2, 2) + &
                (central_cavity_heights(1)/2 - central_cavity_transition*central_cavity_ratios(1)/2)
            cavity_tops(1, 2, 1) = vessel_tops(1, 2, 1) - &
                (central_cavity_heights(1)/2                                                       )
            cavity_tops(1, 2, 2) = vessel_tops(1, 2, 2) + &
                (central_cavity_heights(1)/2                                                       )
            cavity_tops(1, 3, 1) = vessel_tops(1, 2, 1) - &
                (central_cavity_heights(1)/2 + central_cavity_transition*central_cavity_ratios(1)/2)
            cavity_tops(1, 3, 2) = vessel_tops(1, 2, 2) + &
                (central_cavity_heights(1)/2 + central_cavity_transition*central_cavity_ratios(1)/2)

            !  cavity_sides(1, 1, :) = closest cavity side
            !  cavity_sides(1, 2, :) = middle cavity side
            !  cavity_sides(1, 3, :) = furthest cavity side
            allocate(cavity_sides(1, 3, problem_dim))
            cavity_sides(1, 1, 1) = x_centre + &
                (central_cavity_widths(1) - central_cavity_transition)/2
            cavity_sides(1, 1, 2) = y_centre + &
                (central_cavity_widths(1) - central_cavity_transition)/2
            cavity_sides(1, 2, 1) = x_centre + &
                (central_cavity_widths(1)                            )/2
            cavity_sides(1, 2, 2) = y_centre + &
                (central_cavity_widths(1)                            )/2
            cavity_sides(1, 3, 1) = x_centre + &
                (central_cavity_widths(1) + central_cavity_transition)/2
            cavity_sides(1, 3, 2) = y_centre + &
                (central_cavity_widths(1) + central_cavity_transition)/2
        else
            call write_message(io_err, "Geometry not supported: " // control_file)
            error stop
        end if

        !!!!!!!!!!!!!!!!!!!!!!!!!!
        !! CAVITY LENGTH RATIOS !!
        !!!!!!!!!!!!!!!!!!!!!!!!!!
        allocate(central_cavity_ratios(no_placentones))
        do i = 1, no_placentones
            central_cavity_ratios(i) = central_cavity_heights(i)/central_cavity_widths(i)
        end do

        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        !! CAVITY TRANSITION POINTS !!
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        !  cavity_tops(:, 1, :) = lower cavity top
        !  cavity_tops(:, 2, :) = middle cavity top
        !  cavity_tops(:, 3, :) = upper cavity top
        allocate(cavity_tops(no_placentones, 3, problem_dim))
        do i = 1, no_placentones
            cavity_tops(i, 1, 1) = vessel_tops(i, 1, 1) - &
                (central_cavity_heights(i)/2 - central_cavity_transition*central_cavity_ratios(i)/2)*cos(vessel_angles(i, 2))
            cavity_tops(i, 1, 2) = vessel_tops(i, 1, 2) + &
                (central_cavity_heights(i)/2 - central_cavity_transition*central_cavity_ratios(i)/2)*sin(vessel_angles(i, 2))
            cavity_tops(i, 2, 1) = vessel_tops(i, 2, 1) - &
                (central_cavity_heights(i)/2                                                       )*cos(vessel_angles(i, 2))
            cavity_tops(i, 2, 2) = vessel_tops(i, 2, 2) + &
                (central_cavity_heights(i)/2                                                       )*sin(vessel_angles(i, 2))
            cavity_tops(i, 3, 1) = vessel_tops(i, 3, 1) - &
                (central_cavity_heights(i)/2 + central_cavity_transition*central_cavity_ratios(i)/2)*cos(vessel_angles(i, 2))
            cavity_tops(i, 3, 2) = vessel_tops(i, 3, 2) + &
                (central_cavity_heights(i)/2 + central_cavity_transition*central_cavity_ratios(i)/2)*sin(vessel_angles(i, 2))
        end do

        !  cavity_sides(:, 1, :) = closest cavity side
        !  cavity_sides(:, 2, :) = middle cavity side
        !  cavity_sides(:, 3, :) = furthest cavity side
        allocate(cavity_sides(no_placentones, 3, problem_dim))
        do i = 1, no_placentones
            cavity_sides(i, 1, 1) = x_centre + boundary_radius* &
                cos(vessel_angles(i, 2) + ((central_cavity_widths(i) - central_cavity_transition)/2)/boundary_radius)
            cavity_sides(i, 1, 2) = y_centre - boundary_radius* &
                sin(vessel_angles(i, 2) + ((central_cavity_widths(i) - central_cavity_transition)/2)/boundary_radius)
            cavity_sides(i, 2, 1) = x_centre + boundary_radius* &
                cos(vessel_angles(i, 2) + ((central_cavity_widths(i)                            )/2)/boundary_radius)
            cavity_sides(i, 2, 2) = y_centre - boundary_radius* &
                sin(vessel_angles(i, 2) + ((central_cavity_widths(i)                            )/2)/boundary_radius)
            cavity_sides(i, 3, 1) = x_centre + boundary_radius* &
                cos(vessel_angles(i, 2) + ((central_cavity_widths(i) + central_cavity_transition)/2)/boundary_radius)
            cavity_sides(i, 3, 2) = y_centre - boundary_radius* &
                sin(vessel_angles(i, 2) + ((central_cavity_widths(i) + central_cavity_transition)/2)/boundary_radius)
        end do

        ! Recalculated here to help with the boundary conditions being consistent between timesteps.
        do i = 1, no_placentones
            central_cavity_heights(i) = 2*sqrt( &
                (cavity_tops(i, 2, 1) - vessel_tops(i, 2, 1))**2 + (cavity_tops(i, 2, 2) - vessel_tops(i, 2, 2))**2 &
            )
            central_cavity_widths(i) = 2*sqrt( &
                (cavity_sides(i, 2, 1) - vessel_tops(i, 2, 1))**2 + (cavity_sides(i, 2, 2) - vessel_tops(i, 2, 2))**2 &
            )
            central_cavity_ratios(i) = central_cavity_heights(i)/central_cavity_widths(i)
        end do
        central_cavity_transition = sqrt((cavity_sides(4, 3, 1) - cavity_sides(4, 1, 1))**2 + &
            (cavity_sides(4, 3, 2) - cavity_sides(4, 1, 2))**2)

        if (processor_no == 0) then
            print *, "INITIALISING..."
            print *, "CAVITY HEIGHT: ", central_cavity_heights(4)
            print *, "CAVITY WIDTH:  ", central_cavity_widths(4)
            print *, "CAVITY RATIO: ", central_cavity_ratios(4)
            print *, "CAVITY TRANSITION: ", central_cavity_transition
            print *, "CAVITY TOP: ", cavity_tops(4, 2, :)
            print *, "VESSEL TOP: ", vessel_tops(4, 2, :)
            print *, "ARTERY WIDTH SM: ", artery_width_sm
            print *, "ARTERY LENGTH: ", artery_length
            print *, "BOUNDARY RADIUS: ", boundary_radius
            print *, "X_CENTRE: ", x_centre
            print *, "Y_CENTRE: ", y_centre
            print *, "PLACENTONE WIDTH: ", placentone_widths(4)
        end if
    end subroutine

    subroutine finalise_simple_geometry()
        deallocate(move_mesh_centre)
        call delete_solution(solution_moving_mesh)
    end subroutine
    
    subroutine finalise_geometry(control_file)
        implicit none
        
        character(len=20), intent(in) :: control_file
        
        if (trim(control_file) == 'placenta') then
            deallocate(wall_angles, wall_heights, &
                placenta_bottom, placenta_top, wall_tops, left_marginal_sinus_tops, right_marginal_sinus_tops)
        end if
        deallocate(vessel_tops, vessel_angles, cavity_tops, cavity_sides, central_cavity_ratios, move_mesh_centre, &
            placentone_sides, placentone_widths, cumulative_placentone_widths, artery_sides)

        call delete_solution(solution_moving_mesh)
    end subroutine
    
    subroutine move_mesh(mesh_data, mesh_data_orig, problem_dim, mesh_time, time_step)
        use param
        
        implicit none
        
        type(mesh), intent(inout) :: mesh_data, mesh_data_orig
        integer, intent(in)       :: problem_dim
        real(db), intent(in)      :: mesh_time, time_step
        
        integer                          :: no_nodes, i, element_number
        real(db), dimension(problem_dim) :: mesh_velocity
        type(linkedlistint), pointer     :: element
        
        no_nodes = mesh_data%no_nodes

        call project_function(solution_moving_mesh, mesh_data_orig, project_mesh_velocity)
        
        do i = 1, no_nodes
            ! mesh_velocity = calculate_mesh_velocity(mesh_data%coords(:, i), problem_dim, mesh_time)
            element => mesh_data%node_eles(i)
            element_number = element%value ! Doesn't matter which element we choose, as the solution is continuous.
            call compute_uh_glob_pt(mesh_velocity, problem_dim, element_number, mesh_data%coords(:, i), problem_dim, &
                mesh_data_orig, solution_moving_mesh)
            
            mesh_data%coords(:, i) = mesh_data%coords(:, i) + mesh_velocity*time_step
        end do
    end subroutine

    subroutine anal_soln_moving_mesh(u, global_point, problem_dim, no_vars, boundary_no, t)
        use param
    
        implicit none
    
        real(db), dimension(no_vars), intent(out)    :: u
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: problem_dim
        integer, intent(in)                          :: no_vars
        integer, intent(in)                          :: boundary_no
        real(db), intent(in)                         :: t

        u = calculate_mesh_velocity(global_point, problem_dim, t)

    end subroutine

    subroutine get_boundary_no_moving_mesh(boundary_no, strongly_enforced_bcs, global_point, face_coords, no_face_vert, &
            problem_dim, mesh_data)
        use param
        use fe_mesh

        implicit none

        integer, intent(inout)                                     :: boundary_no
        character(len=nvmax), intent(out)                          :: strongly_enforced_bcs
        real(db), dimension(problem_dim), intent(in)               :: global_point
        real(db), dimension(no_face_vert, problem_dim), intent(in) :: face_coords
        integer, intent(in)                                        :: no_face_vert
        integer, intent(in)                                        :: problem_dim
        type(mesh), intent(in)                                     :: mesh_data

        if (problem_dim == 2) then
            strongly_enforced_bcs = '11'
        else
            print *, "Error: get_boundary_no_moving_mesh not implemented for problem_dim /= 2"
            error stop
        end if

    end subroutine

    subroutine project_mesh_velocity(u, global_point, problem_dim, no_vars, boundary_no, t)
        use fe_mesh

        implicit none

        real(db), dimension(no_vars), intent(out)    :: u
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: problem_dim
        integer, intent(in)                          :: no_vars
        integer, intent(in)                          :: boundary_no
        real(db), intent(in)                         :: t

        u = calculate_mesh_velocity(global_point, problem_dim, t)

    end subroutine

    function calculate_mesh_velocity_zero(coord, problem_dim, mesh_time)
        use param
        
        implicit none
        
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: coord
        real(db), intent(in)                         :: mesh_time
        real(db), dimension(problem_dim)             :: calculate_mesh_velocity_zero
        
        calculate_mesh_velocity_zero = 0.0_db
        
    end function

    function calculate_mesh_velocity_interior(coord, problem_dim, mesh_time)
        use param
        
        implicit none
        
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: coord
        real(db), intent(in)                         :: mesh_time
        real(db), dimension(problem_dim)             :: calculate_mesh_velocity_interior

        real(db) :: x, y

        x = coord(1)
        y = coord(2)
        
        ! calculate_mesh_velocity_interior(1) =  sin(2.0_db*pi*mesh_time)*y*(1.0_db - y)
        ! calculate_mesh_velocity_interior(2) = -sin(2.0_db*pi*mesh_time)*x*(1.0_db - x)
        ! calculate_mesh_velocity_interior(1) =  y*(1.0_db - y)*x*(1.0_db - x)
        ! calculate_mesh_velocity_interior(2) = -y*(1.0_db - y)*x*(1.0_db - x)
        ! calculate_mesh_velocity_interior(1) =  sin(2.0_db*pi*x*y)*(0.5_db - x)*(0.5_db - y)
        ! calculate_mesh_velocity_interior(2) = -sin(2.0_db*pi*x*y)*(0.5_db - x)*(0.5_db - y)
        ! calculate_mesh_velocity_interior(1) =  sin(2.0_db*pi*x*y)*sin(2.0_db*pi*(1.0_db-x)*(1.0_db-y))
        ! calculate_mesh_velocity_interior(2) = -sin(2.0_db*pi*x*y)*sin(2.0_db*pi*(1.0_db-x)*(1.0_db-y))

        ! Mesh velocity that only moves within the interior (is zero on the boundary).
        calculate_mesh_velocity_interior(1) = 5.0_db*sin(2.0_db*pi*mesh_time)*x*(x-1.0_db)*y*(y-1.0_db)
        calculate_mesh_velocity_interior(2) = 5.0_db*sin(2.0_db*pi*mesh_time)*x*(x-1.0_db)*y*(y-1.0_db)

        ! A nicer velocity...
        ! calculate_mesh_velocity_interior(1) = -0.1_db*sin(2.0_db*pi*mesh_time)*sin(2*pi*x)*sin(2*pi*y)
        ! calculate_mesh_velocity_interior(2) = -0.1_db*sin(2.0_db*pi*mesh_time)*sin(2*pi*x)*sin(2*pi*y)

        ! [Etienne, 2009]
        ! calculate_mesh_velocity_interior(1) = mesh_time*(1.0_db-x**2)*(y+1.0_db)/32.0_db
        ! calculate_mesh_velocity_interior(2) = mesh_time*(1.0_db-y**2)*(x+mesh_time*(1.0_db-x**2)/32.0_db + 1.0_db)/32.0_db
        
    end function

    function calculate_mesh_velocity_interior_ti(coord, problem_dim, mesh_time)
        use param
        
        implicit none
        
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: coord
        real(db), intent(in)                         :: mesh_time
        real(db), dimension(problem_dim)             :: calculate_mesh_velocity_interior_ti

        real(db) :: x, y

        x = coord(1)
        y = coord(2)

        ! Mesh velocity that only moves within the interior (is zero on the boundary).
        calculate_mesh_velocity_interior_ti(1) = 5.0_db*x*(x-1.0_db)*y*(y-1.0_db)
        calculate_mesh_velocity_interior_ti(2) = 5.0_db*x*(x-1.0_db)*y*(y-1.0_db)
        
    end function

    function calculate_mesh_velocity_shear(coord, problem_dim, mesh_time)
        use param
        
        implicit none
        
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: coord
        real(db), intent(in)                         :: mesh_time
        real(db), dimension(problem_dim)             :: calculate_mesh_velocity_shear
        
        calculate_mesh_velocity_shear(1) = 0.0_db
        calculate_mesh_velocity_shear(2) = coord(1)
        
    end function

    function calculate_mesh_velocity_constant_up(coord, problem_dim, mesh_time)
        use param
        
        implicit none
        
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: coord
        real(db), intent(in)                         :: mesh_time
        real(db), dimension(problem_dim)             :: calculate_mesh_velocity_constant_up
        
        calculate_mesh_velocity_constant_up(1) = 0.0_db
        calculate_mesh_velocity_constant_up(2) = 1.0_db
        
    end function

    function calculate_mesh_velocity_circular(coord, problem_dim, mesh_time)
        use param
        
        implicit none
        
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: coord
        real(db), intent(in)                         :: mesh_time
        real(db), dimension(problem_dim)             :: calculate_mesh_velocity_circular
        
        calculate_mesh_velocity_circular(1) = -cos(2.0_db*pi*mesh_time)
        calculate_mesh_velocity_circular(2) =  sin(2.0_db*pi*mesh_time)
        
    end function

    function calculate_mesh_velocity_incompressible(coord, problem_dim, mesh_time)
        use param
        
        implicit none
        
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: coord
        real(db), intent(in)                         :: mesh_time
        real(db), dimension(problem_dim)             :: calculate_mesh_velocity_incompressible
        
        calculate_mesh_velocity_incompressible(1) =  coord(1)
        calculate_mesh_velocity_incompressible(2) = -coord(2)
        
    end function

    function calculate_mesh_velocity_incompressible2(coord, problem_dim, mesh_time)
        use param
        
        implicit none
        
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: coord
        real(db), intent(in)                         :: mesh_time
        real(db), dimension(problem_dim)             :: calculate_mesh_velocity_incompressible2

        calculate_mesh_velocity_incompressible2(1) =  coord(1)**2*coord(2)
        calculate_mesh_velocity_incompressible2(2) = -coord(2)**2*coord(1)
        
    end function
    
    function calculate_mesh_velocity_oscillating_sine(coord, problem_dim, mesh_time)
        use param
        
        implicit none
        
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: coord
        real(db), intent(in)                         :: mesh_time
        real(db), dimension(problem_dim)             :: calculate_mesh_velocity_oscillating_sine
        
        real(db) :: x, y

        x = coord(1) - move_mesh_centre(1)
        y = coord(2) - move_mesh_centre(2)
        
        calculate_mesh_velocity_oscillating_sine(1) = x*sin(2.0_db*pi*mesh_time)
        calculate_mesh_velocity_oscillating_sine(2) = y*sin(2.0_db*pi*mesh_time)
        
    end function

    subroutine update_geometry(mesh_time, time_step, control_file)
        implicit none
        
        real(db), intent(in)          :: mesh_time, time_step
        character(len=20), intent(in) :: control_file

        real(db), dimension(2) :: update_velocity, coord
        integer                :: i, j
        real(db)               :: x, y

        if (trim(control_file) == 'placenta') then
            !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            !! PLACENTONE WIDTHS AND SIDES !!
            !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            do i = 1, no_placentones
                do j = 1, 2
                    update_velocity           = calculate_mesh_velocity(placentone_sides(i, j, :), 2, mesh_time)
                    placentone_sides(i, j, :) = placentone_sides(i, j, :) + update_velocity*time_step
                end do

                placentone_widths(i) = placentone_sides(i, 2, 1) - placentone_sides(i, 1, 1)
            end do

            wall_width = placentone_sides(4, 1, 1) - placentone_sides(3, 2, 1)

            cumulative_placentone_widths(1) = placentone_sides(1, 1, 1)
            do i = 2, no_placentones
                cumulative_placentone_widths(i) = cumulative_placentone_widths(i-1) + placentone_widths(i-1) + wall_width
            end do

            !!!!!!!!!!!!!!!!!!!!!!!!!
            !! PLACENTA DIMENSIONS !!
            !!!!!!!!!!!!!!!!!!!!!!!!!
            ! Circle centre.
            coord           = [x_centre, y_centre]
            update_velocity = calculate_mesh_velocity(coord, 2, mesh_time)
            x_centre        = x_centre + update_velocity(1)*time_step
            y_centre        = y_centre + update_velocity(2)*time_step

            ! Boundary radius.
            boundary_radius = sqrt((placentone_sides(1, 1, 1) - x_centre)**2 + (placentone_sides(1, 1, 2) - y_centre)**2)

            ! Placenta height and width.
            update_velocity = calculate_mesh_velocity(placenta_bottom, 2, mesh_time)
            placenta_bottom = placenta_bottom + update_velocity*time_step

            update_velocity = calculate_mesh_velocity(placenta_top, 2, mesh_time)
            placenta_top    = placenta_top + update_velocity*time_step

            placenta_height = placenta_top(2) - placenta_bottom(2)
            placenta_width  = placentone_sides(6, 2, 1) - placentone_sides(1, 1, 1)

            ! Marginal sinus size.
            update_velocity                = calculate_mesh_velocity(left_marginal_sinus_tops(1, :), 2, mesh_time)
            left_marginal_sinus_tops(1, :) = left_marginal_sinus_tops(1, :) + update_velocity*time_step

            update_velocity                = calculate_mesh_velocity(left_marginal_sinus_tops(2, :), 2, mesh_time)
            left_marginal_sinus_tops(2, :) = left_marginal_sinus_tops(2, :) + update_velocity*time_step

            ms_pipe_width = sqrt((left_marginal_sinus_tops(1, 1) - left_marginal_sinus_tops(2, 1))**2 + &
                (left_marginal_sinus_tops(1, 2) - left_marginal_sinus_tops(2, 2))**2)

            update_velocity                 = calculate_mesh_velocity(right_marginal_sinus_tops(1, :), 2, mesh_time)
            right_marginal_sinus_tops(1, :) = right_marginal_sinus_tops(1, :) + update_velocity*time_step

            update_velocity                 = calculate_mesh_velocity(right_marginal_sinus_tops(2, :), 2, mesh_time)
            right_marginal_sinus_tops(2, :) = right_marginal_sinus_tops(2, :) + update_velocity*time_step

            !!!!!!!!!!!!!!!!!!
            !! ARTERY SIDES !!
            !!!!!!!!!!!!!!!!!!
            do i = 1, no_placentones
                do j = 1, 2
                    update_velocity       = calculate_mesh_velocity(artery_sides(i, j, :), 2, mesh_time)
                    artery_sides(i, j, :) = artery_sides(i, j, :) + update_velocity(:)*time_step
                end do
            end do

            ! TODO: investigate why you need to divide by 2...
            artery_width_sm = sqrt((artery_sides(1, 1, 1) - artery_sides(1, 2, 1))**2 + &
                (artery_sides(1, 1, 2) - artery_sides(1, 2, 2))**2)/2.0_db
            
            x = (artery_sides(1, 1, 1) + artery_sides(1, 2, 1))/2.0_db
            y = (artery_sides(1, 1, 2) + artery_sides(1, 2, 2))/2.0_db
            artery_length = sqrt((x - vessel_tops(1, 2, 1))**2 + (y - vessel_tops(1, 2, 2))**2)

            !!!!!!!!!!!!!!!!!
            !! WALL ANGLES !!
            !!!!!!!!!!!!!!!!!
            do i = 1, no_placentones-1
                coord(1) = cumulative_placentone_widths(i) + placentone_widths(i) + wall_width/2.0_db
                coord(2) = y_centre - sqrt((boundary_radius**2 - (coord(1) - x_centre)**2))
                wall_angles(i) = -atan2(coord(2) - y_centre, coord(1) - x_centre)
            end do

            !!!!!!!!!!!!!!!!!!
            !! WALL HEIGHTS !!
            !!!!!!!!!!!!!!!!!!
            do i = 1, no_placentones-1
                do j = 1, 2
                    update_velocity = calculate_mesh_velocity(wall_tops(i, j, :), 2, mesh_time)
                    wall_tops(i, j, :) = wall_tops(i, j, :) + update_velocity*time_step
                end do

                wall_heights(i) = sqrt((placentone_sides(i, 2, 1) - wall_tops(i, 1, 1))**2 + &
                    (placentone_sides(i, 2, 2) - wall_tops(i, 1, 2))**2)
            end do

            !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            !! CAVITY TRANSITIONS AND VESSEL TOPS/ANGLES !!
            !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            do i = 1, no_placentones
                ! Cavity tops.
                do j = 1, 3
                    update_velocity      = calculate_mesh_velocity(cavity_tops(i, j, :), 2, mesh_time)
                    cavity_tops(i, j, :) = cavity_tops(i, j, :) + update_velocity*time_step
                end do

                ! Cavity sides.
                do j = 1, 3
                    update_velocity       = calculate_mesh_velocity(cavity_sides(i, j, :), 2, mesh_time)
                    cavity_sides(i, j, :) = cavity_sides(i, j, :) + update_velocity*time_step
                end do

                ! Vessel tops.
                do j = 1, 3
                    update_velocity      = calculate_mesh_velocity(vessel_tops(i, j, :), 2, mesh_time)
                    vessel_tops(i, j, :) = vessel_tops(i, j, :) + update_velocity*time_step
                    vessel_angles(i, j)  = -atan2((vessel_tops(i, j, 2)-y_centre), (vessel_tops(i, j, 1)-x_centre))
                end do

                ! Cavity widths and heights.
                central_cavity_heights(i) = 2*sqrt( &
                    (cavity_tops(i, 2, 1) - vessel_tops(i, 2, 1))**2 + (cavity_tops(i, 2, 2) - vessel_tops(i, 2, 2))**2 &
                )

                ! Cavity transition.
                central_cavity_widths(i) = 2*sqrt( &
                    (cavity_sides(i, 2, 1) - vessel_tops(i, 2, 1))**2 + (cavity_sides(i, 2, 2) - vessel_tops(i, 2, 2))**2 &
                )

                ! Cavity ratios
                central_cavity_ratios(i) = central_cavity_heights(i)/central_cavity_widths(i)
            end do

            ! Cavity transition.
            central_cavity_transition = sqrt((cavity_sides(4, 3, 1) - cavity_sides(4, 1, 1))**2 + &
                (cavity_sides(4, 3, 2) - cavity_sides(4, 1, 2))**2)

            if (processor_no == 0) then
                print *, "UPDATING..."
                print *, "CAVITY HEIGHT: ", central_cavity_heights(4)
                print *, "CAVITY WIDTH:  ", central_cavity_widths(4)
                print *, "CAVITY RATIO: ", central_cavity_ratios(4)
                print *, "CAVITY TRANSITION: ", central_cavity_transition
                print *, "CAVITY TOP: ", cavity_tops(4, 2, :)
                print *, "VESSEL TOP: ", vessel_tops(4, 2, :)
                print *, "ARTERY WIDTH SM: ", artery_width_sm
                print *, "ARTERY LENGTH: ", artery_length
                print *, "BOUNDARY RADIUS: ", boundary_radius
                print *, "X_CENTRE: ", x_centre
                print *, "Y_CENTRE: ", y_centre
                print *, "PLACENTONE WIDTH: ", placentone_widths(4)
            end if
        else
            call write_message(io_msg, "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            call write_message(io_msg, "!! WARNING: update_geometry not implemented for this geometry. !!")
            call write_message(io_msg, "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        end if

        !!!!!!!!!!!!!!!!!!!!!!!
        !! PLACENTONE WIDTHS !!
        !!!!!!!!!!!!!!!!!!!!!!!
        ! do i = 1, no_placentones
        !     do j = 1, 2
        !         update_velocity           = calculate_mesh_velocity(placentone_sides(i, j, :), 2, mesh_time)
        !         placentone_sides(i, j, :) = placentone_sides(i, j, :) + update_velocity*time_step
        !     end do

        !     placentone_widths(i) = placentone_sides(i, 2, 1) - placentone_sides(i, 1, 1)
        ! end do

        ! cumulative_placentone_widths(1) = placentone_sides(1, 1, 1)
        ! do i = 2, no_placentones
        !     cumulative_placentone_widths(i) = cumulative_placentone_widths(i-1) + placentone_widths(i-1) + wall_width
        ! end do

        !!!!!!!!!!!!!!!!!!!!!!!!
        !! CAVITY TRANSITIONS !!
        !!!!!!!!!!!!!!!!!!!!!!!!
        ! do i = 1, no_placentones
        !     ! Cavity tops.
        !     do j = 1, 3
        !         update_velocity      = calculate_mesh_velocity(cavity_tops(i, j, :), 2, mesh_time)
        !         cavity_tops(i, j, :) = cavity_tops(i, j, :) + update_velocity*time_step
        !     end do

        !     ! Vessel tops.
        !     do j = 1, 3
        !         update_velocity      = calculate_mesh_velocity(vessel_tops(i, j, :), 2, mesh_time)
        !         vessel_tops(i, j, :) = vessel_tops(i, j, :) + update_velocity*time_step
        !     end do

        !     ! Cavity widths and heights.
        !     central_cavity_heights(i) = 2*sqrt( &
        !         (cavity_tops(i, 2, 1) - vessel_tops(i, 2, 1))**2 + (cavity_tops(i, 2, 2) - vessel_tops(i, 2, 2))**2 &
        !     )

        !     ! Cavity transition.
        !     central_cavity_widths(i) = 2*sqrt( &
        !         (cavity_sides(i, 2, 1) - vessel_tops(i, 2, 1))**2 + (cavity_sides(i, 2, 2) - vessel_tops(i, 2, 2))**2 &
        !     )

        !     ! Cavity ratios
        !     central_cavity_ratios(i) = central_cavity_heights(i)/central_cavity_widths(i)
        ! end do

        !!!!!!!!!!!!!!!!!!!!!!!
        !! PIPES TRANSITIONS !!
        !!!!!!!!!!!!!!!!!!!!!!!

        !!!!!!!!!!!!!!!!
        !! ARTERY BCS !!
        !!!!!!!!!!!!!!!!
    end subroutine
    
    ! subroutine update_geometry(mesh_time, time_step)
    !     implicit none
        
    !     real(db), intent(in) :: mesh_time, time_step
        
    !     real(db), dimension(2) :: update_velocity, coord
    !     integer                :: i, j, no_vessels
    !     real(db)               :: boundary_radius_old
    
    !     ! if (processor_no == 0) then
    !     !     print *, "Original parameters:"
    !     !     print *, "  boundary_radius = ", boundary_radius
    !     !     print *, "  central_cavity_heights(3) = ", central_cavity_heights(3)
    !     !     print *, "  central_cavity_widths(3) = ", central_cavity_widths(3)
    !     !     print *, "  central_cavity_transition = ", central_cavity_transition
    !     ! end if

    !     ! if (processor_no == 0) then
    !     !     print *, "Radius:"
    !     !     print *, "  coord(1) = ", x_centre
    !     !     print *, "  coord(2) = ", boundary_radius - y_centre
    !     ! end if

    !     ! if (processor_no == 0) then
    !     !     print *, "Original points:"
    !     !     print *, "  single_cavity_tops(1, 1) = ", single_cavity_tops(1, 1)
    !     !     print *, "  single_cavity_tops(1, 2) = ", single_cavity_tops(1, 2)
    !     !     print *, "  single_cavity_tops(2, 1) = ", single_cavity_tops(2, 1)
    !     !     print *, "  single_cavity_tops(2, 2) = ", single_cavity_tops(2, 2)
    !     !     print *, "  vessel_tops(3, 2, 1) = ", vessel_tops(3, 2, 1)
    !     !     print *, "  vessel_tops(3, 2, 2) = ", vessel_tops(3, 2, 2)
    !     ! end if

    !     ! Update boundary radius.
    !     coord(1) = x_centre
    !     coord(2) = boundary_radius - y_centre
    !     boundary_radius_old = boundary_radius
    !     update_velocity     = calculate_mesh_velocity(coord, 2, mesh_time)
    !     boundary_radius     = boundary_radius - update_velocity(2)*time_step

    !     ! Inflation ratio.
    !     inflation_ratio = boundary_radius_old/boundary_radius

    !     ! Update vessel tops and angles.
    !     no_vessels = 3
    !     do i = 1, no_placentones
    !         do j = 1, no_vessels
    !             update_velocity = calculate_mesh_velocity(vessel_tops(i, j, :), 2, mesh_time)

    !             vessel_tops(i, j, :) = vessel_tops(i, j, :) + update_velocity*time_step
    !             vessel_angles(i, j)  = -atan2((vessel_tops(i, j, 2)-y_centre), (vessel_tops(i, j, 1)-x_centre))
    !         end do
    !     end do

    !     ! Update central cavity tops.
    !     do i = 1, 2
    !         update_velocity = calculate_mesh_velocity(single_cavity_tops(i, :), 2, mesh_time)

    !         single_cavity_tops(i, :) = single_cavity_tops(i, :) + update_velocity*time_step
    !     end do
        
    !     ! Update cavity width, height, and translition lengths.
    !     central_cavity_transition = sqrt( &
    !         (single_cavity_tops(1, 1) - single_cavity_tops(2, 1))**2 + (single_cavity_tops(1, 2) - single_cavity_tops(2, 2))**2 &
    !     )/4.0_db
    !     central_cavity_heights(3) = 0*central_cavity_transition + 2*sqrt( &
    !         (vessel_tops(3, 2, 1) - single_cavity_tops(1, 1))**2 + (vessel_tops(3, 2, 2) - single_cavity_tops(1, 2))**2 &
    !     )
    !     central_cavity_widths(3) = central_cavity_heights(3)*central_cavity_ratios(3)

    !     ! TODO: PIPE TRANSITION

    !     ! if (processor_no == 0) then
    !     !     print *, "Updated points:"
    !     !     print *, "  single_cavity_tops(1, 1) = ", single_cavity_tops(1, 1)
    !     !     print *, "  single_cavity_tops(1, 2) = ", single_cavity_tops(1, 2)
    !     !     print *, "  single_cavity_tops(2, 1) = ", single_cavity_tops(2, 1)
    !     !     print *, "  single_cavity_tops(2, 2) = ", single_cavity_tops(2, 2)
    !     !     print *, "  vessel_tops(3, 2, 1) = ", vessel_tops(3, 2, 1)
    !     !     print *, "  vessel_tops(3, 2, 2) = ", vessel_tops(3, 2, 2)

    !     !     print *, "Updated parameters:"
    !     !     print *, "  boundary_radius = ", boundary_radius
    !     !     print *, "  central_cavity_heights(3) = ", central_cavity_heights(3)
    !     !     print *, "  central_cavity_widths(3) = ", central_cavity_widths(3)
    !     !     print *, "  central_cavity_transition = ", central_cavity_transition

    !     !     ! stop
    !     ! end if

    !     ! Update placentone widths.
    !     ! placentone_widths = placentone_widths*inflation_ratio
    ! end subroutine
    
    function calculate_placentone_cavity_transition(global_point, problem_dim, element_region_id, steepness, placentone_no)
        use param
        
        implicit none
        
        real(db)                                     :: calculate_placentone_cavity_transition
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: element_region_id
        real(db), intent(in)                         :: steepness
        integer, intent(in)                          :: placentone_no
        
        real(db)               :: x, y, r, r0, r1, r2, theta
        real(db)               :: a0, b0, a1, b1, a2, b2
        real(db), dimension(2) :: centre
        
        x = global_point(1)
        y = global_point(2)
        
        ! Centre of ellipse.
        centre(1) = vessel_locations(placentone_no, 2) ! location 2 is artery
        centre(2) = 0.0_db
        
        ! Angle and radius from ellipse centre to point.
        theta = atan2(y - centre(2), x - centre(1))
        r     = sqrt((x - centre(1))**2 + (y - centre(2))**2)
        
        ! Semi-major and semi-minor axes for all 3 ellipses.
        a1 = central_cavity_widths(placentone_no) /2.0_db
        b1 = central_cavity_heights(placentone_no)/2.0_db
        
        a0 = a1 - central_cavity_transition/2.0_db
        a2 = a1 + central_cavity_transition/2.0_db
        b0 = b1 - central_cavity_transition*central_cavity_ratios(placentone_no)/2.0_db
        b2 = b1 + central_cavity_transition*central_cavity_ratios(placentone_no)/2.0_db
        
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
        
        calculate_placentone_pipe_transition = smooth_tanh_function(y, steepness, y0, y2)
    end function
    
    function translate_placenta_to_placentone_point(problem_dim, placenta_point, element_region_id)
        use param
        
        implicit none
        
        real(db), dimension(problem_dim)             :: translate_placenta_to_placentone_point
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: placenta_point
        integer, intent(in)                          :: element_region_id
        
        real(db), dimension(problem_dim) :: circle_centre, rotation_centre, temp_coord
        real(db)                         :: radius, translate_angle, scaling_factor, y_offset, angle
        integer                          :: placentone_no, vessel_no
        
        radius   = y_centre
        
        if (element_region_id == 401) then
            placentone_no    = 1
            translate_angle  = pi
            scaling_factor   = 2.0_db * ms_pipe_width/0.075_db
            circle_centre(1) = (left_marginal_sinus_tops(1, 2) + left_marginal_sinus_tops(2, 2))/2.0_db + &
                placentone_sides(1, 1, 1)
            circle_centre(2) = (left_marginal_sinus_tops(1, 2) + left_marginal_sinus_tops(2, 2))/2.0_db
            y_offset         = circle_centre(2)
            temp_coord       = placenta_point
        else if (element_region_id == 402) then
            placentone_no    = 1
            translate_angle  = 0.0_db
            scaling_factor   = 2.0_db * ms_pipe_width/0.075_db
            circle_centre(1) = -(right_marginal_sinus_tops(1, 2) + right_marginal_sinus_tops(2, 2))/2.0_db + &
                placentone_sides(no_placentones, 2, 1)
            circle_centre(2) = (left_marginal_sinus_tops(1, 2) + left_marginal_sinus_tops(2, 2))/2.0_db
            y_offset         = circle_centre(2)
            temp_coord       = placenta_point
        else if (411 <= element_region_id .and. element_region_id <= 473) then
            placentone_no    = (element_region_id-400)/10
            vessel_no        = mod(element_region_id-400, 10)
            if (1 <= vessel_no .and. vessel_no <= 3) then
                translate_angle  = vessel_angles(placentone_no, vessel_no)
                scaling_factor   = placentone_widths(placentone_no)/placentone_widths(4)
                circle_centre(1) = x_centre
                circle_centre(2) = y_centre
                y_offset         = circle_centre(2) - placenta_bottom(2)
                temp_coord       = placenta_point
            else
                ! Note: placentone_no = wall_no here.
                ! For septal veins, we first need to transform points to the basal plate, and then do the usual transformation.
                scaling_factor  = 1.0_db/placentone_widths(4)
                circle_centre(1) = x_centre
                circle_centre(2) = y_centre
                if (vessel_no == 7) then
                    rotation_centre = placentone_sides(placentone_no, 2, :)

                    angle = 0.0_db
                    temp_coord(1) =   (placenta_point(1) - rotation_centre(1))*sin(angle) &
                    + (placenta_point(2) - rotation_centre(2))*cos(angle)
                    temp_coord(2) = - (placenta_point(1) - rotation_centre(1))*cos(angle) &
                    + (placenta_point(2) - rotation_centre(2))*sin(angle)
                    temp_coord = temp_coord + rotation_centre

                    translate_angle = wall_angles(placentone_no)
                    y_offset        = circle_centre(2) - placenta_bottom(2)
                else if (vessel_no == 8) then
                    translate_angle = wall_angles(placentone_no)
                    y_offset        = circle_centre(2) - wall_heights(placentone_no) - placenta_bottom(2)
                    temp_coord      = placenta_point
                else if (vessel_no == 9) then
                    rotation_centre = placentone_sides(placentone_no+1, 1, :)

                    angle = pi
                    temp_coord(1) =   (placenta_point(1) - rotation_centre(1))*sin(angle) &
                    + (placenta_point(2) - rotation_centre(2))*cos(angle)
                    temp_coord(2) = - (placenta_point(1) - rotation_centre(1))*cos(angle) &
                    + (placenta_point(2) - rotation_centre(2))*sin(angle)
                    temp_coord = temp_coord + rotation_centre

                    translate_angle = wall_angles(placentone_no)
                    y_offset        = circle_centre(2) - placenta_bottom(2)
                else 
                    print *, "Error in translate_placenta_to_placentone_point. Missed case."
                    print *, "element_region_id = ", element_region_id
                    print *, "vessel_no = ", vessel_no
                    error stop
                end if
            end if
        else if (501 <= element_region_id .and. element_region_id <= 527) then
            placentone_no    = mod(element_region_id-500, 10)
            vessel_no        = 2 ! Always on artery.
            translate_angle  = vessel_angles(placentone_no, vessel_no)
            scaling_factor   = placentone_widths(placentone_no)/placentone_widths(4)
            circle_centre(1) = x_centre
            circle_centre(2) = y_centre
            y_offset         = circle_centre(2) - placenta_bottom(2)
            temp_coord       = placenta_point
        else
            print *, "Error in translate_placenta_to_placentone_point. Missed case: element_region_id = ", element_region_id
            error stop
        end if
        
        translate_placenta_to_placentone_point(1) =   (temp_coord(1) - circle_centre(1))*sin(translate_angle) &
        + (temp_coord(2) - circle_centre(2))*cos(translate_angle)
        translate_placenta_to_placentone_point(2) = - (temp_coord(1) - circle_centre(1))*cos(translate_angle) &
        + (temp_coord(2) - circle_centre(2))*sin(translate_angle)

        translate_placenta_to_placentone_point(1) = translate_placenta_to_placentone_point(1)/scaling_factor + &
            vessel_locations(placentone_no, 2)
        translate_placenta_to_placentone_point(2) = (translate_placenta_to_placentone_point(2) + y_offset)/scaling_factor
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