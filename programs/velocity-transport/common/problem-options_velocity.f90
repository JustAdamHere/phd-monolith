module problem_options_velocity
    use aptofem_kernel

    save

    real(db)         :: velocity_diffusion_coefficient, velocity_convection_coefficient, &
        velocity_pressure_coefficient, velocity_forcing_coefficient, &
        velocity_reaction_coefficient, velocity_time_coefficient, reynold_ramp_start_ratio, reynold_ramp_step_base
    logical          :: large_boundary_v_penalisation
    character(len=2) :: fe_space_velocity
    integer          :: no_reynold_ramp_steps

contains
    subroutine get_user_data_velocity(section_name, aptofem_stored_keys)
        implicit none

        character(len=*), intent(in) :: section_name
        type(aptofem_keys), pointer  :: aptofem_stored_keys

        integer :: ierr

        call get_aptofem_key_definition('velocity_diffusion_coefficient', &
            velocity_diffusion_coefficient, section_name, aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('velocity_convection_coefficient', &
            velocity_convection_coefficient, section_name, aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('velocity_reaction_coefficient', &
            velocity_reaction_coefficient,  section_name, aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('velocity_pressure_coefficient', &
            velocity_pressure_coefficient, section_name, aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('velocity_time_coefficient', &
            velocity_time_coefficient, section_name, aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('velocity_forcing_coefficient', &
            velocity_forcing_coefficient, section_name, aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('large_boundary_v_penalisation', large_boundary_v_penalisation, section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('no_reynold_ramp_steps', no_reynold_ramp_steps, section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('reynold_ramp_start_ratio', reynold_ramp_start_ratio, section_name, &
            aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('reynold_ramp_step_base', reynold_ramp_step_base, section_name, &
            aptofem_stored_keys, ierr)
    end subroutine

    subroutine set_space_type_velocity(aptofem_stored_keys)
        type(aptofem_keys), pointer :: aptofem_stored_keys

        character(len=100) :: fe_space_velocity_temp
        integer            :: ierr

        call get_aptofem_key_definition('fe_space', fe_space_velocity_temp, 'fe_solution_velocity', aptofem_stored_keys, ierr)
        fe_space_velocity = fe_space_velocity_temp(1:2)

        if (fe_space_velocity /= 'DG' .and. fe_space_velocity /= 'CG') then
            call write_message(io_err, 'Error: fe space should be DG or CG.')
            stop
        end if
    end subroutine

    subroutine project_permeability_300(u, global_point, problem_dim, no_vars, boundary_no, t)
        use fe_mesh

        implicit none

        real(db), dimension(no_vars), intent(out)    :: u
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: problem_dim
        integer, intent(in)                          :: no_vars
        integer, intent(in)                          :: boundary_no
        real(db), intent(in)                         :: t

        u = calculate_velocity_reaction_coefficient(global_point, problem_dim, 300)

    end subroutine

    subroutine project_permeability_400(u, global_point, problem_dim, no_vars, boundary_no, t)
        use fe_mesh

        implicit none

        real(db), dimension(no_vars), intent(out)    :: u
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: problem_dim
        integer, intent(in)                          :: no_vars
        integer, intent(in)                          :: boundary_no
        real(db), intent(in)                         :: t

        u = calculate_velocity_reaction_coefficient(global_point, problem_dim, 422)

    end subroutine

    subroutine project_permeability_500(u, global_point, problem_dim, no_vars, boundary_no, t)
        use fe_mesh

        implicit none

        real(db), dimension(no_vars), intent(out)    :: u
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: problem_dim
        integer, intent(in)                          :: no_vars
        integer, intent(in)                          :: boundary_no
        real(db), intent(in)                         :: t

        u = calculate_velocity_reaction_coefficient(global_point, problem_dim, 511)

    end subroutine

    function calculate_velocity_diffusion_coefficient(global_point, problem_dim, element_region_id)
        use param

        real(db)                                     :: calculate_velocity_diffusion_coefficient
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: element_region_id

        calculate_velocity_diffusion_coefficient = velocity_diffusion_coefficient
    end function

    function calculate_velocity_convection_coefficient(global_point, problem_dim, element_region_id)
        use param

        real(db)                                     :: calculate_velocity_convection_coefficient
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: element_region_id

        calculate_velocity_convection_coefficient = velocity_convection_coefficient
    end function

    function calculate_velocity_reaction_coefficient(global_point, problem_dim, element_region_id)
        use param
        use problem_options
        use program_name_module

        implicit none

        real(db)                                     :: calculate_velocity_reaction_coefficient
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: element_region_id

        character(len=20)      :: name
        real(db)               :: steepness
        real(db), dimension(2) :: translated_point

        call program_name(name)

        steepness = 0.999_db

        if (400 <= element_region_id .and. element_region_id <= 599) then
            if (trim(name) == 'placentone') then
                translated_point = global_point
            else if (trim(name) == 'placenta') then
                translated_point = translate_placenta_to_placentone_point(problem_dim, global_point, element_region_id)
            else if (trim(name) == 'placentone-3d') then
                translated_point = translate_placentone_3d_to_placentone_point(problem_dim, global_point, element_region_id)
            else
                print *, "Error in calculate_velocity_reaction_coefficient. Missed case."
                print *, "name = ", name
                error stop
            end if
        else
            translated_point = 0.0_db
        end if

        if (300 <= element_region_id .and. element_region_id <= 399) then
            calculate_velocity_reaction_coefficient = velocity_reaction_coefficient* &
                1.0_db
        else if (element_region_id == 412 .or. element_region_id == 422 .or. element_region_id == 432 .or. &
                 element_region_id == 442 .or. element_region_id == 452 .or. element_region_id == 462 .or. &
                 element_region_id == 472) then
            calculate_velocity_reaction_coefficient = &
                0.0_db
        else if (400 <= element_region_id .and. element_region_id <= 499) then
            calculate_velocity_reaction_coefficient = velocity_reaction_coefficient* &
                calculate_placentone_pipe_transition(translated_point, problem_dim, element_region_id, steepness)
        else if (500 <= element_region_id .and. element_region_id <= 509) then
            calculate_velocity_reaction_coefficient = &
                0.0_db
        else if (510 <= element_region_id .and. element_region_id <= 529) then
            calculate_velocity_reaction_coefficient = velocity_reaction_coefficient* &
                calculate_placentone_cavity_transition(translated_point, problem_dim, element_region_id, steepness)
        else
            print *, "Error in calculate_velocity_reaction_coefficient. Missed case."
            print *, "element_region_id = ", element_region_id
            stop
        end if
        
    end function

    function calculate_velocity_pressure_coefficient(global_point, problem_dim, element_region_id)
        use param

        real(db)                                     :: calculate_velocity_pressure_coefficient
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: element_region_id

        calculate_velocity_pressure_coefficient = velocity_pressure_coefficient
    end function

    function calculate_velocity_time_coefficient(global_point, problem_dim, element_region_id)
        use param

        real(db)                                     :: calculate_velocity_time_coefficient
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: element_region_id

        calculate_velocity_time_coefficient = velocity_time_coefficient
    end function

    function calculate_velocity_forcing_coefficient(global_point, problem_dim, element_region_id)
        use param

        real(db)                                     :: calculate_velocity_forcing_coefficient
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: element_region_id

        calculate_velocity_forcing_coefficient = velocity_forcing_coefficient
    end function

end module
