module previous_velocity
  use aptofem_kernel

  implicit none

  type(mesh)          :: prev_mesh_data
  type(solution)      :: prev_solution_velocity_data

  contains

  subroutine setup_previous_velocity(solution_velocity)
    type(solution), intent(in) :: solution_velocity

    call make_copy_of_solution(prev_solution_velocity_data, solution_velocity)

  end subroutine

  subroutine setup_previous_mesh(mesh_data)
    type(mesh), intent(in) :: mesh_data

    call make_copy_of_mesh(prev_mesh_data, mesh_data)

  end subroutine

  subroutine finalise_previous_velocity()
    call delete_solution(prev_solution_velocity_data)
  end subroutine

  subroutine finalise_previous_mesh()
    call delete_mesh(prev_mesh_data)
  end subroutine

end module