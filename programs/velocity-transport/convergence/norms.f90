module norms
  implicit none

  contains

  !------------------------------------------------------------------
!>   Computes the errors
!!
!!   errors(1) = || u-u_h ||_{L_2}
!!
!!   errors(2) = | u-u_h |_{H^1}
!!
!!   errors(3) = || u-u_h ||_{DG}
!!
!!   errors(4) = | u-u_h |_{H^2}
!!
!! Author:
!!   P.Houston
!------------------------------------------------------------------
! subroutine error_norms_transport(errors,mesh_data,soln_data,t)
!   !--------------------------------------------------------------------
!     use param
!     use fe_mesh
!     use fe_solution
!     use basis_fns_storage_type
!     use aptofem_fe_matrix_assembly
!     use problem_options
!     use bcs_transport
  
!     implicit none
  
!     real(db), dimension(4), intent(out) :: errors
!     type(mesh), intent(inout) :: mesh_data !< FE mesh
!     type(solution), intent(inout) :: soln_data !< FE solution
!     real(db), intent(in) :: t !< Time
  
!   ! Local variables
  
!     type(basis_storage) :: fe_basis_info
!     character(len=aptofem_length_key_def) :: control_parameter
!     integer :: no_eles,no_nodes,no_faces,problem_dim,no_pdes, &
!          i,j,k,qk,iv,no_quad_points,npinc, &
!          no_quad_points_volume_max,no_quad_points_face_max, &
!          bdry_face,dim_soln_coeff
!     real(db), dimension(:,:), allocatable :: global_points_ele
!     real(db), dimension(:), allocatable :: quad_weights_ele,jacobian
!     real(db), dimension(:,:), allocatable :: gradient_u
!     real(db), dimension(:), allocatable :: u
!     real(db) :: l2_norm,h1_semi_norm,dg_norm,full_dispenal,h2_norm,hessian_norm
!     real(db), dimension(:), allocatable :: quad_weights_face,face_jacobian, &
!          dispenal
!     real(db), dimension(:,:), allocatable :: global_points_face,face_normals,hessian_uh
!     integer, dimension(:,:), allocatable :: global_dof_numbers1,global_dof_numbers2, &
!          global_dof_numbers
!     integer, dimension(2) :: neighbors,loc_face_no
!     integer, dimension(:), allocatable :: no_dofs_per_variable1, &
!          no_dofs_per_variable2,no_dofs_per_variable
!     real(db), dimension(:,:,:),allocatable :: hessian_u
  
!     dim_soln_coeff = get_dim_soln_coeff(soln_data)
!     no_pdes = get_no_pdes(soln_data)
  
!     call get_mesh_info(no_eles,no_nodes,no_faces,problem_dim, &
!          mesh_data)
  
!     npinc = 4
!     call compute_max_no_quad_points(no_quad_points_volume_max, &
!            no_quad_points_face_max,mesh_data,soln_data,npinc)
  
!     control_parameter = 'so_deriv_uh_ele'
!     call initialize_fe_basis_storage(fe_basis_info,control_parameter,soln_data, &
!          problem_dim,no_quad_points_volume_max,no_quad_points_face_max)
  
!     allocate(gradient_u(no_pdes,problem_dim))
!     allocate(u(no_pdes))
!     allocate(hessian_uh(problem_dim,problem_dim))
!     allocate(hessian_u(no_pdes,problem_dim,problem_dim))
!     allocate(no_dofs_per_variable(dim_soln_coeff))
!     allocate(global_points_ele(problem_dim,no_quad_points_volume_max))
!     allocate(jacobian(no_quad_points_volume_max))
!     allocate(quad_weights_ele(no_quad_points_volume_max))
!     allocate(global_dof_numbers(dim_soln_coeff,no_ele_dofs_per_var_max))
  
!     errors = 0.0_db
!     l2_norm = 0.0_db
!     h1_semi_norm = 0.0_db
!     h2_norm = 0.0_db
!     dg_norm = 0.0_db
  
!     do k = 1,no_eles
  
!        call element_integration_info(dim_soln_coeff,problem_dim,mesh_data, &
!             soln_data,k,npinc,no_quad_points_volume_max, &
!             no_quad_points,global_points_ele,jacobian,quad_weights_ele, &
!             global_dof_numbers,no_dofs_per_variable,fe_basis_info)
  
!        do qk = 1,no_quad_points
  
!   ! Determine analytical solution
  
