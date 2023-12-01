module previous_velocity
  use aptofem_kernel
  use basis_fns_storage_type

  implicit none

  type(mesh)          :: prev_mesh_data
  type(solution)      :: prev_solution_velocity_data
  integer             :: prev_dim_soln_coeff, prev_no_pdes, prev_no_elements, prev_no_nodes, prev_no_faces, prev_problem_dim, &
    prev_npinc, prev_no_quad_points_volume_max, prev_no_quad_points_face_max
  type(basis_storage) :: prev_fe_basis_info

  contains

  subroutine setup_previous_velocity(mesh_data, solution_velocity)
    type(mesh), intent(in) :: mesh_data
    type(solution), intent(in) :: solution_velocity

    character(len=aptofem_length_key_def) :: control_parameter

    ! call make_copy_of_mesh(prev_mesh_data, mesh_data)
    ! call make_copy_of_solution(prev_solution_velocity_data, solution_velocity)

    ! call get_mesh_info(prev_no_elements, prev_no_nodes, prev_no_faces, prev_problem_dim, prev_mesh_data)

    ! prev_npinc = 2
    ! call compute_max_no_quad_points(prev_no_quad_points_volume_max, prev_no_quad_points_face_max, prev_mesh_data, &
    !   prev_solution_velocity_data, prev_npinc)

    ! control_parameter = 'uh_ele'
    ! call initialize_fe_basis_storage(prev_fe_basis_info, control_parameter, prev_solution_velocity_data, &
    !   prev_problem_dim, prev_no_quad_points_volume_max, prev_no_quad_points_face_max)

  end subroutine

  subroutine finalise_previous_velocity()
    ! call delete_fe_basis_storage(prev_fe_basis_info)
  end subroutine

end module