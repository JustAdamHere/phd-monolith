program test
  implicit none

  interface translate
    function translate(global_point, problem_dim, element_region_id)
      implicit none

      integer, parameter :: db = selected_real_kind(15,20)

      real(db), dimension(2)                       :: translate
      integer, intent(in)                          :: problem_dim
      real(db), dimension(problem_dim), intent(in) :: global_point
      integer, intent(in)                          :: element_region_id
    end function
  end interface

  integer, parameter :: db = selected_real_kind(15,20)

  print *, translate([0.18132478468_db, 1.14875481131_db], 2, 411)
  print *, translate([0.2_db, 1.132135_db], 2, 411)
  print *, translate([0.21876710282_db, 1.1156180_db], 2, 411)
  print *, translate([0.148187819837_db, 1.11131230123_db], 2, 411)
  print *, translate([0.185630137976_db, 1.07817550625_db], 2, 411)

end program

function translate(global_point, problem_dim, element_region_id)
  implicit none

  integer, parameter :: db = selected_real_kind(15,20)
  real(db), parameter :: pi             = 3.141592653589793_db

  real(db), dimension(2)                       :: translate
  integer, intent(in)                          :: problem_dim
  real(db), dimension(problem_dim), intent(in) :: global_point
  integer, intent(in)                          :: element_region_id

  character(len=20)       :: name
  real(db)                :: steepness, translate_angle, x_centre, y_centre, placentone_width, wall_width, placenta_width, &
      pipe_width, wall_height, radius
  real(db), dimension(2)  :: translated_point, centre_top

  real(db) :: artery_location

  artery_location = 0.5_db

  name = 'placenta'

  steepness = 0.999_db

  if (trim(name) == 'placenta') then
      placentone_width = 1.0_db                            ! 40 mm
      wall_width       = 0.075_db*placentone_width         ! 3  mm
      placenta_width   = 6*placentone_width + 5*wall_width ! 255mm
      pipe_width       = 0.05_db*placentone_width          ! 2  mm
      wall_height      = 0.6_db*placentone_width           ! 24 mm

      x_centre = placenta_width/2
      y_centre = sqrt(2*x_centre**2)
      radius   = y_centre

      if (300 <= element_region_id .and. element_region_id <= 399) then

      else if (element_region_id == 412 .or. element_region_id == 422 .or. element_region_id == 432 .or. &
               element_region_id == 442 .or. element_region_id == 452 .or. element_region_id == 462) then

      else if (400 <= element_region_id .and. element_region_id <= 499) then
          if (element_region_id == 411) then
              centre_top(1)   = (placentone_width + wall_width)*0 + 0.2*placentone_width
              centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
              translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
          else if (element_region_id == 413) then
              centre_top(1)   = (placentone_width + wall_width)*0 + 0.8*placentone_width
              centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
              translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
          else if (element_region_id == 421) then
              centre_top(1)   = (placentone_width + wall_width)*1 + 0.2*placentone_width
              centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
              translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
          else if (element_region_id == 423) then
              centre_top(1)   = (placentone_width + wall_width)*1 + 0.8*placentone_width
              centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
              translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
          else if (element_region_id == 431) then
              centre_top(1)   = (placentone_width + wall_width)*2 + 0.2*placentone_width
              centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
              translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
          else if (element_region_id == 433) then
              centre_top(1)   = (placentone_width + wall_width)*2 + 0.8*placentone_width
              centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
              translate_angle = -atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
          else if (element_region_id == 441) then
              centre_top(1)   = (placentone_width + wall_width)*3 + 0.2*placentone_width
              centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
              translate_angle =     - atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
          else if (element_region_id == 443) then
              centre_top(1)   = (placentone_width + wall_width)*3 + 0.8*placentone_width
              centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
              translate_angle =     - atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
          else if (element_region_id == 451) then
              centre_top(1)   = (placentone_width + wall_width)*4 + 0.2*placentone_width
              centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
              translate_angle =     - atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
          else if (element_region_id == 453) then
              centre_top(1)   = (placentone_width + wall_width)*4 + 0.8*placentone_width
              centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
              translate_angle =     - atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
          else if (element_region_id == 461) then
              centre_top(1)   = (placentone_width + wall_width)*5 + 0.2*placentone_width
              centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
              translate_angle =     - atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
          else if (element_region_id == 463) then
              centre_top(1)   = (placentone_width + wall_width)*5 + 0.8*placentone_width
              centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
              translate_angle =     - atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
          end if

          !! THIS "WORKS"
          translated_point(1) = (global_point(1) - x_centre)*sin(translate_angle) &
            + (global_point(2) - y_centre)*cos(translate_angle) + artery_location
          translated_point(2) = - (global_point(1) - x_centre)*cos(translate_angle) &
            + (global_point(2) - y_centre)*sin(translate_angle) + y_centre

          ! translated_point(1) = (global_point(1)-centre_top(1))*cos(translate_angle - pi/2) + artery_location
          ! translated_point(2) = (global_point(2)-centre_top(2))*sin(translate_angle - pi/2)

      else if (500 <= element_region_id .and. element_region_id <= 599) then
          if (element_region_id == 501) then
              centre_top(1)   = (placentone_width + wall_width)*0 + 0.5*placentone_width
              centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
              translate_angle = atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
          else if (element_region_id == 502) then
              centre_top(1)   = (placentone_width + wall_width)*1 + 0.5*placentone_width
              centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
              translate_angle = atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
          else if (element_region_id == 503) then
              centre_top(1)   = (placentone_width + wall_width)*2 + 0.5*placentone_width
              centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
              translate_angle = atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
          else if (element_region_id == 504) then
              centre_top(1)   = (placentone_width + wall_width)*3 + 0.5*placentone_width
              centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
              translate_angle = atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
          else if (element_region_id == 505) then
              centre_top(1)   = (placentone_width + wall_width)*4 + 0.5*placentone_width
              centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
              translate_angle = atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
          else if (element_region_id == 506) then
              centre_top(1)   = (placentone_width + wall_width)*5 + 0.5*placentone_width
              centre_top(2)   = y_centre - (radius**2 - (centre_top(1) - x_centre)**2)**0.5
              translate_angle = atan2((centre_top(2)-y_centre), (centre_top(1)-x_centre))
          end if

          translated_point(1) = (global_point(1) - x_centre)*sin(translate_angle - pi/2) &
              + (global_point(2) - y_centre)*cos(translate_angle - pi/2) + artery_location
          translated_point(2) = (global_point(1) - x_centre)*cos(translate_angle - pi/2) &
              - (global_point(2) - y_centre)*sin(translate_angle - pi/2)
      else
          print *, "Error in calculate_nsku_reaction_coefficient. Missed case."
          print *, "element_region_id = ", element_region_id
          stop
      end if
    end if

    translate = translated_point
end function