!           call anal_soln_transport(u,global_points_ele(:,qk),problem_dim,no_pdes,0,t)
!           call anal_soln_gradient_transport(gradient_u,global_points_ele(:,qk),problem_dim,no_pdes,t)
!           call anal_soln_hessian_transport(hessian_u,global_points_ele(:,qk),problem_dim,no_pdes,t)
  
!           l2_norm = l2_norm + jacobian(qk)*quad_weights_ele(qk) &
!                *dot_product(u-uh_element(fe_basis_info,no_pdes,qk), &
!                u-uh_element(fe_basis_info,no_pdes,qk))
          
!           do iv = 1,no_pdes
!              h1_semi_norm = h1_semi_norm + jacobian(qk)*quad_weights_ele(qk) &
!                  *dot_product(gradient_u(iv,:)- &
!                  grad_uh_element(fe_basis_info,problem_dim,iv,qk,1), &
!                  gradient_u(iv,:)-grad_uh_element(fe_basis_info,problem_dim,iv,qk,1))
  
!              hessian_uh = hessian_uh_element(fe_basis_info,problem_dim,iv,qk,1)
!              hessian_norm = 0.0_db
!              do i = 1,problem_dim
!                 do j = 1,problem_dim
!                    hessian_norm = hessian_norm &
!                      + (hessian_u(iv,i,j)-hessian_uh(i,j))**2
!                 end do
!              end do
  
!              h2_norm = h2_norm + jacobian(qk)*quad_weights_ele(qk)*hessian_norm
  
!          end do
  
!        end do
  
!     end do
  
!     dg_norm = h1_semi_norm
  
!     call delete_fe_basis_storage(fe_basis_info)
  
!     deallocate(gradient_u,no_dofs_per_variable,global_points_ele,jacobian, &
!          quad_weights_ele,global_dof_numbers,hessian_u,hessian_uh)
  
!     control_parameter = 'uh_face'
!     call initialize_fe_basis_storage(fe_basis_info,control_parameter,soln_data, &
!          problem_dim,no_quad_points_volume_max,no_quad_points_face_max)
  
!     allocate(global_points_face(problem_dim,no_quad_points_face_max))
!     allocate(face_jacobian(no_quad_points_face_max))
!     allocate(face_normals(problem_dim,no_quad_points_face_max))
!     allocate(quad_weights_face(no_quad_points_face_max))
!     allocate(no_dofs_per_variable1(dim_soln_coeff))
!     allocate(no_dofs_per_variable2(dim_soln_coeff))
!     allocate(dispenal(dim_soln_coeff))
!     allocate(global_dof_numbers1(dim_soln_coeff,no_ele_dofs_per_var_max))
!     allocate(global_dof_numbers2(dim_soln_coeff,no_ele_dofs_per_var_max))
  
!     do k = 1,no_faces
          
!        call face_integration_info(dim_soln_coeff,problem_dim,mesh_data,soln_data, &
!             k,neighbors,loc_face_no,npinc,no_quad_points_face_max, &
!             no_quad_points,global_points_face,face_jacobian,face_normals, &
!             quad_weights_face,global_dof_numbers1,no_dofs_per_variable1, &
!             bdry_face,global_dof_numbers2,no_dofs_per_variable2, &
!             fe_basis_info)
  
!        call aptofem_dg_penalisation(dispenal,k,neighbors, &
!             mesh_data,soln_data,problem_dim,dim_soln_coeff)
               
!        full_dispenal = interior_penalty_parameter*dispenal(1)
  
!        if (bdry_face > 0) then 
  
!   ! Boundary face
  
!           do qk = 1,no_quad_points
!              call anal_soln_transport(u,global_points_face(:,qk),problem_dim,no_pdes,0,t)
!              dg_norm = dg_norm+full_dispenal*face_jacobian(qk)*quad_weights_face(qk) &
!                   *dot_product(u-uh_face1(fe_basis_info,no_pdes,qk), &
!                   u-uh_face1(fe_basis_info,no_pdes,qk))
!           end do
  
!        else 
  
!   ! Interior face
  
!           do qk = 1,no_quad_points
!              dg_norm = dg_norm+full_dispenal*face_jacobian(qk)*quad_weights_face(qk) &
!                   *dot_product( &
!                   uh_face1(fe_basis_info,no_pdes,qk)-uh_face2(fe_basis_info,no_pdes,qk), &
!                   uh_face1(fe_basis_info,no_pdes,qk)-uh_face2(fe_basis_info,no_pdes,qk))
!           end do
  
!        end if
         
!     end do
    
