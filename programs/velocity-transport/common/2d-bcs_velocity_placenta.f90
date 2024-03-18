module placenta_2d_bcs_velocity
  implicit none

  contains

  subroutine placenta_2d_convert_velocity_boundary_no(boundary_no, boundary_no_new)
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

  subroutine placenta_2d_convert_velocity_region_id(region_id, region_id_new)
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

  subroutine placenta_2d_forcing_function_velocity(f, global_point, problem_dim, no_vars, t, element_region_id)
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

  subroutine placenta_2d_anal_soln_velocity(u, global_point, problem_dim, no_vars, boundary_no, t, element_region_id)
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

    real(db)                         :: r, radius
    real(db), dimension(problem_dim) :: centre_top, centre_bc
    real(db)                         :: theta_bc, theta_top
    real(db)                         :: amplitude
    integer                          :: placentone_no

    u = 0.0_db

    if (111 <= boundary_no .and. boundary_no <= 117) then
      placentone_no = boundary_no-110

      ! Select arteries.
      centre_top(1) = vessel_tops  (placentone_no, 2, 1)
      centre_top(2) = vessel_tops  (placentone_no, 2, 2)
      theta_top     = vessel_angles(placentone_no, 2)
      
      theta_bc  = theta_top
      radius    = boundary_radius
      ! centre_bc(1) = x_centre + radius*cos(theta_bc) + artery_length*cos(theta_bc)
      ! centre_bc(2) = y_centre - ((radius+artery_length)**2 - (centre_bc(1) - x_centre)**2)**0.5
      centre_bc(1) = (artery_sides(placentone_no, 1, 1) + artery_sides(placentone_no, 2, 1))/2.0_db
      centre_bc(2) = (artery_sides(placentone_no, 1, 2) + artery_sides(placentone_no, 2, 2))/2.0_db

      if (normalise_inlet_velocity) then
        amplitude = 0.0125_db/artery_width_sm
      else
        amplitude = 1.0_db
      end if

      r    = sqrt((global_point(1) - centre_bc(1))**2 + (global_point(2) - centre_bc(2))**2)
      ! u    = current_velocity_amplitude * calculate_poiseuille_flow(r, artery_width_sm/2.0_db)
      u    = amplitude * calculate_poiseuille_flow(r, artery_width_sm/2.0_db)
      u(1) = -u(1) * cos(theta_bc)
      u(2) =  u(2) * sin(theta_bc)
    end if

    ! if (boundary_no == 111) then
    !   print *, "centre_bc = ", centre_bc
    !   print *, "u = ", u

    ! end if

    if (moving_mesh .and. .not. compute_ss_flag) then
      u(1:2) = u(1:2) + calculate_mesh_velocity(global_point, problem_dim, t)
    end if

    ! if (u(2) <= -1e-5) then
    !     print *, "Error: vertical inflow velocity negative"
    !     print *, "boundary_no = ", boundary_no
    !     print *, "r = ", r
    !     print *, "centre = ", x_centre, y_centre
    !     print *, "radius = ", radius
    !     print *, "centre_top = ", centre_top(1), centre_top(2)
    !     print *, "theta_top = ", theta_top
    !     print *, "centre_bc = ", centre_bc
    !     print *, "artery_width_sm = ", artery_width_sm
    !     print *, "no_placentones = ", no_placentones
    !     print *, "placentone_widths = ", placentone_widths
    !     print *, "cumulative_placentone_widths = ", cumulative_placentone_widths
    !     print *, "current_velocity_amplitude = ", current_velocity_amplitude
    !     print *, "velocity = ", u(1), u(2)
    !     stop
    ! end if

    ! if (u(1)**2 + u(2)**2 >= 1.0 + 1e-5) then
    !     print *, "Error: inflow velocity maxima too high"
    !     print *, u(1)**2 + u(2)**2
    !     stop
    ! end if
  end subroutine

  subroutine placenta_2d_anal_soln_velocity_1(u_1, global_point, problem_dim, no_vars, t, element_region_id)
    use param
    use problem_options

    implicit none

    real(db), dimension(no_vars, problem_dim), intent(out) :: u_1
    real(db), dimension(problem_dim), intent(in)           :: global_point
    integer, intent(in)                                    :: problem_dim
    integer, intent(in)                                    :: no_vars
    real(db), intent(in)                                   :: t
    integer, intent(in)                                    :: element_region_id

    real(db) :: x, y
    real(db) :: diffusion_coefficient

    x = global_point(1)
    y = global_point(2)

    u_1 = 0.0_db
  end subroutine

  subroutine placenta_2d_get_boundary_no_velocity(boundary_no, strongly_enforced_bcs, global_point, face_coords, no_face_vert,&
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

    real(db) :: x, y, tol

    strongly_enforced_bcs = '000'

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

  subroutine placenta_2d_dirichlet_bc_velocity(u, global_point, problem_dim, no_vars, boundary_no, t)
    use param

    implicit none

    integer, intent(in)                           :: problem_dim, no_vars
    real(db), dimension(no_vars), intent(out)     :: u
    real(db), dimension(problem_dim), intent(in)  :: global_point
    integer, intent(in)                           :: boundary_no
    real(db), intent(in)                          :: t

    real(db), dimension(no_vars) :: sol

    call placenta_2d_anal_soln_velocity(sol, global_point, problem_dim, no_vars, boundary_no, t, -1)

    u(1:no_vars) = sol(1:no_vars)

  end subroutine

  subroutine placenta_2d_neumann_bc_velocity(un, global_point, problem_dim, boundary_no, t, element_region_id, normal)
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
    real(db)                                        :: x, y
    real(db)                                        :: diffusion_coefficient, pressure_coefficient

    x = global_point(1)
    y = global_point(2)

    un = 0.0_db
  end subroutine

end module