module program_name_module
  use aptofem_kernel
  
  implicit none

  contains

  subroutine program_name(name, print_choice)
    character(len=20), intent(out) :: name
    logical, optional, intent(in)  :: print_choice

    name = "placentone-3d"

    if (present(print_choice)) then
      if (print_choice) then
        call write_message(io_msg, "Selecting geometry: " // name)
      end if
    end if
  end subroutine
end module