module assembly_name_module
  use aptofem_kernel

  implicit none

  contains

  subroutine get_assembly_name(name)
    character(len=20), intent(out) :: name

    name = "ns-nsb"

    call write_message(io_msg, "Selecting velocity model: " // name)
  end subroutine
end module