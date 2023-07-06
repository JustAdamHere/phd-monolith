module bcs_transport
    contains

    subroutine convert_transport_boundary_no(boundary_no, boundary_no_new)
        integer, intent(in)  :: boundary_no
        integer, intent(out) :: boundary_no_new

        if (boundary_no == 0) then
            boundary_no_new = 0
        else if (100 <= boundary_no .and. boundary_no <= 101) then
            boundary_no_new = 200
        else if (102 <= boundary_no .and. boundary_no <= 110) then
            boundary_no_new = 100
        else if (111 <= boundary_no .and. boundary_no <= 116) then
            boundary_no_new = 100
        else if (200 <= boundary_no .and. boundary_no <= 299) then
            boundary_no_new = 200
        else
            print *, "Error: no transport boundary to convert to"
            print *, boundary_no
            stop
        end if

        ! if (boundary_no == 0) then
        !     boundary_no_new = 0
        ! else if (boundary_no == 100) then
        !     boundary_no_new = 200
        ! else if (boundary_no == 101) then
        !     boundary_no_new = 200
        ! else if (boundary_no == 102) then
        !     boundary_no_new = 100
        ! else if (boundary_no == 200) then
        !     boundary_no_new = 200
        ! else
        !     print *, "Error: no transport boundary to convert to"
        !     print *, boundary_no
        !     stop
        ! end if
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

        u = 0.0_db
        !if (boundary_no == 100 .and. mod(local_t, 40.0_db) < 16.0_db) then
        if (boundary_no == 100) then
            !u = 1.0_db * (0.6_db + (sin(global_t*pi))*0.4_db) ! Oscillates between 0.2 and 1.0.
            u = 1.0_db
        else if (boundary_no == 101) then
            u = 0.0_db
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

        u_1 = 0.0_db
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

        u_hessian = 0.0_db
    end subroutine

    subroutine forcing_function_transport(f, global_point, problem_dim, no_vars, local_t)
        use param
        use problem_options_transport

        implicit none

        real(db), dimension(no_vars), intent(out)    :: f
        real(db), dimension(problem_dim), intent(in) :: global_point
        integer, intent(in)                          :: problem_dim
        integer, intent(in)                          :: no_vars
        real(db), intent(in)                         :: local_t

        real(db) :: x, y

        real(db) :: global_t

        global_t = transport_time_coefficient*local_t

        x = global_point(1)
        y = global_point(2)

        f(1) = 0.0_db
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

        real(db), dimension(problem_dim)              :: u
        real(db), dimension(problem_dim, problem_dim) :: u_gradient

        real(db)               :: tol
        real(db)               :: x, y
        real(db)               :: u_x, u_y

        real(db) :: global_t

        global_t = transport_time_coefficient*local_t

        tol = 1.0d-7

        x = global_point(1)
        y = global_point(2)

        f = 0.0_db
    end subroutine
end module