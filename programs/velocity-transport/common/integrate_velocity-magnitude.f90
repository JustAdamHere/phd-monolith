module integrate_velocity_magnitude
  use aptofem_kernel
  use param

  implicit none

  contains

  function calculate_integral_velocity_magnitude(mesh_data, velocity_solution, IVS_only)
    use fe_mesh
    use fe_solution
    use basis_fns_storage_type

    implicit none

    ! Input arguments.
    real(db) :: calculate_integral_velocity_magnitude
    type(mesh), intent(inout)  :: mesh_data
    type(solution), intent(in) :: velocity_solution
    logical, intent(in)        :: IVS_only

    ! Local variables.
    type(basis_storage)                    :: fe_basis_info
    character(len=aptofem_length_key_def)  :: control_parameter
    integer                                :: no_eles, no_nodes, no_faces, problem_dim, npinc, no_quad_points_volume_max, &
      no_quad_points_face_max, i, k, dim_soln_coeff, no_pdes, no_quad_points, element_region_id, qk, min_region
    real(db), dimension(:), allocatable    :: uh, quad_weights_ele, jacobian
    integer, dimension(:), allocatable     :: no_dofs_per_variable
    real(db), dimension(:, :), allocatable :: quad_points_ele
    integer, dimension(:, :), allocatable  :: global_dof_numbers
    real(db)                               :: velocity_magnitude

    !!!!!!!!!!!!!!!!!!!!!
    ! INTEGRATION SETUP !
    !!!!!!!!!!!!!!!!!!!!!
    call get_mesh_info(no_eles, no_nodes, no_faces, problem_dim, mesh_data)

    dim_soln_coeff = get_dim_soln_coeff(velocity_solution)
    no_pdes        = get_no_pdes(velocity_solution)

    npinc = 2
    call compute_max_no_quad_points(no_quad_points_volume_max, no_quad_points_face_max, mesh_data, velocity_solution, npinc)

    control_parameter = 'fo_deriv_uh_ele'
    call initialize_fe_basis_storage(fe_basis_info, control_parameter, velocity_solution, problem_dim, no_quad_points_volume_max, &
      no_quad_points_face_max)

    !!!!!!!!!!!!!!!!!!
    ! PRE-ALLOCATION !
    !!!!!!!!!!!!!!!!!!
    allocate(uh                  (no_pdes))
    allocate(quad_points_ele     (problem_dim, no_quad_points_volume_max))
    allocate(quad_weights_ele    (no_quad_points_volume_max))
    allocate(jacobian            (no_quad_points_volume_max))
    allocate(global_dof_numbers  (dim_soln_coeff, no_ele_dofs_per_var_max))
    allocate(no_dofs_per_variable(dim_soln_coeff))

    !!!!!!!!!!!!!!!!!!
    ! BUILD INTEGRAL !
    !!!!!!!!!!!!!!!!!!
    calculate_integral_velocity_magnitude = 0.0_db

    do k = 1, no_eles
      call element_integration_info(dim_soln_coeff, problem_dim, mesh_data, velocity_solution, k, npinc, &
        no_quad_points_volume_max, no_quad_points, quad_points_ele, jacobian, quad_weights_ele, global_dof_numbers, &
        no_dofs_per_variable, fe_basis_info)

      element_region_id = get_element_region_id(mesh_data, k)

      if (IVS_only) then
        min_region = 520
      else
        min_region = 500
      end if

      if ((300 <= element_region_id .and. element_region_id <= 399) .or. &
          (min_region <= element_region_id .and. element_region_id <= 529)) then 
        do qk = 1, no_quad_points
          uh = uh_element(fe_basis_info, no_pdes, qk)

          velocity_magnitude = 0.0_db
          do i = 1, problem_dim
            velocity_magnitude = velocity_magnitude + uh(i)**2
          end do
          velocity_magnitude = sqrt(velocity_magnitude)

          calculate_integral_velocity_magnitude = calculate_integral_velocity_magnitude + quad_weights_ele(qk) * jacobian(qk) * &
            velocity_magnitude
        end do
      end if
    end do

    !!!!!!!!!!!!!!!!
    ! DEALLOCATION !
    !!!!!!!!!!!!!!!!
    call delete_fe_basis_storage(fe_basis_info)
    deallocate(uh, quad_points_ele, quad_weights_ele, jacobian, global_dof_numbers, no_dofs_per_variable)

  end function

end module