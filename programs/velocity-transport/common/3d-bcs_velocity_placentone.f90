module bcs_velocity
  implicit none

  contains

  subroutine convert_velocity_boundary_no(boundary_no, boundary_no_new)
    integer, intent(in)  :: boundary_no
    integer, intent(out) :: boundary_no_new

    ! if (boundary_no == 0) then
    !   boundary_no_new = 0
    ! else if (100 <= boundary_no .and. boundary_no <= 199) then
    !   boundary_no_new = boundary_no
    ! else if (200 <= boundary_no .and. boundary_no <= 299) then
    !   boundary_no_new = boundary_no
    ! else
    !   print *, "Error: no Navier-Stokes+ku boundary to convert to"
    !   print *, boundary_no
    !   stop
    ! end if

    boundary_no_new = boundary_no

  end subroutine

  subroutine convert_velocity_region_id(region_id, region_id_new)
    integer, intent(in)  :: region_id
    integer, intent(out) :: region_id_new

    ! if (region_id == -1) then
    !   region_id_new = -1
    ! else if (300 <= region_id .and. region_id <= 399) then
    !   region_id_new = 301
    ! else if (400 <= region_id .and. region_id <= 499) then
    !   region_id_new = 501
    ! else if (500 <= region_id .and. region_id <= 599) then
    !   region_id_new = 501
    ! else
    !   print *, "Error: no Navier-Stokes+ku region to convert to"
    !   print *, region_id
    !   stop
    ! end if

    region_id_new = region_id

  end subroutine

  subroutine forcing_function_velocity(f, global_point, problem_dim, no_vars, t, element_region_id)
    use param
    use problem_options

    implicit none

    real(db), dimension(no_vars), intent(out)    :: f
    real(db), dimension(problem_dim), intent(in) :: global_point
    integer, intent(in)                          :: problem_dim
    integer, intent(in)                          :: no_vars
    real(db), intent(in)                         :: t
    integer, intent(in)                          :: element_region_id

    real(db)                                  :: u1_xx, u1_yy, u2_xx, u2_yy, u1_t, u2_t
    real(db), dimension(no_vars)              :: u
    real(db), dimension(no_vars, problem_dim) :: grad_u
    real(db)                                  :: x, y, z
    real(db)                                  :: diffusion_coefficient

    x = global_point(1)
    y = global_point(2)
    z = global_point(3)

    f = 0.0_db

  end subroutine

  subroutine anal_soln_velocity(u, global_point, problem_dim, no_vars, boundary_no, t, element_region_id)
    use param
    use problem_options

    implicit none

    real(db), dimension(no_vars), intent(out)    :: u
    real(db), dimension(problem_dim), intent(in) :: global_point
    integer, intent(in)                          :: problem_dim
    integer, intent(in)                          :: no_vars
    integer, intent(in)                          :: boundary_no
    real(db), intent(in)                         :: t
    integer, intent(in)                          :: element_region_id

    real(db) :: x, y, z
    real(db) :: left, right
    real(db) :: amplitude
    real(db) :: global_time ! TODO: check relationship between local and global t
    real(db) :: artery_width_sm

    artery_width_sm = 0.0125_db ! 0.5mm

    u = 0.0_db

    x = global_point(1)
    y = global_point(2)
    z = global_point(3)

    if (boundary_no == 111) then
        u(2) = -2.0_db*(x-(artery_location-artery_width_sm/2))*(x-(artery_location+artery_width_sm/2)) + &
               -2.0_db*(z-(0.0_db         -artery_width_sm/2))*(z-(0.0_db         +artery_width_sm/2))

        u(2) = u(2) / (artery_width_sm**2)

        ! u(2) = u(2) * (0.6_db + (cos(t*pi))*0.4_db) ! Oscillates between 0.2 and 1.0.
        call Boileau_velocity_amplitude(amplitude, t)
        u(2) = u(2) * amplitude

        if (u(2) <= -1e-5) then
          print *, "Error: inflow velocity negative"
          print *, u(2)
          stop
        end if
    end if
  end subroutine

  subroutine Boileau_velocity_amplitude(amplitude, global_time)
    use param

    implicit none

    real(db), intent(out) :: amplitude
    real(db), intent(in)  :: global_time

    real(db) :: period, offset_time

    period      = 1.0_db
    !offset_time = global_time + 0.055_db
    offset_time = global_time + 0.184_db

    amplitude = (1e-6)/1.3303206357558143e-05 * ( &
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

  subroutine anal_soln_velocity_1(u_1, global_point, problem_dim, no_vars, t, element_region_id)
    use param
    use problem_options

    implicit none

    real(db), dimension(no_vars, problem_dim), intent(out) :: u_1
    real(db), dimension(problem_dim), intent(in)           :: global_point
    integer, intent(in)                                    :: problem_dim
    integer, intent(in)                                    :: no_vars
    real(db), intent(in)                                   :: t
    integer, intent(in)                                    :: element_region_id

    real(db) :: x, y, z
    real(db) :: diffusion_coefficient

    x = global_point(1)
    y = global_point(2)
    z = global_point(3)

    u_1 = 0.0_db
  end subroutine

  subroutine get_boundary_no_velocity(boundary_no, strongly_enforced_bcs, global_point, face_coords, no_face_vert,&
      problem_dim, mesh_data)
    use param
    use fe_mesh
    use problem_options_velocity

    implicit none

    integer, intent(inout)                                     :: boundary_no
    character(len=nvmax), intent(out)                          :: strongly_enforced_bcs
    real(db), dimension(problem_dim), intent(in)               :: global_point
    real(db), dimension(no_face_vert, problem_dim), intent(in) :: face_coords
    integer, intent(in)                                        :: no_face_vert
    integer, intent(in)                                        :: problem_dim
    type(mesh), intent(in)                                     :: mesh_data

    real(db) :: x, y, tol

    if (fe_space_velocity == 'DG') then
      strongly_enforced_bcs = '0000'
    else
      strongly_enforced_bcs = '1110'

      if (200 <= abs(boundary_no) .and. abs(boundary_no) <= 299) then
        strongly_enforced_bcs = '0000'
      end if
    end if

    !strongly_enforced_bcs = '111'

    ! x = global_point(1)
    ! y = global_point(2)

    ! tol = 1.0d-10

    ! if (abs(x - 1.0_db) <= tol) then
    !   boundary_no = 201
    ! else if (abs(x + 1.0_db) <= tol) then
    !   boundary_no = 102
    ! else if (abs(y - 1.0_db) <= tol) then
    !   boundary_no = 103
    ! else if (abs(y + 1.0_db) <= tol) then
    !   boundary_no = 104
    ! else if (abs(x) <= 0.0_db .and. y <= tol) then
    !   boundary_no = 105
    ! else if (abs(y) <= 0.0_db .and. x >= tol) then
    !   boundary_no = 106
    ! else
    !   print *, "Boundary unknown"
    !   print *, "x = ", x
    !   print *, "y = ", y
    !   stop
    ! end if
  end subroutine

  subroutine dirichlet_bc_velocity(u, global_point, problem_dim, no_vars, boundary_no, t)
    use param

    implicit none

    integer, intent(in)                           :: problem_dim, no_vars
    real(db), dimension(no_vars), intent(out)     :: u
    real(db), dimension(problem_dim), intent(in)  :: global_point
    integer, intent(in)                           :: boundary_no
    real(db), intent(in)                          :: t

    real(db), dimension(no_vars) :: sol

    call anal_soln_velocity(sol, global_point, problem_dim, no_vars, boundary_no, t, -1)

    u(1:no_vars) = sol(1:no_vars)

  end subroutine

  subroutine neumann_bc_velocity(un, global_point, problem_dim, boundary_no, t, element_region_id, normal)
    use param
    use problem_options

    implicit none

    integer, intent(in)                           :: problem_dim
    real(db), dimension(problem_dim), intent(out) :: un
    real(db), dimension(problem_dim), intent(in)  :: global_point
    integer, intent(in)                           :: boundary_no
    real(db), intent(in)                          :: t
    integer, intent(in)                           :: element_region_id
    real(db), dimension(problem_dim), intent(in)  :: normal

    real(db), dimension(problem_dim+1)              :: u
    real(db), dimension(problem_dim+1, problem_dim) :: u_1
    real(db)                                        :: x, y, z
    real(db)                                        :: diffusion_coefficient, pressure_coefficient

    x = global_point(1)
    y = global_point(2)
    z = global_point(3)

    un = 0.0_db
  end subroutine

end module