module velocity_bc_interface
  abstract interface
    subroutine if_convert_velocity_boundary_no(boundary_no, boundary_no_new)
      implicit none 

      integer, intent(in)  :: boundary_no
      integer, intent(out) :: boundary_no_new
    end subroutine

    subroutine if_convert_velocity_region_id(region_id, region_id_new)
      implicit none

      integer, intent(in)  :: region_id
      integer, intent(out) :: region_id_new
    end subroutine

    subroutine if_forcing_function_velocity(f, global_point, problem_dim, no_vars, t, element_region_id)
      use param
      implicit none

      real(db), dimension(no_vars), intent(out)    :: f
      real(db), dimension(problem_dim), intent(in) :: global_point
      integer, intent(in)                          :: problem_dim
      integer, intent(in)                          :: no_vars
      real(db), intent(in)                         :: t
      integer, intent(in)                          :: element_region_id
    end subroutine

    subroutine if_anal_soln_velocity(u, global_point, problem_dim, no_vars, boundary_no, t, element_region_id)
      use param
      implicit none

      real(db), dimension(no_vars), intent(out)    :: u
      real(db), dimension(problem_dim), intent(in) :: global_point
      integer, intent(in)                          :: problem_dim
      integer, intent(in)                          :: no_vars
      integer, intent(in)                          :: boundary_no
      real(db), intent(in)                         :: t
      integer, intent(in)                          :: element_region_id
    end subroutine

    subroutine if_anal_soln_velocity_1(u, global_point, problem_dim, no_vars, t, element_region_id)
      use param
      implicit none

      real(db), dimension(no_vars, problem_dim), intent(out)    :: u
      real(db), dimension(problem_dim), intent(in)              :: global_point
      integer, intent(in)                                       :: problem_dim
      integer, intent(in)                                       :: no_vars
      real(db), intent(in)                                      :: t
      integer, intent(in)                                       :: element_region_id
    end subroutine

    subroutine if_get_boundary_no_velocity(boundary_no, strongly_enforced_bcs, global_point, face_coords, no_face_vert, &
        problem_dim, mesh_data)
      use param
      use fe_mesh
      implicit none

      integer, intent(inout)                                     :: boundary_no
      character(len=*), intent(out)                              :: strongly_enforced_bcs
      real(db), dimension(problem_dim), intent(in)               :: global_point
      real(db), dimension(no_face_vert, problem_dim), intent(in) :: face_coords
      integer, intent(in)                                        :: no_face_vert
      integer, intent(in)                                        :: problem_dim
      type(mesh), intent(in)                                     :: mesh_data
    end subroutine

    subroutine if_dirichlet_bc_velocity(u, global_point, problem_dim, no_vars, boundary_no, t)
      use param
      implicit none

      integer, intent(in)                           :: problem_dim, no_vars
      real(db), dimension(no_vars), intent(out)     :: u
      real(db), dimension(problem_dim), intent(in)  :: global_point
      integer, intent(in)                           :: boundary_no
      real(db), intent(in)                          :: t
    end subroutine

    subroutine if_neumann_bc_velocity(un, global_point, problem_dim, boundary_no, t, element_region_id, normal)
      use param
      implicit none

      integer, intent(in)                           :: problem_dim
      real(db), dimension(problem_dim), intent(out) :: un
      real(db), dimension(problem_dim), intent(in)  :: global_point
      integer, intent(in)                           :: boundary_no
      real(db), intent(in)                          :: t
      integer, intent(in)                           :: element_region_id
      real(db), dimension(problem_dim), intent(in)  :: normal
    end subroutine
  end interface

  procedure (if_convert_velocity_boundary_no), pointer :: convert_velocity_boundary_no => null()
  procedure (if_convert_velocity_region_id), pointer   :: convert_velocity_region_id => null()
  procedure (if_forcing_function_velocity), pointer    :: forcing_function_velocity => null()
  procedure (if_anal_soln_velocity), pointer           :: anal_soln_velocity => null()
  procedure (if_anal_soln_velocity_1), pointer         :: anal_soln_velocity_1 => null()
  procedure (if_get_boundary_no_velocity), pointer     :: get_boundary_no_velocity => null()
  procedure (if_dirichlet_bc_velocity), pointer        :: dirichlet_bc_velocity => null()
  procedure (if_neumann_bc_velocity), pointer          :: neumann_bc_velocity => null()

  contains

  subroutine setup_velocity_bcs(geometry_name)
    use aptofem_kernel

    use placenta_2d_bcs_velocity
    use placentone_2d_bcs_velocity
    use placentone_3d_bcs_velocity

    use bcs_analytic_velocity
    use bcs_constant_up_velocity
    use bcs_constant_diagonal_velocity
    use bcs_etienne2009_velocity
    use bcs_etienne2009_ti_velocity
    use bcs_poiseuille_velocity
    use bcs_shear_velocity
    use bcs_tb_free_lr_solid_velocity
    use bcs_zero_velocity

    implicit none

    character(len=30), intent(in) :: geometry_name

    if (trim(geometry_name) == 'placentone') then
      convert_velocity_boundary_no => placentone_2d_convert_velocity_boundary_no
      convert_velocity_region_id   => placentone_2d_convert_velocity_region_id
      forcing_function_velocity    => placentone_2d_forcing_function_velocity
      anal_soln_velocity           => placentone_2d_anal_soln_velocity
      anal_soln_velocity_1         => placentone_2d_anal_soln_velocity_1
      get_boundary_no_velocity     => placentone_2d_get_boundary_no_velocity
      dirichlet_bc_velocity        => placentone_2d_dirichlet_bc_velocity
      neumann_bc_velocity          => placentone_2d_neumann_bc_velocity
    else if (trim(geometry_name) == 'placenta') then
      convert_velocity_boundary_no => placenta_2d_convert_velocity_boundary_no
      convert_velocity_region_id   => placenta_2d_convert_velocity_region_id
      forcing_function_velocity    => placenta_2d_forcing_function_velocity
      anal_soln_velocity           => placenta_2d_anal_soln_velocity
      anal_soln_velocity_1         => placenta_2d_anal_soln_velocity_1
      get_boundary_no_velocity     => placenta_2d_get_boundary_no_velocity
      dirichlet_bc_velocity        => placenta_2d_dirichlet_bc_velocity
      neumann_bc_velocity          => placenta_2d_neumann_bc_velocity
    else if (trim(geometry_name) == 'placentone-3d') then
      convert_velocity_boundary_no => placentone_3d_convert_velocity_boundary_no
      convert_velocity_region_id   => placentone_3d_convert_velocity_region_id
      forcing_function_velocity    => placentone_3d_forcing_function_velocity
      anal_soln_velocity           => placentone_3d_anal_soln_velocity
      anal_soln_velocity_1         => placentone_3d_anal_soln_velocity_1
      get_boundary_no_velocity     => placentone_3d_get_boundary_no_velocity
      dirichlet_bc_velocity        => placentone_3d_dirichlet_bc_velocity
      neumann_bc_velocity          => placentone_3d_neumann_bc_velocity
    else if (trim(geometry_name) == 'square_analytic') then
      convert_velocity_boundary_no => analytic_2d_convert_velocity_boundary_no
      convert_velocity_region_id   => analytic_2d_convert_velocity_region_id
      forcing_function_velocity    => analytic_2d_forcing_function_velocity
      anal_soln_velocity           => analytic_2d_anal_soln_velocity
      anal_soln_velocity_1         => analytic_2d_anal_soln_velocity_1
      get_boundary_no_velocity     => analytic_2d_get_boundary_no_velocity
      dirichlet_bc_velocity        => analytic_2d_dirichlet_bc_velocity
      neumann_bc_velocity          => analytic_2d_neumann_bc_velocity
    else if (trim(geometry_name) == 'square_constant_up') then
      convert_velocity_boundary_no => constant_up_2d_convert_velocity_boundary_no
      convert_velocity_region_id   => constant_up_2d_convert_velocity_region_id
      forcing_function_velocity    => constant_up_2d_forcing_function_velocity
      anal_soln_velocity           => constant_up_2d_anal_soln_velocity
      anal_soln_velocity_1         => constant_up_2d_anal_soln_velocity_1
      get_boundary_no_velocity     => constant_up_2d_get_boundary_no_velocity
      dirichlet_bc_velocity        => constant_up_2d_dirichlet_bc_velocity
      neumann_bc_velocity          => constant_up_2d_neumann_bc_velocity
    else if (trim(geometry_name) == 'square_constant_diagonal') then
      convert_velocity_boundary_no => constant_diagonal_2d_convert_velocity_boundary_no
      convert_velocity_region_id   => constant_diagonal_2d_convert_velocity_region_id
      forcing_function_velocity    => constant_diagonal_2d_forcing_function_velocity
      anal_soln_velocity           => constant_diagonal_2d_anal_soln_velocity
      anal_soln_velocity_1         => constant_diagonal_2d_anal_soln_velocity_1
      get_boundary_no_velocity     => constant_diagonal_2d_get_boundary_no_velocity
      dirichlet_bc_velocity        => constant_diagonal_2d_dirichlet_bc_velocity
      neumann_bc_velocity          => constant_diagonal_2d_neumann_bc_velocity
    else if (trim(geometry_name) == 'square_poiseuille') then
      convert_velocity_boundary_no => poiseuille_2d_convert_velocity_boundary_no
      convert_velocity_region_id   => poiseuille_2d_convert_velocity_region_id
      forcing_function_velocity    => poiseuille_2d_forcing_function_velocity
      anal_soln_velocity           => poiseuille_2d_anal_soln_velocity
      anal_soln_velocity_1         => poiseuille_2d_anal_soln_velocity_1
      get_boundary_no_velocity     => poiseuille_2d_get_boundary_no_velocity
      dirichlet_bc_velocity        => poiseuille_2d_dirichlet_bc_velocity
      neumann_bc_velocity          => poiseuille_2d_neumann_bc_velocity
    else if (trim(geometry_name) == 'square_etienne2009') then
      convert_velocity_boundary_no => etienne2009_2d_convert_velocity_boundary_no
      convert_velocity_region_id   => etienne2009_2d_convert_velocity_region_id
      forcing_function_velocity    => etienne2009_2d_forcing_function_velocity
      anal_soln_velocity           => etienne2009_2d_anal_soln_velocity
      anal_soln_velocity_1         => etienne2009_2d_anal_soln_velocity_1
      get_boundary_no_velocity     => etienne2009_2d_get_boundary_no_velocity
      dirichlet_bc_velocity        => etienne2009_2d_dirichlet_bc_velocity
      neumann_bc_velocity          => etienne2009_2d_neumann_bc_velocity
    else if (trim(geometry_name) == 'square_etienne2009_ti') then
      convert_velocity_boundary_no => etienne2009_ti_2d_convert_velocity_boundary_no
      convert_velocity_region_id   => etienne2009_ti_2d_convert_velocity_region_id
      forcing_function_velocity    => etienne2009_ti_2d_forcing_function_velocity
      anal_soln_velocity           => etienne2009_ti_2d_anal_soln_velocity
      anal_soln_velocity_1         => etienne2009_ti_2d_anal_soln_velocity_1
      get_boundary_no_velocity     => etienne2009_ti_2d_get_boundary_no_velocity
      dirichlet_bc_velocity        => etienne2009_ti_2d_dirichlet_bc_velocity
      neumann_bc_velocity          => etienne2009_ti_2d_neumann_bc_velocity
    else if (trim(geometry_name) == 'square_shear') then
      convert_velocity_boundary_no => shear_2d_convert_velocity_boundary_no
      convert_velocity_region_id   => shear_2d_convert_velocity_region_id
      forcing_function_velocity    => shear_2d_forcing_function_velocity
      anal_soln_velocity           => shear_2d_anal_soln_velocity
      anal_soln_velocity_1         => shear_2d_anal_soln_velocity_1
      get_boundary_no_velocity     => shear_2d_get_boundary_no_velocity
      dirichlet_bc_velocity        => shear_2d_dirichlet_bc_velocity
      neumann_bc_velocity          => shear_2d_neumann_bc_velocity
    else if (trim(geometry_name) == 'square_tb_free_lr_solid') then
      convert_velocity_boundary_no => tb_free_lr_solid_2d_convert_velocity_boundary_no
      convert_velocity_region_id   => tb_free_lr_solid_2d_convert_velocity_region_id
      forcing_function_velocity    => tb_free_lr_solid_2d_forcing_function_velocity
      anal_soln_velocity           => tb_free_lr_solid_2d_anal_soln_velocity
      anal_soln_velocity_1         => tb_free_lr_solid_2d_anal_soln_velocity_1
      get_boundary_no_velocity     => tb_free_lr_solid_2d_get_boundary_no_velocity
      dirichlet_bc_velocity        => tb_free_lr_solid_2d_dirichlet_bc_velocity
      neumann_bc_velocity          => tb_free_lr_solid_2d_neumann_bc_velocity
    else if (trim(geometry_name) == 'square_zero') then
      convert_velocity_boundary_no => zero_2d_convert_velocity_boundary_no
      convert_velocity_region_id   => zero_2d_convert_velocity_region_id
      forcing_function_velocity    => zero_2d_forcing_function_velocity
      anal_soln_velocity           => zero_2d_anal_soln_velocity
      anal_soln_velocity_1         => zero_2d_anal_soln_velocity_1
      get_boundary_no_velocity     => zero_2d_get_boundary_no_velocity
      dirichlet_bc_velocity        => zero_2d_dirichlet_bc_velocity
      neumann_bc_velocity          => zero_2d_neumann_bc_velocity
    else 
      call write_message(io_err, "Error: Unknown geometry name: " // trim(geometry_name))
      error stop
    end if
  end subroutine
end module