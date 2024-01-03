module bcs_analytic_velocity
  implicit none

  contains

  subroutine analytic_2d_convert_velocity_boundary_no(boundary_no, boundary_no_new)
    integer, intent(in)  :: boundary_no
    integer, intent(out) :: boundary_no_new

    ! Interior.
    if (boundary_no == 0) then
      boundary_no_new = 0
    ! Bottom.
    else if (boundary_no == 101) then
      boundary_no_new = boundary_no
    ! Right.
    else if (boundary_no == 102) then
      boundary_no_new = boundary_no + 100
    ! Top.
    else if (boundary_no == 103) then
      boundary_no_new = boundary_no
    ! Left.
    else if (boundary_no == 104) then
      boundary_no_new = boundary_no + 100
    else
      print *, "Error: no Navier-Stokes+ku boundary to convert to"
      print *, boundary_no
      stop
    end if

  end subroutine

  subroutine analytic_2d_convert_velocity_region_id(region_id, region_id_new)
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

  subroutine analytic_2d_forcing_function_velocity(f, global_point, problem_dim, no_vars, t, element_region_id)
    use param
    use problem_options
    use problem_options_velocity

    implicit none

    real(db), dimension(no_vars), intent(out)    :: f
    real(db), dimension(problem_dim), intent(in) :: global_point
    integer, intent(in)                          :: problem_dim
    integer, intent(in)                          :: no_vars
    real(db), intent(in)                         :: t
    integer, intent(in)                          :: element_region_id

    real(db)                                  :: u1_xx, u1_yy, u2_xx, u2_yy, u1_t, u2_t
    real(db), dimension(no_vars)              :: u_exact
    real(db), dimension(no_vars, problem_dim) :: grad_u_exact
    real(db)                                  :: x, y
    real(db)                                  :: time_coefficient, diffusion_coefficient, convection_coefficient, &
      reaction_coefficient, pressure_coefficient

    ! real(db) :: re

    ! re = 40.0_db

    x = global_point(1)
    y = global_point(2)

    call analytic_2d_anal_soln_velocity(u_exact,global_point,problem_dim,no_vars,0,t,element_region_id)
    call analytic_2d_anal_soln_velocity_1(grad_u_exact,global_point,problem_dim,no_vars,t,element_region_id)

    time_coefficient       = calculate_velocity_time_coefficient      (global_point, problem_dim, element_region_id)
    diffusion_coefficient  = calculate_velocity_diffusion_coefficient (global_point, problem_dim, element_region_id)
    convection_coefficient = calculate_velocity_convection_coefficient(global_point, problem_dim, element_region_id)
    reaction_coefficient   = calculate_velocity_reaction_coefficient  (global_point, problem_dim, element_region_id)
    pressure_coefficient   = calculate_velocity_pressure_coefficient  (global_point, problem_dim, element_region_id)

    ! u1_t = 0.0_db
    ! u2_t = 0.0_db

    ! u1_xx = -(y*cos(y)+sin(y))*exp(x)
    ! u1_yy = -(-3.0_db*sin(y)-y*cos(y))*exp(x)

    ! u2_xx = y*sin(y)*exp(x)
    ! u2_yy = (-sin(y)*y+2.0_db*cos(y))*exp(x)

    if (no_time_steps > 0) then
      u1_t =  sin(t)*(y*cos(y)+sin(y))*exp(x)
      u2_t = -sin(t)*y*sin(y)*exp(x)
    else
      u1_t = 0.0_db
      u2_t = 0.0_db
    end if

    u1_xx = -cos(t)*(y*cos(y)+sin(y))*exp(x)
    u1_yy = -cos(t)*(-3.0_db*sin(y)-y*cos(y))*exp(x)

    u2_xx = cos(t)*y*sin(y)*exp(x)
    u2_yy = cos(t)*(-sin(y)*y+2.0_db*cos(y))*exp(x)

    f(1) = 0.0_db + &
      time_coefficient*u1_t - &
      diffusion_coefficient*(u1_xx + u1_yy) + &
      convection_coefficient*dot_product(u_exact(1:2), grad_u_exact(1, 1:2)) + &
      pressure_coefficient*grad_u_exact(3, 1) + &
      reaction_coefficient*u_exact(1)
    f(2) = 0.0_db + &
      time_coefficient*u2_t - &
      diffusion_coefficient*(u2_xx + u2_yy) + &
      convection_coefficient*dot_product(u_exact(1:2), grad_u_exact(2, 1:2)) + &
      pressure_coefficient*grad_u_exact(3, 2) + &
      reaction_coefficient*u_exact(2)
    f(3) = 0.0_db

    ! u1_t = 2.0_db*pi**2*(y*cos(y)+sin(y))*exp(x)*exp(-2.0_db*pi**2*t/re)/re
    ! u2_t = -2.0_db*pi**2*y*sin(y)*exp(x)*exp(-2.0_db*pi**2*t/re)/re

    ! u1_xx = -(y*cos(y)+sin(y))*exp(x)*exp(-2.0_db*pi**2*t/re)
    ! u1_yy = -(-3.0_db*sin(y)-y*cos(y))*exp(x)*exp(-2.0_db*pi**2*t/re)

    ! u2_xx = y*sin(y)*exp(x)*exp(-2.0_db*pi**2*t/re)
    ! u2_yy = (-sin(y)*y+2.0_db*cos(y))*exp(x)*exp(-2.0_db*pi**2*t/re)

    ! f(1) = u1_t + dot_product(u_exact(1:2),grad_u_exact(1,:)) - (u1_xx+u1_yy)/re + grad_u_exact(3,1) + u_exact(1)
    ! f(2) = u2_t + dot_product(u_exact(1:2),grad_u_exact(2,:)) - (u2_xx+u2_yy)/re + grad_u_exact(3,2) + u_exact(2)
    ! f(3) = 0.0_db

  end subroutine

  subroutine analytic_2d_anal_soln_velocity(u, global_point, problem_dim, no_vars, boundary_no, t, element_region_id)
    use param

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

    ! real(db) :: re

    ! re = 40.0_db

    u = 0.0_db

    x = global_point(1)
    y = global_point(2)

    ! u(1) = -(y*cos(y)+sin(y))*exp(x)
    ! u(2) =  y*sin(y)*exp(x)
    ! u(3) =  2.0_db*exp(x)*sin(y)

    u(1) = -cos(t)*(y*cos(y)+sin(y))*exp(x)
    u(2) =  cos(t)*y*sin(y)*exp(x)
    u(3) =  cos(t)*2.0_db*exp(x)*sin(y)

    ! u(1) = -(y*cos(y)+sin(y))*exp(x)*exp(-2.0_db*pi**2*t/re)
    ! u(2) = y*sin(y)*exp(x)*exp(-2.0_db*pi**2*t/re)
    ! u(3) = 2.0_db*exp(x)*sin(y)*exp(-2.0_db*pi**2*t/re)
  end subroutine

  subroutine analytic_2d_anal_soln_velocity_1(u_1, global_point, problem_dim, no_vars, t, element_region_id)
    use param

    implicit none

    real(db), dimension(no_vars, problem_dim), intent(out) :: u_1
    real(db), dimension(problem_dim), intent(in)           :: global_point
    integer, intent(in)                                    :: problem_dim
    integer, intent(in)                                    :: no_vars
    real(db), intent(in)                                   :: t
    integer, intent(in)                                    :: element_region_id

    real(db) :: x, y

    ! real(db) :: re

    ! re = 40.0_db

    x = global_point(1)
    y = global_point(2)

    ! u_1(1,1) = -(y*cos(y)+sin(y))*exp(x)
    ! u_1(1,2) = -(2.0_db*cos(y)-y*sin(y))*exp(x)

    ! u_1(2,1) = y*sin(y)*exp(x)
    ! u_1(2,2) = (sin(y)+y*cos(y))*exp(x)

    ! u_1(3,1) = 2.0_db*exp(x)*sin(y)
    ! u_1(3,2) = 2.0_db*exp(x)*cos(y)

    u_1(1,1) = -cos(t)*(y*cos(y)+sin(y))*exp(x)
    u_1(1,2) = -cos(t)*(2.0_db*cos(y)-y*sin(y))*exp(x)

    u_1(2,1) = cos(t)*y*sin(y)*exp(x)
    u_1(2,2) = cos(t)*(sin(y)+y*cos(y))*exp(x)

    u_1(3,1) = cos(t)*2.0_db*exp(x)*sin(y)
    u_1(3,2) = cos(t)*2.0_db*exp(x)*cos(y)

    ! u_1(1,1) = -(y*cos(y)+sin(y))*exp(x)*exp(-2.0_db*pi**2*t/re)
    ! u_1(1,2) = -(2.0_db*cos(y)-y*sin(y))*exp(x)*exp(-2.0_db*pi**2*t/re)

    ! u_1(2,1) = y*sin(y)*exp(x)*exp(-2.0_db*pi**2*t/re)
    ! u_1(2,2) = (sin(y)+y*cos(y))*exp(x)*exp(-2.0_db*pi**2*t/re)

    ! u_1(3,1) = 2.0_db*exp(x)*sin(y)*exp(-2.0_db*pi**2*t/re)
    ! u_1(3,2) = 2.0_db*exp(x)*cos(y)*exp(-2.0_db*pi**2*t/re)
  end subroutine

  subroutine analytic_2d_get_boundary_no_velocity(boundary_no, strongly_enforced_bcs, global_point, face_coords, no_face_vert,&
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

  subroutine analytic_2d_dirichlet_bc_velocity(u, global_point, problem_dim, no_vars, boundary_no, t)
    use param

    implicit none

    integer, intent(in)                           :: problem_dim, no_vars
    real(db), dimension(no_vars), intent(out)     :: u
    real(db), dimension(problem_dim), intent(in)  :: global_point
    integer, intent(in)                           :: boundary_no
    real(db), intent(in)                          :: t

    real(db), dimension(no_vars) :: sol

    call analytic_2d_anal_soln_velocity(sol, global_point, problem_dim, no_vars, boundary_no, t, -1)

    u(1:no_vars) = sol(1:no_vars)

  end subroutine

  subroutine analytic_2d_neumann_bc_velocity(un, global_point, problem_dim, boundary_no, t, element_region_id, normal)
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

    real(db)                                        :: x, y
    real(db), dimension(problem_dim+1)              :: u
    real(db), dimension(problem_dim+1, problem_dim) :: grad_u

    un = 0.0_db

    x = global_point(1)
    y = global_point(2)

    call analytic_2d_anal_soln_velocity(u,global_point,problem_dim,problem_dim+1,0,t,element_region_id)
    call analytic_2d_anal_soln_velocity_1(grad_u,global_point,problem_dim,problem_dim+1,t,element_region_id)

    un(1) = dot_product(grad_u(1,:),normal)-u(problem_dim+1)*normal(1)
    un(2) = dot_product(grad_u(2,:),normal)-u(problem_dim+1)*normal(2)
  end subroutine

end module