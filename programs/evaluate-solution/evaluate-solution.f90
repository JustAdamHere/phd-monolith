program evaluate_solution
  use aptofem_kernel
  use fe_solution_restart_io
  use bcs_nsku
  use refine_region
  use program_name_module
  use problem_options

  implicit none

  type(aptofem_keys), pointer :: aptofem_stored_keys
  type(solution)              :: solution_data
  type(mesh)                  :: mesh_data, mesh_data_orig

  type(refinement_tree)              :: mesh_tree
  integer, dimension(:), allocatable :: refinement_marks
  integer                            :: mesh_no, no_eles

  character(len=20) :: control_file
  character(len=50) :: program_dir, filename_no_ext, problem, run_no_string
  integer           :: problem_dim, run_no

  real(db), dimension(:, :), allocatable :: global_points
  integer                                :: no_points, i

  interface
    subroutine read_global_points(problem_dim, filename_no_ext, global_points, no_points)
      use aptofem_kernel

      implicit none

      integer, intent(in)                                   :: problem_dim
      character(len=*), intent(in)                          :: filename_no_ext
      real(db), dimension(:, :), allocatable, intent(inout) :: global_points
      integer, intent(out)                                  :: no_points
    end subroutine

    subroutine output_solution(dim, filename_no_ext, global_points, no_points, mesh_data, solution_data)
      use aptofem_kernel

      implicit none

      integer, intent(in)                    :: dim
      character(len=*), intent(in)           :: filename_no_ext
      real(db), dimension(:, :), intent(out) :: global_points
      integer, intent(in)                    :: no_points
      type(mesh), intent(in)                 :: mesh_data
      type(solution), intent(in)             :: solution_data
    end subroutine
  end interface

  !!!!!!!!!!!!!!!!!!!!!!!!!
  !! CHECK #ARGS MATCHES !!
  !!!!!!!!!!!!!!!!!!!!!!!!!
  if (command_argument_count() /= 2) then
    write(*, *) 'ERROR: Incorrect number of arguments'
    stop
  end if

  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !! SET CONTROL FILE AND I/O VARIABLES !!
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  call program_name(control_file)
  call get_command_argument(1, filename_no_ext)
  call get_command_argument(2, run_no_string)

  read(run_no_string, '(i10)') run_no

  problem         = 'dg_nsku_transport'
  program_dir     = '../' // trim(problem) // '/'

  !!!!!!!!!!!!!!!!!!!
  !! APTOFEM SETUP !!
  !!!!!!!!!!!!!!!!!!!
  call AptoFEM_initialize(aptofem_stored_keys, 'acf_' // trim(control_file) // '.dat', trim(program_dir))
  call get_user_data     ('user_data', aptofem_stored_keys)
  call create_mesh       (mesh_data, get_boundary_no_nsku, 'mesh_gen', aptofem_stored_keys)

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

  !!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !! VELOCITY PROBLEM SETUP !!
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!
  call create_fe_solution(solution_data, mesh_data, 'fe_solution_nsku', aptofem_stored_keys, &
    dirichlet_bc_nsku)

  !!!!!!!!!!!!!!!!!!!!!!
  !! READ IN SOLUTION !!
  !!!!!!!!!!!!!!!!!!!!!!
  call read_solution_for_restart(mesh_data, solution_data, 0, trim(problem) // '_nsku_' // trim(control_file), run_no, &
    '../../output/')

  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !! OUTPUT SOLUTION AT POINTS !!
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  call read_global_points(problem_dim, filename_no_ext, global_points, no_points)
  call output_solution   (problem_dim, filename_no_ext, global_points, no_points, mesh_data, solution_data)

  !!!!!!!!!!!!!!
  !! CLEAN UP !!
  !!!!!!!!!!!!!!
  deallocate(global_points)

  call delete_solution (solution_data)
  call delete_mesh     (mesh_data)
  call AptoFEM_finalize(aptofem_stored_keys)

end program

subroutine read_global_points(problem_dim, filename_no_ext, global_points, no_points)
  use aptofem_kernel

  implicit none

  integer, intent(in)                                   :: problem_dim
  character(len=*), intent(in)                          :: filename_no_ext
  real(db), dimension(:, :), allocatable, intent(inout) :: global_points
  integer, intent(out)                                  :: no_points

  integer :: i

  open(23111998, file='../../output/mri-points_' // trim(filename_no_ext) // '.dat', status='old', action='read')

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

subroutine output_solution(problem_dim, filename_no_ext, global_points, no_points, mesh_data, solution_data)
  use aptofem_kernel

  implicit none

  integer, intent(in)                    :: problem_dim
  character(len=*), intent(in)           :: filename_no_ext
  real(db), dimension(:, :), intent(out) :: global_points
  integer, intent(in)                    :: no_points
  type(mesh), intent(in)                 :: mesh_data
  type(solution), intent(in)             :: solution_data

  integer                          :: i, element_no
  real(db), dimension(problem_dim) :: uh

  open(23111999, file='../../output/mri-solution_' // trim(filename_no_ext) // '.dat', status='replace', action='write')

  write(23111999, *) no_points

  do i = 1, no_points
    element_no = find_element_global_search(global_points(:, i), mesh_data, problem_dim)

    if (element_no == -1) then
      uh = 0.0_db
    else
      call compute_uh_glob_pt(uh, problem_dim+1, element_no, global_points(:, i), problem_dim, mesh_data, solution_data)
    end if

    if (problem_dim == 2) then
      write(23111999, *) uh(1), uh(2)
    else if (problem_dim == 3) then
      write(23111999, *) uh(1), uh(2), uh(3)
    end if
  end do
end subroutine