module placentone_2d_bcs_velocity
  implicit none

  contains

  subroutine placentone_2d_convert_velocity_boundary_no(boundary_no, boundary_no_new)
    integer, intent(in)  :: boundary_no
    integer, intent(out) :: boundary_no_new

    if (boundary_no == 0) then
      boundary_no_new = 0
    else if (100 <= boundary_no .and. boundary_no <= 199) then
      boundary_no_new = boundary_no
    else if (200 <= boundary_no .and. boundary_no <= 299) then
      boundary_no_new = boundary_no
    else
      print *, "Error: no Navier-Stokes+ku boundary to convert to"
      print *, boundary_no
      stop
    end if

  end subroutine

  subroutine placentone_2d_convert_velocity_region_id(region_id, region_id_new)
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

  subroutine placentone_2d_forcing_function_velocity(f, global_point, problem_dim, no_vars, t, element_region_id)
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
    real(db)                                  :: x, y
    real(db)                                  :: diffusion_coefficient

    x = global_point(1)
    y = global_point(2)

    f = 0.0_db

  end subroutine

  subroutine placentone_2d_anal_soln_velocity(u, global_point, problem_dim, no_vars, boundary_no, t, element_region_id)
    use param
    use problem_options
    use problem_options_velocity
    use problem_options_geometry

    implicit none

    real(db), dimension(no_vars), intent(out)    :: u
    real(db), dimension(problem_dim), intent(in) :: global_point
    integer, intent(in)                          :: problem_dim
    integer, intent(in)                          :: no_vars
    integer, intent(in)                          :: boundary_no
    real(db), intent(in)                         :: t
    integer, intent(in)                          :: element_region_id

    real(db) :: x, y, r
    real(db) :: left, right
    real(db) :: amplitude
    real(db) :: global_time ! TODO: check relationship between local and global t

    u = 0.0_db

    x = global_point(1)
    y = global_point(2)

    if (boundary_no == 111) then
        r    = sqrt((x - vessel_locations(1, 2))**2 + (0.0_db - 0.0_db)**2)
        ! u(2) = current_velocity_amplitude * calculate_poiseuille_flow(r, artery_width_sm/2)
        u(2) = 1.0_db * calculate_poiseuille_flow(r, artery_width_sm/2)

        if (u(2) <= -1e-5) then
          print *, "Error: inflow velocity negative"
          print *, u(2)
          stop
        end if
    end if
  end subroutine

  subroutine placentone_2d_anal_soln_velocity_1(u_1, global_point, problem_dim, no_vars, t, element_region_id)
    use param
    use problem_options

    implicit none

    real(db), dimension(no_vars, problem_dim), intent(out) :: u_1
    real(db), dimension(problem_dim), intent(in)           :: global_point
    integer, intent(in)                                    :: problem_dim
    integer, intent(in)                                    :: no_vars
    real(db), intent(in)                                   :: t
    integer, intent(in)                                    :: element_region_id

    u_1 = 0.0_db
  end subroutine

  subroutine placentone_2d_get_boundary_no_velocity(boundary_no, strongly_enforced_bcs, global_point, face_coords, no_face_vert,&
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

    if (fe_space_velocity == 'DG') then
      strongly_enforced_bcs = '000'
    else
      strongly_enforced_bcs = '110'

      if (200 <= abs(boundary_no) .and. abs(boundary_no) <= 299) then
        strongly_enforced_bcs = '000'
      end if
    end if
  end subroutine

  subroutine placentone_2d_dirichlet_bc_velocity(u, global_point, problem_dim, no_vars, boundary_no, t)
    use param

    implicit none

    integer, intent(in)                           :: problem_dim, no_vars
    real(db), dimension(no_vars), intent(out)     :: u
    real(db), dimension(problem_dim), intent(in)  :: global_point
    integer, intent(in)                           :: boundary_no
    real(db), intent(in)                          :: t

    real(db), dimension(no_vars) :: sol

    call placentone_2d_anal_soln_velocity(sol, global_point, problem_dim, no_vars, boundary_no, t, -1)

    u(1:no_vars) = sol(1:no_vars)

  end subroutine

  subroutine placentone_2d_neumann_bc_velocity(un, global_point, problem_dim, boundary_no, t, element_region_id, normal)
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

    un = 0.0_db
  end subroutine

end module