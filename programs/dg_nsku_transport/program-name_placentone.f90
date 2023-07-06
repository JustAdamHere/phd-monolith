module program_name_module
  implicit none

  contains

  subroutine program_name(name)
    character(len=20), intent(out) :: name

    name = "placentone"
  end subroutine
end module