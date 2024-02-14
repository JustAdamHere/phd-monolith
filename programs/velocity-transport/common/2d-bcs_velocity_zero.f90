module bcs_zero_velocity
  implicit none

  contains

  subroutine zero_2d_convert_velocity_boundary_no(boundary_no, boundary_no_new)
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
      boundary_no_new = boundary_no
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

  subroutine zero_2d_convert_velocity_region_id(region_id, region_id_new)
    integer, intent(in)  :: region_id
    integer, intent(out) :: region_id_new

    region_id_new = region_id

  end subroutine

  subroutine zero_2d_forcing_function_velocity(f, global_point, problem_dim, no_vars, t, element_region_id)
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

    f = 0.0_db

  end subroutine

  subroutine zero_2d_anal_soln_velocity(u, global_point, problem_dim, no_vars, boundary_no, t, element_region_id)
    use param

    implicit none

    real(db), dimension(no_vars), intent(out)    :: u
    real(db), dimension(problem_dim), intent(in) :: global_point
    integer, intent(in)                          :: problem_dim
    integer, intent(in)                          :: no_vars
    integer, intent(in)                          :: boundary_no
    real(db), intent(in)                         :: t
    integer, intent(in)                          :: element_region_id

    u = 0.0_db
  end subroutine

  subroutine zero_2d_anal_soln_velocity_1(u_1, global_point, problem_dim, no_vars, t, element_region_id)
    use param

    implicit none

    real(db), dimension(no_vars, problem_dim), intent(out) :: u_1
    real(db), dimension(problem_dim), intent(in)           :: global_point
    integer, intent(in)                                    :: problem_dim
    integer, intent(in)                                    :: no_vars
    real(db), intent(in)                                   :: t
    integer, intent(in)                                    :: element_region_id

    u_1 = 0.0_db
  end subroutine

  subroutine zero_2d_get_boundary_no_velocity(boundary_no, strongly_enforced_bcs, global_point, face_coords, no_face_vert,&
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

  subroutine zero_2d_dirichlet_bc_velocity(u, global_point, problem_dim, no_vars, boundary_no, t)
    use param

    implicit none

    integer, intent(in)                           :: problem_dim, no_vars
    real(db), dimension(no_vars), intent(out)     :: u
    real(db), dimension(problem_dim), intent(in)  :: global_point
    integer, intent(in)                           :: boundary_no
    real(db), intent(in)                          :: t

    real(db), dimension(no_vars) :: sol

    call zero_2d_anal_soln_velocity(sol, global_point, problem_dim, no_vars, boundary_no, t, -1)

    u(1:no_vars) = sol(1:no_vars)

  end subroutine

  subroutine zero_2d_neumann_bc_velocity(un, global_point, problem_dim, boundary_no, t, element_region_id, normal)
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

    call zero_2d_anal_soln_velocity(u,global_point,problem_dim,problem_dim+1,0,t,element_region_id)
    call zero_2d_anal_soln_velocity_1(grad_u,global_point,problem_dim,problem_dim+1,t,element_region_id)

    un(1) = dot_product(grad_u(1,:),normal)-u(problem_dim+1)*normal(1)
    un(2) = dot_product(grad_u(2,:),normal)-u(problem_dim+1)*normal(2)
  end subroutine

end module