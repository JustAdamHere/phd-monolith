module problem_options_velocity
    use aptofem_kernel

    save

    real(db)         :: velocity_diffusion_coefficient, velocity_convection_coefficient, &
        velocity_pressure_coefficient, velocity_forcing_coefficient, &
        velocity_reaction_coefficient, velocity_time_coefficient, reynold_ramp_start_ratio, reynold_ramp_step_base, &
        current_velocity_amplitude
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

    function calculate_poiseuille_flow(r, r_tot)
        use param

        real(db)             :: calculate_poiseuille_flow
        real(db), intent(in) :: r, r_tot

        calculate_poiseuille_flow = 1.0_db - (r/r_tot)**2
    end function

    subroutine Boileau_velocity_amplitude(global_time)
        use param
    
        implicit none
    
        real(db), intent(in)  :: global_time
    
        real(db) :: period, offset_time
    
        period      = 1.0_db
        !offset_time = global_time + 0.055_db
        offset_time = global_time + 0.184_db
    
        current_velocity_amplitude = (1e-6)/1.3303206357558143e-05 * ( &
            6.5 &
            +3.294_db    *sin(2* pi*offset_time/period - 0.023974_db) &
            +1.9262_db   *sin(4* pi*offset_time/period - 1.1801_db) &
            -1.4219_db   *sin(6* pi*offset_time/period + 0.92701_db) &
            -0.66627_db  *sin(8* pi*offset_time/period - 0.24118_db) &
            -0.33933_db  *sin(10*pi*offset_time/period - 0.27471_db) &
            -0.37914_db  *sin(12*pi*offset_time/period - 1.0557_db) &
            +0.22396_db  *sin(14*pi*offset_time/period + 1.22_db) &
            +0.1507_db   *sin(16*pi*offset_time/period + 1.0984_db) &
            +0.18735_db  *sin(18*pi*offset_time/period + 0.067483_db) &
            +0.038625_db *sin(20*pi*offset_time/period + 0.22262_db) &
            +0.012643_db *sin(22*pi*offset_time/period - 0.10093_db) &
            -0.0042453_db*sin(24*pi*offset_time/period - 1.1044_db) &
            -0.012781_db *sin(26*pi*offset_time/period - 1.3739_db) &
            +0.014805_db *sin(28*pi*offset_time/period + 1.2797_db) &
            +0.012249_db *sin(30*pi*offset_time/period + 0.80827_db) &
            +0.0076502_db*sin(32*pi*offset_time/period + 0.40757_db) &
            +0.0030692_db*sin(34*pi*offset_time/period + 0.195_db) &
            -0.0012271_db*sin(36*pi*offset_time/period - 1.1371_db) &
            -0.0042581_db*sin(38*pi*offset_time/period - 0.92102_db) &
            -0.0069785_db*sin(40*pi*offset_time/period - 1.2364_db) &
            +0.0085652_db*sin(42*pi*offset_time/period + 1.4539_db) &
            +0.0081881_db*sin(44*pi*offset_time/period + 0.89599_db) &
            +0.0056549_db*sin(46*pi*offset_time/period + 0.17623_db) &
            +0.0026358_db*sin(48*pi*offset_time/period - 1.3003_db) &
            -0.0050868_db*sin(50*pi*offset_time/period - 0.011056_db) &
            -0.0085829_db*sin(52*pi*offset_time/period - 0.86463_db) &
        ) ! [m3/s]
    end subroutine

    subroutine Carson_velocity_amplitude(global_time)
        use param
    
        implicit none
    
        real(db), intent(in)  :: global_time
    
        real(db), dimension(104) :: sample_t, sample_u
        real(db)                 :: t_range, current_t, weight
        integer                  :: found_index, i

        ! Taken from https://apps.automeris.io/wpd/
        !  Data from Fig4 H in [Carson, 2021] 
        sample_t = (/&
            0.32918, &
            0.33902, &
            0.34897, &
            0.35569, &
            0.36334, &
            0.37005, &
            0.37473, &
            0.37795, &
            0.38308, &
            0.38656, &
            0.38984, &
            0.39113, &
            0.39476, &
            0.39804, &
            0.40131, &
            0.40459, &
            0.40787, &
            0.41291, &
            0.41607, &
            0.41935, &
            0.42590, &
            0.43273, &
            0.44038, &
            0.44722, &
            0.45377, &
            0.46033, &
            0.46689, &
            0.47344, &
            0.48000, &
            0.48656, &
            0.49377, &
            0.50213, &
            0.50869, &
            0.51771, &
            0.52754, &
            0.53738, &
            0.54721, &
            0.55705, &
            0.56689, &
            0.57672, &
            0.58656, &
            0.59639, &
            0.60623, &
            0.61606, &
            0.62590, &
            0.63574, &
            0.64557, &
            0.65541, &
            0.66524, &
            0.67508, &
            0.68492, &
            0.69475, &
            0.70459, &
            0.71442, &
            0.72426, &
            0.73409, &
            0.74393, &
            0.75377, &
            0.76360, &
            0.77344, &
            0.78327, &
            0.79311, &
            0.80295, &
            0.81278, &
            0.82262, &
            0.83196, &
            0.83819, &
            0.84100, &
            0.84475, &
            0.84680, &
            0.85008, &
            0.85335, &
            0.85695, &
            0.86041, &
            0.86401, &
            0.86770, &
            0.87016, &
            0.87344, &
            0.87671, &
            0.87999, &
            0.88327, &
            0.88655, &
            0.88983, &
            0.89311, &
            0.89639, &
            0.89967, &
            0.90294, &
            0.90622, &
            0.90950, &
            0.91278, &
            0.91641, &
            0.91969, &
            0.92453, &
            0.92945, &
            0.93475, &
            0.93901, &
            0.94393, &
            0.94896, &
            0.95540, &
            0.96196, &
            0.96879, &
            0.97709, &
            0.98655, &
            0.99638  &
        /)

        sample_u = (/&
            140.66,  &
            140.40,  &
            139.08,  &
            137.32,  &
            135.65,  &
            133.41,  &
            131.14,  &
            129.03,  &
            126.76,  &
            124.43,  &
            122.33,  &
            120.24,  &
            118.02,  &
            115.52,  &
            113.00,  &
            110.43,  &
            107.93,  &
            105.52,  &
            103.29,  &
            101.59,  &
            99.682,  &
            97.637,  &
            95.718,  &
            93.596,  &
            91.417,  &
            89.086,  &
            86.820,  &
            84.641,  &
            82.591,  &
            80.713,  &
            78.858,  &
            77.477,  &
            76.139,  &
            74.945,  &
            73.420,  &
            71.981,  &
            70.600,  &
            69.420,  &
            68.327,  &
            67.406,  &
            66.572,  &
            65.852,  &
            65.133,  &
            64.356,  &
            63.666,  &
            62.975,  &
            62.285,  &
            61.594,  &
            60.904,  &
            60.127,  &
            59.321,  &
            58.602,  &
            57.854,  &
            57.106,  &
            56.329,  &
            55.581,  &
            54.832,  &
            54.113,  &
            53.308,  &
            52.617,  &
            51.926,  &
            51.236,  &
            50.517,  &
            49.941,  &
            50.171,  &
            51.685,  &
            54.305,  &
            56.760,  &
            58.961,  &
            61.982,  &
            65.176,  &
            68.197,  &
            71.300,  &
            74.446,  &
            77.218,  &
            79.817,  &
            82.425,  &
            84.612,  &
            86.684,  &
            88.755,  &
            90.827,  &
            92.899,  &
            94.970,  &
            97.042,  &
            99.114,  &
            101.21,  &
            103.37,  &
            105.56,  &
            107.75,  &
            109.79,  &
            111.95,  &
            114.20,  &
            116.63,  &
            119.22,  &
            121.79,  &
            124.43,  &
            126.48,  &
            128.58,  &
            130.78,  &
            132.87,  &
            134.98,  &
            136.91,  &
            139.22,  &
            140.40  &
        /)

        sample_t = sample_t - 0.32918_db
        t_range  = sample_t(104) - sample_t(1)

        sample_u = sample_u / 140.66_db

        found_index = 1
        do i = 1, 103
            current_t = mod(global_time, t_range)

            if (sample_t(i) <= current_t .and. current_t <= sample_t(i+1)) then
                found_index = i
                exit
            end if
        end do

        weight = (current_t - sample_t(found_index)) / (sample_t(found_index+1) - sample_t(found_index))

        current_velocity_amplitude = sample_u(found_index) + weight * (sample_u(found_index+1) - sample_u(found_index))

    end subroutine

end module
