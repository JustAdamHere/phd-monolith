module outflow_flux
    use aptofem_kernel

    real(db), dimension(:), allocatable :: outflow_fluxes, pe_outflow_fluxes, ke_outflow_fluxes, one_integral

    contains
    !--------------------------------------------------------------------
    !>  This routine the flux on a portion of the boundary (for Adam)
    !!
    !! AUTHOR:
    !!   P.Houston
    !! MODIFIED BY:
    !!   A.Blakey
    !!
    !! Date created
    !!   11-03-2022
    !! Date modified
    !!   16-03-2022
    !--------------------------------------------------------------------
    ! function calculate_outflow_flux(mesh_data,flow_solution,boundary_no)
    ! !--------------------------------------------------------------------
    !     use param
    !     use fe_mesh
    !     use fe_solution

    !     implicit none

    !     real(db) :: calculate_outflow_flux
    !     type(mesh), intent(inout) :: mesh_data !< FE mesh
    !     type(solution), intent(in) :: flow_solution !< Flow solution
    !     integer, intent(in) :: boundary_no

    !     ! Local variables
    !     integer :: no_eles,no_nodes,no_faces,problem_dim,npinc,no_quad_points_volume_max, &
    !         no_quad_points_face_max,k,bdry_face_no,no_quad_points,no_face_nodes, &
    !         interior_face_boundary_no,no_pdes_flow,qk,dim_soln_coeff_flow
    !     integer, dimension(2) :: neighbours,loc_face_no
    !     integer, dimension(no_nodes_per_face_max) :: face_nodes
    !     integer, dimension(:,:), allocatable :: pvec
    !     real :: integral
    !     real(db), dimension(:,:,:), allocatable :: inv_jacobi_mat,jacobi_mat
    !     real(db), dimension(:,:), allocatable :: local_points,global_points,face_normals
    !     real(db), dimension(:), allocatable :: quad_weights,face_jacobian,det_jacobi_mat, &
    !         uh_flow

    !     call get_mesh_info(no_eles,no_nodes,no_faces,problem_dim, &
    !         mesh_data)

    !     dim_soln_coeff_flow = get_dim_soln_coeff(flow_solution)
    !     no_pdes_flow = get_no_pdes(flow_solution)

    !     allocate(uh_flow(no_pdes_flow))
    !     allocate(pvec(dim_soln_coeff_flow,problem_dim))

    !     npinc = 2

    !     call compute_max_no_quad_points(no_quad_points_volume_max, &
    !         no_quad_points_face_max,mesh_data,flow_solution,npinc)

    !     allocate(local_points(problem_dim,no_quad_points_face_max))
    !     allocate(global_points(problem_dim,no_quad_points_face_max))
    !     allocate(face_normals(problem_dim,no_quad_points_face_max))
    !     allocate(quad_weights(no_quad_points_face_max))
    !     allocate(face_jacobian(no_quad_points_face_max))
    !     allocate(det_jacobi_mat(no_quad_points_face_max))
    !     allocate(jacobi_mat(problem_dim,problem_dim,no_quad_points_face_max))
    !     allocate(inv_jacobi_mat(problem_dim,problem_dim,no_quad_points_face_max))

    !     calculate_outflow_flux = 0.0_db

    !     do k = 1,no_faces
    !         bdry_face_no = get_boundary_identifier(k,mesh_data)

    !         if (bdry_face_no == boundary_no) then
    !             integral = 0.0_db

    !             call get_face_info(k,neighbours,loc_face_no,face_nodes, &
    !                 no_face_nodes,interior_face_boundary_no,mesh_data)

    !             call get_element_polynomial_degrees(flow_solution, &
    !                 pvec,problem_dim,neighbours(1),dim_soln_coeff_flow)

    !             no_quad_points = compute_no_quad_points_mesh_face(mesh_data, &
    !                 neighbours(1),loc_face_no(1),dim_soln_coeff_flow,problem_dim, &
    !                 pvec,pvec,npinc)

    !             call get_face_transform_quad_pts(mesh_data,neighbours(1),loc_face_no(1), &
    !                 problem_dim,local_points(:,1:no_quad_points), &
    !                 global_points(:,1:no_quad_points),quad_weights(1:no_quad_points), &
    !                 no_quad_points,face_jacobian(1:no_quad_points), &
    !                 face_normals(:,1:no_quad_points),jacobi_mat(:,:,1:no_quad_points), &
    !                 det_jacobi_mat(1:no_quad_points),inv_jacobi_mat(:,:,1:no_quad_points))

    !             do qk = 1,no_quad_points
    !                 call compute_uh_loc_glob_pt(uh_flow,no_pdes_flow,neighbours(1), &
    !                     local_points(:,qk),global_points(:,qk),problem_dim,mesh_data,flow_solution)

    !                 integral = integral + &
    !                     dot_product(uh_flow(1:problem_dim), face_normals(:,qk))*quad_weights(qk)*face_jacobian(qk)
    !             end do

    !             calculate_outflow_flux = calculate_outflow_flux+integral

    !         end if
    !     end do

    !     deallocate(pvec,local_points,global_points,quad_weights,face_jacobian, &
    !         det_jacobi_mat,jacobi_mat,inv_jacobi_mat,uh_flow)

    ! end function calculate_outflow_flux

    subroutine setup_outflow_fluxes(largest_bdry_face_no)
        use param

        implicit none

        integer, intent(in)       :: largest_bdry_face_no

        allocate(outflow_fluxes   (largest_bdry_face_no))
        allocate(pe_outflow_fluxes(largest_bdry_face_no))
        allocate(ke_outflow_fluxes(largest_bdry_face_no))
        allocate(one_integral     (largest_bdry_face_no))
        outflow_fluxes    = 0.0_db
        pe_outflow_fluxes = 0.0_db
        ke_outflow_fluxes = 0.0_db
        one_integral      = 0.0_db

    end subroutine

    subroutine finalise_outflow_fluxes()
        implicit none

        deallocate(outflow_fluxes, pe_outflow_fluxes, ke_outflow_fluxes)
    end subroutine

    function sum_nonzero_fluxes()
        use param

        implicit none

        real(db) :: sum_nonzero_fluxes

        integer :: i

        sum_nonzero_fluxes = 0.0_db
        do i = 1, size(outflow_fluxes)
            sum_nonzero_fluxes = sum_nonzero_fluxes + outflow_fluxes(i)
        end do

    end function

    function sum_nonzero_pe_fluxes()
        use param

        implicit none

        real(db) :: sum_nonzero_pe_fluxes

        integer :: i

        sum_nonzero_pe_fluxes = 0.0_db
        do i = 1, size(outflow_fluxes)
            sum_nonzero_pe_fluxes = sum_nonzero_pe_fluxes + pe_outflow_fluxes(i)
        end do
    end function

    function sum_nonzero_ke_fluxes()
        use param

        implicit none

        real(db) :: sum_nonzero_ke_fluxes

        integer :: i

        sum_nonzero_ke_fluxes = 0.0_db
        do i = 1, size(outflow_fluxes)
            sum_nonzero_ke_fluxes = sum_nonzero_ke_fluxes + ke_outflow_fluxes(i)
        end do
    end function

    function sum_nonzero_one()
        use param

        implicit none

        real(db) :: sum_nonzero_one

        integer :: i

        sum_nonzero_one = 0.0_db
        do i = 1, size(outflow_fluxes)
            sum_nonzero_one = sum_nonzero_one + one_integral(i)
        end do
    end function

    subroutine calculate_outflow_fluxes(mesh_data, flow_solution)
        use param
        use fe_mesh
        use fe_solution

        implicit none

        type(mesh), intent(inout) :: mesh_data
        type(solution), intent(in) :: flow_solution

        ! Local variables
        integer :: no_eles,no_nodes,no_faces,problem_dim,npinc,no_quad_points_volume_max, &
            no_quad_points_face_max,k,bdry_face_no,no_quad_points,no_face_nodes, &
            interior_face_boundary_no,no_pdes_flow,qk,dim_soln_coeff_flow
        integer, dimension(2) :: neighbours,loc_face_no
        integer, dimension(no_nodes_per_face_max) :: face_nodes
        integer, dimension(:,:), allocatable :: pvec
        real(db) :: integral, pe_integral, ke_integral, one_integral_temp
        real(db), dimension(:,:,:), allocatable :: inv_jacobi_mat,jacobi_mat
        real(db), dimension(:,:), allocatable :: local_points,global_points,face_normals
        real(db), dimension(:), allocatable :: quad_weights,face_jacobian,det_jacobi_mat, &
            uh_flow

        call get_mesh_info(no_eles,no_nodes,no_faces,problem_dim, &
            mesh_data)

        dim_soln_coeff_flow = get_dim_soln_coeff(flow_solution)
        no_pdes_flow = get_no_pdes(flow_solution)

        allocate(uh_flow(no_pdes_flow))
        allocate(pvec(dim_soln_coeff_flow,problem_dim))

        npinc = 2

        call compute_max_no_quad_points(no_quad_points_volume_max, &
            no_quad_points_face_max,mesh_data,flow_solution,npinc)

        allocate(local_points(problem_dim,no_quad_points_face_max))
        allocate(global_points(problem_dim,no_quad_points_face_max))
        allocate(face_normals(problem_dim,no_quad_points_face_max))
        allocate(quad_weights(no_quad_points_face_max))
        allocate(face_jacobian(no_quad_points_face_max))
        allocate(det_jacobi_mat(no_quad_points_face_max))
        allocate(jacobi_mat(problem_dim,problem_dim,no_quad_points_face_max))
        allocate(inv_jacobi_mat(problem_dim,problem_dim,no_quad_points_face_max))

        do k = 1,no_faces
            bdry_face_no = get_boundary_identifier(k,mesh_data)

            if (bdry_face_no /= 0) then
                integral          = 0.0_db
                pe_integral       = 0.0_db
                ke_integral       = 0.0_db
                one_integral_temp = 0.0_db

                call get_face_info(k,neighbours,loc_face_no,face_nodes, &
                    no_face_nodes,interior_face_boundary_no,mesh_data)

                call get_element_polynomial_degrees(flow_solution, &
                    pvec,problem_dim,neighbours(1),dim_soln_coeff_flow)

                no_quad_points = compute_no_quad_points_mesh_face(mesh_data, &
                    neighbours(1),loc_face_no(1),dim_soln_coeff_flow,problem_dim, &
                    pvec,pvec,npinc)

                call get_face_transform_quad_pts(mesh_data,neighbours(1),loc_face_no(1), &
                    problem_dim,local_points(:,1:no_quad_points), &
                    global_points(:,1:no_quad_points),quad_weights(1:no_quad_points), &
                    no_quad_points,face_jacobian(1:no_quad_points), &
                    face_normals(:,1:no_quad_points),jacobi_mat(:,:,1:no_quad_points), &
                    det_jacobi_mat(1:no_quad_points),inv_jacobi_mat(:,:,1:no_quad_points))

                do qk = 1,no_quad_points
                    call compute_uh_loc_glob_pt(uh_flow,no_pdes_flow,neighbours(1), &
                        local_points(:,qk),global_points(:,qk),problem_dim,mesh_data,flow_solution)

                    integral = integral + &
                        quad_weights(qk)*face_jacobian(qk)*dot_product(uh_flow(1:problem_dim), face_normals(:,qk))

                    pe_integral = pe_integral + &
                        quad_weights(qk)*face_jacobian(qk)*dot_product(uh_flow(1:problem_dim), face_normals(:,qk))* &
                            uh_flow(problem_dim+1)

                    ke_integral = ke_integral + &
                        quad_weights(qk)*face_jacobian(qk)*dot_product(uh_flow(1:problem_dim), face_normals(:,qk))* &
                            0.5_db*abs(dot_product(uh_flow(1:problem_dim), uh_flow(1:problem_dim)))
                    
                    one_integral_temp = one_integral_temp + &
                        quad_weights(qk)*face_jacobian(qk)*1.0_db
                end do

                bdry_face_no = get_boundary_identifier(k,mesh_data)

                outflow_fluxes   (bdry_face_no) = outflow_fluxes   (bdry_face_no) + integral
                pe_outflow_fluxes(bdry_face_no) = pe_outflow_fluxes(bdry_face_no) + pe_integral
                ke_outflow_fluxes(bdry_face_no) = ke_outflow_fluxes(bdry_face_no) + ke_integral
                one_integral     (bdry_face_no) = one_integral     (bdry_face_no) + one_integral_temp
            end if
        end do

        deallocate(pvec,local_points,global_points,quad_weights,face_jacobian, &
            det_jacobi_mat,jacobi_mat,inv_jacobi_mat,uh_flow)

    end subroutine
end module