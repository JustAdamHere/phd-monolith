program evaluate_solution
  use aptofem_kernel
  use fe_solution_restart_io
  use point_searching
  use velocity_bc_interface
  use refine_region
  use problem_options
  use problem_options_velocity
  use problem_options_geometry

  implicit none

  type(aptofem_keys), pointer :: aptofem_stored_keys
  type(solution)              :: solution_data
  type(mesh)                  :: mesh_data, mesh_data_orig

  type(refinement_tree)              :: mesh_tree
  integer, dimension(:), allocatable :: refinement_marks
  integer                            :: mesh_no, no_eles

  type(bounding_box_tree) :: mesh_bounding_box_tree

  character(len=50) :: program_dir, filename_no_ext, problem, run_no_string
  integer           :: problem_dim, run_no

  real(db), dimension(:, :), allocatable :: global_points
  integer                                :: no_points

  interface
    subroutine read_global_points(problem_dim, filename_no_ext, run_no, global_points, no_points)
      use aptofem_kernel

      implicit none

      integer, intent(in)                                   :: problem_dim
      character(len=*), intent(in)                          :: filename_no_ext, run_no
      real(db), dimension(:, :), allocatable, intent(inout) :: global_points
      integer, intent(out)                                  :: no_points
    end subroutine

    subroutine output_solution(dim, filename_no_ext, run_no, global_points, no_points, &
        mesh_bounding_box_tree, mesh_data, solution_data)
      use aptofem_kernel
      use point_searching

      implicit none

      integer, intent(in)                    :: dim
      character(len=*), intent(in)           :: filename_no_ext, run_no
      real(db), dimension(:, :), intent(out) :: global_points
      integer, intent(in)                    :: no_points
      type(bounding_box_tree), intent(in)    :: mesh_bounding_box_tree
      type(mesh), intent(in)                 :: mesh_data
      type(solution), intent(in)             :: solution_data
    end subroutine
  end interface

  !!!!!!!!!!!!!!!!!!!!!!!!!
  !! CHECK #ARGS MATCHES !!
  !!!!!!!!!!!!!!!!!!!!!!!!!
  if (command_argument_count() /= 4) then
    print *, "ERROR: Incorrect number of command line arguments."
    print *, " Usage: ./evaluate-solution_bb.out <nsb|ns-b|ns-nsb|s-b> <placentone|placenta|placentone-3d>"
    print *, "    dg_velocity-transport <run_no>"
    error stop
  end if

  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !! SET CONTROL FILE AND I/O VARIABLES !!
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  call get_command_argument(1, assembly_name)
  if (assembly_name /= 'nsb' .and. assembly_name /= 'ns-b' .and. assembly_name /= 'ns-nsb' .and. assembly_name /= 's-b') then
      call write_message(io_err, 'Error: assembly_name should be nsb or ns-b or ns-nsb or s-b.')
      error stop
  end if
  call get_command_argument(2, geometry_name)
  if (geometry_name /= 'placentone' .and. geometry_name /= 'placenta' .and. geometry_name /= 'placentone-3d') then
      call write_message(io_err, 'Error: geometry_name should be placentone or placenta or placentone-3d.')
      error stop
  end if
  call get_command_argument(3, filename_no_ext)
  call get_command_argument(4, run_no_string)
  read(run_no_string, '(i10)') run_no

  problem         = 'dg_velocity-transport'
  program_dir     = '../velocity-transport/common/'

  !!!!!!!!!!!!!!!!!!!
  !! APTOFEM SETUP !!
  !!!!!!!!!!!!!!!!!!!
  ! call AptoFEM_initialize(aptofem_stored_keys, 'acf_' // trim(geometry_name) // '.dat', trim(program_dir))
  ! call get_user_data     ('user_data', aptofem_stored_keys)
  ! call create_mesh       (mesh_data, get_boundary_no_velocity, 'mesh_gen', aptofem_stored_keys)
  ! call set_space_type_velocity(aptofem_stored_keys)

  call AptoFEM_initialize     (aptofem_stored_keys, 'acf_' // trim(geometry_name) // '.dat', trim(program_dir))
  call setup_velocity_bcs     (geometry_name)
  call create_mesh            (mesh_data, get_boundary_no_velocity, 'mesh_gen', aptofem_stored_keys)
  call get_user_data          ('user_data', aptofem_stored_keys)
  call get_user_data_velocity ('user_data', aptofem_stored_keys)
  call set_space_type_velocity(aptofem_stored_keys)
  call initialise_geometry    (geometry_name, no_placentones)

  problem_dim = get_problem_dim(mesh_data)

  !!!!!!!!!!!!!!!!!
  !! REFINE MESH !!
  !!!!!!!!!!!!!!!!!
  do mesh_no = 1, no_uniform_refinements_everywhere
    no_eles = mesh_data%no_eles
    allocate(refinement_marks(no_eles))

    call write_message(io_msg, '========================================================')
    call write_message(io_msg, '  Refinement step ')
    call refine_region_indicator(refinement_marks, no_eles, mesh_data, 300, 599)

    ! mesh_smoother = .false.

    ! call h_refine_mesh(mesh_tree, mesh_data, mesh_data_orig, no_eles, mesh_smoother, refinement_marks)
    call h_mesh_adaptation('uniform_refinement', aptofem_stored_keys, mesh_tree, mesh_data, mesh_data_orig, &
        mesh_no, no_eles, refinement_marks)
    call write_message(io_msg, '========================================================')

    deallocate(refinement_marks)

    call delete_mesh(mesh_data_orig)
  end do

  do mesh_no = 1, no_uniform_refinements_cavity
      no_eles = mesh_data%no_eles
      allocate(refinement_marks(no_eles))

      call write_message(io_msg, '========================================================')
      call write_message(io_msg, '  Refinement step ')
      call refine_region_indicator(refinement_marks, no_eles, mesh_data, 500, 599)

      ! mesh_smoother = .false.

      ! call h_refine_mesh(mesh_tree, mesh_data, mesh_data_orig, no_eles, mesh_smoother, refinement_marks)
      call h_mesh_adaptation('uniform_refinement', aptofem_stored_keys, mesh_tree, mesh_data, mesh_data_orig, &
          mesh_no + no_uniform_refinements_everywhere, no_eles, refinement_marks)
      call write_message(io_msg, '========================================================')

      deallocate(refinement_marks)

      call delete_mesh(mesh_data_orig)
  end do

  do mesh_no = 1, no_uniform_refinements_inlet
      no_eles = mesh_data%no_eles
      allocate(refinement_marks(no_eles))

      call write_message(io_msg, '========================================================')
      call write_message(io_msg, '  Refinement step ')
      call refine_region_indicator(refinement_marks, no_eles, mesh_data, 400, 499)

      ! mesh_smoother = .false.

      ! call h_refine_mesh(mesh_tree, mesh_data, mesh_data_orig, no_eles, mesh_smoother, refinement_marks)
      call h_mesh_adaptation('uniform_refinement', aptofem_stored_keys, mesh_tree, mesh_data, mesh_data_orig, &
          mesh_no + no_uniform_refinements_everywhere + no_uniform_refinements_cavity, no_eles, refinement_marks)
      call write_message(io_msg, '========================================================')

      deallocate(refinement_marks)

      call delete_mesh(mesh_data_orig)
  end do

  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !! CREATE BOUNDING BOX TREE !!
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  call construct_bounding_box_tree(mesh_bounding_box_tree, mesh_data)

  !!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !! VELOCITY PROBLEM SETUP !!
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!
  call create_fe_solution(solution_data, mesh_data, 'fe_solution_velocity', aptofem_stored_keys, &
    dirichlet_bc_velocity)

  !!!!!!!!!!!!!!!!!!!!!!
  !! READ IN SOLUTION !!
  !!!!!!!!!!!!!!!!!!!!!!
  call read_solution_for_restart(mesh_data, solution_data, 0, trim(problem) // '_velocity_' // trim(geometry_name), run_no, &
    '../../output/')

  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !! OUTPUT SOLUTION AT POINTS !!
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  call read_global_points(problem_dim, filename_no_ext, run_no_string, global_points, no_points)
  call output_solution   (problem_dim, filename_no_ext, run_no_string, global_points, no_points, mesh_bounding_box_tree, &
    mesh_data, solution_data)

  !!!!!!!!!!!!!!
  !! CLEAN UP !!
  !!!!!!!!!!!!!!
  deallocate(global_points)

  call delete_bounding_box_tree(mesh_bounding_box_tree)
  call delete_solution (solution_data)
  call delete_mesh     (mesh_data)
  call AptoFEM_finalize(aptofem_stored_keys)

end program

subroutine read_global_points(problem_dim, filename_no_ext, run_no, global_points, no_points)
  use aptofem_kernel

  implicit none

  integer, intent(in)                                   :: problem_dim
  character(len=*), intent(in)                          :: filename_no_ext, run_no
  real(db), dimension(:, :), allocatable, intent(inout) :: global_points
  integer, intent(out)                                  :: no_points

  integer :: i

  open(23111998, file='../../output/mri-points_' // trim(filename_no_ext) // '_' // trim(run_no) // '.dat', status='old', &
    action='read')

  read(23111998, *) no_points
  allocate(global_points(problem_dim, no_points))

  if (problem_dim == 2) then
    do i = 1, no_points
      read(23111998, *) global_points(1, i), global_points(2, i)
    end do
  else if (problem_dim == 3) then
    do i = 1, no_points
      read(23111998, *) global_points(1, i), global_points(2, i), global_points(3, i)
    end do
  end if

  close(23111998)
end subroutine

subroutine output_solution(problem_dim, filename_no_ext, run_no, global_points, no_points, &
    mesh_bounding_box_tree, mesh_data, solution_data)
  use aptofem_kernel
  use point_searching

  implicit none

  integer, intent(in)                    :: problem_dim
  character(len=*), intent(in)           :: filename_no_ext, run_no
  real(db), dimension(:, :), intent(out) :: global_points
  integer, intent(in)                    :: no_points
  type(bounding_box_tree), intent(in)    :: mesh_bounding_box_tree
  type(mesh), intent(in)                 :: mesh_data
  type(solution), intent(in)             :: solution_data

  integer                          :: i, element_no
  real(db), dimension(problem_dim) :: uh

  open(23111999, file='../../output/mri-solution_' // trim(filename_no_ext) // '_' // trim(run_no) // '.dat', status='replace', &
    action='write')

  write(23111999, *) no_points

  do i = 1, no_points
    element_no = find_point_in_element_bb_method(global_points(:, i), problem_dim, &
        mesh_bounding_box_tree, mesh_data)

    if (element_no > 0) then
      call compute_uh_glob_pt(uh, problem_dim+1, element_no, global_points(:, i), problem_dim, mesh_data, solution_data)
    else
      uh = 0.0_db
    end if

    if (problem_dim == 2) then
      write(23111999, *) uh(1), uh(2)
    else if (problem_dim == 3) then
      write(23111999, *) uh(1), uh(2), uh(3)
    end if
  end do
end subroutine