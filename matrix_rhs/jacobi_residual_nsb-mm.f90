module jacobi_residual_nsb_mm
  use placenta_2d_bcs_velocity
  use placentone_2d_bcs_velocity
  use placentone_3d_bcs_velocity
  use velocity_bc_interface
  use previous_timestep

  ! TODO: Lots of redundant local variables.

  implicit none

  contains

  !--------------------------------------------------------------------
  !> Defines the element (non)linear residual vector for the
  !! Navier-Stokes+ku equations.
  !!
  !! Authors:
  !!   Paul Houston, Adam Blakey
  !!
  !! Date Created:
  !!   26-10-2022
  !--------------------------------------------------------------------
  subroutine element_residual_nsb_mm(element_rhs, &
    mesh_data,soln_data,facet_data,fe_basis_info)
    !--------------------------------------------------------------------
    use problem_options
    use problem_options_velocity
    use problem_options_geometry
    use basis_fns_storage_type
    use aptofem_fe_matrix_assembly
    use base_solution_type

    include 'assemble_residual_element.h'

    ! Local variables

    integer :: qk,i,j,ieqn
    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points) &
    :: floc
    real(db), dimension(facet_data%problem_dim,facet_data%problem_dim, &
    facet_data%no_quad_points) :: fluxes
    real(db) :: div_u
    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points) :: &
    interpolant_uh
    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points, &
    facet_data%problem_dim) :: gradient_uh
    real(db), dimension(facet_data%dim_soln_coeff,facet_data%no_quad_points, &
    facet_data%problem_dim,maxval(facet_data%no_dofs_per_variable)) :: grad_phi
    real(db), dimension(facet_data%dim_soln_coeff,facet_data%no_quad_points, &
    maxval(facet_data%no_dofs_per_variable)) :: phi
    real(db) :: dirk_scaling_factor,current_time

    real(db) :: diffusion_terms, convection_terms, reaction_terms, forcing_terms, pressure_terms, incompressibility_terms, &
      time_terms, prev_time_terms
    integer  :: element_region_id

    ! Previous solution variables.
    real(db), dimension(facet_data%no_pdes, facet_data%no_quad_points) :: prev_uh
    real(db), dimension(facet_data%problem_dim, facet_data%no_quad_points) :: prev_global_points_ele
    real(db), dimension(facet_data%no_quad_points) :: prev_jacobian, prev_quad_weights_ele
    real(db), dimension(facet_data%dim_soln_coeff, facet_data%no_quad_points, maxval(facet_data%no_dofs_per_variable)) :: prev_phi
    integer, dimension(facet_data%dim_soln_coeff, maxval(facet_data%no_dofs_per_variable)) :: prev_global_dof_numbers
    integer, dimension(facet_data%dim_soln_coeff) :: prev_no_dofs_per_variable
    integer :: prev_no_quad_points

    character(len=aptofem_length_key_def) :: control_parameter

    integer             :: prev_dim_soln_coeff, prev_no_pdes, prev_no_elements, prev_no_nodes, prev_no_faces, prev_problem_dim, &
      prev_npinc, prev_no_quad_points_volume_max, prev_no_quad_points_face_max
    type(basis_storage) :: prev_fe_basis_info

    ! Moving mesh variables.
    real(db), dimension(facet_data%problem_dim) :: mesh_velocity
    real(db), dimension(facet_data%problem_dim, facet_data%no_quad_points) :: mesh_uh
    real(db), dimension(facet_data%problem_dim, facet_data%no_quad_points) :: mesh_global_points_ele
    real(db), dimension(facet_data%no_quad_points) :: mesh_jacobian, mesh_quad_weights_ele
    real(db), dimension(facet_data%dim_soln_coeff, facet_data%no_quad_points, maxval(facet_data%no_dofs_per_variable)) :: mesh_phi
    integer, dimension(facet_data%dim_soln_coeff, maxval(facet_data%no_dofs_per_variable)) :: mesh_global_dof_numbers
    integer, dimension(facet_data%dim_soln_coeff) :: mesh_no_dofs_per_variable
    integer :: mesh_no_quad_points

    integer             :: mesh_dim_soln_coeff, mesh_no_pdes, mesh_no_elements, mesh_no_nodes, mesh_no_faces, mesh_problem_dim, &
      mesh_npinc, mesh_no_quad_points_volume_max, mesh_no_quad_points_face_max
    type(basis_storage) :: mesh_fe_basis_info

    ! Extra variables on previous mesh.
    real(db), dimension(facet_data%problem_dim, facet_data%no_quad_points) :: &
      prev_gauss_points_local, prev_gauss_points_global, mesh_gauss_points_local, mesh_gauss_points_global
    real(db), dimension(facet_data%problem_dim, facet_data%problem_dim, facet_data%no_quad_points) :: &
      prev_jacobi_mat, prev_inv_jacobi_mat, mesh_jacobi_mat, mesh_inv_jacobi_mat
    integer :: prev_dim_soln_coeff_start, prev_dim_soln_coeff_end, prev_dim_soln_coeff_fe_space, mesh_dim_soln_coeff_start, &
      mesh_dim_soln_coeff_end, mesh_dim_soln_coeff_fe_space

    ! Setup basis storage.
    control_parameter = 'uh_ele'
    ! I think the only reason we need prev_fe_basis_info is for the basis_element property, which we're not allowed to access
    !  from fe_basis_info due to the intent().
    call initialize_fe_basis_storage(prev_fe_basis_info, control_parameter, prev_solution_velocity_data, &
      facet_data%problem_dim, facet_data%no_quad_points_volume_max, facet_data%no_quad_points_face_max)
    call initialize_fe_basis_storage(mesh_fe_basis_info, control_parameter, solution_moving_mesh, &
      facet_data%problem_dim, facet_data%no_quad_points_volume_max, facet_data%no_quad_points_face_max)

    ! Get element DoFs for moving mesh solution.
    mesh_dim_soln_coeff = get_dim_soln_coeff(solution_moving_mesh)
    call get_element_dof_numbers(prev_mesh_data, solution_moving_mesh, mesh_global_dof_numbers, mesh_no_dofs_per_variable, &
      facet_data%element_number, mesh_dim_soln_coeff)

    ! Get element info (definitely required for prev_uh, unsure about mesh_uh).
    prev_no_quad_points = facet_data%no_quad_points
    mesh_no_quad_points = facet_data%no_quad_points
    call get_element_transform_quad_pts(prev_mesh_data, facet_data%element_number, facet_data%problem_dim, &
      prev_gauss_points_local, prev_global_points_ele, prev_quad_weights_ele, prev_no_quad_points, prev_jacobi_mat, &
      prev_jacobian)
    call get_element_transform_quad_pts(prev_mesh_data, facet_data%element_number, facet_data%problem_dim, &
      mesh_gauss_points_local, mesh_global_points_ele, mesh_quad_weights_ele, mesh_no_quad_points, mesh_jacobi_mat, &
      mesh_jacobian)

    do i = 1, prev_solution_velocity_data%no_fem_spaces
      prev_dim_soln_coeff_start    = prev_solution_velocity_data%fem_spaces(i)%fem%dim_soln_coeff_start_end(1)
      prev_dim_soln_coeff_end      = prev_solution_velocity_data%fem_spaces(i)%fem%dim_soln_coeff_start_end(2)
      prev_dim_soln_coeff_fe_space = prev_solution_velocity_data%fem_spaces(i)%fem%dim_soln_coeff_fe_space

      call prev_solution_velocity_data%fem_spaces(i)%fem%basis_fns_stored_quad_pts(prev_mesh_data, facet_data%element_number, &
        facet_data%problem_dim, facet_data%no_quad_points, prev_dim_soln_coeff_fe_space, &
        prev_gauss_points_local(:, 1:facet_data%no_quad_points), prev_gauss_points_global(:, 1:facet_data%no_quad_points), &
        prev_no_dofs_per_variable, prev_fe_basis_info%basis_element, prev_jacobi_mat(:, :, 1:facet_data%no_quad_points), &
        prev_jacobian(1:facet_data%no_quad_points))
    end do

    do i = 1, solution_moving_mesh%no_fem_spaces
      mesh_dim_soln_coeff_start    = solution_moving_mesh%fem_spaces(i)%fem%dim_soln_coeff_start_end(1)
      mesh_dim_soln_coeff_end      = solution_moving_mesh%fem_spaces(i)%fem%dim_soln_coeff_start_end(2)
      mesh_dim_soln_coeff_fe_space = solution_moving_mesh%fem_spaces(i)%fem%dim_soln_coeff_fe_space

      call solution_moving_mesh%fem_spaces(i)%fem%basis_fns_stored_quad_pts(prev_mesh_data, facet_data%element_number, &
        facet_data%problem_dim, facet_data%no_quad_points, mesh_dim_soln_coeff_fe_space, &
        mesh_gauss_points_local(:, 1:facet_data%no_quad_points), mesh_global_points_ele(:, 1:facet_data%no_quad_points), &
        mesh_no_dofs_per_variable, mesh_fe_basis_info%basis_element, mesh_jacobi_mat(:, :, 1:facet_data%no_quad_points), &
        mesh_jacobian(1:facet_data%no_quad_points))
    end do

    call compute_uh_with_basis_fns_pts(prev_uh(:, 1:facet_data%no_quad_points), facet_data%no_pdes, facet_data%no_quad_points, &
      facet_data%dim_soln_coeff, facet_data%no_dofs_per_variable, facet_data%global_dof_numbers, fe_basis_info%basis_element, &
      prev_solution_velocity_data)
    call compute_uh_with_basis_fns_pts(mesh_uh(:, 1:facet_data%no_quad_points), facet_data%problem_dim, facet_data%no_quad_points, &
      mesh_dim_soln_coeff, mesh_no_dofs_per_variable, mesh_global_dof_numbers, mesh_fe_basis_info%basis_element, &
      solution_moving_mesh)

    associate( &
      dim_soln_coeff => facet_data%dim_soln_coeff, &
      no_pdes => facet_data%no_pdes, &
      problem_dim => facet_data%problem_dim, &
      no_quad_points => facet_data%no_quad_points, &
      global_points_ele => facet_data%global_points, &
      integral_weighting => facet_data%integral_weighting, &
      element_number => facet_data%element_number, &
      element_region_id_old => facet_data%element_region_id, &
      no_dofs_per_variable => facet_data%no_dofs_per_variable, &
      scheme_user_data => facet_data%scheme_user_data)

      dirk_scaling_factor = scheme_user_data%dirk_scaling_factor
      current_time = scheme_user_data%current_time

      call convert_velocity_region_id(element_region_id_old, element_region_id)

      element_rhs = 0.0_db

      ! Calculate value of forcing function at quadrature points

      do qk = 1,no_quad_points
        interpolant_uh(1:no_pdes,qk) = uh_element(fe_basis_info,no_pdes,qk)
        do i = 1,no_pdes
          gradient_uh(i,qk,1:problem_dim) = grad_uh_element(fe_basis_info,problem_dim,i,qk,1)
        end do
        call forcing_function_velocity(floc(:,qk),global_points_ele(:,qk),problem_dim,no_pdes,current_time,&
          element_region_id)
        mesh_velocity = mesh_uh(1:problem_dim, qk)
        call convective_fluxes(interpolant_uh(:,qk),fluxes(:,:,qk),problem_dim,no_pdes,mesh_velocity)

      end do

      ! Calculate Basis Functions

      do i = 1,dim_soln_coeff
        grad_phi(i,1:no_quad_points,1:problem_dim,1:no_dofs_per_variable(i)) = fe_basis_info%basis_element &
        %deriv_basis_fns(i)%grad_data(1:no_quad_points,1:problem_dim,1:no_dofs_per_variable(i),1)
        phi(i,1:no_quad_points,1:no_dofs_per_variable(i)) = fe_basis_info%basis_element%basis_fns(i) &
        %fem_basis_fns(1:no_quad_points,1:no_dofs_per_variable(i),1)
      end do

      ! Calculate basis functions on previous mesh.
      do i = 1, dim_soln_coeff
        prev_phi(i, 1:no_quad_points, 1:no_dofs_per_variable(i)) = &
          fe_basis_info%basis_element%basis_fns(i)%fem_basis_fns(1:no_quad_points, 1:no_dofs_per_variable(i), 1)
      end do

      ! Loop over quadrature points

      do qk = 1,no_quad_points

        ! Momentum Equations
      
        do ieqn = 1,problem_dim

          ! Loop over phi_i

          do i = 1,no_dofs_per_variable(ieqn)
            prev_time_terms = calculate_velocity_time_coefficient(prev_gauss_points_global(:, qk), problem_dim, &
              element_region_id)* &
                dirk_scaling_factor*prev_uh(ieqn, qk)*prev_phi(ieqn, qk, i)

            time_terms = -calculate_velocity_time_coefficient(global_points_ele(:, qk), problem_dim, &
                element_region_id)* &
                  dirk_scaling_factor*interpolant_uh(ieqn, qk)*phi(ieqn, qk, i)

            diffusion_terms = calculate_velocity_diffusion_coefficient(global_points_ele(:, qk), problem_dim, &
                element_region_id)* &
              (-1.0_db) * dot_product(gradient_uh(ieqn,qk,:),grad_phi(ieqn,qk,:,i))

            convection_terms = calculate_velocity_convection_coefficient(global_points_ele(:, qk), problem_dim, &
                element_region_id)* &
            dot_product(fluxes(1:problem_dim,ieqn,qk), grad_phi(ieqn,qk,1:problem_dim,i))

            pressure_terms = calculate_velocity_pressure_coefficient(global_points_ele(:, qk), problem_dim, &
                element_region_id)* &
              interpolant_uh(problem_dim+1,qk)*grad_phi(ieqn,qk,ieqn,i)

            forcing_terms = calculate_velocity_forcing_coefficient(global_points_ele(:, qk), problem_dim, &
                element_region_id)* &
              floc(ieqn, qk)*phi(ieqn, qk, i)

            reaction_terms = -calculate_velocity_reaction_coefficient(global_points_ele(:, qk), problem_dim, &
                element_region_id)* &
              interpolant_uh(ieqn, qk)*phi(ieqn, qk, i)

            element_rhs(ieqn, i) = element_rhs(ieqn, i) + integral_weighting(qk) * ( &
              time_terms + &
              diffusion_terms + &
              convection_terms + &
              reaction_terms + &
              pressure_terms + &
              forcing_terms &
            ) &
            + prev_jacobian(qk)*prev_quad_weights_ele(qk)*prev_time_terms

          end do
        end do
      end do

      ! Divergence-free constraint

      ! Loop over quadrature points

      do qk = 1,no_quad_points

        ! Loop over phi_i

        do i = 1,no_dofs_per_variable(problem_dim+1)
          div_u = 0.0_db
          do ieqn = 1,problem_dim
            div_u = div_u+gradient_uh(ieqn,qk,ieqn)
          end do

          incompressibility_terms = (floc(problem_dim+1, qk) - div_u)*phi(problem_dim+1, qk, i)

          element_rhs(no_pdes, i) = element_rhs(no_pdes, i) + integral_weighting(qk) * ( &
            incompressibility_terms &
          )

        end do
      end do

    end associate

    call delete_fe_basis_storage(prev_fe_basis_info)
    call delete_fe_basis_storage(mesh_fe_basis_info)

  end subroutine element_residual_nsb_mm

  !--------------------------------------------------------------------
  !> Defines the face (non)linear residual vector for the
  !! Navier-Stokes+ku equations.
  !!
  !! Authors:
  !!   Paul Houston, Adam Blakey
  !!
  !! Date Created:
  !!   26-10-2022
  !  --------------------------------------------------------------
  subroutine element_residual_face_nsb_mm(face_residual_p,face_residual_m, &
    mesh_data,soln_data,facet_data,fe_basis_info)
    !--------------------------------------------------------------------
    use problem_options
    use problem_options_velocity
    use problem_options_geometry
    use aptofem_fe_matrix_assembly

    include 'assemble_residual_int_bdry_face.h'

    ! Local variables

    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points) &
    :: uloc
    real(db), dimension(facet_data%problem_dim, &
    facet_data%no_quad_points) :: unloc,nflxsoln
    integer :: i,qk,ieqn
    real(db) :: full_dispenal
    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points) :: &
    interpolant_uh1, interpolant_uh2
    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points, &
    facet_data%problem_dim) :: gradient_uh1,gradient_uh2
    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points, &
    facet_data%problem_dim,maxval(facet_data%no_dofs_per_variable1)) &
    :: grad_phi1
    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points, &
    facet_data%problem_dim,maxval(facet_data%no_dofs_per_variable2)) &
    :: grad_phi2
    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points, &
    maxval(facet_data%no_dofs_per_variable1)) :: phi1
    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points, &
    maxval(facet_data%no_dofs_per_variable2)) :: phi2
    real(db) :: current_time

    integer               :: bdry_face
    integer, dimension(2) :: face_element_region_ids
    real(db)              :: diffusion_terms, convection_terms, forcing_terms, pressure_terms, incompressibility_terms, &
      penalty_terms, boundary_terms
    integer               :: region_id

    ! Moving mesh variables.
    real(db), dimension(facet_data%problem_dim) :: mesh_velocity
    real(db), dimension(facet_data%problem_dim, facet_data%no_quad_points) :: mesh_uh
    real(db), dimension(facet_data%problem_dim, facet_data%no_quad_points_face_max) :: mesh_global_points_face, mesh_face_normals
    real(db), dimension(facet_data%no_quad_points_face_max) :: mesh_face_jacobian, mesh_quad_weights_face
    real(db), dimension(facet_data%dim_soln_coeff, facet_data%no_quad_points_face_max, maxval(facet_data%no_dofs_per_variable1)) ::&
       mesh_phi
    integer, dimension(facet_data%dim_soln_coeff, maxval(facet_data%no_dofs_per_variable1)) :: mesh_global_dof_numbers1, &
      mesh_global_dof_numbers2
    integer, dimension(facet_data%dim_soln_coeff) :: mesh_no_dofs_per_variable1, mesh_no_dofs_per_variable2
    integer :: mesh_no_quad_points
    integer, dimension(2) :: mesh_neighbors, mesh_loc_face_no

    ! Additional variables on previous mesh.
    integer :: element_no1, element_no2, mesh_dim_soln_coeff_start, mesh_dim_soln_coeff_end, mesh_dim_soln_coeff_fe_space
    real(db), dimension(facet_data%problem_dim, facet_data%no_quad_points) :: mesh_local_points1, mesh_local_points2, &
      mesh_global_points
    real(db), dimension(facet_data%problem_dim, facet_data%problem_dim, facet_data%no_quad_points) :: mesh_jacobi_mat1, &
      mesh_inv_jacobi_mat1, mesh_jacobi_mat2
    real(db), dimension(facet_data%no_quad_points) :: mesh_jacobian1, mesh_jacobian2

    character(len=aptofem_length_key_def) :: control_parameter

    integer             :: mesh_dim_soln_coeff, mesh_no_pdes, mesh_no_elements, mesh_no_nodes, mesh_no_faces, mesh_problem_dim, &
      mesh_npinc, mesh_no_quad_points_volume_max, mesh_no_quad_points_face_max, mesh_bdry_face
    type(basis_storage) :: mesh_fe_basis_info

    ! Setup basis storage (purely for quadrature points).
    control_parameter = 'uh_face'
    call initialize_fe_basis_storage(mesh_fe_basis_info, control_parameter, solution_moving_mesh, &
      facet_data%problem_dim, facet_data%no_quad_points_volume_max, facet_data%no_quad_points_face_max)

    ! Assuming continuity, we will mostly just work on face 1; in fact it probably could work with just face 1; I suspect problems
    !  may arise in compute_uh_with_basis_fns_pts if we don't do anything to face 2.
    element_no1 = facet_data%neighbours(1)
    element_no2 = facet_data%neighbours(2)

    ! Get the local face numbers.
    mesh_loc_face_no = mesh_data%mesh_faces(facet_data%face_number)%loc_face_no

    ! Get element DoFs for moving mesh solution.
    mesh_dim_soln_coeff = get_dim_soln_coeff(solution_moving_mesh)
    call get_element_dof_numbers(prev_mesh_data, solution_moving_mesh, mesh_global_dof_numbers1, mesh_no_dofs_per_variable1, &
      element_no1, mesh_dim_soln_coeff)

    ! Get face integration info.
    mesh_no_quad_points = facet_data%no_quad_points
    call get_face_transform_quad_pts(prev_mesh_data, element_no1, mesh_loc_face_no(1), facet_data%problem_dim, &
      mesh_local_points1(:,1:facet_data%no_quad_points), mesh_global_points(:, 1:facet_data%no_quad_points), &
      mesh_quad_weights_face(1:facet_data%no_quad_points), mesh_no_quad_points, mesh_face_jacobian(1:facet_data%no_quad_points), &
      mesh_face_normals(:, 1:facet_data%no_quad_points), mesh_jacobi_mat1(:, :, 1:facet_data%no_quad_points), &
      mesh_jacobian1(1:facet_data%no_quad_points), mesh_inv_jacobi_mat1(:, :, 1:facet_data%no_quad_points))

    do i = 1, solution_moving_mesh%no_fem_spaces
      mesh_dim_soln_coeff_start    = solution_moving_mesh%fem_spaces(i)%fem%dim_soln_coeff_start_end(1)
      mesh_dim_soln_coeff_end      = solution_moving_mesh%fem_spaces(i)%fem%dim_soln_coeff_start_end(2)
      mesh_dim_soln_coeff_fe_space = solution_moving_mesh%fem_spaces(i)%fem%dim_soln_coeff_fe_space

      call solution_moving_mesh%fem_spaces(i)%fem%uh_basis_fns_pts(prev_mesh_data, solution_moving_mesh, &
        element_no1, facet_data%problem_dim, facet_data%no_quad_points, mesh_dim_soln_coeff_fe_space, &
        mesh_local_points1(:, 1:facet_data%no_quad_points), mesh_global_points(:, 1:facet_data%no_quad_points), &
        mesh_no_dofs_per_variable1, mesh_fe_basis_info%basis_face1, mesh_jacobi_mat1(:, :, 1:facet_data%no_quad_points), &
        mesh_jacobian1(1:facet_data%no_quad_points))
      if (element_no2 > 0) then
        call solution_moving_mesh%fem_spaces(i)%fem%uh_basis_fns_pts(prev_mesh_data, solution_moving_mesh, &
          element_no2, facet_data%problem_dim, facet_data%no_quad_points, mesh_dim_soln_coeff_fe_space, &
          mesh_local_points2(:, 1:facet_data%no_quad_points), mesh_global_points(:, 1:facet_data%no_quad_points), &
          mesh_no_dofs_per_variable2, mesh_fe_basis_info%basis_face2, mesh_jacobi_mat2(:, :, 1:facet_data%no_quad_points), &
          mesh_jacobian2(1:facet_data%no_quad_points))
      end if
    end do

    call compute_uh_with_basis_fns_pts(mesh_uh(:, 1:facet_data%no_quad_points), facet_data%problem_dim, facet_data%no_quad_points, &
      mesh_dim_soln_coeff, mesh_no_dofs_per_variable1, mesh_global_dof_numbers1, mesh_fe_basis_info%basis_face1, &
      solution_moving_mesh)

    associate( &
      dim_soln_coeff => facet_data%dim_soln_coeff, &
      no_pdes => facet_data%no_pdes, &
      problem_dim => facet_data%problem_dim, &
      no_quad_points => facet_data%no_quad_points, &
      global_points_face => facet_data%global_points, &
      integral_weighting => facet_data%integral_weighting, &
      face_number => facet_data%face_number, &
      neighbours => facet_data%neighbours, &
      interior_face_boundary_no => facet_data%interior_face_boundary_no, &
      face_element_region_ids_old => facet_data%face_element_region_ids, &
      bdry_face_old => facet_data%bdry_no, &
      no_dofs_per_variable1 => facet_data%no_dofs_per_variable1, &
      no_dofs_per_variable2 => facet_data%no_dofs_per_variable2, &
      face_normals => facet_data%face_normals, &
      dispenal => facet_data%dispenal, &
      scheme_user_data => facet_data%scheme_user_data)

      current_time = scheme_user_data%current_time

      face_residual_p = 0.0_db
      face_residual_m = 0.0_db

      full_dispenal = interior_penalty_parameter*dispenal(1)

      call convert_velocity_boundary_no(bdry_face_old, bdry_face)
      call convert_velocity_region_id(face_element_region_ids_old(1), face_element_region_ids(1))
      call convert_velocity_region_id(face_element_region_ids_old(2), face_element_region_ids(2))

      !!!!!!!!!!!!!!!!!!!!!!!!!!!
      !! CONVECTION TERMS ONLY !!
      !!!!!!!!!!!!!!!!!!!!!!!!!!!
      if (bdry_face > 0) then
        if (large_boundary_v_penalisation) then
          full_dispenal = 1e10_db
        end if

        do qk = 1,no_quad_points
          interpolant_uh1(1:no_pdes,qk) = uh_face1(fe_basis_info,no_pdes,qk)
          do i = 1,no_pdes
            gradient_uh1(i,qk,1:problem_dim) = grad_uh_face1(fe_basis_info,problem_dim,i,qk,1)
          end do

          ! The solution is continuous, so we only need to do this on one side of the face.
          mesh_velocity = mesh_uh(1:problem_dim, qk)

          call anal_soln_velocity(uloc(:,qk),global_points_face(:,qk),problem_dim,no_pdes,bdry_face,current_time, &
            face_element_region_ids(1))
          ! if (solid_wall_mesh_velocity .and. uloc(1, qk) == 0.0_db .and. uloc(2, qk) == 0.0_db) then
          if (solid_wall_mesh_velocity) then
            uloc(1:2, qk) = uloc(1:2, qk) + mesh_velocity
          end if
          call compute_boundary_condition(interpolant_uh2(:,qk), &
            interpolant_uh1(:,qk),uloc(:,qk),abs(bdry_face),problem_dim,no_pdes)
          call neumann_bc_velocity(unloc(:,qk),global_points_face(:,qk),problem_dim,bdry_face,current_time, &
            face_element_region_ids(1), face_normals(:, qk))
          call lax_friedrichs(nflxsoln(:,qk),interpolant_uh1(:,qk), &
            interpolant_uh2(:,qk),face_normals(:,qk),problem_dim,no_pdes,mesh_velocity)

        end do

        do i = 1,no_pdes
          grad_phi1(i,1:no_quad_points,1:problem_dim,1:no_dofs_per_variable1(i)) = fe_basis_info%basis_face1 &
          %deriv_basis_fns(i)%grad_data(1:no_quad_points,:,1:no_dofs_per_variable1(i),1)
          phi1(i,1:no_quad_points,1:no_dofs_per_variable1(i)) = fe_basis_info%basis_face1%basis_fns(i) &
          %fem_basis_fns(1:no_quad_points,1:no_dofs_per_variable1(i),1)
        end do

        if (100 <= abs(bdry_face) .and. abs(bdry_face) <= 199) then
          do ieqn = 1,problem_dim
            do qk = 1,no_quad_points
              do i = 1,no_dofs_per_variable1(ieqn)

                convection_terms = calculate_velocity_convection_coefficient(global_points_face(:, qk), problem_dim, &
                    face_element_region_ids(1))* &
                  (-1.0_db) * nflxsoln(ieqn,qk)*phi1(ieqn,qk,i)

                face_residual_p(ieqn, i) = face_residual_p(ieqn, i) + integral_weighting(qk)*( &
                  convection_terms &
                )

              end do
            end do
          end do

        else if (200 <= abs(bdry_face) .and. abs(bdry_face) <= 299) then
          do ieqn = 1,problem_dim
            do qk = 1,no_quad_points
              do i = 1,no_dofs_per_variable1(ieqn)

                convection_terms = calculate_velocity_convection_coefficient(global_points_face(:, qk), problem_dim, &
                    face_element_region_ids(1))* &
                  (-1.0_db) * nflxsoln(ieqn,qk)*phi1(ieqn,qk,i)

                face_residual_p(ieqn, i) = face_residual_p(ieqn, i) + integral_weighting(qk) * ( &
                  convection_terms &
                )

              end do
            end do
          end do
        end if
      else
        do qk = 1,no_quad_points
          interpolant_uh1(:,qk) = uh_face1(fe_basis_info,no_pdes,qk)
          interpolant_uh2(:,qk) = uh_face2(fe_basis_info,no_pdes,qk)
          do i = 1,no_pdes
            gradient_uh1(i,qk,1:problem_dim) = grad_uh_face1(fe_basis_info,problem_dim,i,qk,1)
            gradient_uh2(i,qk,1:problem_dim) = grad_uh_face2(fe_basis_info,problem_dim,i,qk,1)
          end do
          ! The solution is continuous, so we only need to do this on one side of the face.
          mesh_velocity = mesh_uh(1:problem_dim, qk)
          call lax_friedrichs(nflxsoln(:,qk),interpolant_uh1(:,qk), &
            interpolant_uh2(:,qk),face_normals(:,qk),problem_dim,no_pdes,mesh_velocity)
        end do

        do i = 1,no_pdes
          grad_phi1(i,1:no_quad_points,1:problem_dim,1:no_dofs_per_variable1(i)) = fe_basis_info%basis_face1 &
          %deriv_basis_fns(i)%grad_data(1:no_quad_points,:,1:no_dofs_per_variable1(i),1)
          grad_phi2(i,1:no_quad_points,1:problem_dim,1:no_dofs_per_variable2(i)) = fe_basis_info%basis_face2 &
          %deriv_basis_fns(i)%grad_data(1:no_quad_points,:,1:no_dofs_per_variable2(i),1)
          phi1(i,1:no_quad_points,1:no_dofs_per_variable1(i)) = fe_basis_info%basis_face1%basis_fns(i) &
          %fem_basis_fns(1:no_quad_points,1:no_dofs_per_variable1(i),1)
          phi2(i,1:no_quad_points,1:no_dofs_per_variable2(i)) = fe_basis_info%basis_face2%basis_fns(i) &
          %fem_basis_fns(1:no_quad_points,1:no_dofs_per_variable2(i),1)
        end do

        ! TODO: wtf?!
        ! if (500 <= face_element_region_ids(1) .and. face_element_region_ids(1) <= 599) then
        !   region_id = face_element_region_ids(1)
        ! else
        !   region_id = face_element_region_ids(2)
        ! end if
        region_id = face_element_region_ids(1)

        do ieqn = 1,problem_dim
          do qk = 1,no_quad_points
            do i = 1,no_dofs_per_variable1(ieqn)

              convection_terms = calculate_velocity_convection_coefficient(global_points_face(:, qk), problem_dim, &
                  region_id) * &
                (-1.0_db) * nflxsoln(ieqn, qk)*phi1(ieqn, qk, i)

              face_residual_p(ieqn, i) = face_residual_p(ieqn, i) + integral_weighting(qk)* ( &
                convection_terms &
              )

            end do

            do i = 1,no_dofs_per_variable2(ieqn)

              convection_terms = calculate_velocity_convection_coefficient(global_points_face(:, qk), problem_dim, &
                  region_id) * &
                nflxsoln(ieqn, qk)*phi2(ieqn, qk, i)

              face_residual_m(ieqn, i) = face_residual_m(ieqn, i) + integral_weighting(qk) * ( &
                convection_terms &
              )

            end do
          end do
        end do
      end if

      !!!!!!!!!!!!!!!!!!!!!
      !! REMAINING TERMS !!
      !!!!!!!!!!!!!!!!!!!!!
      if (bdry_face > 0) then
        if (large_boundary_v_penalisation) then
          full_dispenal = 1e10_db
        end if

        do qk = 1,no_quad_points
          interpolant_uh1(1:no_pdes,qk) = uh_face1(fe_basis_info,no_pdes,qk)
          do i = 1,no_pdes
            gradient_uh1(i,qk,1:problem_dim) = grad_uh_face1(fe_basis_info,problem_dim,i,qk,1)
          end do

          ! The solution is continuous, so we only need to do this on one side of the face.
          mesh_velocity = mesh_uh(1:problem_dim, qk)

          call anal_soln_velocity(uloc(:,qk),global_points_face(:,qk),problem_dim,no_pdes,bdry_face,current_time, &
            face_element_region_ids(1))
          ! if (solid_wall_mesh_velocity .and. uloc(1, qk) == 0.0_db .and. uloc(2, qk) == 0.0_db) then
          if (solid_wall_mesh_velocity) then
            uloc(1:2, qk) = uloc(1:2, qk) + mesh_velocity
          end if
          call compute_boundary_condition(interpolant_uh2(:,qk), &
            interpolant_uh1(:,qk),uloc(:,qk),abs(bdry_face),problem_dim,no_pdes)
          call neumann_bc_velocity(unloc(:,qk),global_points_face(:,qk),problem_dim,bdry_face,current_time, &
            face_element_region_ids(1),face_normals(:,qk))
          call lax_friedrichs(nflxsoln(:,qk),interpolant_uh1(:,qk), &
            interpolant_uh2(:,qk),face_normals(:,qk),problem_dim,no_pdes,mesh_velocity)

        end do

        do i = 1,no_pdes
          grad_phi1(i,1:no_quad_points,1:problem_dim,1:no_dofs_per_variable1(i)) = fe_basis_info%basis_face1 &
          %deriv_basis_fns(i)%grad_data(1:no_quad_points,:,1:no_dofs_per_variable1(i),1)
          phi1(i,1:no_quad_points,1:no_dofs_per_variable1(i)) = fe_basis_info%basis_face1%basis_fns(i) &
          %fem_basis_fns(1:no_quad_points,1:no_dofs_per_variable1(i),1)
        end do

        if (100 <= abs(bdry_face) .and. abs(bdry_face) <= 199) then
          do ieqn = 1,problem_dim
            do qk = 1,no_quad_points
              do i = 1,no_dofs_per_variable1(ieqn)

                diffusion_terms = calculate_velocity_diffusion_coefficient(global_points_face(:, qk), problem_dim, &
                    face_element_region_ids(1))* ( &
                  dot_product(gradient_uh1(ieqn, qk, :), face_normals(:, qk))*phi1(ieqn,qk,i) + &
                  (interpolant_uh1(ieqn,qk)-uloc(ieqn,qk))*dot_product(grad_phi1(ieqn,qk,:,i),face_normals(:,qk)) &
                )

                pressure_terms = calculate_velocity_pressure_coefficient(global_points_face(:, qk), problem_dim, &
                    face_element_region_ids(1))* &
                  (-1.0_db) * interpolant_uh1(problem_dim+1,qk)*face_normals(ieqn,qk)*phi1(ieqn,qk,i)

                boundary_terms = calculate_velocity_diffusion_coefficient(global_points_face(:, qk), problem_dim, &
                    face_element_region_ids(1))* &
                  (-1.0_db) * full_dispenal*(interpolant_uh1(ieqn,qk)-uloc(ieqn,qk))*phi1(ieqn,qk,i)

                face_residual_p(ieqn, i) = face_residual_p(ieqn, i) + integral_weighting(qk)*( &
                  diffusion_terms + &
                  pressure_terms + &
                  boundary_terms &
                )

              end do
            end do
          end do

          do qk = 1,no_quad_points
            do i = 1,no_dofs_per_variable1(problem_dim+1)

              incompressibility_terms = dot_product(interpolant_uh1(1:problem_dim, qk) - uloc(1:problem_dim, qk), &
                face_normals(:, qk)) * phi1(problem_dim+1, qk, i)

              face_residual_p(no_pdes, i) = face_residual_p(no_pdes, i) + integral_weighting(qk) * &
                incompressibility_terms

            end do
          end do

        else if (200 <= abs(bdry_face) .and. abs(bdry_face) <= 299) then
          do ieqn = 1,problem_dim
            do qk = 1,no_quad_points
              do i = 1,no_dofs_per_variable1(ieqn)

                forcing_terms = calculate_velocity_forcing_coefficient(global_points_face(:, qk), problem_dim, &
                    face_element_region_ids(1))* &
                  unloc(ieqn,qk)*phi1(ieqn,qk,i)

                face_residual_p(ieqn, i) = face_residual_p(ieqn, i) + integral_weighting(qk) * ( &
                  forcing_terms &
                )

              end do
            end do
          end do
        end if

      else

        do qk = 1,no_quad_points
          interpolant_uh1(:,qk) = uh_face1(fe_basis_info,no_pdes,qk)
          interpolant_uh2(:,qk) = uh_face2(fe_basis_info,no_pdes,qk)
          do i = 1,no_pdes
            gradient_uh1(i,qk,1:problem_dim) = grad_uh_face1(fe_basis_info,problem_dim,i,qk,1)
            gradient_uh2(i,qk,1:problem_dim) = grad_uh_face2(fe_basis_info,problem_dim,i,qk,1)
          end do
          ! The solution is continuous, so we only need to do this on one side of the face.
          mesh_velocity = mesh_uh(1:problem_dim, qk)
          call lax_friedrichs(nflxsoln(:,qk),interpolant_uh1(:,qk), &
            interpolant_uh2(:,qk),face_normals(:,qk),problem_dim,no_pdes,mesh_velocity)
        end do

        do i = 1,no_pdes
          grad_phi1(i,1:no_quad_points,1:problem_dim,1:no_dofs_per_variable1(i)) = fe_basis_info%basis_face1 &
          %deriv_basis_fns(i)%grad_data(1:no_quad_points,:,1:no_dofs_per_variable1(i),1)
          grad_phi2(i,1:no_quad_points,1:problem_dim,1:no_dofs_per_variable2(i)) = fe_basis_info%basis_face2 &
          %deriv_basis_fns(i)%grad_data(1:no_quad_points,:,1:no_dofs_per_variable2(i),1)
          phi1(i,1:no_quad_points,1:no_dofs_per_variable1(i)) = fe_basis_info%basis_face1%basis_fns(i) &
          %fem_basis_fns(1:no_quad_points,1:no_dofs_per_variable1(i),1)
          phi2(i,1:no_quad_points,1:no_dofs_per_variable2(i)) = fe_basis_info%basis_face2%basis_fns(i) &
          %fem_basis_fns(1:no_quad_points,1:no_dofs_per_variable2(i),1)
        end do

        do ieqn = 1,problem_dim
          do qk = 1,no_quad_points
            do i = 1,no_dofs_per_variable1(ieqn)

              penalty_terms = calculate_velocity_diffusion_coefficient(global_points_face(:, qk), problem_dim, &
                  face_element_region_ids(1))* &
                (-1.0_db) * full_dispenal*(interpolant_uh1(ieqn, qk) - interpolant_uh2(ieqn, qk)) * phi1(ieqn, qk, i)

              diffusion_terms = calculate_velocity_diffusion_coefficient(global_points_face(:, qk), problem_dim, &
                  face_element_region_ids(1))* ( &
                0.5_db*dot_product(gradient_uh1(ieqn, qk, :) + gradient_uh2(ieqn, qk, :), face_normals(:, qk)) &
                  * phi1(ieqn, qk, i) + &
                0.5_db *(interpolant_uh1(ieqn, qk) - interpolant_uh2(ieqn, qk))  &
                  *dot_product(grad_phi1(ieqn, qk, :, i), face_normals(:, qk)) &
              )

              pressure_terms = calculate_velocity_pressure_coefficient(global_points_face(:, qk), problem_dim, &
                  face_element_region_ids(1)) * &
                (-0.5_db)*(interpolant_uh1(problem_dim+1, qk) + interpolant_uh2(problem_dim+1, qk))* &
                  face_normals(ieqn, qk)*phi1(ieqn, qk, i)

              face_residual_p(ieqn, i) = face_residual_p(ieqn, i) + integral_weighting(qk)* ( &
                penalty_terms + &
                diffusion_terms + &
                pressure_terms &
              )

            end do

            do i = 1,no_dofs_per_variable2(ieqn)

              penalty_terms = calculate_velocity_diffusion_coefficient(global_points_face(:, qk), problem_dim, &
                  face_element_region_ids(1))* &
                full_dispenal*(interpolant_uh1(ieqn, qk) - interpolant_uh2(ieqn, qk)) * phi2(ieqn, qk, i)

              diffusion_terms = calculate_velocity_diffusion_coefficient(global_points_face(:, qk), problem_dim, &
                  face_element_region_ids(1)) * ( &
                (-0.5_db)*dot_product(gradient_uh1(ieqn, qk, :) + gradient_uh2(ieqn, qk, :), face_normals(:, qk)) &
                  * phi2(ieqn, qk, i) + &
                0.5_db *(interpolant_uh1(ieqn, qk) - interpolant_uh2(ieqn, qk))  &
                  *dot_product(grad_phi2(ieqn, qk, :, i), face_normals(:, qk)) &
              )

              pressure_terms = calculate_velocity_pressure_coefficient(global_points_face(:, qk), problem_dim, &
                  face_element_region_ids(1)) * &
                0.5_db*(interpolant_uh1(problem_dim+1, qk) + interpolant_uh2(problem_dim+1, qk))* &
                  face_normals(ieqn, qk)*phi2(ieqn, qk, i)

              face_residual_m(ieqn, i) = face_residual_m(ieqn, i) + integral_weighting(qk) * ( &
                penalty_terms + &
                diffusion_terms + &
                pressure_terms &
              )

            end do
          end do
        end do

        do qk = 1,no_quad_points

          do i = 1,no_dofs_per_variable1(problem_dim+1)

            incompressibility_terms = 0.5_db*dot_product(interpolant_uh1(1:problem_dim, qk) - interpolant_uh2(1:problem_dim, qk), &
                face_normals(:, qk)) &
              *phi1(problem_dim+1, qk, i)

            face_residual_p(no_pdes, i) = face_residual_p(no_pdes, i) + integral_weighting(qk) * ( &
              incompressibility_terms &
            )

          end do

          do i = 1,no_dofs_per_variable2(problem_dim+1)

            incompressibility_terms = 0.5_db*dot_product(interpolant_uh1(1:problem_dim, qk) - interpolant_uh2(1:problem_dim, qk), &
                face_normals(:, qk)) &
              *phi2(problem_dim+1, qk, i)

            face_residual_m(no_pdes, i) = face_residual_m(no_pdes, i) + integral_weighting(qk) * ( &
              incompressibility_terms &
            )

          end do
        end do

      end if

    end associate

  end subroutine element_residual_face_nsb_mm
  !--------------------------------------------------------------------
  ! PURPOSE:
  !> Defines the element jacobian matrix for the
  !!  Navier-Stokes-Brinkman equations
  !!
  !! Authors:
  !!   Paul Houston, Adam Blakey
  !!
  !! Date Created:
  !!   26-10-2022
  !--------------------------------------------------------------------
  subroutine jacobian_nsb_mm(element_matrix, &
    mesh_data, soln_data, facet_data, fe_basis_info)
    !--------------------------------------------------------------------
    use problem_options
    use problem_options_velocity
    use problem_options_geometry
    use aptofem_fe_matrix_assembly

    include 'assemble_jac_matrix_element.h'

    ! Local variables

    integer :: qk,i,j,ieqn,ivar
    real(db) :: diff_terms,gradgradterm,pgradv,qgradu,convection_term,uvterm
    real(db), dimension(facet_data%problem_dim,facet_data%problem_dim, &
    facet_data%problem_dim,facet_data%no_quad_points) :: fluxes_prime
    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points) :: interpolant_uh
    real(db), dimension(facet_data%dim_soln_coeff,facet_data%no_quad_points, &
    facet_data%problem_dim,maxval(facet_data%no_dofs_per_variable)) :: grad_phi
    real(db), dimension(facet_data%dim_soln_coeff,facet_data%no_quad_points, &
    maxval(facet_data%no_dofs_per_variable)) :: phi
    real(db) :: dirk_scaling_factor,current_time
    real(db) :: mass_matrix
    integer  :: element_region_id

    ! Moving mesh variables.
    real(db), dimension(facet_data%problem_dim) :: mesh_velocity
    real(db), dimension(facet_data%problem_dim, facet_data%no_quad_points) :: mesh_uh
    real(db), dimension(facet_data%problem_dim, facet_data%no_quad_points) :: mesh_global_points_ele
    real(db), dimension(facet_data%no_quad_points) :: mesh_jacobian, mesh_quad_weights_ele
    real(db), dimension(facet_data%dim_soln_coeff, facet_data%no_quad_points, maxval(facet_data%no_dofs_per_variable)) :: mesh_phi
    integer, dimension(facet_data%dim_soln_coeff, maxval(facet_data%no_dofs_per_variable)) :: mesh_global_dof_numbers
    integer, dimension(facet_data%dim_soln_coeff) :: mesh_no_dofs_per_variable
    integer :: mesh_no_quad_points

    ! Extra variables on previous mesh.
    real(db), dimension(facet_data%problem_dim, facet_data%no_quad_points) :: &
      prev_gauss_points_local, prev_gauss_points_global, mesh_gauss_points_local, mesh_gauss_points_global
    real(db), dimension(facet_data%problem_dim, facet_data%problem_dim, facet_data%no_quad_points) :: &
      prev_jacobi_mat, prev_inv_jacobi_mat, mesh_jacobi_mat, mesh_inv_jacobi_mat
    integer :: prev_dim_soln_coeff_start, prev_dim_soln_coeff_end, prev_dim_soln_coeff_fe_space, mesh_dim_soln_coeff_start, &
      mesh_dim_soln_coeff_end, mesh_dim_soln_coeff_fe_space

    character(len=aptofem_length_key_def) :: control_parameter

    integer             :: mesh_dim_soln_coeff, mesh_no_pdes, mesh_no_elements, mesh_no_nodes, mesh_no_faces, mesh_problem_dim, &
      mesh_npinc, mesh_no_quad_points_volume_max, mesh_no_quad_points_face_max
    type(basis_storage) :: mesh_fe_basis_info

    ! Setup basis storage (purely for quadrature points).
    control_parameter = 'uh_ele'
    call initialize_fe_basis_storage(mesh_fe_basis_info, control_parameter, solution_moving_mesh, &
      facet_data%problem_dim, facet_data%no_quad_points_volume_max, facet_data%no_quad_points_face_max)

    ! Get element DoFs for moving mesh solution.
    mesh_dim_soln_coeff = get_dim_soln_coeff(solution_moving_mesh)
    call get_element_dof_numbers(prev_mesh_data, solution_moving_mesh, mesh_global_dof_numbers, mesh_no_dofs_per_variable, &
      facet_data%element_number, mesh_dim_soln_coeff)

    ! Get element integration info.
    mesh_no_quad_points = facet_data%no_quad_points
    call get_element_transform_quad_pts(prev_mesh_data, facet_data%element_number, facet_data%problem_dim, &
      mesh_gauss_points_local, mesh_global_points_ele, mesh_quad_weights_ele, mesh_no_quad_points, mesh_jacobi_mat, &
      mesh_jacobian)

    do i = 1, solution_moving_mesh%no_fem_spaces
      mesh_dim_soln_coeff_start    = solution_moving_mesh%fem_spaces(i)%fem%dim_soln_coeff_start_end(1)
      mesh_dim_soln_coeff_end      = solution_moving_mesh%fem_spaces(i)%fem%dim_soln_coeff_start_end(2)
      mesh_dim_soln_coeff_fe_space = solution_moving_mesh%fem_spaces(i)%fem%dim_soln_coeff_fe_space

      call solution_moving_mesh%fem_spaces(i)%fem%basis_fns_stored_quad_pts(prev_mesh_data, facet_data%element_number, &
        facet_data%problem_dim, facet_data%no_quad_points, mesh_dim_soln_coeff_fe_space, &
        mesh_gauss_points_local(:, 1:facet_data%no_quad_points), mesh_global_points_ele(:, 1:facet_data%no_quad_points), &
        mesh_no_dofs_per_variable, mesh_fe_basis_info%basis_element, mesh_jacobi_mat(:, :, 1:facet_data%no_quad_points), &
        mesh_jacobian(1:facet_data%no_quad_points))
    end do
    
    call compute_uh_with_basis_fns_pts(mesh_uh(:, 1:facet_data%no_quad_points), facet_data%problem_dim, facet_data%no_quad_points, &
      mesh_dim_soln_coeff, mesh_no_dofs_per_variable, mesh_global_dof_numbers, mesh_fe_basis_info%basis_element, &
      solution_moving_mesh)

    associate( &
      dim_soln_coeff => facet_data%dim_soln_coeff, &
      no_pdes => facet_data%no_pdes, &
      problem_dim => facet_data%problem_dim, &
      no_quad_points => facet_data%no_quad_points, &
      global_points_ele => facet_data%global_points, &
      integral_weighting => facet_data%integral_weighting, &
      element_number => facet_data%element_number, &
      element_region_id_old => facet_data%element_region_id, &
      no_dofs_per_variable => facet_data%no_dofs_per_variable, &
      scheme_user_data => facet_data%scheme_user_data)

      dirk_scaling_factor = scheme_user_data%dirk_scaling_factor
      current_time = scheme_user_data%current_time

      call convert_velocity_region_id(element_region_id_old, element_region_id)

      element_matrix = 0.0_db

      do qk = 1,no_quad_points
        interpolant_uh(:,qk) = uh_element(fe_basis_info,no_pdes,qk)
        mesh_velocity = mesh_uh(1:problem_dim, qk)
        call jacobian_convective_fluxes(interpolant_uh(:,qk), &
          fluxes_prime(:,:,:,qk),problem_dim,no_pdes,mesh_velocity)
      end do

      do i = 1,dim_soln_coeff
        grad_phi(i,1:no_quad_points,1:problem_dim,1:no_dofs_per_variable(i)) = fe_basis_info%basis_element &
        %deriv_basis_fns(i)%grad_data(1:no_quad_points,1:problem_dim,1:no_dofs_per_variable(i),1)
        phi(i,1:no_quad_points,1:no_dofs_per_variable(i)) = fe_basis_info%basis_element%basis_fns(i) &
        %fem_basis_fns(1:no_quad_points,1:no_dofs_per_variable(i),1)
      end do

      do qk = 1,no_quad_points
        do ieqn = 1,no_pdes
          do i = 1,no_dofs_per_variable(ieqn)
            do ivar = 1,no_pdes
              do j = 1,no_dofs_per_variable(ivar)

                convection_term = 0.0_db
                mass_matrix = 0.0_db

                if (ieqn <= problem_dim .and. ivar <= problem_dim) then

                  convection_term = dot_product( &
                  fluxes_prime(1:problem_dim,ieqn,ivar,qk), &
                  grad_phi(ieqn,qk,1:problem_dim,i))*phi(ivar,qk,j)

                  if (ieqn == ivar) then
                    mass_matrix = dirk_scaling_factor*phi(ivar,qk,j)*phi(ieqn,qk,i)
                  end if

                end if

                gradgradterm = cal_gradgradterm(grad_phi(ivar,qk,:,j), &
                grad_phi(ieqn,qk,:,i),ivar,ieqn,problem_dim,no_pdes)

                pgradv = cal_gradterm(phi(ivar,qk,j), &
                grad_phi(ieqn,qk,:,i),ivar,ieqn,problem_dim,no_pdes)

                qgradu = cal_gradterm(phi(ieqn,qk,i), &
                grad_phi(ivar,qk,:,j),ieqn,ivar,problem_dim,no_pdes)

                uvterm = cal_uvterm(phi(ieqn, qk, i), phi(ivar, qk, j), ieqn, ivar, problem_dim, no_pdes)

                element_matrix(ieqn,ivar,i,j) = element_matrix(ieqn,ivar,i,j) + integral_weighting(qk)*( &
                  calculate_velocity_time_coefficient(global_points_ele(:, qk), problem_dim, &
                    element_region_id) * &
                      mass_matrix + &
                  calculate_velocity_diffusion_coefficient(global_points_ele(:, qk), problem_dim, &
                    element_region_id) * &
                      gradgradterm - &
                  calculate_velocity_pressure_coefficient(global_points_ele(:, qk), problem_dim, &
                    element_region_id) * &
                      pgradv + &
                  qgradu - &
                  calculate_velocity_convection_coefficient(global_points_ele(:, qk), problem_dim, &
                    element_region_id) * &
                      convection_term + &
                  calculate_velocity_reaction_coefficient(global_points_ele(:, qk), problem_dim, &
                    element_region_id) * &
                      uvterm &
                )

              end do
            end do
          end do
        end do
      end do
    end associate

  end subroutine jacobian_nsb_mm

  !--------------------------------------------------------------------
  ! PURPOSE:
  !> Defines the face jacobian matrices for the
  !!  Navier-Stokes-Brinkman equations.
  !!
  !! Author:
  !!   Paul Houston, Adam Blakey
  !!
  !! Date Created:
  !!   26-10-2022
  !--------------------------------------------------------------------
  subroutine jacobian_face_nsb_mm(face_matrix_pp,face_matrix_pm, &
    face_matrix_mp,face_matrix_mm, mesh_data, soln_data, &
    facet_data, fe_basis_info)
    !--------------------------------------------------------------------
    use problem_options
    use problem_options_velocity
    use problem_options_geometry
    use aptofem_fe_matrix_assembly

    include 'assemble_jac_matrix_int_bdry_face.h'

    ! Local variables

    integer :: qk,i,j,ieqn,ivar
    real(db) :: full_dispenal,diff_terms,pvterm,quterm, &
    convective_flux_1,convective_flux_2,convection_terms
    real(db), dimension(facet_data%problem_dim,facet_data%problem_dim, &
    facet_data%problem_dim,facet_data%no_quad_points) :: &
    fluxes_prime1,fluxes_prime2
    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points) :: uloc
    real(db), dimension(facet_data%no_quad_points) :: alpha
    real(db), dimension(facet_data%problem_dim,facet_data%problem_dim, &
    facet_data%no_quad_points) :: boundary_jacobian
    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points) :: &
    interpolant_uh1,interpolant_uh2
    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points, &
    facet_data%problem_dim) :: grad_uh1, grad_uh2
    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points, &
    facet_data%problem_dim,maxval(facet_data%no_dofs_per_variable1)) :: grad_phi1
    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points, &
    facet_data%problem_dim,maxval(facet_data%no_dofs_per_variable2)) :: grad_phi2
    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points, &
    maxval(facet_data%no_dofs_per_variable1)) :: phi1
    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points, &
    maxval(facet_data%no_dofs_per_variable2)) :: phi2
    real(db) :: current_time

    real(db) :: diffusion_coefficient, convection_coefficient, reaction_coefficient, pressure_coefficient, &
    forcing_coefficient

    integer               :: effective_bdry_no, bdry_face
    integer, dimension(2) :: face_element_region_ids
    integer               :: region_id

    ! Moving mesh variables.
    real(db), dimension(facet_data%problem_dim) :: mesh_velocity
    real(db), dimension(facet_data%problem_dim, facet_data%no_quad_points) :: mesh_uh
    real(db), dimension(facet_data%problem_dim, facet_data%no_quad_points_face_max) :: mesh_global_points_face, mesh_face_normals
    real(db), dimension(facet_data%no_quad_points_face_max) :: mesh_face_jacobian, mesh_quad_weights_face
    real(db), dimension(facet_data%dim_soln_coeff, facet_data%no_quad_points_face_max, maxval(facet_data%no_dofs_per_variable1)) ::&
       mesh_phi
    integer, dimension(facet_data%dim_soln_coeff, maxval(facet_data%no_dofs_per_variable1)) :: mesh_global_dof_numbers1, &
      mesh_global_dof_numbers2
    integer, dimension(facet_data%dim_soln_coeff) :: mesh_no_dofs_per_variable1, mesh_no_dofs_per_variable2
    integer :: mesh_no_quad_points
    integer, dimension(2) :: mesh_neighbors, mesh_loc_face_no

    ! Additional variables on previous mesh.
    integer :: element_no1, element_no2, mesh_dim_soln_coeff_start, mesh_dim_soln_coeff_end, mesh_dim_soln_coeff_fe_space
    real(db), dimension(facet_data%problem_dim, facet_data%no_quad_points) :: mesh_local_points1, mesh_local_points2, &
      mesh_global_points
    real(db), dimension(facet_data%problem_dim, facet_data%problem_dim, facet_data%no_quad_points) :: mesh_jacobi_mat1, &
      mesh_inv_jacobi_mat1, mesh_jacobi_mat2
    real(db), dimension(facet_data%no_quad_points) :: mesh_jacobian1, mesh_jacobian2

    character(len=aptofem_length_key_def) :: control_parameter

    integer             :: mesh_dim_soln_coeff, mesh_no_pdes, mesh_no_elements, mesh_no_nodes, mesh_no_faces, mesh_problem_dim, &
      mesh_npinc, mesh_no_quad_points_volume_max, mesh_no_quad_points_face_max, mesh_bdry_face
    type(basis_storage) :: mesh_fe_basis_info

    ! Setup basis storage (purely for quadrature points).
    control_parameter = 'uh_face'
    call initialize_fe_basis_storage(mesh_fe_basis_info, control_parameter, solution_moving_mesh, &
      facet_data%problem_dim, facet_data%no_quad_points_volume_max, facet_data%no_quad_points_face_max)

    ! Assuming continuity, we will mostly just work on face 1; in fact it probably could work with just face 1; I suspect problems
    !  may arise in compute_uh_with_basis_fns_pts if we don't do anything to face 2.
    element_no1 = facet_data%neighbours(1)
    element_no2 = facet_data%neighbours(2)

    ! Get the local face numbers.
    mesh_loc_face_no = mesh_data%mesh_faces(facet_data%face_number)%loc_face_no

    ! Get element DoFs for moving mesh solution.
    mesh_dim_soln_coeff = get_dim_soln_coeff(solution_moving_mesh)
    call get_element_dof_numbers(prev_mesh_data, solution_moving_mesh, mesh_global_dof_numbers1, mesh_no_dofs_per_variable1, &
      element_no1, mesh_dim_soln_coeff)

    ! Get face integration info.
    mesh_no_quad_points = facet_data%no_quad_points
    call get_face_transform_quad_pts(prev_mesh_data, element_no1, mesh_loc_face_no(1), facet_data%problem_dim, &
      mesh_local_points1(:,1:facet_data%no_quad_points), mesh_global_points(:, 1:facet_data%no_quad_points), &
      mesh_quad_weights_face(1:facet_data%no_quad_points), mesh_no_quad_points, mesh_face_jacobian(1:facet_data%no_quad_points), &
      mesh_face_normals(:, 1:facet_data%no_quad_points), mesh_jacobi_mat1(:, :, 1:facet_data%no_quad_points), &
      mesh_jacobian1(1:facet_data%no_quad_points), mesh_inv_jacobi_mat1(:, :, 1:facet_data%no_quad_points))

    do i = 1, solution_moving_mesh%no_fem_spaces
      mesh_dim_soln_coeff_start    = solution_moving_mesh%fem_spaces(i)%fem%dim_soln_coeff_start_end(1)
      mesh_dim_soln_coeff_end      = solution_moving_mesh%fem_spaces(i)%fem%dim_soln_coeff_start_end(2)
      mesh_dim_soln_coeff_fe_space = solution_moving_mesh%fem_spaces(i)%fem%dim_soln_coeff_fe_space

      call solution_moving_mesh%fem_spaces(i)%fem%uh_basis_fns_pts(prev_mesh_data, solution_moving_mesh, &
        element_no1, facet_data%problem_dim, facet_data%no_quad_points, mesh_dim_soln_coeff_fe_space, &
        mesh_local_points1(:, 1:facet_data%no_quad_points), mesh_global_points(:, 1:facet_data%no_quad_points), &
        mesh_no_dofs_per_variable1, mesh_fe_basis_info%basis_face1, mesh_jacobi_mat1(:, :, 1:facet_data%no_quad_points), &
        mesh_jacobian1(1:facet_data%no_quad_points))
      if (element_no2 > 0) then
        call solution_moving_mesh%fem_spaces(i)%fem%uh_basis_fns_pts(prev_mesh_data, solution_moving_mesh, &
          element_no2, facet_data%problem_dim, facet_data%no_quad_points, mesh_dim_soln_coeff_fe_space, &
          mesh_local_points2(:, 1:facet_data%no_quad_points), mesh_global_points(:, 1:facet_data%no_quad_points), &
          mesh_no_dofs_per_variable2, mesh_fe_basis_info%basis_face2, mesh_jacobi_mat2(:, :, 1:facet_data%no_quad_points), &
          mesh_jacobian2(1:facet_data%no_quad_points))
      end if
    end do

    call compute_uh_with_basis_fns_pts(mesh_uh(:, 1:facet_data%no_quad_points), facet_data%problem_dim, facet_data%no_quad_points, &
      mesh_dim_soln_coeff, mesh_no_dofs_per_variable1, mesh_global_dof_numbers1, mesh_fe_basis_info%basis_face1, &
      solution_moving_mesh)

    associate( &
      dim_soln_coeff => facet_data%dim_soln_coeff, &
      no_pdes => facet_data%no_pdes, &
      problem_dim => facet_data%problem_dim, &
      no_quad_points => facet_data%no_quad_points, &
      global_points_face => facet_data%global_points, &
      integral_weighting => facet_data%integral_weighting, &
      face_number => facet_data%face_number, &
      neighbours => facet_data%neighbours, &
      interior_face_boundary_no => facet_data%interior_face_boundary_no, &
      face_element_region_ids_old => facet_data%face_element_region_ids, &
      bdry_face_old => facet_data%bdry_no, &
      no_dofs_per_variable1 => facet_data%no_dofs_per_variable1, &
      no_dofs_per_variable2 => facet_data%no_dofs_per_variable2, &
      face_normals => facet_data%face_normals, &
      dispenal => facet_data%dispenal, &
      scheme_user_data => facet_data%scheme_user_data)

      current_time = scheme_user_data%current_time

      face_matrix_pp = 0.0_db
      face_matrix_pm = 0.0_db
      face_matrix_mp = 0.0_db
      face_matrix_mm = 0.0_db

      full_dispenal = interior_penalty_parameter*dispenal(1)

      call convert_velocity_boundary_no(bdry_face_old, bdry_face)
      call convert_velocity_region_id(face_element_region_ids_old(1), face_element_region_ids(1))
      call convert_velocity_region_id(face_element_region_ids_old(2), face_element_region_ids(2))

      !!!!!!!!!!!!!!!!!!!!!!!!!!!
      !! CONVECTION TERMS ONLY !!
      !!!!!!!!!!!!!!!!!!!!!!!!!!!
      if (bdry_face > 0) then
        if (large_boundary_v_penalisation) then
          full_dispenal = 1e10_db
        end if

        ! Calculate value of analytical solution at quadrature points
        do qk = 1,no_quad_points
          interpolant_uh1(:,qk) = uh_face1(fe_basis_info,no_pdes,qk)
          do i = 1,no_pdes
            grad_uh1(i,qk,1:problem_dim) = grad_uh_face1(fe_basis_info,problem_dim,i,qk,1)
          end do

          ! The solution is continuous, so we only need to do this on one side of the face.
          mesh_velocity = mesh_uh(1:problem_dim, qk)

          call anal_soln_velocity(uloc(:,qk),global_points_face(:,qk),problem_dim,no_pdes,0,current_time, &
            face_element_region_ids(1))
          ! if (solid_wall_mesh_velocity .and. uloc(1, qk) == 0.0_db .and. uloc(2, qk) == 0.0_db) then
          if (solid_wall_mesh_velocity) then
            uloc(1:2, qk) = uloc(1:2, qk) + mesh_velocity
          end if
          call compute_boundary_condition(interpolant_uh2(:,qk), &
            interpolant_uh1(:,qk),uloc(:,qk),abs(bdry_face),problem_dim,no_pdes)
          alpha(qk) = cal_alpha(interpolant_uh1(:,qk),interpolant_uh2(:,qk), &
            face_normals(:,qk),problem_dim,no_pdes,mesh_velocity)
          call jacobian_convective_fluxes(interpolant_uh1(:,qk), &
            fluxes_prime1(:,:,:,qk),problem_dim,no_pdes, mesh_velocity)
          call jacobian_convective_fluxes(interpolant_uh2(:,qk), &
            fluxes_prime2(:,:,:,qk),problem_dim,no_pdes, mesh_velocity)
          call jacobian_lf_flux_bdry(boundary_jacobian(:,:,qk), &
            abs(bdry_face),fluxes_prime2(:,:,:,qk),alpha(qk),face_normals(:,qk), &
            interpolant_uh1(:,qk),problem_dim,no_pdes)
        end do

        do i = 1,no_pdes
          grad_phi1(i,1:no_quad_points,1:problem_dim,1:no_dofs_per_variable1(i)) = fe_basis_info%basis_face1 &
          %deriv_basis_fns(i)%grad_data(1:no_quad_points,:,1:no_dofs_per_variable1(i),1)
          phi1(i,1:no_quad_points,1:no_dofs_per_variable1(i)) = fe_basis_info%basis_face1%basis_fns(i) &
          %fem_basis_fns(1:no_quad_points,1:no_dofs_per_variable1(i),1)
        end do

        if (100 <= abs(bdry_face) .and. abs(bdry_face) <= 199) then ! Dirichlet boundary
          ! Loop over quadrature points
          do qk = 1,no_quad_points

            convection_coefficient = calculate_velocity_convection_coefficient(global_points_face(:, qk), &
              problem_dim, face_element_region_ids(1))

            ! Loop over the equations
            do ieqn = 1,no_pdes
              ! Loop over phi_i
              do i = 1,no_dofs_per_variable1(ieqn)
                ! Loop over the variables
                do ivar = 1,no_pdes
                  ! Loop over phi_j
                  do j = 1,no_dofs_per_variable1(ivar)
                    convective_flux_1 = 0.0_db
                    convective_flux_2 = 0.0_db

                    if (ieqn <= problem_dim .and. ivar <= problem_dim) then
                      convective_flux_1 = 0.5_db*dot_product( &
                        fluxes_prime1(1:problem_dim,ieqn,ivar,qk), &
                        face_normals(1:problem_dim,qk)&
                      )
                      if (ieqn == ivar) then
                        convective_flux_1 = convective_flux_1+0.5_db*alpha(qk)
                      endif
                      convective_flux_2 = boundary_jacobian(ieqn,ivar,qk)
                    end if

                    convection_terms = convection_coefficient* &
                      (convective_flux_1+convective_flux_2)*phi1(ivar,qk,j)*phi1(ieqn,qk,i)

                    face_matrix_pp(ieqn,ivar,i,j) = face_matrix_pp(ieqn,ivar,i,j) &
                      +integral_weighting(qk)*convection_terms

                  end do
                end do
              end do
            end do
          end do
        else if (200 <= abs(bdry_face) .and. abs(bdry_face) <= 299) then ! Neumann Boundary
          ! Loop over quadrature points
          do qk = 1,no_quad_points

            convection_coefficient = calculate_velocity_convection_coefficient(global_points_face(:, qk), &
              problem_dim, face_element_region_ids(1))

            ! Loop over the equations
            do ieqn = 1,no_pdes
              ! Loop over phi_i
              do i = 1,no_dofs_per_variable1(ieqn)
                ! Loop over the variables
                do ivar = 1,no_pdes
                  ! Loop over phi_j
                  do j = 1,no_dofs_per_variable1(ivar)
                    convective_flux_1 = 0.0_db
                    convective_flux_2 = 0.0_db

                    if (ieqn <= problem_dim .and. ivar <= problem_dim) then
                      convective_flux_1 = 0.5_db*dot_product( &
                      fluxes_prime1(1:problem_dim,ieqn,ivar,qk), &
                      face_normals(1:problem_dim,qk))
                      if (ieqn == ivar) then
                        convective_flux_1 = convective_flux_1+0.5_db*alpha(qk)
                      endif
                      convective_flux_2 = boundary_jacobian(ieqn,ivar,qk)
                    end if

                    convection_terms = convection_coefficient* &
                      (convective_flux_1+convective_flux_2)*phi1(ivar,qk,j)*phi1(ieqn,qk,i)

                    face_matrix_pp(ieqn,ivar,i,j) = face_matrix_pp(ieqn,ivar,i,j) &
                      +integral_weighting(qk)*convection_terms

                  end do
                end do
              end do
            end do
          end do
        end if
      else
        do qk = 1,no_quad_points
          interpolant_uh1(:,qk) = uh_face1(fe_basis_info,no_pdes,qk)
          interpolant_uh2(:,qk) = uh_face2(fe_basis_info,no_pdes,qk)
          do i = 1,no_pdes
            grad_uh1(i,qk,1:problem_dim) = grad_uh_face1(fe_basis_info,problem_dim,i,qk,1)
            grad_uh2(i,qk,1:problem_dim) = grad_uh_face2(fe_basis_info,problem_dim,i,qk,1)
          end do
          ! The solution is continuous, so we only need to do this on one side of the face.
          mesh_velocity = mesh_uh(1:problem_dim, qk)
          alpha(qk) = cal_alpha(interpolant_uh1(:,qk),interpolant_uh2(:,qk), &
            face_normals(:,qk),problem_dim,no_pdes,mesh_velocity)
          call jacobian_convective_fluxes(interpolant_uh1(:,qk), &
            fluxes_prime1(:,:,:,qk),problem_dim,no_pdes,mesh_velocity)
          call jacobian_convective_fluxes(interpolant_uh2(:,qk), &
            fluxes_prime2(:,:,:,qk),problem_dim,no_pdes,mesh_velocity)
        end do

        do i = 1,no_pdes
          grad_phi1(i,1:no_quad_points,1:problem_dim,1:no_dofs_per_variable1(i)) = fe_basis_info%basis_face1 &
          %deriv_basis_fns(i)%grad_data(1:no_quad_points,:,1:no_dofs_per_variable1(i),1)
          grad_phi2(i,1:no_quad_points,1:problem_dim,1:no_dofs_per_variable2(i)) = fe_basis_info%basis_face2 &
          %deriv_basis_fns(i)%grad_data(1:no_quad_points,:,1:no_dofs_per_variable2(i),1)
          phi1(i,1:no_quad_points,1:no_dofs_per_variable1(i)) = fe_basis_info%basis_face1%basis_fns(i) &
          %fem_basis_fns(1:no_quad_points,1:no_dofs_per_variable1(i),1)
          phi2(i,1:no_quad_points,1:no_dofs_per_variable2(i)) = fe_basis_info%basis_face2%basis_fns(i) &
          %fem_basis_fns(1:no_quad_points,1:no_dofs_per_variable2(i),1)
        end do

        ! if (500 <= face_element_region_ids(1) .and. face_element_region_ids(1) <= 599) then
        !   region_id = face_element_region_ids(1)
        ! else
        !   region_id = face_element_region_ids(2)
        ! end if
        region_id = face_element_region_ids(1)

        do qk = 1,no_quad_points

          convection_coefficient = calculate_velocity_convection_coefficient(global_points_face(:, qk), &
            problem_dim, region_id)

          do ieqn = 1,no_pdes

            do ivar = 1,no_pdes

              convective_flux_1 = 0.0_db
              convective_flux_2 = 0.0_db

              if (ieqn <= problem_dim .and. ivar <= problem_dim) then
                convective_flux_1 = 0.5_db*dot_product( &
                fluxes_prime1(1:problem_dim,ieqn,ivar,qk), &
                face_normals(1:problem_dim,qk))
                convective_flux_2 = 0.5_db*dot_product( &
                fluxes_prime2(1:problem_dim,ieqn,ivar,qk), &
                face_normals(1:problem_dim,qk))
                if (ieqn == ivar) then
                  convective_flux_1 = convective_flux_1+0.5_db*alpha(qk)
                  convective_flux_2 = convective_flux_2-0.5_db*alpha(qk)
                endif
              end if

              ! Loop over phi_i
              do i = 1,no_dofs_per_variable1(ieqn)

                ! u^+ v^+ w.r.t. ele1

                ! Loop over phi_j
                do j = 1,no_dofs_per_variable1(ivar)
                  convection_terms = &
                    convection_coefficient * &
                    convective_flux_1*phi1(ieqn,qk,i)*phi1(ivar,qk,j)

                  face_matrix_pp(ieqn,ivar,i,j) = face_matrix_pp(ieqn,ivar,i,j) &
                    +integral_weighting(qk)*(convection_terms)
                end do

                ! u^- v^+ w.r.t. ele1

                ! Loop over phi_j
                do j = 1,no_dofs_per_variable2(ivar)
                  convection_terms = &
                    convection_coefficient * &
                    convective_flux_2*phi1(ieqn,qk,i)*phi2(ivar,qk,j)

                  face_matrix_mp(ieqn,ivar,i,j) = face_matrix_mp(ieqn,ivar,i,j) &
                    +integral_weighting(qk)*(convection_terms)

                end do
              end do

              ! Loop over phi_i
              do i = 1,no_dofs_per_variable2(ieqn)

                ! u^+ v^- w.r.t. ele1

                ! Loop over phi_j
                do j = 1,no_dofs_per_variable1(ivar)
                  convection_terms = &
                    convection_coefficient * &
                    convective_flux_1*phi2(ieqn,qk,i)*phi1(ivar,qk,j)

                  face_matrix_pm(ieqn,ivar,i,j) = face_matrix_pm(ieqn,ivar,i,j) &
                    +integral_weighting(qk)*((-1.0_db)*convection_terms)
                end do

                ! u^- v^- w.r.t. ele1

                ! Loop over phi_j
                do j = 1,no_dofs_per_variable2(ivar)
                  convection_terms = &
                    convection_coefficient * &
                    convective_flux_2*phi2(ieqn,qk,i)*phi2(ivar,qk,j)

                  face_matrix_mm(ieqn,ivar,i,j) = face_matrix_mm(ieqn,ivar,i,j) &
                    +integral_weighting(qk)*((-1.0_db)*convection_terms)

                end do
              end do
            end do
          end do
        end do
      end if

      !!!!!!!!!!!!!!!!!!!!!
      !! REMAINING TERMS !!
      !!!!!!!!!!!!!!!!!!!!!
      ! If we're on the interior.
      if (bdry_face == 0) then
        do qk = 1,no_quad_points
          interpolant_uh1(:,qk) = uh_face1(fe_basis_info,no_pdes,qk)
          interpolant_uh2(:,qk) = uh_face2(fe_basis_info,no_pdes,qk)
          do i = 1,no_pdes
            grad_uh1(i,qk,1:problem_dim) = grad_uh_face1(fe_basis_info,problem_dim,i,qk,1)
            grad_uh2(i,qk,1:problem_dim) = grad_uh_face2(fe_basis_info,problem_dim,i,qk,1)
          end do
          ! The solution is continuous, so we only need to do this on one side of the face.
          mesh_velocity = mesh_uh(1:problem_dim, qk)
          alpha(qk) = cal_alpha(interpolant_uh1(:,qk),interpolant_uh2(:,qk), &
            face_normals(:,qk),problem_dim,no_pdes,mesh_velocity)
          call jacobian_convective_fluxes(interpolant_uh1(:,qk), &
            fluxes_prime1(:,:,:,qk),problem_dim,no_pdes,mesh_velocity)
          call jacobian_convective_fluxes(interpolant_uh2(:,qk), &
            fluxes_prime2(:,:,:,qk),problem_dim,no_pdes,mesh_velocity)
        end do

        do i = 1,no_pdes
          grad_phi1(i,1:no_quad_points,1:problem_dim,1:no_dofs_per_variable1(i)) = fe_basis_info%basis_face1 &
          %deriv_basis_fns(i)%grad_data(1:no_quad_points,:,1:no_dofs_per_variable1(i),1)
          grad_phi2(i,1:no_quad_points,1:problem_dim,1:no_dofs_per_variable2(i)) = fe_basis_info%basis_face2 &
          %deriv_basis_fns(i)%grad_data(1:no_quad_points,:,1:no_dofs_per_variable2(i),1)
          phi1(i,1:no_quad_points,1:no_dofs_per_variable1(i)) = fe_basis_info%basis_face1%basis_fns(i) &
          %fem_basis_fns(1:no_quad_points,1:no_dofs_per_variable1(i),1)
          phi2(i,1:no_quad_points,1:no_dofs_per_variable2(i)) = fe_basis_info%basis_face2%basis_fns(i) &
          %fem_basis_fns(1:no_quad_points,1:no_dofs_per_variable2(i),1)
        end do

        do qk = 1,no_quad_points

          diffusion_coefficient  = calculate_velocity_diffusion_coefficient(global_points_face(:, qk), &
            problem_dim, face_element_region_ids(1))
          pressure_coefficient   = calculate_velocity_pressure_coefficient(global_points_face(:, qk), &
            problem_dim, face_element_region_ids(1))
          forcing_coefficient    = calculate_velocity_forcing_coefficient(global_points_face(:, qk), &
            problem_dim, face_element_region_ids(1))

          do ieqn = 1,no_pdes

            do ivar = 1,no_pdes

              convective_flux_1 = 0.0_db
              convective_flux_2 = 0.0_db

              if (ieqn <= problem_dim .and. ivar <= problem_dim) then
                convective_flux_1 = 0.5_db*dot_product( &
                fluxes_prime1(1:problem_dim,ieqn,ivar,qk), &
                face_normals(1:problem_dim,qk))
                convective_flux_2 = 0.5_db*dot_product( &
                fluxes_prime2(1:problem_dim,ieqn,ivar,qk), &
                face_normals(1:problem_dim,qk))
                if (ieqn == ivar) then
                  convective_flux_1 = convective_flux_1+0.5_db*alpha(qk)
                  convective_flux_2 = convective_flux_2-0.5_db*alpha(qk)
                endif

              end if

              ! Loop over phi_i
              do i = 1,no_dofs_per_variable1(ieqn)

                ! u^+ v^+ w.r.t. ele1

                ! Loop over phi_j
                do j = 1,no_dofs_per_variable1(ivar)
                  diff_terms = &
                    diffusion_coefficient * &
                    cal_diff_terms_int_face(grad_phi1(ivar,qk,:,j), &
                      grad_phi1(ieqn,qk,:,i),phi1(ivar,qk,j), &
                      phi1(ieqn,qk,i),face_normals(:,qk),full_dispenal, &
                      ivar,ieqn,problem_dim,no_pdes)

                  pvterm = &
                    pressure_coefficient * &
                    0.5_db*cal_grad_terms_bdry_face(phi1(ivar,qk,j), &
                      phi1(ieqn,qk,i),face_normals(:,qk),ivar,ieqn, &
                      problem_dim,no_pdes)

                  quterm = 0.5_db*cal_grad_terms_bdry_face(phi1(ieqn,qk,i), &
                    phi1(ivar,qk,j),face_normals(:,qk),ieqn,ivar, &
                    problem_dim,no_pdes)

                  face_matrix_pp(ieqn,ivar,i,j) = face_matrix_pp(ieqn,ivar,i,j) &
                    +integral_weighting(qk)*(diff_terms+pvterm-quterm)

                end do

                ! u^- v^+ w.r.t. ele1

                ! Loop over phi_j
                do j = 1,no_dofs_per_variable2(ivar)
                  diff_terms = &
                    diffusion_coefficient * &
                    cal_diff_terms_int_face(grad_phi2(ivar,qk,:,j), &
                      grad_phi1(ieqn,qk,:,i),-phi2(ivar,qk,j), &
                      phi1(ieqn,qk,i),face_normals(:,qk),full_dispenal, &
                      ivar,ieqn,problem_dim,no_pdes)

                  pvterm = &
                    pressure_coefficient * &
                    0.5_db*cal_grad_terms_bdry_face(phi2(ivar,qk,j), &
                      phi1(ieqn,qk,i),face_normals(:,qk),ivar,ieqn, &
                      problem_dim,no_pdes)

                  quterm = -0.5_db*cal_grad_terms_bdry_face(phi1(ieqn,qk,i), &
                    phi2(ivar,qk,j),face_normals(:,qk),ieqn,ivar, &
                    problem_dim,no_pdes)

                  face_matrix_mp(ieqn,ivar,i,j) = face_matrix_mp(ieqn,ivar,i,j) &
                    +integral_weighting(qk)*(diff_terms+pvterm-quterm)

                end do
              end do

              ! Loop over phi_i
              do i = 1,no_dofs_per_variable2(ieqn)

                ! u^+ v^- w.r.t. ele1

                ! Loop over phi_j
                do j = 1,no_dofs_per_variable1(ivar)
                  diff_terms = &
                    diffusion_coefficient * &
                    cal_diff_terms_int_face(grad_phi1(ivar,qk,:,j), &
                      grad_phi2(ieqn,qk,:,i),phi1(ivar,qk,j), &
                      -phi2(ieqn,qk,i),face_normals(:,qk),full_dispenal, &
                      ivar,ieqn,problem_dim,no_pdes)

                  pvterm = &
                    pressure_coefficient * &
                    (-0.5_db)*cal_grad_terms_bdry_face(phi1(ivar,qk,j), &
                      phi2(ieqn,qk,i),face_normals(:,qk),ivar,ieqn, &
                      problem_dim,no_pdes)

                  quterm = 0.5_db*cal_grad_terms_bdry_face(phi2(ieqn,qk,i), &
                    phi1(ivar,qk,j),face_normals(:,qk),ieqn,ivar, &
                    problem_dim,no_pdes)

                  face_matrix_pm(ieqn,ivar,i,j) = face_matrix_pm(ieqn,ivar,i,j) &
                    +integral_weighting(qk)*(diff_terms+pvterm-quterm)

                end do

                ! u^- v^- w.r.t. ele1

                ! Loop over phi_j
                do j = 1,no_dofs_per_variable2(ivar)
                  diff_terms = &
                    diffusion_coefficient * &
                    cal_diff_terms_int_face(grad_phi2(ivar,qk,:,j), &
                      grad_phi2(ieqn,qk,:,i),-phi2(ivar,qk,j), &
                      -phi2(ieqn,qk,i),face_normals(:,qk),full_dispenal, &
                      ivar,ieqn,problem_dim,no_pdes)

                  pvterm = &
                    pressure_coefficient * &
                    (-0.5_db)*cal_grad_terms_bdry_face(phi2(ivar,qk,j), &
                      phi2(ieqn,qk,i),face_normals(:,qk),ivar,ieqn, &
                      problem_dim,no_pdes)

                  quterm = -0.5_db*cal_grad_terms_bdry_face(phi2(ieqn,qk,i), &
                    phi2(ivar,qk,j),face_normals(:,qk),ieqn,ivar, &
                    problem_dim,no_pdes)

                  face_matrix_mm(ieqn,ivar,i,j) = face_matrix_mm(ieqn,ivar,i,j) &
                    +integral_weighting(qk)*(diff_terms+pvterm-quterm)

                end do
              end do
            end do
          end do
        end do

      else if (bdry_face > 0) then
        if (large_boundary_v_penalisation) then
          full_dispenal = 1e10_db
        end if

        ! Calculate value of analytical solution at quadrature points
        do qk = 1,no_quad_points
          interpolant_uh1(:,qk) = uh_face1(fe_basis_info,no_pdes,qk)
          do i = 1,no_pdes
            grad_uh1(i,qk,1:problem_dim) = grad_uh_face1(fe_basis_info,problem_dim,i,qk,1)
          end do

          call anal_soln_velocity(uloc(:,qk),global_points_face(:,qk),problem_dim,no_pdes,0,current_time, &
            face_element_region_ids(1))
          ! if (solid_wall_mesh_velocity .and. uloc(1, qk) == 0.0_db .and. uloc(2, qk) == 0.0_db) then
          if (solid_wall_mesh_velocity) then
            uloc(1:2, qk) = uloc(1:2, qk) + mesh_velocity
          end if
          ! The solution is continuous, so we only need to do this on one side of the face.
          mesh_velocity = mesh_uh(1:problem_dim, qk)
          call compute_boundary_condition(interpolant_uh2(:,qk), &
            interpolant_uh1(:,qk),uloc(:,qk),abs(bdry_face),problem_dim,no_pdes)
            alpha(qk) = cal_alpha(interpolant_uh1(:,qk),interpolant_uh2(:,qk), &
            face_normals(:,qk),problem_dim,no_pdes,mesh_velocity)
          call jacobian_convective_fluxes(interpolant_uh1(:,qk), &
            fluxes_prime1(:,:,:,qk),problem_dim,no_pdes,mesh_velocity)
          call jacobian_convective_fluxes(interpolant_uh2(:,qk), &
            fluxes_prime2(:,:,:,qk),problem_dim,no_pdes,mesh_velocity)
          call jacobian_lf_flux_bdry(boundary_jacobian(:,:,qk), &
            abs(bdry_face),fluxes_prime2(:,:,:,qk),alpha(qk),face_normals(:,qk), &
            interpolant_uh1(:,qk),problem_dim,no_pdes)
        end do

        do i = 1,no_pdes
          grad_phi1(i,1:no_quad_points,1:problem_dim,1:no_dofs_per_variable1(i)) = fe_basis_info%basis_face1 &
            %deriv_basis_fns(i)%grad_data(1:no_quad_points,:,1:no_dofs_per_variable1(i),1)
          phi1(i,1:no_quad_points,1:no_dofs_per_variable1(i)) = fe_basis_info%basis_face1%basis_fns(i) &
            %fem_basis_fns(1:no_quad_points,1:no_dofs_per_variable1(i),1)
        end do

        diffusion_coefficient = calculate_velocity_diffusion_coefficient(global_points_face(:, qk), &
          problem_dim, face_element_region_ids(1))
        pressure_coefficient   = calculate_velocity_pressure_coefficient(global_points_face(:, qk), &
          problem_dim, face_element_region_ids(1))
        forcing_coefficient    = calculate_velocity_forcing_coefficient(global_points_face(:, qk), &
          problem_dim, face_element_region_ids(1))

        if (100 <= abs(bdry_face) .and. abs(bdry_face) <= 199) then ! Dirichlet boundary
          ! Loop over quadrature points
          do qk = 1,no_quad_points
            ! Loop over the equations
            do ieqn = 1,no_pdes
              ! Loop over phi_i
              do i = 1,no_dofs_per_variable1(ieqn)
                ! Loop over the variables
                do ivar = 1,no_pdes
                  ! Loop over phi_j
                  do j = 1,no_dofs_per_variable1(ivar)
                    diff_terms = &
                      diffusion_coefficient * &
                      cal_diff_terms_bdry_face(grad_phi1(ivar,qk,:,j), &
                        grad_phi1(ieqn,qk,:,i),phi1(ivar,qk,j), &
                        phi1(ieqn,qk,i),face_normals(:,qk),full_dispenal, &
                        ivar,ieqn,problem_dim,no_pdes)

                    pvterm = &
                      pressure_coefficient * &
                      cal_grad_terms_bdry_face(phi1(ivar,qk,j), &
                        phi1(ieqn,qk,i),face_normals(:,qk),ivar,ieqn, &
                        problem_dim,no_pdes)

                    quterm = cal_grad_terms_bdry_face(phi1(ieqn,qk,i), &
                      phi1(ivar,qk,j),face_normals(:,qk),ieqn,ivar, &
                      problem_dim,no_pdes)

                    face_matrix_pp(ieqn,ivar,i,j) = face_matrix_pp(ieqn,ivar,i,j) &
                      +integral_weighting(qk)*(diff_terms+pvterm-quterm)

                  end do
                end do
              end do
            end do
          end do

        else if (200 <= abs(bdry_face) .and. abs(bdry_face) <= 299) then ! Neumann Boundary

        else
          print *, "Unknown boundary condition"
          print *, bdry_face
          error stop
        end if

      else
        print *, "Unrecognised region ID and bdry_face combination."
        print *, "bdry_face                  = ", bdry_face
        print *, "interior_face_boundary_no  = ", interior_face_boundary_no
        print *, "face_element_region_ids(1) = ", face_element_region_ids(1)
        print *, "face_element_region_ids(2) = ", face_element_region_ids(2)
        error stop
      end if

    end associate

  end subroutine jacobian_face_nsb_mm

  !--------------------------------------------------------------------
  ! PURPOSE:
  !> Defines the nonlinear residual for the
  !!  Navier-Stokes+ku equations in CG.
  !!
  !! Author:
  !!   Paul Houston, Adam Blakey
  !!
  !! Date Created:
  !!   22-06-2023
  !--------------------------------------------------------------------
  subroutine element_residual_cg_boundary_nsb_mm(face_residual, mesh_data, soln_data, facet_data, fe_basis_info)
    use param

    include 'assemble_residual_bdry_face.h'

    integer :: qk,i,j,ieqn
    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points) :: un
    real(db), dimension(facet_data%no_pdes) :: uh1
    real(db), dimension(facet_data%no_pdes,facet_data%no_quad_points, maxval(facet_data%no_dofs_per_variable1)) :: phi1

    associate( &
      dim_soln_coeff => facet_data%dim_soln_coeff, &
      no_pdes => facet_data%no_pdes, &
      problem_dim => facet_data%problem_dim, &
      no_quad_points => facet_data%no_quad_points, &
      global_points => facet_data%global_points, &
      integral_weighting => facet_data%integral_weighting, &
      face_number => facet_data%face_number, &
      interior_face_boundary_no => facet_data%interior_face_boundary_no, &
      face_element_region_ids => facet_data%face_element_region_ids, &
      boundary_no => facet_data%bdry_no, &
      no_dofs_per_variable => facet_data%no_dofs_per_variable1, &
      face_normals => facet_data%face_normals)

      face_residual = 0.0_db

      if (200 <= abs(boundary_no) .and. abs(boundary_no) <= 299) then
        do qk = 1, no_quad_points
          uh1 = uh_face1(fe_basis_info, no_pdes, qk)
          call neumann_bc_velocity(un, global_points(1:problem_dim, qk), problem_dim, boundary_no, 0.0_db, &
            face_element_region_ids(1), face_normals(1:problem_dim, qk))
        end do

        do i = 1, no_pdes
          phi1(i, 1:no_quad_points, 1:no_dofs_per_variable(i)) = fe_basis_info%basis_face1%basis_fns(i) &
            %fem_basis_fns(1:no_quad_points, 1:no_dofs_per_variable(i), 1)
        end do

        do ieqn = 1, no_pdes
          do qk = 1, no_quad_points
            do i = 1, no_dofs_per_variable(ieqn)
              face_residual(ieqn, i) = face_residual(ieqn,i) &
                -integral_weighting(qk)*un(ieqn, qk)*phi1(ieqn, qk, i)
            end do
          end do
        end do
      end if
    end associate
  end subroutine element_residual_cg_boundary_nsb_mm

  function cal_gradgradterm(grad_phi_u,grad_phi_v,ivar,ieqn,problem_dim,no_pdes)

    use param
    implicit none

    integer, intent(in) :: problem_dim,no_pdes
    real(db) :: cal_gradgradterm
    real(db), dimension(problem_dim), intent(in) :: grad_phi_u,grad_phi_v
    integer, intent(in) :: ivar,ieqn

    cal_gradgradterm = 0.0_db

    if (ieqn == ivar .and. ivar < problem_dim+1) then
      cal_gradgradterm = dot_product(grad_phi_u,grad_phi_v)
    end if

  end function cal_gradgradterm

  function cal_uvterm(phi_u,phi_v,ivar,ieqn,problem_dim,no_pdes)

    use param
    implicit none

    integer, intent(in) :: problem_dim,no_pdes
    real(db) :: cal_uvterm
    real(db), intent(in) :: phi_u,phi_v
    integer, intent(in) :: ivar,ieqn

    cal_uvterm = 0.0_db

    if (ieqn == ivar .and. ivar < problem_dim+1) then
      cal_uvterm = phi_u*phi_v
    end if

  end function cal_uvterm

  ! --------------------------------------------------------------
  ! This routine calculates the components of the v . grad p term
  ! --------------------------------------------------------------
  function cal_gradterm(phi_v,grad_phi_p,ip,iv,problem_dim,no_pdes)

    use param
    implicit none

    integer, intent(in) :: problem_dim,no_pdes
    real(db) :: cal_gradterm
    real(db), dimension(problem_dim), intent(in) :: grad_phi_p
    real(db), intent(in) :: phi_v
    integer, intent(in) :: ip, iv

    cal_gradterm = 0.0_db

    if (ip == problem_dim+1) then
      if (iv < problem_dim+1) then
        cal_gradterm = phi_v*grad_phi_p(iv)
      endif
    end if

  end function cal_gradterm

  function cal_diff_terms_bdry_face(grad_phi_u,grad_phi_v,phi_u,phi_v, &
    normal,penalisation,ivar,ieqn,problem_dim,no_pdes)

    use param
    implicit none

    integer, intent(in) :: problem_dim,no_pdes
    real(db) :: cal_diff_terms_bdry_face
    real(db), dimension(problem_dim), intent(in) :: grad_phi_u,grad_phi_v,normal
    real(db), intent(in) :: phi_u,phi_v
    real(db), intent(in) :: penalisation
    integer, intent(in) :: ivar,ieqn

    cal_diff_terms_bdry_face = 0.0_db

    if (ieqn == ivar .and. ivar < problem_dim+1) then
      cal_diff_terms_bdry_face = -dot_product(grad_phi_v,normal)*phi_u &
      -dot_product(grad_phi_u,normal)*phi_v+penalisation*phi_u*phi_v
    end if

  end function cal_diff_terms_bdry_face

  function cal_diff_terms_int_face(grad_phi_u,grad_phi_v,phi_u,phi_v, &
    normal,penalisation,ivar,ieqn,problem_dim,no_pdes)

    use param
    implicit none

    integer, intent(in) :: problem_dim,no_pdes
    real(db) :: cal_diff_terms_int_face
    real(db), dimension(problem_dim), intent(in) :: grad_phi_u,grad_phi_v,normal
    real(db), intent(in) :: phi_u,phi_v
    real(db), intent(in) :: penalisation
    integer, intent(in) :: ivar,ieqn

    cal_diff_terms_int_face = 0.0_db

    if (ieqn == ivar .and. ivar < problem_dim+1) then
      cal_diff_terms_int_face = -0.5_db*(dot_product(grad_phi_v,normal)*phi_u &
      +dot_product(grad_phi_u,normal)*phi_v)+penalisation*phi_u*phi_v
    end if

  end function cal_diff_terms_int_face

  function cal_grad_terms_bdry_face(phi_p,phi_v,normal,ip,iv,problem_dim,no_pdes)

    use param
    implicit none

    integer, intent(in) :: problem_dim,no_pdes
    real(db) :: cal_grad_terms_bdry_face
    real(db), dimension(problem_dim), intent(in) :: normal
    real(db), intent(in) :: phi_p,phi_v
    integer, intent(in) :: ip,iv

    cal_grad_terms_bdry_face = 0.0_db

    if (ip == problem_dim+1) then
      if (iv < problem_dim+1) then
        cal_grad_terms_bdry_face = phi_v*phi_p*normal(iv)
      endif
    end if

  end function cal_grad_terms_bdry_face

  ! -------------------------------------------------------------
  !> This routine defines the convective fluxes
  !!
  !! Author:
  !!  Paul Houston
  ! -------------------------------------------------------------
  subroutine convective_fluxes(soln,fluxes,problem_dim,no_pdes,mesh_velocity)
    ! -------------------------------------------------------------

    use param
    implicit none

    integer, intent(in) :: problem_dim !< problem dimension
    integer, intent(in) :: no_pdes !< Number of variables in PDE system
    real(db), dimension(no_pdes), intent(in) :: soln
    real(db), dimension(problem_dim), intent(in) :: mesh_velocity
    real(db), intent(out), dimension(problem_dim,problem_dim) :: fluxes

    ! Local variables

    real(db), dimension(problem_dim) :: velocity
    integer :: i,j

    velocity = soln(1:problem_dim)

    do i = 1,problem_dim
      do j = 1,problem_dim
        ! fluxes(i,j) = velocity(i)*velocity(j)
        fluxes(i,j) = (velocity(i) - mesh_velocity(i))*velocity(j)
      end do
    end do

  end subroutine convective_fluxes

  !  -------------------------------------------------------------
  subroutine jacobian_convective_fluxes(soln,fluxes_prime,problem_dim,no_pdes,mesh_velocity)
    !  -------------------------------------------------------------
    !<   This routine defines the Jacobian matrix of the convective fluxes
    !<
    !<   Storage arrangement:
    !<
    !<   Fluxes\_prime(problem\_dim,ieqn,ivar)
    !<
    !<   ieqn - equation number
    !< \begin{verbatim}
    !< .   Derivative: \partial F_{ieqn}
    !< .               -----------------
    !< .               \partial u_{ivar}
    !< \end{verbatim}
    !< Authors:
    !<  Edward Hall and Paul Houston
    !  -------------------------------------------------------------
    use param

    implicit none

    integer, intent(in) :: problem_dim !< problem dimension
    integer, intent(in) :: no_pdes !< Number of variables in PDE system
    real(db), dimension(no_pdes), intent(in) :: soln
    real(db), dimension(problem_dim), intent(in) :: mesh_velocity
    real(db), dimension(problem_dim,problem_dim,problem_dim) :: &
    fluxes_prime
    real(db), dimension(problem_dim) :: velocity

    velocity = soln(1:problem_dim)

    if (problem_dim == 2) then

      fluxes_prime(1,1,1) = 2.0_db*velocity(1) - mesh_velocity(1)
      fluxes_prime(1,1,2) = 0.0_db
      fluxes_prime(1,2,1) = velocity(2) - mesh_velocity(2)
      fluxes_prime(1,2,2) = velocity(1)

      fluxes_prime(2,1,1) = velocity(2)
      fluxes_prime(2,1,2) = velocity(1) - mesh_velocity(1)
      fluxes_prime(2,2,1) = 0.0_db
      fluxes_prime(2,2,2) = 2.0_db*velocity(2) - mesh_velocity(2)

    else if (problem_dim == 3) then

      fluxes_prime(1,1,1) = 2.0_db*velocity(1) - mesh_velocity(1)
      fluxes_prime(1,1,2) = 0.0_db
      fluxes_prime(1,1,3) = 0.0_db
      fluxes_prime(1,2,1) = velocity(2) - mesh_velocity(2)
      fluxes_prime(1,2,2) = velocity(1)
      fluxes_prime(1,2,3) = 0.0_db
      fluxes_prime(1,3,1) = velocity(3) - mesh_velocity(3)
      fluxes_prime(1,3,2) = 0.0_db
      fluxes_prime(1,3,3) = velocity(1)

      fluxes_prime(2,1,1) = velocity(2) - mesh_velocity(2)
      fluxes_prime(2,1,2) = velocity(1) - mesh_velocity(1)
      fluxes_prime(2,1,3) = 0.0_db
      fluxes_prime(2,2,1) = 0.0_db
      fluxes_prime(2,2,2) = 2.0_db*velocity(2) - mesh_velocity(2)
      fluxes_prime(2,2,3) = 0.0_db
      fluxes_prime(2,3,1) = 0.0_db
      fluxes_prime(2,3,2) = velocity(3) - mesh_velocity(3)
      fluxes_prime(2,3,3) = velocity(2)

      fluxes_prime(3,1,1) = velocity(3)
      fluxes_prime(3,1,2) = 0.0_db
      fluxes_prime(3,1,3) = velocity(1) - mesh_velocity(1)
      fluxes_prime(3,2,1) = 0.0_db
      fluxes_prime(3,2,2) = velocity(3)
      fluxes_prime(3,2,3) = velocity(2) - mesh_velocity(2)
      fluxes_prime(3,3,1) = 0.0_db
      fluxes_prime(3,3,2) = 0.0_db
      fluxes_prime(3,3,3) = 2.0_db*velocity(3) - mesh_velocity(3)

    end if

  end subroutine jacobian_convective_fluxes
  !  -------------------------------------------------------------
  subroutine compute_boundary_condition(boundary_condition,computed_soln, &
    analytical_soln,bdryno,problem_dim,no_pdes)
    !  -------------------------------------------------------------
    !<  This routine computes the boundary condition ($U_-$) based on
    !<  available data as well as the numerical solution computed
    !<  from inside the computational domain
    !  -------------------------------------------------------------
    !< \begin{verbatim}
    !<   The boundaries are numbered as follows:
    !<
    !<  100-199 : dirichlet boundary conditions
    !<
    !<  200-299 : Neumann conditions
    !<
    !<  300-399 : First variable Neumann, second variable Dirichlet
    !<
    !< \end{verbatim}
    !<
    !< Author:
    !<  Paul Houston
    !  -------------------------------------------------------------
    use param

    implicit none

    integer, intent(in) :: problem_dim !< problem dimension
    integer, intent(in) :: no_pdes !< Number of variables in PDE system
    real(db), dimension(no_pdes), intent(out) :: boundary_condition
    real(db), dimension(no_pdes), intent(in) :: computed_soln, &
    analytical_soln
    integer, intent(in) :: bdryno

    if (100 <= bdryno .and. bdryno <= 199) then

      boundary_condition = analytical_soln

    else if (200 <= bdryno .and. bdryno <= 299) then

      boundary_condition = computed_soln

    else

      print *,'compute_boundary_condition: Boundary number incorrect', bdryno
      error stop

    endif

  end subroutine compute_boundary_condition
  !  -------------------------------------------------------------
  subroutine compute_jac_boundary_condition(boundary_jacobian, &
    computed_soln,bdryno,normal,problem_dim,no_pdes)
    !  -------------------------------------------------------------
    !<  This routine computes the Jacobian matrix of the specified
    !<  boundary condition.
    !<
    !< Author:
    !<  Edward Hall
    !  -------------------------------------------------------------
    use param

    implicit none

    integer, intent(in) :: problem_dim !< problem dimension
    integer, intent(in) :: no_pdes !< Number of variables in PDE system
    real(db), dimension(problem_dim,problem_dim), intent(out) :: &
    boundary_jacobian
    real(db), dimension(no_pdes), intent(in) :: computed_soln
    real(db), dimension(problem_dim), intent(in) :: normal
    integer, intent(in) :: bdryno
    integer :: iv

    if (100 <= bdryno .and. bdryno <= 199) then

      boundary_jacobian = 0.0_db

    else if (200 <= bdryno .and. bdryno <= 299) then

      boundary_jacobian = 0.0_db
      do iv = 1,problem_dim
        boundary_jacobian(iv,iv) = 1.0_db
      end do

    else

      print *,'compute_jac_boundary_condition:'
      print *,'Boundary number incorrect',bdryno
      error stop

    endif

  end subroutine compute_jac_boundary_condition

  ! --------------------------------------------------------------
  subroutine lax_friedrichs(nflxsoln,u1,u2,normal,problem_dim,no_pdes,mesh_velocity)
    ! --------------------------------------------------------------
    !< This routine calculates the Lax Friedrichs flux
    !<
    !< Author:
    !<  Paul Houston
    ! --------------------------------------------------------------
    use param

    implicit none

    integer, intent(in) :: problem_dim !< problem dimension
    integer, intent(in) :: no_pdes !< Number of variables in PDE system
    real(db), dimension(problem_dim), intent(out) :: nflxsoln
    real(db), dimension(no_pdes), intent(in) :: u1,u2
    real(db), dimension(problem_dim), intent(in) :: normal,mesh_velocity
    real(db), dimension(problem_dim,problem_dim) :: fluxes1,fluxes2
    real(db) :: alpha
    integer :: i

    call convective_fluxes(u1,fluxes1,problem_dim,no_pdes,mesh_velocity)
    call convective_fluxes(u2,fluxes2,problem_dim,no_pdes,mesh_velocity)

    alpha = cal_alpha(u1,u2,normal,problem_dim,no_pdes,mesh_velocity)

    nflxsoln = 0.0_db

    do i = 1,problem_dim
      nflxsoln = nflxsoln+(fluxes1(i,:)+fluxes2(i,:))*normal(i)
    end do

    nflxsoln = 0.5_db*(nflxsoln-alpha*(u2(1:problem_dim)-u1(1:problem_dim)))

  end subroutine lax_friedrichs

  function cal_alpha(u1,u2,normal,problem_dim,no_pdes,mesh_velocity)

    use param

    implicit none

    real(db) :: cal_alpha
    integer, intent(in) :: problem_dim,no_pdes
    real(db), dimension(problem_dim), intent(in) :: normal,mesh_velocity
    real(db), dimension(no_pdes), intent(in) :: u1,u2

    cal_alpha = max( &
      abs(2.0_db*dot_product(u1(1:problem_dim), normal) - dot_product(mesh_velocity, normal)), &
      abs(2.0_db*dot_product(u2(1:problem_dim), normal) - dot_product(mesh_velocity, normal)), &
      abs(       dot_product(u1(1:problem_dim), normal) - dot_product(mesh_velocity, normal)), &
      abs(       dot_product(u2(1:problem_dim), normal) - dot_product(mesh_velocity, normal))  &
    )

  end function cal_alpha
  !  -------------------------------------------------------------
  subroutine jacobian_lf_flux_bdry(bc_jac,bdryno,fluxes_prime,alpha,normal, &
    soln,problem_dim,no_pdes)
    !  -------------------------------------------------------------
    !<  This subroutine calculates the Jacobian of the boundary
    !<  conditions at the given quadrature point for the Lax
    !<  Friedrichs flux
    !<
    !< Author:
    !<  Paul Houston
    !  -------------------------------------------------------------
    use param

    implicit none

    integer, intent(in) :: problem_dim !< problem dimension
    integer, intent(in) :: no_pdes
    real(db), dimension(problem_dim,problem_dim), intent(out) :: bc_jac
    real(db), dimension(problem_dim,problem_dim,problem_dim), intent(in) :: fluxes_prime
    real(db), dimension(problem_dim), intent(in) :: normal
    real(db), dimension(no_pdes), intent(in) :: soln
    real(db), intent(in) :: alpha
    integer, intent(in) :: bdryno
    real(db), dimension(problem_dim,problem_dim) :: var_jac

    real(db), dimension(problem_dim,problem_dim) :: temp_mat
    integer :: i

    call compute_jac_boundary_condition(var_jac, &
    soln,bdryno,normal,problem_dim,no_pdes)

    bc_jac = 0.0_db

    temp_mat = 0.0_db
    do i = 1,problem_dim
      temp_mat = temp_mat+fluxes_prime(i,:,:)*normal(i)
    end do

    bc_jac = 0.5_db*(matmul(temp_mat,var_jac)-alpha*var_jac)

  end subroutine jacobian_lf_flux_bdry

end module
