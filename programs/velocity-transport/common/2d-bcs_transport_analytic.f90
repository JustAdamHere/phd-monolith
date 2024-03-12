module bcs_transport
  save

  logical :: is_analytic_solution = .false.

  contains

  subroutine setup_transport_bcs(geometry_name)
    character(len=50), intent(in) :: geometry_name

    if (geometry_name(1:6) == 'square') then
        is_analytic_solution = .true.
    else
        is_analytic_solution = .false.
    end if
  end subroutine

  subroutine convert_transport_boundary_no(boundary_no, boundary_no_new)
      integer, intent(in)  :: boundary_no
      integer, intent(out) :: boundary_no_new

      if (is_analytic_solution) then
        ! Interior.
        if (boundary_no == 0) then
            boundary_no_new = 0
        ! Bottom.
        else if (boundary_no == 101) then
            boundary_no_new = boundary_no
        ! Right.
        else if (boundary_no == 102) then
            boundary_no_new = boundary_no
        ! Top.
        else if (boundary_no == 103) then
            boundary_no_new = boundary_no + 100
        ! Left.
        else if (boundary_no == 104) then
            boundary_no_new = boundary_no + 100
        else
            print *, "Error: no transport boundary to convert to"
            print *, boundary_no
            stop
        end if
      else
        if (boundary_no == 0) then
            boundary_no_new = 0
        else if (100 <= boundary_no .and. boundary_no <= 101) then
            boundary_no_new = 200
        else if (102 <= boundary_no .and. boundary_no <= 110) then
            boundary_no_new = 100
        else if (111 <= boundary_no .and. boundary_no <= 117) then
            boundary_no_new = 100
        else if (200 <= boundary_no .and. boundary_no <= 299) then
            boundary_no_new = 200
        else
            print *, "Error: no transport boundary to convert to"
            print *, boundary_no
            stop
        end if
      end if
  end subroutine

  subroutine get_boundary_no_transport(boundary_no, strongly_enforced_bcs, global_point, face_coords, no_face_vert, problem_dim,&
          mesh_data)
      use param
      use problem_options_transport
      use fe_mesh

      implicit none

      integer, intent(inout)                                     :: boundary_no
      character(len=nvmax), intent(out)                          :: strongly_enforced_bcs
      real(db), dimension(problem_dim), intent(in)               :: global_point
      real(db), dimension(no_face_vert, problem_dim), intent(in) :: face_coords
      integer, intent(in)                                        :: no_face_vert
      integer, intent(in)                                        :: problem_dim
      type(mesh), intent(in)                                     :: mesh_data

      real(db) :: x, y
      real(db) :: tol

      strongly_enforced_bcs = '0'

      ! if (abs(x) < tol) then
      !  boundary_no = 1
      ! else if (abs(y) < tol) then
      !  boundary_no = 2
      ! else if (abs(x-1.0_db) < tol) then
      !  boundary_no = 103
      ! else if (abs(y-1.0_db) < tol) then
      !  boundary_no = 4
      ! else
      !  print *,'Error: boundary not found'
      !  stop
      ! end if
  end subroutine

  subroutine anal_soln_transport(u, global_point, problem_dim, no_vars, boundary_no, local_t)
      use param
      use problem_options_transport

      implicit none

      real(db), dimension(no_vars), intent(out)    :: u
      real(db), dimension(problem_dim), intent(in) :: global_point
      integer, intent(in)                          :: problem_dim
      integer, intent(in)                          :: no_vars
      integer, intent(in)                          :: boundary_no
      real(db), intent(in)                         :: local_t

      real(db) :: global_t

      global_t = transport_time_coefficient*local_t

      if (is_analytic_solution) then
        u = exp(global_point(1) - global_point(2))*cos(global_t)
      else
        if (boundary_no == 100) then
            !u = 1.0_db * (0.6_db + (sin(global_t*pi))*0.4_db) ! Oscillates between 0.2 and 1.0.
            u = 1.0_db
        else if (boundary_no == 101) then
            u = 0.0_db
        end if
      end if
  end subroutine

  subroutine anal_soln_gradient_transport(u_1, global_point, problem_dim, no_vars, local_t)
      use param
      use problem_options_transport

      implicit none

      real(db), dimension(no_vars, problem_dim), intent(out) :: u_1
      real(db), dimension(problem_dim), intent(in)           :: global_point
      integer, intent(in)                                    :: problem_dim
      integer, intent(in)                                    :: no_vars
      real(db), intent(in)                                   :: local_t

      real(db) :: global_t

      global_t = transport_time_coefficient*local_t

      if (is_analytic_solution) then
        u_1(1, 1) =  exp(global_point(1) - global_point(2))*cos(global_t)
        u_1(1, 2) = -exp(global_point(1) - global_point(2))*cos(global_t)
      else
        u_1 = 0.0_db
      end if
  end subroutine

  subroutine anal_soln_hessian_transport(u_hessian, global_point, problem_dim, no_vars, local_t)
      use param
      use problem_options_transport

      implicit none

      real(db), dimension(no_vars, problem_dim, problem_dim), intent(out) :: u_hessian
      real(db), dimension(problem_dim), intent(in)                        :: global_point
      integer, intent(in)                                                 :: problem_dim
      integer, intent(in)                                                 :: no_vars
      real(db), intent(in)                                                :: local_t

      real(db) :: global_t

      global_t = transport_time_coefficient*local_t

      if (is_analytic_solution) then
        u_hessian(1, 1, 1) =  exp(global_point(1) - global_point(2))*cos(global_t)
        u_hessian(1, 1, 2) = -exp(global_point(1) - global_point(2))*cos(global_t)
        u_hessian(1, 2, 1) = -exp(global_point(1) - global_point(2))*cos(global_t)
        u_hessian(1, 2, 2) =  exp(global_point(1) - global_point(2))*cos(global_t)
      else
        u_hessian = 0.0_db
      end if
  end subroutine

  subroutine forcing_function_transport(f, global_point, problem_dim, no_vars, local_t)
      use param
      use problem_options_transport
      use velocity_bc_interface

      implicit none

      real(db), dimension(no_vars), intent(out)    :: f
      real(db), dimension(problem_dim), intent(in) :: global_point
      integer, intent(in)                          :: problem_dim
      integer, intent(in)                          :: no_vars
      real(db), intent(in)                         :: local_t

      real(db) :: x, y, global_t
      real(db) :: c_t, c_xx, c_yy, c_x, c_y, c
      real(db), dimension(problem_dim+1) :: u
      real(db), dimension(problem_dim+1, problem_dim) :: u_1

      global_t = transport_time_coefficient*local_t

      x = global_point(1)
      y = global_point(2)

      if (is_analytic_solution) then
        c    =  exp(x - y)*cos(global_t)
        c_t  = -exp(x - y)*sin(global_t)
        c_x  =  exp(x - y)*cos(global_t)
        c_y  = -exp(x - y)*cos(global_t)
        c_xx =  exp(x - y)*cos(global_t)
        c_yy =  exp(x - y)*cos(global_t)

        call anal_soln_velocity(u, global_point, problem_dim, problem_dim+1, 0, local_t, 0)
        call anal_soln_velocity_1(u_1, global_point, problem_dim, problem_dim+1, local_t, 0)

        f = &
          c_t*transport_time_coefficient - &
          (c_xx + c_yy)*transport_diffusion_coefficient + &
          (u(1)*c_x + u_1(1, 1)*c)*transport_convection_coefficient + &
          (u(2)*c_y + u_1(2, 2)*c)*transport_convection_coefficient + &
          c*transport_reaction_coefficient
      else
        f = 0.0_db
      end if
  end subroutine

  subroutine neumann_bc_transport(f, global_point, problem_dim, no_vars, local_t, normal)
      use param
      use problem_options_transport

      implicit none

      real(db), dimension(no_vars), intent(out)    :: f
      real(db), dimension(problem_dim), intent(in) :: global_point
      integer, intent(in)                          :: problem_dim
      integer, intent(in)                          :: no_vars
      real(db), intent(in)                         :: local_t
      real(db), dimension(problem_dim), intent(in) :: normal

      real(db) :: global_t

      real(db), dimension(problem_dim) :: c_1

      global_t = transport_time_coefficient*local_t

      if (is_analytic_solution) then
        call anal_soln_gradient_transport(c_1, global_point, problem_dim, no_vars, local_t)
        f = dot_product(c_1, normal)
      else
        f = 0.0_db
      end if
  end subroutine
end module