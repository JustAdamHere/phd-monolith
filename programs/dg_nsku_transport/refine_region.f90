module refine_region

  contains

  !  --------------------------------------------------------------
  !>  This routine calculates marks all elements in specified regions
  !!   for refinement.
  !!
  !! Author:
  !!  Adam Blakey
  !  --------------------------------------------------------------
  subroutine refine_region_indicator(error_indicator, no_eles, mesh_data, refine_region_id_min, refine_region_id_max)
  !  --------------------------------------------------------------

    use fe_mesh

    implicit none

    type(mesh), intent(inout)                 :: mesh_data
    integer, intent(inout)                    :: no_eles
    integer, dimension(no_eles), intent(out) :: error_indicator
    integer, intent(in)                       :: refine_region_id_min, refine_region_id_max

    integer :: element_region_id, k

    do k = 1, no_eles
      element_region_id = get_element_region_id(mesh_data, k)


      if (refine_region_id_min <= element_region_id .and. element_region_id <= refine_region_id_max) then
        error_indicator(k) = 1000
      else
        error_indicator(k) = 0
      end if
    end do

  end subroutine

end module