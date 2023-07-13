module program_name_module
  implicit none

  contains

  subroutine program_name(name, print_choice)
    character(len=20), intent(out) :: name
    logical, optional, intent(in)  :: print_choice

    name = "placentone"

    if (present(print_choice)) then
      if (print_choice) then
        print *, "Selecting geometry: ", name
      end if
    end if
  end subroutine
end module