module program_name_module
  implicit none

  contains

  subroutine program_name(name)
    character(len=20), intent(out) :: name

    name = "placenta"
  end subroutine
end module