module assembly_name_module
  implicit none

  contains

  subroutine get_assembly_name(name)
    character(len=20), intent(out) :: name

    name = "s-b"

    print *, "Selecting velocity model: ", name
  end subroutine
end module