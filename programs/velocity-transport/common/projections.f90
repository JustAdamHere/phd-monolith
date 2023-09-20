module projections
  
  abstract interface 
    subroutine anal_soln_arg_region_id(fun_value,global_point,problem_dim,no_pde_variables, &
      boundary_no,current_time,element_region_id)
      use param
      
      integer, intent(in) :: problem_dim 
      !< Problem dimension
      integer, intent(in) :: no_pde_variables 
      !< Number of variables in PDE system
      real(db), dimension(no_pde_variables), intent(out) :: fun_value 
      !< Value of vector-valued function at the point of interest
      real(db), dimension(problem_dim), intent(in) :: global_point
      !< Point of evaluation.
      integer, intent(in) :: boundary_no
      !< Boundary identification number if called to set up
      !< Dirichlet boundary conditions, zero otherwise.
      real(db), intent(in) :: current_time
      !< Denotes the current time. This is only used for time 
      !< dependent problems. If absent, then the solution/
      !< Dirichlet boundary conditions should be evaluated at 
      !< time t=0.
      integer, intent(in) :: element_region_id
      !< Denotes the region id of the element.
      
    end subroutine anal_soln_arg_region_id
  end interface
  
  contains
  
  ! --------------------------------------------------------------------
  !> This routine computes the elementwise L2 projection of a given 
  !! function onto the finite element space. 
  !!
  !! Author: 
  !!   Paul Houston
  !! Modified by:
  !!   Adam Blakey
  !!
  !! Date Created:
  !!   09-11-2010
  ! --------------------------------------------------------------------
  ! subroutine project_function_region_id(fe_solution,mesh_data, &
  !   soln_data,no_pde_variables,specific_function_ptr)
  subroutine project_function_region_id(soln_data,mesh_data,specific_function_ptr)
    !--------------------------------------------------------------------
    use param
    use fe_mesh
    use base_solution_type
    use dg_fe_solution
    
    implicit none
    
    type(mesh), intent(inout) :: mesh_data !< Finite element mesh
    type(solution), intent(inout) :: soln_data !< Finite element solution
    
    procedure(anal_soln_arg_region_id) :: specific_function_ptr
    !< Pointer to
    !< an external (vector-valued) function to be projected
    !< This should have the following header.
    !<  
    !<  subroutine specific_function(fun_value,global_point,problem_dim, &
    !<      no_pde_variables,boundary_no,current_time)
    !<    
    !<  use param
    !<
    !<  integer, intent(in) :: problem_dim --- Problem dimension
    !<
    !<     integer, intent(in) :: no_pde_variables --- Number of variables in PDE system
    !<
    !<     real(db), dimension(no_pde_variables), intent(out) :: fun_value --- Value of
    !<     vector-valued function at the point of interest
    !<
    !<    real(db), dimension(problem_dim), intent(in) :: global_point 
    !<    --- Point of evaluation.
    !<
    !<  integer, intent(in) :: boundary_no
    !<    --- Boundary identification number. This is only used 
    !<        if called to set up
    !<        Dirichlet boundary conditions, zero otherwise.
    !<
    !<  real(db), intent(in) :: current_time
    !<    --- Denotes the current time. This is only used for time 
    !<        dependent problems. If absent, then the solution/
    !<        Dirichlet boundary conditions should be evaluated at 
    !<        time t=0.
    !<
    !<  real(db), intent(in) :: element_region_id
    !<    --- Denotes the region id of the element.
    !<
    !<  end subroutine specific_function    
    
    integer :: no_pde_variables !< Total number of variables in the underlying
    !< system of PDEs (includes all FE spaces)
    
    ! Local variables
    
    integer :: no_eles,no_nodes,no_faces,problem_dim,k, &
    no_quad_points_volume_max,no_quad_points_face_max, &
    npinc,dim_soln_coeff_fe_space,no_quad_points,qk, &
    iv_global,i,j,iv,dim_basis_fn_fe_space,space_no,element_region_id
    real(db), dimension(:,:), allocatable :: gauss_points_global,gauss_points_local
    real(db), dimension(:), allocatable :: jacobian,quad_weights
    integer, dimension(:), allocatable :: no_dofs_per_variable
    real(db), dimension(:,:,:,:), allocatable :: basis_fns
    real(db), dimension(:,:), allocatable :: amat
    real(db), dimension(:), allocatable :: rhs
    real(db), dimension(:,:), allocatable :: soln_values
    real(db), dimension(:,:), allocatable :: fun_value
    real(db), dimension(:), allocatable :: integralweighting
    integer, dimension(:,:), allocatable :: global_dof_numbers
    real(db), dimension(:,:,:), allocatable :: jacobi_mat

    call set_solution_vector_scalar(0.0_db,soln_data)

    do space_no = 1,soln_data%no_fem_spaces
      no_pde_variables = soln_data%no_pde_variables

      call get_mesh_info(no_eles,no_nodes,no_faces,problem_dim, &
      mesh_data)
      
      dim_soln_coeff_fe_space = soln_data%fem_spaces(space_no)%fem%dim_soln_coeff_fe_space
      dim_basis_fn_fe_space = soln_data%fem_spaces(space_no)%fem%dim_basis_fn_fe_space
      
      npinc = 2
      call soln_data%fem_spaces(space_no)%fem%compute_max_no_quad_points_fe_space( &
      mesh_data,no_quad_points_volume_max,no_quad_points_face_max,npinc)
      
      !$OMP PARALLEL &
      !$OMP DEFAULT(SHARED), &
      !$OMP PRIVATE(gauss_points_global,gauss_points_local, &
      !$OMP  jacobi_mat,jacobian,quad_weights,no_dofs_per_variable, &
      !$OMP  basis_fns,soln_values,fun_value,integralweighting, &
      !$OMP  global_dof_numbers,k,no_quad_points,qk,iv,iv_global, &
      !$OMP  amat,rhs,i,j)
      
      allocate(gauss_points_global(problem_dim,no_quad_points_volume_max))
      allocate(gauss_points_local(problem_dim,no_quad_points_volume_max))
      allocate(jacobi_mat(problem_dim,problem_dim,no_quad_points_volume_max))
      allocate(jacobian(no_quad_points_volume_max))
      allocate(quad_weights(no_quad_points_volume_max))
      allocate(no_dofs_per_variable(dim_soln_coeff_fe_space))
      allocate(basis_fns(dim_soln_coeff_fe_space,no_quad_points_volume_max, &
      no_ele_dofs_per_var_max,dim_basis_fn_fe_space))
      allocate(soln_values(dim_soln_coeff_fe_space,no_ele_dofs_per_var_max))
      allocate(fun_value(no_pde_variables,no_quad_points_volume_max))
      allocate(integralweighting(no_quad_points_volume_max))
      allocate(global_dof_numbers(dim_soln_coeff_fe_space,no_ele_dofs_per_var_max))
      allocate(amat(no_ele_dofs_per_var_max,no_ele_dofs_per_var_max))
      allocate(rhs(no_ele_dofs_per_var_max))
      
      ! Loop over the elements
      
      !$OMP DO SCHEDULE(DYNAMIC)
      
      do k = 1,no_eles
        
        if (soln_data%fem_spaces(space_no)%fem%active_elements(k)) then

          element_region_id = get_element_region_id(mesh_data,k)
          
          ! Compute quadrature, basis fns, and
          ! the Jacobian of the element transformation
          
          no_quad_points = compute_no_quad_points_mesh_element(mesh_data, &
          k,dim_soln_coeff_fe_space,problem_dim, &
          soln_data%fem_spaces(space_no)%fem%poly_vec(:,:,k),npinc)
          
          call get_element_transform_quad_pts(mesh_data,k, &
          problem_dim,gauss_points_local(:,1:no_quad_points), &
          gauss_points_global(:,1:no_quad_points),quad_weights(1:no_quad_points), &
          no_quad_points,jacobi_mat(:,:,1:no_quad_points),jacobian(1:no_quad_points))
          
          do qk = 1,no_quad_points
            integralweighting(qk) = quad_weights(qk)*jacobian(qk)
            
            call specific_function_ptr(fun_value(1:no_pde_variables,qk), &
            gauss_points_global(1:problem_dim,qk),problem_dim,no_pde_variables,0, &
            soln_data%current_time,element_region_id)
            
          end do
          
          do iv = 1,dim_soln_coeff_fe_space
            
            call soln_data%fem_spaces(space_no)%fem%polynomial_spaces(k)% &
            element_fe_space%get_basis_stored_quad_pts(problem_dim,no_quad_points, &
            gauss_points_local(:,1:no_quad_points), &
            gauss_points_global(:,1:no_quad_points), &
            soln_data%fem_spaces(space_no)%fem%poly_vec(iv,:,k), &
            no_dofs_per_variable(iv),dim_basis_fn_fe_space, &
            basis_fns(iv,1:no_quad_points,:,:))
            
          end do
          
          call soln_data%fem_spaces(space_no)%fem%get_ele_dof_nos_fe_space(mesh_data, &
          global_dof_numbers,no_dofs_per_variable, &
          k,dim_soln_coeff_fe_space)
          
          ! Loop over number of variables for a vector function
          
          iv_global = soln_data%fem_spaces(space_no)%fem%no_pde_variables_start_end(1)
          do iv = 1,dim_soln_coeff_fe_space
            !
            ! Assemble Matrix and right hand side
            !
            amat = 0.0_db
            rhs = 0.0_db
            
            ! Loop over quadrature points
            
            do qk = 1,no_quad_points
              
              do i = 1,no_dofs_per_variable(iv)
                do j = 1,no_dofs_per_variable(iv)
                  
                  amat(i,j) = amat(i,j)+integralweighting(qk) &
                  *basis_fns(iv,qk,j,1)*basis_fns(iv,qk,i,1)
                  
                end do
                
                rhs(i) = rhs(i)+integralweighting(qk) &
                *fun_value(iv_global,qk)*basis_fns(iv,qk,i,1)
                
              end do
            end do
            
            soln_values(iv,1:no_dofs_per_variable(iv)) &
            = solve_ax_eq_b( &
            amat(1:no_dofs_per_variable(iv),1:no_dofs_per_variable(iv)), &
            rhs(1:no_dofs_per_variable(iv)),no_dofs_per_variable(iv))
            
            iv_global = iv_global+1
            
          end do
          
          do iv = 1,dim_soln_coeff_fe_space
            do i = 1,no_dofs_per_variable(iv)
              call set_solution(soln_values(iv,i),soln_data,global_dof_numbers(iv,i))
            end do
          end do
          
        end if
        
      end do
      
      !$OMP END DO
      
      deallocate(gauss_points_global,gauss_points_local,jacobian,quad_weights, &
      no_dofs_per_variable,basis_fns,soln_values,fun_value,integralweighting, &
      global_dof_numbers,jacobi_mat,amat,rhs)
      
      !$OMP END PARALLEL
    end do
    
  end subroutine project_function_region_id
end module