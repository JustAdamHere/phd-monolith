module matrix_rhs_transport_ss
  use bcs_transport
  use problem_options
  use problem_options_transport
  use solution_storage_velocity

  contains

  subroutine stiffness_matrix_load_vector_transport_ss(element_matrix, element_rhs, mesh_data, soln_data, facet_data, &
        fe_basis_info)
      include "assemble_matrix_rhs_element.h"

      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      !! CONTAINED IN HEADER FILE !!
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      ! use param
      ! use fe_mesh
      ! use fe_solution
      ! use basis_fns_storage_type
      ! use matrix_assembly_data_type

      ! implicit none

      ! type(basis_storage), intent(in) :: fe_basis_info !< FE basis functions
      ! type(matrix_assembly_data_facet), intent(in) :: facet_data !< Facet data
      ! real(db), dimension(facet_data%dim_soln_coeff,facet_data%dim_soln_coeff, &
      ! facet_data%no_dofs_per_var_max,facet_data%no_dofs_per_var_max), &
      ! intent(out) :: element_matrix !< Element stiffness matrices
      ! !< computed for each variable in the system
      ! real(db), dimension(facet_data%dim_soln_coeff,facet_data%no_dofs_per_var_max), &
      ! intent(out) :: element_rhs
      ! !< Element rhs vector for each PDE equation in the system
      ! type(mesh), intent(in) :: mesh_data !< FE mesh
      ! type(solution), intent(in) :: soln_data !< FE solution

      !!!!!!!!!!!!!!!
      !! VARIABLES !!
      !!!!!!!!!!!!!!!
      integer  :: i, j
      integer  :: q
      real(db) :: diffusion_terms, convection_terms, reaction_terms, forcing_terms

      real(db), dimension(facet_data%no_pdes)      :: f
      real(db), dimension(facet_data%dim_soln_coeff, facet_data%no_quad_points, &
          maxval(facet_data%no_dofs_per_variable)) :: phi
      real(db), dimension(facet_data%dim_soln_coeff, facet_data%no_quad_points, facet_data%problem_dim, &
          maxval(facet_data%no_dofs_per_variable)) :: phi_1

      real(db) :: current_time

      real(db), dimension(facet_data%problem_dim)                         :: u_darcy_velocity
      real(db), dimension(facet_data%problem_dim, facet_data%problem_dim) :: u_darcy_velocity_1

      real(db) :: trace_u_darcy_velocity_1

      associate(&
          dim_soln_coeff       => facet_data%dim_soln_coeff, &
          no_pdes              => facet_data%no_pdes, &
          problem_dim          => facet_data%problem_dim, &
          no_quad_points       => facet_data%no_quad_points, &
          global_points        => facet_data%global_points, &
          integral_weighting   => facet_data%integral_weighting, &
          element_no           => facet_data%element_number, &
          element_region_id    => facet_data%element_region_id, &
          global_dof_numbers   => facet_data%global_dof_numbers, &
          no_dofs_per_variable => facet_data%no_dofs_per_variable &
      )
          current_time = 0.0_db

          element_matrix = 0.0_db
          element_rhs    = 0.0_db

          do i = 1, dim_soln_coeff
              phi  (i, 1:no_quad_points,                1:no_dofs_per_variable(i)) &
                  = fe_basis_info%basis_element%basis_fns(i) &
                  %fem_basis_fns(1:no_quad_points, 1:no_dofs_per_variable(i), 1)
              phi_1(i, 1:no_quad_points, 1:problem_dim, 1:no_dofs_per_variable(i)) &
                  = fe_basis_info%basis_element%deriv_basis_fns(i) &
                  %grad_data(1:no_quad_points, 1:problem_dim, 1:no_dofs_per_variable(i), 1)
          end do

          do q = 1, no_quad_points
              call calculate_convective_velocity_0_1(u_darcy_velocity, u_darcy_velocity_1, global_points(:, q), problem_dim, &
                  element_no, mesh_data)

              trace_u_darcy_velocity_1 = 0.0_db
              do i = 1, problem_dim
                  trace_u_darcy_velocity_1 = trace_u_darcy_velocity_1 + u_darcy_velocity_1(i, i)
              end do

              call forcing_function_transport(f, global_points(:, q), problem_dim, no_pdes, current_time)

              do i = 1, no_dofs_per_variable(1)
                  forcing_terms = phi(1, q, i)*f(1)

                  element_rhs(1, i) = element_rhs(1, i) + integral_weighting(q)*( &
                      forcing_terms*calculate_transport_forcing_coefficient(global_points(:, q), problem_dim, &
                          element_region_id) &
                  )

                  do j = 1, no_dofs_per_variable(1)
                      diffusion_terms  = dot_product(phi_1(1, q, :, i), phi_1(1, q, :, j))
                      convection_terms = -dot_product(u_darcy_velocity, phi_1(1, q, :, i))*phi(1, q, j) &
                                              -(trace_u_darcy_velocity_1)*phi(1, q, i)*phi(1, q, j)
                      reaction_terms   = phi(1, q, j)*phi(1, q, i)

                      element_matrix(1, 1, i, j) = element_matrix(1, 1, i, j) + integral_weighting(q)*( &
                          diffusion_terms *calculate_transport_diffusion_coefficient(global_points(:, q), problem_dim, &
                              element_region_id) + &
                          convection_terms*calculate_transport_convection_coefficient(global_points(:, q), problem_dim, &
                              element_region_id) + &
                          reaction_terms  *calculate_transport_reaction_coefficient(global_points(:, q), problem_dim, &
                              element_region_id))

                  end do
              end do
          end do

      end associate

  end subroutine

  subroutine stiffness_matrix_load_vector_face_transport_ss(face_matrix_pp, face_matrix_pm, face_matrix_mp, face_matrix_mm,  &
      face_rhs, mesh_data, soln_data, facet_data, fe_basis_info)

      include 'assemble_matrix_rhs_face.h'

      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      !! CONTAINED IN HEADER FILE !!
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      ! use param
      ! use fe_mesh
      ! use fe_solution
      ! use basis_fns_storage_type
      ! use matrix_assembly_data_type

      ! implicit none

      ! type(basis_storage), intent(in) :: fe_basis_info !< FE basis functions
      ! type(matrix_assembly_data_facet), intent(in) :: facet_data !< Facet data
      ! real(db), dimension(facet_data%dim_soln_coeff,facet_data%dim_soln_coeff, &
      ! facet_data%no_dofs_per_var_max,facet_data%no_dofs_per_var_max), &
      ! intent(out) :: face_matrix_pp !< Face stiffness matrix
      ! !< involving the plus-plus contributions with respect to the
      ! !< first element neighboring the face
      ! real(db), dimension(facet_data%dim_soln_coeff,facet_data%dim_soln_coeff, &
      ! facet_data%no_dofs_per_var_max,facet_data%no_dofs_per_var_max), &
      ! intent(out) :: face_matrix_pm !< Face stiffness matrix
      ! !< involving the plus-minus contributions with respect to the
      ! !< first element neighboring the face
      ! real(db), dimension(facet_data%dim_soln_coeff,facet_data%dim_soln_coeff, &
      ! facet_data%no_dofs_per_var_max,facet_data%no_dofs_per_var_max), &
      ! intent(out) :: face_matrix_mp !< Face stiffness matrix
      ! !< involving the minus-plus contributions with respect to the
      ! !< first element neighboring the face
      ! real(db), dimension(facet_data%dim_soln_coeff,facet_data%dim_soln_coeff, &
      ! facet_data%no_dofs_per_var_max,facet_data%no_dofs_per_var_max), &
      ! intent(out) :: face_matrix_mm !< Face stiffness matrix
      ! !< involving the minus-minus contributions with respect to the
      ! !< first element neighboring the face
      ! real(db), dimension(facet_data%dim_soln_coeff,facet_data%no_dofs_per_var_max), &
      ! intent(out) :: face_rhs
      ! !< Face rhs vector for each PDE equation in the system
      ! type(mesh), intent(in) :: mesh_data !< FE mesh
      ! type(solution), intent(in) :: soln_data !< FE solution

      integer                                        :: qk, i, j
      real(db)                                       :: full_dispenal, full_dispenal_old
      real(db)                                       :: diffusion_terms, convection_terms
      real(db), dimension(facet_data%no_pdes)        :: f, u, un
      real(db), dimension(facet_data%dim_soln_coeff) :: dispenal_new
      real(db), dimension(facet_data%dim_soln_coeff, facet_data%no_quad_points, facet_data%problem_dim, &
          maxval(facet_data%no_dofs_per_variable1))  :: grad_phi_p
      real(db), dimension(facet_data%dim_soln_coeff, facet_data%no_quad_points, facet_data%problem_dim, &
          maxval(facet_data%no_dofs_per_variable2))  :: grad_phi_m
      real(db)                                       :: current_time
      real(db)                                       :: a_dot_n_p, a_dot_n_m
      real(db)                                       :: deriv_flux_plus, deriv_flux_minus
      integer                                        :: bdry_face
      integer                                        :: element_no

      real(db), dimension(facet_data%dim_soln_coeff, facet_data%no_quad_points, maxval(facet_data%no_dofs_per_variable1)) :: phi_p
      real(db), dimension(facet_data%dim_soln_coeff, facet_data%no_quad_points, maxval(facet_data%no_dofs_per_variable1)) :: phi_m

      real(db), dimension(facet_data%problem_dim+1) :: u_darcy_p
      real(db), dimension(facet_data%problem_dim+1) :: u_darcy_m
      real(db), dimension(facet_data%problem_dim)   :: u_darcy_velocity_p
      real(db), dimension(facet_data%problem_dim)   :: u_darcy_velocity_m

      associate( &
          dim_soln_coeff            => facet_data%dim_soln_coeff, &
          no_pdes                   => facet_data%no_pdes, &
          problem_dim               => facet_data%problem_dim, &
          no_quad_points            => facet_data%no_quad_points, &
          global_points_face        => facet_data%global_points, &
          integral_weighting        => facet_data%integral_weighting, &
          face_number               => facet_data%face_number, &
          interior_face_boundary_no => facet_data%interior_face_boundary_no, &
          face_element_region_ids   => facet_data%face_element_region_ids, &
          bdry_face_old             => facet_data%bdry_no, &
          no_dofs_per_variable1     => facet_data%no_dofs_per_variable1, &
          no_dofs_per_variable2     => facet_data%no_dofs_per_variable2, &
          face_normals              => facet_data%face_normals, &
          dispenal                  => facet_data%dispenal, &
          scheme_user_data          => facet_data%scheme_user_data, &
          neighbour_elements        => facet_data%neighbours &
      )

          current_time = 0.0_db

          call convert_transport_boundary_no(bdry_face_old, bdry_face)

          element_no = get_interior_face_boundary_no(face_number, mesh_data)

          face_matrix_pp = 0.0_db
          face_matrix_pm = 0.0_db
          face_matrix_mp = 0.0_db
          face_matrix_mm = 0.0_db
          face_rhs       = 0.0_db

          do i = 1, dim_soln_coeff
              grad_phi_p(i, 1:no_quad_points, 1:problem_dim, 1:no_dofs_per_variable1(i)) = fe_basis_info%basis_face1 &
                  %deriv_basis_fns(i)%grad_data(1:no_quad_points, 1:problem_dim, 1:no_dofs_per_variable1(i), 1)
              grad_phi_m(i, 1:no_quad_points, 1:problem_dim, 1:no_dofs_per_variable2(i)) = fe_basis_info%basis_face2 &
                  %deriv_basis_fns(i)%grad_data(1:no_quad_points, 1:problem_dim, 1:no_dofs_per_variable2(i), 1)

              phi_p(i, 1:no_quad_points, 1:no_dofs_per_variable1(i)) = fe_basis_info%basis_face1%basis_fns(i) &
                  %fem_basis_fns(1:no_quad_points, 1:no_dofs_per_variable1(i), 1)
              phi_m(i, 1:no_quad_points, 1:no_dofs_per_variable2(i)) = fe_basis_info%basis_face2%basis_fns(i) &
                  %fem_basis_fns(1:no_quad_points, 1:no_dofs_per_variable2(i), 1)
          end do

          full_dispenal = interior_penalty_parameter*dispenal(1)

          if (bdry_face > 0) then
              if (100 <= bdry_face .and. bdry_face <= 199) then
                  do qk = 1, no_quad_points
                      call calculate_convective_velocity(u_darcy_velocity_p, global_points_face(:, qk), problem_dim, &
                          neighbour_elements(1), mesh_data)

                      a_dot_n_p        = dot_product(u_darcy_velocity_p, face_normals(:, qk))
                      deriv_flux_plus  = 0.5_db*(a_dot_n_p + abs(a_dot_n_p))
                      deriv_flux_minus = 0.5_db*(a_dot_n_p - abs(a_dot_n_p))

                      call anal_soln_transport(u, global_points_face(:, qk), problem_dim, no_pdes, bdry_face, current_time)

                      do i = 1, no_dofs_per_variable1(1)
                          diffusion_terms = &
                              -dot_product(grad_phi_p(1, qk, :, i), face_normals(:, qk)) + full_dispenal*phi_p(1, qk, i)

                          convection_terms = &
                              -deriv_flux_minus*phi_p(1, qk, i)

                          face_rhs(1, i) = face_rhs(1, i) + integral_weighting(qk)*u(1)* &
                          ( &
                              diffusion_terms *calculate_transport_diffusion_coefficient(global_points_face(:, qk), &
                                  problem_dim, face_element_region_ids(1)) + &
                              convection_terms*calculate_transport_convection_coefficient(global_points_face(:, qk), &
                                  problem_dim, face_element_region_ids(1)) &
                          )

                          do j = 1, no_dofs_per_variable1(1)
                              diffusion_terms = &
                                  -dot_product(grad_phi_p(1, qk, :, i), face_normals(:, qk))*phi_p(1, qk, j) &
                                  -dot_product(grad_phi_p(1, qk, :, j), face_normals(:, qk))*phi_p(1, qk, i) &
                                  +full_dispenal*phi_p(1, qk, j)*phi_p(1, qk, i)

                              convection_terms = &
                                  deriv_flux_plus*phi_p(1, qk, i)*phi_p(1, qk, j)

                              face_matrix_pp(1, 1, i, j) = face_matrix_pp(1, 1, i, j) + integral_weighting(qk) * &
                              ( &
                                  diffusion_terms *calculate_transport_diffusion_coefficient(global_points_face(:, qk), &
                                      problem_dim, face_element_region_ids(1)) + &
                                  convection_terms*calculate_transport_convection_coefficient(global_points_face(:, qk), &
                                      problem_dim, face_element_region_ids(1)) &
                              )
                          end do
                      end do
                  end do
              else if (200 <= bdry_face .and. bdry_face <= 299) then
                  do qk = 1, no_quad_points
                      call calculate_convective_velocity(u_darcy_velocity_p, global_points_face(:, qk), problem_dim, &
                          neighbour_elements(1), mesh_data)

                      a_dot_n_p        = dot_product(u_darcy_velocity_p, face_normals(:, qk))
                      deriv_flux_plus  = 0.5_db*(a_dot_n_p + abs(a_dot_n_p))
                      deriv_flux_minus = 0.5_db*(a_dot_n_p - abs(a_dot_n_p))

                      call neumann_bc_transport(un, global_points_face(:, qk), problem_dim, no_pdes, current_time, face_normals)

                      do i = 1, no_dofs_per_variable1(1)
                          diffusion_terms = un(1)*phi_p(1, qk, i)

                          face_rhs(1, i) = face_rhs(1, i) + &
                              integral_weighting(qk)*diffusion_terms

                          do j = 1, no_dofs_per_variable1(1)
                              convection_terms = &
                                  deriv_flux_plus*phi_p(1, qk, i)*phi_p(1, qk, j)

                              face_matrix_pp(1, 1, i, j) = face_matrix_pp(1, 1, i, j) + integral_weighting(qk) * &
                              ( &
                                  convection_terms*calculate_transport_convection_coefficient(global_points_face(:, qk), &
                                      problem_dim, face_element_region_ids(1)) &
                              )
                          end do
                      end do
                  end do
              end if
          else
              do qk = 1, no_quad_points
                  call calculate_convective_velocity(u_darcy_velocity_p, global_points_face(:, qk), problem_dim, &
                      neighbour_elements(1), mesh_data)
                  call calculate_convective_velocity(u_darcy_velocity_m, global_points_face(:, qk), problem_dim, &
                      neighbour_elements(2), mesh_data)

                  a_dot_n_p        = dot_product(u_darcy_velocity_p, face_normals(:, qk))
                  a_dot_n_m        = dot_product(u_darcy_velocity_m, face_normals(:, qk))
                  deriv_flux_plus  = 0.5_db*(a_dot_n_p + abs(a_dot_n_p))
                  deriv_flux_minus = 0.5_db*(a_dot_n_m - abs(a_dot_n_m))

                  do i = 1, no_dofs_per_variable1(1)
                      do j = 1, no_dofs_per_variable1(1)
                          diffusion_terms = &
                              -0.5_db*dot_product(grad_phi_p(1, qk, :, i), face_normals(:, qk))*phi_p(1, qk, j) &
                              -0.5_db*dot_product(grad_phi_p(1, qk, :, j), face_normals(:, qk))*phi_p(1, qk, i) &
                              +full_dispenal*phi_p(1, qk, j)*phi_p(1, qk, i)

                          convection_terms = &
                              deriv_flux_plus*phi_p(1, qk, j)*phi_p(1, qk, i)

                          face_matrix_pp(1, 1, i, j) = face_matrix_pp(1, 1, i, j) + integral_weighting(qk)*( &
                              diffusion_terms *calculate_transport_diffusion_coefficient(global_points_face(:, qk), &
                                  problem_dim, face_element_region_ids(1)) + &
                              convection_terms*calculate_transport_convection_coefficient(global_points_face(:, qk), &
                                  problem_dim, face_element_region_ids(1)) &
                          )
                      end do

                      do j = 1, no_dofs_per_variable2(1)
                          diffusion_terms = &
                               0.5_db*dot_product(grad_phi_p(1, qk, :, i), face_normals(:, qk))*phi_m(1, qk, j) &
                              -0.5_db*dot_product(grad_phi_m(1, qk, :, j), face_normals(:, qk))*phi_p(1, qk, i) &
                              -full_dispenal*phi_m(1, qk, j)*phi_p(1, qk, i)

                          convection_terms = &
                              deriv_flux_minus*phi_m(1, qk, j)*phi_p(1, qk, i)

                          face_matrix_mp(1, 1, i, j) = face_matrix_mp(1, 1, i, j) + integral_weighting(qk)*( &
                              diffusion_terms *calculate_transport_diffusion_coefficient(global_points_face(:, qk), &
                                  problem_dim, face_element_region_ids(1)) + &
                              convection_terms*calculate_transport_convection_coefficient(global_points_face(:, qk), &
                                  problem_dim, face_element_region_ids(1)) &
                          )
                      end do
                  end do

                  do i = 1, no_dofs_per_variable2(1)
                      do j = 1, no_dofs_per_variable1(1)
                          diffusion_terms = &
                              -0.5_db*dot_product(grad_phi_m(1, qk, :, i), face_normals(:, qk))*phi_p(1, qk, j) &
                              +0.5_db*dot_product(grad_phi_p(1, qk, :, j), face_normals(:, qk))*phi_m(1, qk, i) &
                              -full_dispenal*phi_p(1, qk, j)*phi_m(1, qk, i)

                          convection_terms = &
                              -deriv_flux_plus*phi_p(1, qk, j)*phi_m(1, qk, i)

                          face_matrix_pm(1, 1, i, j) = face_matrix_pm(1, 1, i, j) + integral_weighting(qk)*( &
                              diffusion_terms *calculate_transport_diffusion_coefficient(global_points_face(:, qk), &
                                  problem_dim, face_element_region_ids(1)) + &
                              convection_terms*calculate_transport_convection_coefficient(global_points_face(:, qk), &
                                  problem_dim, face_element_region_ids(1)) &
                          )
                      end do

                      do j = 1, no_dofs_per_variable2(1)
                          diffusion_terms = &
                               0.5_db*dot_product(grad_phi_m(1, qk, :, i), face_normals(:, qk))*phi_m(1, qk, j) &
                              +0.5_db*dot_product(grad_phi_m(1, qk, :, j), face_normals(:, qk))*phi_m(1, qk, i) &
                              +full_dispenal*phi_m(1, qk, j)*phi_m(1, qk, i)

                          convection_terms = &
                              -deriv_flux_minus*phi_m(1, qk, j)*phi_m(1, qk, i)

                          face_matrix_mm(1, 1, i, j) = face_matrix_mm(1, 1, i, j) + integral_weighting(qk)*( &
                              diffusion_terms *calculate_transport_diffusion_coefficient(global_points_face(:, qk), &
                                  problem_dim, face_element_region_ids(1)) + &
                              convection_terms*calculate_transport_convection_coefficient(global_points_face(:, qk), &
                                  problem_dim, face_element_region_ids(1)) &
                          )
                      end do
                  end do
              end do
          end if

      end associate

  end subroutine
end module