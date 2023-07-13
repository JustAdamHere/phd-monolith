module crossflow_flux
    use aptofem_kernel

    contains    
    !--------------------------------------------------------------------
    !>  This routine calculates the flux between boundaries.
    !!
    !! AUTHOR:
    !!   A.Blakey
    !!
    !! Date created
    !!   24-06-2022
    !--------------------------------------------------------------------
    function calculate_crossflow_flux(mesh_data, flow_solution, region_1, region_2)
    !--------------------------------------------------------------------
        ! Loop over all faces.
            ! Loop over neighbours.
                ! Check neighbours lie in the two regions.

        !bdry_face_no = get_boundary_identifier(k,mesh_data)

        !get_interior_face_boundary_no(face_no,mesh_data)
        !  0 by default
        !  normal is outward normal to the first face
        !compute_interior_face_boundary_no(element_region_id_1,element_region_id_2)
        ! Look at DG error routine for inspiration

        ! Crossflow as array??




        use param
        use fe_mesh
        use fe_solution
        use basis_fns_storage_type

        implicit none

        real(db) :: calculate_crossflow_flux
        type(mesh), intent(inout) :: mesh_data !< FE mesh
        type(solution), intent(in) :: flow_solution !< Flow solution
        integer, intent(in) :: region_1, region_2

        ! Local variables
        integer :: no_eles, no_nodes, no_faces, problem_dim, dim_soln_coeff, k, npinc, no_quad_points_volume_max, &
            no_quad_points_face_max, no_quad_points, bdry_face, qk
        integer, dimension(2) :: neighbors, loc_face_no
        real(db), dimension(:), allocatable :: face_jacobian, quad_weights_face, uh1, uh2
        real(db), dimension(:, :), allocatable :: global_points_face, face_normals, normals
        integer, dimension(:), allocatable :: no_dofs_per_variable1, no_dofs_per_variable2
        integer, dimension(:, :), allocatable :: global_dof_numbers1, global_dof_numbers2
        character(len=aptofem_length_key_def) :: control_parameter
        type(basis_storage) :: fe_basis_info

        real(db) :: integrand1, integrand2
        integer :: intr_face_no, region_face_no

        call get_mesh_info(no_eles, no_nodes, no_faces, problem_dim, mesh_data)

        dim_soln_coeff = get_dim_soln_coeff(flow_solution)
        npinc          = 2
        call compute_max_no_quad_points(no_quad_points_volume_max, no_quad_points_face_max, mesh_data, flow_solution, npinc)

        allocate(global_points_face(problem_dim, no_quad_points_face_max))
        allocate(face_jacobian(no_quad_points_face_max))
        allocate(face_normals(problem_dim, no_quad_points_face_max))
        allocate(quad_weights_face(no_quad_points_face_max))
        allocate(global_dof_numbers1(dim_soln_coeff, no_ele_dofs_per_var_max)) 
        allocate(global_dof_numbers2(dim_soln_coeff, no_ele_dofs_per_var_max))
        allocate(no_dofs_per_variable1(dim_soln_coeff))
        allocate(no_dofs_per_variable2(dim_soln_coeff))
        allocate(normals(problem_dim, no_quad_points_face_max))
        allocate(uh1(dim_soln_coeff))
        allocate(uh2(dim_soln_coeff))

        control_parameter = 'uh_face'
        call initialize_fe_basis_storage(fe_basis_info, control_parameter, flow_solution, &
            problem_dim, no_quad_points_volume_max, no_quad_points_face_max)

        region_face_no = compute_interior_face_boundary_no(region_1, region_2)

        calculate_crossflow_flux = 0.0_db

        do k = 1, no_faces
            intr_face_no = get_interior_face_boundary_no(k, mesh_data)

            if (intr_face_no == region_face_no) then
                call face_integration_info(dim_soln_coeff, problem_dim, mesh_data, flow_solution, k, neighbors, loc_face_no, npinc,&
                    no_quad_points_face_max, no_quad_points, global_points_face, face_jacobian, face_normals, quad_weights_face, &
                    global_dof_numbers1, no_dofs_per_variable1, bdry_face, global_dof_numbers2, no_dofs_per_variable2, &
                    fe_basis_info)

                if (face_normals(1, 1) >= 0) then
                    normals(:, :) = face_normals(:, :)
                else
                    normals(:, :) = -face_normals(:, :)
                end if

                integrand1 = 0.0_db
                integrand2 = 0.0_db

                do qk = 1, no_quad_points
                    uh1 = uh_face1(fe_basis_info, dim_soln_coeff, qk)
                    uh2 = uh_face2(fe_basis_info, dim_soln_coeff, qk)

                    integrand1 = integrand1 + &
                        dot_product(uh1(1:problem_dim), normals(1:problem_dim, qk))*quad_weights_face(qk)*face_jacobian(qk)

                    integrand2 = integrand2 + &
                        dot_product(uh2(1:problem_dim), normals(1:problem_dim, qk))*quad_weights_face(qk)*face_jacobian(qk)
                end do

                calculate_crossflow_flux = calculate_crossflow_flux + (integrand1 + integrand2)/2

                !print *, k
            end if
        end do
        ! print *, region_1
        ! print *, region_2
        ! print *, ""

        deallocate(global_points_face, face_jacobian, face_normals, quad_weights_face, global_dof_numbers1, global_dof_numbers2, &
            no_dofs_per_variable1, no_dofs_per_variable2, normals, uh1, uh2)
    end function calculate_crossflow_flux
end module