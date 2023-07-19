module matrix_rhs_s_b_ss
  use bcs_velocity

  contains

  real(db) function calculate_uv(phi_u, phi_v, ivar, ieqn, global_point, problem_dim, no_pdes, element_region_id)
      use param
      use problem_options
      use problem_options_velocity

      implicit none

      integer, intent(in) :: problem_dim

      real(db), intent(in)                         :: phi_u
      real(db), intent(in)                         :: phi_v
      integer, intent(in)                          :: ivar
      integer, intent(in)                          :: ieqn
      real(db), dimension(problem_dim), intent(in) :: global_point
      integer, intent(in)                          :: no_pdes
      integer, intent(in)                          :: element_region_id

      calculate_uv = 0.0_db

      if (ieqn == ivar) then
          if (ivar < problem_dim+1) then
            !   calculate_uv = calculate_velocity_reaction_coefficient(global_point, problem_dim, element_region_id) * phi_u*phi_v
            if ((300 <= element_region_id .and. element_region_id <= 399) .or. &
                (520 <= element_region_id .and. element_region_id <= 529)) then
                calculate_uv = velocity_reaction_coefficient * phi_u*phi_v
            else
                calculate_uv = 0.0_db
            end if
          end if
      end if
  end function

  real(db) function calculate_gradugradv(grad_phi_u, grad_phi_v, ivar, ieqn, global_point, problem_dim, no_pdes, &
          element_region_id)
      use param
      use problem_options
      use problem_options_velocity

      implicit none

      integer, intent(in) :: problem_dim

      real(db), dimension(problem_dim), intent(in) :: grad_phi_u
      real(db), dimension(problem_dim), intent(in) :: grad_phi_v
      integer, intent(in)                          :: ivar
      integer, intent(in)                          :: ieqn
      real(db), dimension(problem_dim), intent(in) :: global_point
      integer, intent(in)                          :: no_pdes
      integer, intent(in)                          :: element_region_id

      calculate_gradugradv = 0.0_db

      if (ieqn == ivar) then
          if (ivar < problem_dim+1) then
              calculate_gradugradv = calculate_velocity_diffusion_coefficient(global_point, problem_dim, element_region_id) * &
                  dot_product(grad_phi_u, grad_phi_v)
          end if
      end if
  end function

  real(db) function calculate_pgradu(phi_p, grad_phi_u, ip, iv, global_point, problem_dim, no_pdes, element_region_id)
      use param
      use problem_options
      use problem_options_velocity

      implicit none

      integer, intent(in) :: problem_dim

      real(db), intent(in)                         :: phi_p
      real(db), dimension(problem_dim), intent(in) :: grad_phi_u
      integer, intent(in)                          :: ip
      integer, intent(in)                          :: iv
      real(db), dimension(problem_dim), intent(in) :: global_point
      integer, intent(in)                          :: no_pdes
      integer, intent(in)                          :: element_region_id

      calculate_pgradu = 0.0_db

      if (ip == problem_dim+1) then
          if (iv < problem_dim+1) then
              calculate_pgradu = calculate_velocity_pressure_coefficient(global_point, problem_dim, element_region_id) * &
                  phi_p*grad_phi_u(iv)
          end if
      end if
  end function

  real(db) function calculate_a_face1(grad_phi_u, grad_phi_v, phi_u, phi_v, face_normals, ivar, ieqn, global_point, problem_dim, &
          no_pdes, face_element_region_ids)
      use param
      use problem_options
      use problem_options_velocity

      implicit none

      integer, intent(in) :: problem_dim

      real(db), dimension(problem_dim), intent(in) :: grad_phi_u
      real(db), dimension(problem_dim), intent(in) :: grad_phi_v
      real(db), intent(in)                         :: phi_u
      real(db), intent(in)                         :: phi_v
      real(db), dimension(problem_dim), intent(in) :: global_point
      real(db), dimension(problem_dim), intent(in) :: face_normals
      integer, intent(in)                          :: ivar
      integer, intent(in)                          :: ieqn
      integer, intent(in)                          :: no_pdes
      integer, dimension(2), intent(in)            :: face_element_region_ids

      calculate_a_face1 = 0.0_db

      if (ieqn == ivar) then
          if (ivar < problem_dim+1) then
              calculate_a_face1 = -calculate_velocity_diffusion_coefficient(global_point, problem_dim, face_element_region_ids(1))*&
                  dot_product(grad_phi_v, face_normals)*phi_u
          end if
      end if
  end function

  real(db) function calculate_a_face2(grad_phi_u, grad_phi_v, phi_u, phi_v, ivar, ieqn, global_point, dispenal, &
          problem_dim, no_pdes, face_element_region_ids)
      use param
      use problem_options
      use problem_options_velocity

      implicit none

      integer, intent(in) :: problem_dim

      real(db), dimension(problem_dim), intent(in) :: grad_phi_u
      real(db), dimension(problem_dim), intent(in) :: grad_phi_v
      real(db), intent(in)                         :: phi_u
      real(db), intent(in)                         :: phi_v
      integer, intent(in)                          :: ivar
      integer, intent(in)                          :: ieqn
      real(db), dimension(problem_dim), intent(in) :: global_point
      real(db), dimension(problem_dim), intent(in) :: dispenal
      integer, intent(in)                          :: no_pdes
      integer, dimension(2), intent(in)            :: face_element_region_ids

      calculate_a_face2 = 0.0_db

      if (ieqn == ivar) then
          if (ivar < problem_dim+1) then
              calculate_a_face2 = calculate_velocity_diffusion_coefficient(global_point, problem_dim, face_element_region_ids(1)) *&
                  dispenal(1) * interior_penalty_parameter * phi_u * phi_v
          end if
      end if
  end function

  real(db) function calculate_b_face(phi_q, phi_v, face_normals, ieqn, ivar, global_point, problem_dim, no_pdes, &
          face_element_region_ids)
      use param
      use problem_options
      use problem_options_velocity

      implicit none

      integer, intent(in) :: problem_dim

      real(db), intent(in)                         :: phi_q
      real(db), intent(in)                         :: phi_v
      real(db), dimension(problem_dim), intent(in) :: face_normals
      integer, intent(in)                          :: ivar
      integer, intent(in)                          :: ieqn
      real(db), dimension(problem_dim), intent(in) :: global_point
      integer, intent(in)                          :: no_pdes
      integer, dimension(2), intent(in)            :: face_element_region_ids

      calculate_b_face = 0.0_db

      if (ieqn == problem_dim+1) then
          if (ivar < problem_dim+1) then
              calculate_b_face = calculate_velocity_pressure_coefficient(global_point, problem_dim, face_element_region_ids(1)) * &
                  phi_q * phi_v * face_normals(ivar)
          end if
      end if
  end function

  subroutine stiffness_matrix_load_vector_s_b_ss(element_matrix, element_rhs, mesh_data, soln_data, facet_data, fe_basis_info)
      use problem_options
      use problem_options_velocity

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
      integer :: i, j
      integer :: q
      real(db), dimension(facet_data%no_pdes)      :: f
      real(db), dimension(facet_data%dim_soln_coeff, facet_data%no_quad_points, &
          maxval(facet_data%no_dofs_per_variable)) :: phi
      real(db), dimension(facet_data%dim_soln_coeff, facet_data%no_quad_points, facet_data%problem_dim, &
          maxval(facet_data%no_dofs_per_variable)) :: phi_1

      real(db) :: all_terms
      real(db) :: gradugradv_term, pgradu_term, uv_term

      integer :: ieqn, ivar

      associate(&
          dim_soln_coeff       => facet_data%dim_soln_coeff, &
          no_pdes              => facet_data%no_pdes, &
          problem_dim          => facet_data%problem_dim, &
          no_quad_points       => facet_data%no_quad_points, &
          global_points        => facet_data%global_points, &
          integral_weighting   => facet_data%integral_weighting, & ! <-- Quadrature weights and Jacobian.
          element_no           => facet_data%element_number, &
          element_region_id    => facet_data%element_region_id, & ! <-- By default 0, 1 region per element.
          no_dofs_per_variable => facet_data%no_dofs_per_variable &
      )
          !!!!!!!!!!!
          !! SETUP !!
          !!!!!!!!!!!
          element_matrix = 0.0_db
          element_rhs    = 0.0_db

          do i = 1, dim_soln_coeff
              phi  (i, 1:no_quad_points,                1:no_dofs_per_variable(i)) &
                  = fe_basis_info%basis_element%basis_fns(i) &
                  %fem_basis_fns(1:no_quad_points, 1:no_dofs_per_variable(i), 1) !<-- 1 means it's a scalar basis function.
              phi_1(i, 1:no_quad_points, 1:problem_dim, 1:no_dofs_per_variable(i)) &
                  = fe_basis_info%basis_element%deriv_basis_fns(i) &
                  %grad_data(1:no_quad_points, 1:problem_dim, 1:no_dofs_per_variable(i), 1)
          end do

          do q = 1, no_quad_points
              call forcing_function_velocity(f, global_points(:, q), problem_dim, no_pdes, 0.0_db, element_region_id)

              do ieqn = 1, no_pdes
                  do i = 1, no_dofs_per_variable(ieqn)
                      element_rhs(ieqn, i) = element_rhs(ieqn, i) + integral_weighting(q)*f(ieqn)*phi(ieqn, q, i)

                      do ivar = 1, no_pdes
                          do j = 1, no_dofs_per_variable(ivar)
                              all_terms = 0.0_db

                              all_terms = all_terms &
                                  + calculate_gradugradv(phi_1(ivar, q, :, j), phi_1(ieqn, q, :, i), ivar, ieqn, &
                                      global_points(:, q), problem_dim, no_pdes, element_region_id)
                              all_terms = all_terms &
                                  - calculate_pgradu(phi(ivar, q, j), phi_1(ieqn, q, :, i), ivar, ieqn, global_points(:, q), &
                                      problem_dim, no_pdes, element_region_id)
                              all_terms = all_terms &
                                  + calculate_pgradu(phi(ieqn, q, i), phi_1(ivar, q, :, j), ieqn, ivar, global_points(:, q), &
                                      problem_dim, no_pdes, element_region_id)
                              all_terms = all_terms &
                                  + calculate_uv(phi(ivar, q, j), phi(ieqn, q, i), ivar, ieqn, global_points(:, q), &
                                      problem_dim, no_pdes, element_region_id)

                              ! if ((300 <= element_region_id .and. element_region_id <= 399) .or. .not. stokes_in_pipe) then
                              !     all_terms = all_terms &
                              !         + calculate_uv(phi(ivar, q, j), phi(ieqn, q, i), ivar, ieqn, global_points(:, q), &
                              !             problem_dim, no_pdes)
                              ! end if

                              element_matrix(ieqn, ivar, i, j) = element_matrix(ieqn, ivar, i, j) + &
                                  integral_weighting(q)*all_terms 
                          end do
                      end do
                  end do
              end do
          end do

      end associate

  end subroutine

  subroutine stiffness_matrix_load_vector_face_s_b_ss(face_matrix_pp, face_matrix_pm, face_matrix_mp, face_matrix_mm,  face_rhs, & 
      mesh_data, soln_data, facet_data, fe_basis_info)

      use problem_options
      use problem_options_velocity

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
      integer                                        :: ieqn, ivar
      integer                                        :: bdry_face
      real(db)                                       :: all_terms
      real(db), dimension(facet_data%no_pdes)        :: f
      real(db), dimension(facet_data%problem_dim)    :: u, un
      real(db), dimension(facet_data%dim_soln_coeff, facet_data%no_quad_points, facet_data%problem_dim, &
          maxval(facet_data%no_dofs_per_variable1))  :: grad_phi_p
      real(db), dimension(facet_data%dim_soln_coeff, facet_data%no_quad_points, facet_data%problem_dim, &
          maxval(facet_data%no_dofs_per_variable2))  :: grad_phi_m

      real(db), dimension(facet_data%dim_soln_coeff, facet_data%no_quad_points, &
          max(maxval(facet_data%no_dofs_per_variable1), maxval(facet_data%no_dofs_per_variable2))) :: phi_p
      real(db), dimension(facet_data%dim_soln_coeff, facet_data%no_quad_points, &
          max(maxval(facet_data%no_dofs_per_variable1), maxval(facet_data%no_dofs_per_variable2))) :: phi_m
      real(db), dimension(facet_data%problem_dim,    facet_data%no_quad_points, &
          max(maxval(facet_data%no_dofs_per_variable1), maxval(facet_data%no_dofs_per_variable2))) :: phi1

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
          dispenal                  => facet_data%dispenal &
      )

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

          call convert_velocity_boundary_no(bdry_face_old, bdry_face)

          if (bdry_face > 0) then
              do qk = 1, no_quad_points
                  if (bdry_face >= 200 .and. bdry_face <= 299) then
                      call neumann_bc_velocity(un, global_points_face(1:problem_dim, qk), problem_dim, bdry_face, 0.0_db, &
                          face_element_region_ids(1), face_normals(1:problem_dim, qk))

                      do ieqn = 1, no_pdes
                          do i = 1, no_dofs_per_variable1(ieqn)
                              if (ieqn < problem_dim + 1) then
                                  face_rhs(ieqn, i) = face_rhs(ieqn, i) - integral_weighting(qk)*un(ieqn)*phi_p(ieqn, qk, i)
                              else
                                  face_rhs(ieqn, i) = face_rhs(ieqn, i) + 0.0_db
                              end if
                          end do
                      end do
                  else
                      call dirichlet_bc_velocity(u, global_points_face(1:problem_dim, qk), problem_dim, no_pdes, bdry_face, &
                        0.0_db)

                      do ieqn = 1, no_pdes
                          do i = 1, no_dofs_per_variable1(ieqn)
                              if (ieqn < problem_dim + 1) then
                                  all_terms = 0.0_db
                                  
                                  all_terms = all_terms &
                                      + calculate_a_face2(grad_phi_p(ieqn, qk, :, i), grad_phi_p(ieqn, qk, :, i), &
                                              phi_p(ieqn, qk, i), u(ieqn), ieqn, ieqn, global_points_face(1:problem_dim, qk), &
                                              dispenal, problem_dim, no_pdes, face_element_region_ids)

                                  all_terms = all_terms &
                                      + calculate_a_face1(grad_phi_p(ieqn, qk, :, i), grad_phi_p(ieqn, qk, :, i), &
                                              u(ieqn), u(ieqn), face_normals(1:problem_dim, qk), ieqn, ieqn, &
                                              global_points_face(1:problem_dim, qk), problem_dim, no_pdes, &
                                              face_element_region_ids)

                                  face_rhs(ieqn, i) = face_rhs(ieqn, i) + integral_weighting(qk) * all_terms
                              else
                                  all_terms = 0.0_db

                                  all_terms = all_terms &
                                      + calculate_a_face1(u(1:problem_dim), u(1:problem_dim), &
                                          basis_fn_face1(fe_basis_info, problem_dim+1, qk, i, 1), &
                                          basis_fn_face1(fe_basis_info, problem_dim+1, qk, i, 1), &
                                          face_normals(1:problem_dim, qk), 1, 1, global_points_face(1:problem_dim, qk), &
                                          problem_dim, no_pdes, face_element_region_ids)

                                  face_rhs(ieqn, i) = face_rhs(ieqn, i) + integral_weighting(qk) * all_terms
                              end if
                          end do
                      end do

                      do ieqn = 1, no_pdes
                          do i = 1, no_dofs_per_variable1(ieqn)
                              do ivar = 1, no_pdes
                                  do j = 1, no_dofs_per_variable1(ivar)
                                      all_terms = 0.0_db

                                      all_terms = all_terms &
                                          + calculate_a_face1(grad_phi_p(ivar, qk, :, j), grad_phi_p(ieqn, qk, :, i), &
                                              phi_p(ivar, qk, j), phi_p(ieqn, qk, i), face_normals(:, qk), ivar, ieqn, &
                                              global_points_face(1:problem_dim, qk), problem_dim, no_pdes, &
                                              face_element_region_ids) &
                                          + calculate_a_face1(grad_phi_p(ieqn, qk, :, i), grad_phi_p(ivar, qk, :, j), &
                                              phi_p(ieqn, qk, i), phi_p(ivar, qk, j), face_normals(:, qk), ieqn, ivar, &
                                              global_points_face(1:problem_dim, qk), problem_dim, no_pdes, &
                                              face_element_region_ids) &
                                          + calculate_a_face2(grad_phi_p(ivar, qk, :, j), grad_phi_p(ieqn, qk, :, i), &
                                              phi_p(ivar, qk, j), phi_p(ieqn, qk, i), ivar, ieqn, &
                                              global_points_face(1:problem_dim, qk), dispenal, problem_dim, no_pdes, &
                                              face_element_region_ids)

                                      all_terms = all_terms &
                                          + calculate_b_face(phi_p(ivar, qk, j), phi_p(ieqn, qk, i), &
                                              face_normals(1:problem_dim, qk), ivar, ieqn, global_points_face(1:problem_dim, qk),&
                                              problem_dim, no_pdes, face_element_region_ids)

                                      all_terms = all_terms &
                                          - calculate_b_face(phi_p(ieqn, qk, i), phi_p(ivar, qk, j), &
                                              face_normals(1:problem_dim, qk), ieqn, ivar, global_points_face(1:problem_dim, qk),&
                                              problem_dim, no_pdes, face_element_region_ids)

                                      face_matrix_pp(ieqn, ivar, i, j) = face_matrix_pp(ieqn, ivar, i, j) &
                                         + integral_weighting(qk)*all_terms
                                  end do
                              end do
                          end do
                      end do
                  end if
              end do
          else
              do qk = 1, no_quad_points
                  do ieqn = 1, no_pdes
                      do ivar = 1, no_pdes
                          do i = 1, no_dofs_per_variable1(ieqn)
                              do j = 1, no_dofs_per_variable1(ivar)

                                  all_terms = 0.0_db

                                  all_terms = all_terms &
                                      + 0.5_db * calculate_a_face1(grad_phi_p(ivar, qk, :, j), grad_phi_p(ieqn, qk, :, i), &
                                          phi_p(ivar, qk, j), phi_p(ieqn, qk, i), face_normals(:, qk), ivar, ieqn, &
                                          global_points_face(1:problem_dim, qk), problem_dim, no_pdes, face_element_region_ids) &
                                      + 0.5_db * calculate_a_face1(grad_phi_p(ieqn, qk, :, i), grad_phi_p(ivar, qk, :, j), &
                                          phi_p(ieqn, qk, i), phi_p(ivar, qk, j), face_normals(:, qk), ieqn, ivar, &
                                          global_points_face(1:problem_dim, qk), problem_dim, no_pdes, face_element_region_ids) &
                                      + calculate_a_face2(grad_phi_p(ivar, qk, :, j), grad_phi_p(ieqn, qk, :, i), &
                                          phi_p(ivar, qk, j), phi_p(ieqn, qk, i), ivar, ieqn, &
                                          global_points_face(1:problem_dim, qk), dispenal, problem_dim, no_pdes, &
                                          face_element_region_ids)

                                  all_terms = all_terms &
                                      + 0.5_db * calculate_b_face(phi_p(ivar, qk, j), phi_p(ieqn, qk, i), &
                                          face_normals(1:problem_dim, qk), ivar, ieqn, global_points_face(1:problem_dim, qk), &
                                          problem_dim, no_pdes, face_element_region_ids)

                                  all_terms = all_terms &
                                      - 0.5_db * calculate_b_face(phi_p(ieqn, qk, i), phi_p(ivar, qk, j), &
                                          face_normals(1:problem_dim, qk), ieqn, ivar, global_points_face(1:problem_dim, qk), &
                                          problem_dim, no_pdes, face_element_region_ids)

                                  face_matrix_pp(ieqn, ivar, i, j) = face_matrix_pp(ieqn, ivar, i, j) &
                                     + integral_weighting(qk)*all_terms
                              end do

                              do j = 1, no_dofs_per_variable2(ivar)
                                  all_terms = 0.0_db

                                  all_terms = &
                                      - 0.5_db * calculate_a_face1(grad_phi_m(ivar, qk, :, j), grad_phi_p(ieqn, qk, :, i), &
                                          phi_m(ivar, qk, j), phi_p(ieqn, qk, i), face_normals(:, qk), ivar, ieqn, &
                                          global_points_face(1:problem_dim, qk), problem_dim, no_pdes, face_element_region_ids) &
                                      + 0.5_db * calculate_a_face1(grad_phi_p(ieqn, qk, :, i), grad_phi_m(ivar, qk, :, j), &
                                          phi_p(ieqn, qk, i), phi_m(ivar, qk, j), face_normals(:, qk), ieqn, ivar, &
                                          global_points_face(1:problem_dim, qk), problem_dim, no_pdes, face_element_region_ids) &
                                      - calculate_a_face2(grad_phi_m(ivar, qk, :, j), grad_phi_p(ieqn, qk, :, i), &
                                          phi_m(ivar, qk, j), phi_p(ieqn, qk, i), ivar, ieqn, &
                                          global_points_face(1:problem_dim, qk), dispenal, problem_dim, no_pdes, &
                                          face_element_region_ids)

                                  all_terms = all_terms &
                                      + 0.5_db * calculate_b_face(phi_m(ivar, qk, j), phi_p(ieqn, qk, i), &
                                          face_normals(1:problem_dim, qk), ivar, ieqn, global_points_face(1:problem_dim, qk), &
                                          problem_dim, no_pdes, face_element_region_ids)

                                  all_terms = all_terms &
                                      + 0.5_db * calculate_b_face(phi_p(ieqn, qk, i), phi_m(ivar, qk, j), &
                                          face_normals(1:problem_dim, qk), ieqn, ivar, global_points_face(1:problem_dim, qk), &
                                          problem_dim, no_pdes, face_element_region_ids)

                                  face_matrix_mp(ieqn, ivar, i, j) = face_matrix_mp(ieqn, ivar, i, j) &
                                     + integral_weighting(qk)*all_terms
                              end do
                          end do
                      end do

                      do ivar = 1, no_pdes
                          do i = 1, no_dofs_per_variable2(ieqn)
                              do j = 1, no_dofs_per_variable1(ivar)
                                  all_terms = 0.0_db

                                  all_terms = &
                                      + 0.5_db * calculate_a_face1(grad_phi_p(ivar, qk, :, j), grad_phi_m(ieqn, qk, :, i), &
                                          phi_p(ivar, qk, j), phi_m(ieqn, qk, i), face_normals(:, qk), ivar, ieqn, &
                                          global_points_face(1:problem_dim, qk), problem_dim, no_pdes, face_element_region_ids) &
                                      - 0.5_db * calculate_a_face1(grad_phi_m(ieqn, qk, :, i), grad_phi_p(ivar, qk, :, j), &
                                          phi_m(ieqn, qk, i), phi_p(ivar, qk, j), face_normals(:, qk), ieqn, ivar, &
                                          global_points_face(1:problem_dim, qk), problem_dim, no_pdes, face_element_region_ids) &
                                      - calculate_a_face2(grad_phi_p(ivar, qk, :, j), grad_phi_m(ieqn, qk, :, i), &
                                          phi_p(ivar, qk, j), phi_m(ieqn, qk, i), ivar, ieqn, &
                                          global_points_face(1:problem_dim, qk), dispenal, problem_dim, no_pdes, &
                                          face_element_region_ids)

                                  all_terms = all_terms &
                                      - 0.5_db * calculate_b_face(phi_p(ivar, qk, j), phi_m(ieqn, qk, i), &
                                          face_normals(1:problem_dim, qk), ivar, ieqn, global_points_face(1:problem_dim, qk), &
                                          problem_dim, no_pdes, face_element_region_ids)

                                  all_terms = all_terms &
                                      - 0.5_db * calculate_b_face(phi_m(ieqn, qk, i), phi_p(ivar, qk, j), &
                                          face_normals(1:problem_dim, qk), ieqn, ivar, global_points_face(1:problem_dim, qk), &
                                          problem_dim, no_pdes, face_element_region_ids)

                                  face_matrix_pm(ieqn, ivar, i, j) = face_matrix_pm(ieqn, ivar, i, j) &
                                     + integral_weighting(qk)*all_terms
                              end do

                              do j = 1, no_dofs_per_variable2(ivar)
                                  all_terms = 0.0_db

                                  all_terms = &
                                      - 0.5_db * calculate_a_face1(grad_phi_m(ivar, qk, :, j), grad_phi_m(ieqn, qk, :, i), &
                                          phi_m(ivar, qk, j), phi_m(ieqn, qk, i), face_normals(:, qk), ivar, ieqn, &
                                          global_points_face(1:problem_dim, qk), problem_dim, no_pdes, face_element_region_ids) &
                                      - 0.5_db * calculate_a_face1(grad_phi_m(ieqn, qk, :, i), grad_phi_m(ivar, qk, :, j), &
                                          phi_m(ieqn, qk, i), phi_m(ivar, qk, j), face_normals(:, qk), ieqn, ivar, &
                                          global_points_face(1:problem_dim, qk), problem_dim, no_pdes, face_element_region_ids) &
                                      + calculate_a_face2(grad_phi_m(ivar, qk, :, j), grad_phi_m(ieqn, qk, :, i), &
                                          phi_m(ivar, qk, j), phi_m(ieqn, qk, i), ivar, ieqn, &
                                          global_points_face(1:problem_dim, qk), dispenal, problem_dim, no_pdes, &
                                          face_element_region_ids)
                                  all_terms = all_terms &
                                      - 0.5_db * calculate_b_face(phi_m(ivar, qk, j), phi_m(ieqn, qk, i), &
                                          face_normals(1:problem_dim, qk), ivar, ieqn, global_points_face(1:problem_dim, qk), &
                                          problem_dim, no_pdes, face_element_region_ids)
                                  all_terms = all_terms &
                                      + 0.5_db * calculate_b_face(phi_m(ieqn, qk, i), phi_m(ivar, qk, j), &
                                          face_normals(1:problem_dim, qk), ieqn, ivar, global_points_face(1:problem_dim, qk), &
                                          problem_dim, no_pdes, face_element_region_ids)

                                  face_matrix_mm(ieqn, ivar, i, j) = face_matrix_mm(ieqn, ivar, i, j) &
                                     + integral_weighting(qk)*all_terms
                              end do
                          end do
                      end do
                  end do
              end do
          end if        

      end associate
  end subroutine
end module