!     deallocate(global_points_face,face_jacobian,face_normals,quad_weights_face, &
!          no_dofs_per_variable1,no_dofs_per_variable2,dispenal, &
!          global_dof_numbers1,global_dof_numbers2,u)
  
!     call delete_fe_basis_storage(fe_basis_info)
  
!     errors(1) = sqrt(l2_norm)
!     errors(2) = sqrt(h1_semi_norm)
!     errors(3) = sqrt(dg_norm)
!     errors(4) = sqrt(h2_norm)
  
!   end subroutine error_norms_transport

  subroutine error_norms_velocity(errors,mesh_data,soln_data)
    use param
    use fe_mesh
    use fe_solution
    use problem_options
    use basis_fns_storage_type
    use aptofem_fe_matrix_assembly
    use velocity_bc_interface
  
    implicit none
  
    real(db), dimension(5), intent(out) :: errors
    type(mesh), intent(inout) :: mesh_data
    type(solution), intent(inout) :: soln_data
  
  ! Local variables
  
    type(basis_storage) :: fe_basis_info
    character(len=aptofem_length_key_def) :: control_parameter
    integer :: no_eles,no_nodes,no_faces,problem_dim,no_pdes, &
         k,qk,iv,no_quad_points,npinc, &
         no_quad_points_volume_max,no_quad_points_face_max, &
         bdry_face,dim_soln_coeff,iv2,element_region_id
    real(db), dimension(:,:), allocatable :: global_points_ele
    real(db), dimension(:), allocatable :: quad_weights_ele,jacobian
    real(db), dimension(:,:), allocatable :: gradient_u,uh1,uh2
    real(db), dimension(:), allocatable :: u,uh,grad_uh
    real(db) :: l2_norm,h1_semi_norm,dg_norm,full_dispenal,div_uh,grad_e
    real(db), dimension(:), allocatable :: quad_weights_face,face_jacobian, &
         dispenal
    real(db), dimension(:,:), allocatable :: global_points_face,face_normals
    integer, dimension(:,:), allocatable :: global_dof_numbers1,global_dof_numbers2, &
         global_dof_numbers
    integer, dimension(2) :: neighbors,loc_face_no
    integer, dimension(:), allocatable :: no_dofs_per_variable1, &
         no_dofs_per_variable2,no_dofs_per_variable
  
    dim_soln_coeff = get_dim_soln_coeff(soln_data)
    no_pdes = get_no_pdes(soln_data)
  
    call get_mesh_info(no_eles,no_nodes,no_faces,problem_dim, &
         mesh_data)
  
    npinc = 3
    call compute_max_no_quad_points(no_quad_points_volume_max, &
           no_quad_points_face_max,mesh_data,soln_data,npinc)
  
    control_parameter = 'fo_deriv_uh_ele'
    call initialize_fe_basis_storage(fe_basis_info,control_parameter,soln_data, &
         problem_dim,no_quad_points_volume_max,no_quad_points_face_max)
  
    allocate(gradient_u(no_pdes,problem_dim))
    allocate(grad_uh(problem_dim))
    allocate(u(no_pdes))
    allocate(uh(no_pdes))
    allocate(no_dofs_per_variable(dim_soln_coeff))
    allocate(global_points_ele(problem_dim,no_quad_points_volume_max))
    allocate(jacobian(no_quad_points_volume_max))
    allocate(quad_weights_ele(no_quad_points_volume_max))
    allocate(global_dof_numbers(dim_soln_coeff,no_ele_dofs_per_var_max))
  
    errors = 0.0_db
  
    do k = 1,no_eles
  
       call element_integration_info(dim_soln_coeff,problem_dim,mesh_data, &
            soln_data,k,npinc,no_quad_points_volume_max, &
            no_quad_points,global_points_ele,jacobian,quad_weights_ele, &
            global_dof_numbers,no_dofs_per_variable,fe_basis_info)

       element_region_id = get_element_region_id(mesh_data, k)
  
       do qk = 1,no_quad_points
  
  ! Determine analytical solution
  
          call anal_soln_velocity(u,global_points_ele(:,qk),problem_dim,no_pdes,0,0.0_db,element_region_id)
          call anal_soln_velocity_1(gradient_u,global_points_ele(:,qk),problem_dim,no_pdes,0.0_db,element_region_id)
  
          uh = uh_element(fe_basis_info,no_pdes,qk)
          errors(1) = errors(1) + jacobian(qk)*quad_weights_ele(qk) &
               *dot_product(u(1:problem_dim)-uh(1:problem_dim), &
               u(1:problem_dim)-uh(1:problem_dim))
  
          errors(2) = errors(2) + jacobian(qk)*quad_weights_ele(qk) &
               *(u(problem_dim+1)-uh(problem_dim+1))**2
  
          errors(3) = errors(3) + jacobian(qk)*quad_weights_ele(qk) &
               *dot_product(u(1:problem_dim+1)-uh(1:problem_dim+1), &
               u(1:problem_dim+1)-uh(1:problem_dim+1))
  
          div_uh = 0.0_db
          grad_e = 0.0_db
          do iv = 1,problem_dim
             grad_uh = grad_uh_element(fe_basis_info,problem_dim,iv,qk,1)
             div_uh = div_uh+grad_uh(iv)
             do iv2 = 1,problem_dim
                grad_e = grad_e+(gradient_u(iv,iv2)-grad_uh(iv2))**2
             end do
          end do
  
          errors(4) = errors(4) + jacobian(qk)*quad_weights_ele(qk) &
               *(grad_e+(u(problem_dim+1)-uh(problem_dim+1))**2)
  
          errors(5) = errors(5) + jacobian(qk)*quad_weights_ele(qk)*div_uh**2
  
       end do
  
    end do
  
    call delete_fe_basis_storage(fe_basis_info)
  
    deallocate(gradient_u,no_dofs_per_variable,global_points_ele,jacobian, &
         quad_weights_ele,global_dof_numbers,grad_uh)
  
    control_parameter = 'uh_face'
    call initialize_fe_basis_storage(fe_basis_info,control_parameter,soln_data, &
         problem_dim,no_quad_points_volume_max,no_quad_points_face_max)
  
    allocate(global_points_face(problem_dim,no_quad_points_face_max))
    allocate(face_jacobian(no_quad_points_face_max))
    allocate(face_normals(problem_dim,no_quad_points_face_max))
    allocate(quad_weights_face(no_quad_points_face_max))
    allocate(no_dofs_per_variable1(dim_soln_coeff))
    allocate(no_dofs_per_variable2(dim_soln_coeff))
    allocate(dispenal(dim_soln_coeff))
    allocate(global_dof_numbers1(dim_soln_coeff,no_ele_dofs_per_var_max))
    allocate(global_dof_numbers2(dim_soln_coeff,no_ele_dofs_per_var_max))
    allocate(uh1(no_pdes,no_quad_points_face_max))
    allocate(uh2(no_pdes,no_quad_points_face_max))
  
    do k = 1,no_faces
  
       call face_integration_info(dim_soln_coeff,problem_dim,mesh_data,soln_data, &
            k,neighbors,loc_face_no,npinc,no_quad_points_face_max, &
            no_quad_points,global_points_face,face_jacobian,face_normals, &
            quad_weights_face,global_dof_numbers1,no_dofs_per_variable1, &
            bdry_face,global_dof_numbers2,no_dofs_per_variable2, &
            fe_basis_info)
  
       call aptofem_dg_penalisation(dispenal,k,neighbors, &
            mesh_data,soln_data,problem_dim,dim_soln_coeff)

       element_region_id = get_element_region_id(mesh_data, neighbors(1))
               
       full_dispenal = interior_penalty_parameter*dispenal(1)
       
       if (bdry_face > 0) then
          
          do qk = 1,no_quad_points
             call anal_soln_velocity(uh2(:,qk),global_points_face(:,qk),problem_dim,no_pdes,0,0.0_db,element_region_id)
          end do
          
       else
          
          do qk = 1,no_quad_points
             uh2(:,qk) = uh_face2(fe_basis_info,no_pdes,qk)
          end do
          
       end if
  
       do qk = 1,no_quad_points
          
          uh1(:,qk) = uh_face1(fe_basis_info,no_pdes,qk)
  
          errors(4) = errors(4) &
               +dot_product(uh1(1:problem_dim,qk)-uh2(1:problem_dim,qk), &
               uh1(1:problem_dim,qk)-uh2(1:problem_dim,qk)) &
               *quad_weights_face(qk)*face_jacobian(qk)*full_dispenal
          
       end do
       
    end do
  
    deallocate(global_points_face,face_jacobian,face_normals,quad_weights_face, &
         no_dofs_per_variable1,no_dofs_per_variable2,dispenal, &
         global_dof_numbers1,global_dof_numbers2,u,uh,uh1,uh2)
  
    call delete_fe_basis_storage(fe_basis_info)
  
    errors = sqrt(errors)
    
  end subroutine error_norms_velocity
end module