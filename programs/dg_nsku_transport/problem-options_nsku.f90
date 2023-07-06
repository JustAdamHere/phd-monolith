module problem_options_nsku
    use aptofem_kernel

    save

    real(db)          :: nsku_diffusion_coefficient, nsku_convection_coefficient, &
        nsku_pressure_coefficient, nsku_forcing_coefficient, &
        nsku_reaction_coefficient, nsku_time_coefficient
    logical          :: large_boundary_v_penalisation
    character(len=2) :: fe_space_nsku

contains
    subroutine get_user_data_nsku(section_name, aptofem_stored_keys)
        implicit none

        character(len=*), intent(in) :: section_name
        type(aptofem_keys), pointer  :: aptofem_stored_keys

        integer :: ierr

        call get_aptofem_key_definition('nsku_diffusion_coefficient', &
            nsku_diffusion_coefficient, section_name, aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('nsku_convection_coefficient', &
            nsku_convection_coefficient, section_name, aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('nsku_reaction_coefficient', &
            nsku_reaction_coefficient,  section_name, aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('nsku_pressure_coefficient', &
            nsku_pressure_coefficient, section_name, aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('nsku_time_coefficient', &
            nsku_time_coefficient, section_name, aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('nsku_forcing_coefficient', &
            nsku_forcing_coefficient, section_name, aptofem_stored_keys, ierr)
        call get_aptofem_key_definition('large_boundary_v_penalisation', large_boundary_v_penalisation, section_name, &
            aptofem_stored_keys, ierr)
    end subroutine

    subroutine set_space_type_nsku(aptofem_stored_keys)
        type(aptofem_keys), pointer :: aptofem_stored_keys

        character(len=100) :: fe_space_nsku_temp
        integer            :: ierr

        call get_aptofem_key_definition('fe_space', fe_space_nsku_temp, 'fe_solution_nsku', aptofem_stored_keys, ierr)
        fe_space_nsku = fe_space_nsku_temp(1:2)

        if (fe_space_nsku /= 'DG' .and. fe_space_nsku /= 'CG') then
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

        u = calculate_nsku_reaction_coefficient(global_point, problem_dim, 300)

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

        u = calculate_nsku_reaction_coefficient(global_point, problem_dim, 463)

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

        u = calculate_nsku_reaction_coefficient(global_point, problem_dim, 502)

    end subroutine

    function calculate_nsku_diffusion_coefficient(global_point, problem_dim, element_region_id)
        use param

        real(db)                                     :: calculate_nsku_diffusion_coefficient
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: element_region_id

        calculate_nsku_diffusion_coefficient = nsku_diffusion_coefficient
    end function

    function calculate_nsku_convection_coefficient(global_point, problem_dim, element_region_id)
        use param

        real(db)                                     :: calculate_nsku_convection_coefficient
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: element_region_id

        calculate_nsku_convection_coefficient = nsku_convection_coefficient
    end function

    function calculate_nsku_reaction_coefficient(global_point, problem_dim, element_region_id)
        use param
        use problem_options
        use program_name_module

        implicit none

        real(db)                                     :: calculate_nsku_reaction_coefficient
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: element_region_id

        character(len=20)      :: name
        real(db)               :: steepness
        real(db), dimension(2) :: translated_point

        call program_name(name)

        steepness = 0.999_db

        if (trim(name) == 'placentone') then
            if (300 <= element_region_id .and. element_region_id <= 399) then
                calculate_nsku_reaction_coefficient = nsku_reaction_coefficient* &
                    1.0_db
            else if (element_region_id == 412) then
                calculate_nsku_reaction_coefficient = &
                    0.0_db
            else if (400 <= element_region_id .and. element_region_id <= 499) then
                calculate_nsku_reaction_coefficient = nsku_reaction_coefficient* &
                    calculate_placentone_pipe_transition(global_point, problem_dim, element_region_id, steepness)
            else if (500 <= element_region_id .and. element_region_id <= 599) then
                calculate_nsku_reaction_coefficient = nsku_reaction_coefficient* &
                    calculate_placentone_cavity_transition(global_point, problem_dim, element_region_id, steepness)
            else
                print *, "Error in calculate_nsku_reaction_coefficient. Missed case."
                print *, "element_region_id = ", element_region_id
                stop
            end if

        else if (trim(name) == 'placenta') then
            if (300 <= element_region_id .and. element_region_id <= 399) then
                calculate_nsku_reaction_coefficient = nsku_reaction_coefficient* &
                    1.0_db
            else if (element_region_id == 412 .or. element_region_id == 422 .or. element_region_id == 432 .or. &
                     element_region_id == 442 .or. element_region_id == 452 .or. element_region_id == 462) then
                calculate_nsku_reaction_coefficient = &
                    0.0_db
            else if (400 <= element_region_id .and. element_region_id <= 499) then
                translated_point = translate_placenta_to_placentone_point(problem_dim, global_point, element_region_id)

                calculate_nsku_reaction_coefficient = nsku_reaction_coefficient* &
                    calculate_placentone_pipe_transition(translated_point, problem_dim, element_region_id, steepness)

            else if (500 <= element_region_id .and. element_region_id <= 599) then
                translated_point = translate_placenta_to_placentone_point(problem_dim, global_point, element_region_id)

                calculate_nsku_reaction_coefficient = nsku_reaction_coefficient* &
                    calculate_placentone_cavity_transition(translated_point, problem_dim, element_region_id, steepness)

            else
                print *, "Error in calculate_nsku_reaction_coefficient. Missed case."
                print *, "element_region_id = ", element_region_id
                stop
            end if

        end if
    end function

    function calculate_nsku_pressure_coefficient(global_point, problem_dim, element_region_id)
        use param

        real(db)                                     :: calculate_nsku_pressure_coefficient
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: element_region_id

        calculate_nsku_pressure_coefficient = nsku_pressure_coefficient
    end function

    function calculate_nsku_time_coefficient(global_point, problem_dim, element_region_id)
        use param

        real(db)                                     :: calculate_nsku_time_coefficient
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: element_region_id

        calculate_nsku_time_coefficient = nsku_time_coefficient
    end function

    function calculate_nsku_forcing_coefficient(global_point, problem_dim, element_region_id)
        use param

        real(db)                                     :: calculate_nsku_forcing_coefficient
        integer, intent(in)                          :: problem_dim
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: element_region_id

        calculate_nsku_forcing_coefficient = nsku_forcing_coefficient
    end function

end module
