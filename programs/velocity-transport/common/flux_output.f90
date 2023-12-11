module flux_output

  implicit none

  contains

  subroutine write_to_file_headers(file_no, tsvFormat)
  integer, intent(in)            :: file_no
  character(len=100), intent(in) :: tsvFormat

  write(file_no, tsvFormat) &
  'timestep_no', &
  'current_time', &
  !! VELOCITY !!
  ! Crossflow between placentones.
  'velocity-crossflow-flux_301-302', &
  'velocity-crossflow-flux_302-303', &
  'velocity-crossflow-flux_303-304', &
  'velocity-crossflow-flux_304-305', &
  'velocity-crossflow-flux_305-306', &
  'velocity-crossflow-flux_306-307', &
  ! Inlet fluxes.
  'velocity-outflow-flux_111', &
  'velocity-outflow-flux_112', &
  'velocity-outflow-flux_113', &
  'velocity-outflow-flux_114', &
  'velocity-outflow-flux_115', &
  'velocity-outflow-flux_116', &
  'velocity-outflow-flux_117', &
  ! Basal plate outlet fluxes.
  'velocity-outflow-flux_211', &
  'velocity-outflow-flux_212', &
  'velocity-outflow-flux_213', &
  'velocity-outflow-flux_214', &
  'velocity-outflow-flux_215', &
  'velocity-outflow-flux_216', &
  'velocity-outflow-flux_217', &
  'velocity-outflow-flux_218', &
  'velocity-outflow-flux_219', &
  'velocity-outflow-flux_220', &
  'velocity-outflow-flux_221', &
  'velocity-outflow-flux_222', &
  'velocity-outflow-flux_223', &
  'velocity-outflow-flux_224', &
  ! Marginal sinus outlet fluxes.
  'velocity-outflow-flux_230', &
  'velocity-outflow-flux_231', &
  ! Septal wall outlet fluxes.
  'velocity-outflow-flux_241', &
  'velocity-outflow-flux_242', &
  'velocity-outflow-flux_243', &
  'velocity-outflow-flux_251', &
  'velocity-outflow-flux_252', &
  'velocity-outflow-flux_253', &
  'velocity-outflow-flux_261', &
  'velocity-outflow-flux_262', &
  'velocity-outflow-flux_263', &
  'velocity-outflow-flux_271', &
  'velocity-outflow-flux_272', &
  'velocity-outflow-flux_273', &
  'velocity-outflow-flux_281', &
  'velocity-outflow-flux_282', &
  'velocity-outflow-flux_283', &
  'velocity-outflow-flux_291', &
  'velocity-outflow-flux_292', &
  'velocity-outflow-flux_293', &
  ! Sum of all fluxes.
  'velocity_sum-flux', &
  !! TRANSPORT !!
  ! Inlet fluxes.
  'transport-outflow-flux_111', &
  'transport-outflow-flux_112', &
  'transport-outflow-flux_113', &
  'transport-outflow-flux_114', &
  'transport-outflow-flux_115', &
  'transport-outflow-flux_116', &
  'transport-outflow-flux_117', &
  ! Basal plate outlet fluxes.
  'transport-outflow-flux_211', &
  'transport-outflow-flux_212', &
  'transport-outflow-flux_213', &
  'transport-outflow-flux_214', &
  'transport-outflow-flux_215', &
  'transport-outflow-flux_216', &
  'transport-outflow-flux_217', &
  'transport-outflow-flux_218', &
  'transport-outflow-flux_219', &
  'transport-outflow-flux_220', &
  'transport-outflow-flux_221', &
  'transport-outflow-flux_222', &
  'transport-outflow-flux_223', &
  'transport-outflow-flux_224', &
  ! Marginal sinus outlet fluxes.
  'transport-outflow-flux_230', &
  'transport-outflow-flux_231', &
  ! Septal wall outlet fluxes.
  'transport-outflow-flux_241', &
  'transport-outflow-flux_242', &
  'transport-outflow-flux_243', &
  'transport-outflow-flux_251', &
  'transport-outflow-flux_252', &
  'transport-outflow-flux_253', &
  'transport-outflow-flux_261', &
  'transport-outflow-flux_262', &
  'transport-outflow-flux_263', &
  'transport-outflow-flux_271', &
  'transport-outflow-flux_272', &
  'transport-outflow-flux_273', &
  'transport-outflow-flux_281', &
  'transport-outflow-flux_282', &
  'transport-outflow-flux_283', &
  'transport-outflow-flux_291', &
  'transport-outflow-flux_292', &
  'transport-outflow-flux_293', &
  ! Sum of all fluxes.
  'transport_sum-flux'

  flush(file_no)

  end subroutine

  subroutine write_to_file(file_no, tsvFormat, mesh_data, solution_velocity, solution_transport, timestep_no, current_time)
    use param
    use fe_mesh
    use fe_solution
    use crossflow_flux
    use outflow_flux
    use outflow_transport_flux

    integer, intent(in)        :: file_no
    character(len=100)         :: tsvFormat
    type(mesh), intent(inout)  :: mesh_data
    type(solution), intent(in) :: solution_velocity, solution_transport
    integer, intent(in)        :: timestep_no
    real(db), intent(in)       :: current_time

    write(file_no, tsvFormat) &
    timestep_no, &
    current_time, &
    !! VELOCITY !!
    ! Crossflow between placentones.
    calculate_crossflow_flux(mesh_data, solution_velocity, 301, 302), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 302, 303), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 303, 304), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 304, 305), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 305, 306), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 306, 307), &
    ! Inlet fluxes.
    outflow_fluxes(111), &
    outflow_fluxes(112), &
    outflow_fluxes(113), &
    outflow_fluxes(114), &
    outflow_fluxes(115), &
    outflow_fluxes(116), &
    outflow_fluxes(117), &
    ! Basal plate outlet fluxes.
    outflow_fluxes(211), &
    outflow_fluxes(212), &
    outflow_fluxes(213), &
    outflow_fluxes(214), &
    outflow_fluxes(215), &
    outflow_fluxes(216), &
    outflow_fluxes(217), &
    outflow_fluxes(218), &
    outflow_fluxes(219), &
    outflow_fluxes(220), &
    outflow_fluxes(221), &
    outflow_fluxes(222), &
    outflow_fluxes(223), &
    outflow_fluxes(224), &
    ! Marginal sinus outlet fluxes.
    outflow_fluxes(230), &
    outflow_fluxes(231), &
    ! Septal wall outlet fluxes.
    outflow_fluxes(241), &
    outflow_fluxes(242), &
    outflow_fluxes(243), &
    outflow_fluxes(251), &
    outflow_fluxes(252), &
    outflow_fluxes(253), &
    outflow_fluxes(261), &
    outflow_fluxes(262), &
    outflow_fluxes(263), &
    outflow_fluxes(271), &
    outflow_fluxes(272), &
    outflow_fluxes(273), &
    outflow_fluxes(281), &
    outflow_fluxes(282), &
    outflow_fluxes(283), &
    outflow_fluxes(291), &
    outflow_fluxes(292), &
    outflow_fluxes(293), &
    ! Sum of all fluxes.
    sum_nonzero_fluxes(), &
    !! TRANSPORT !!
    ! Inlet fluxes.
    outflow_transport_fluxes(111), &
    outflow_transport_fluxes(112), &
    outflow_transport_fluxes(113), &
    outflow_transport_fluxes(114), &
    outflow_transport_fluxes(115), &
    outflow_transport_fluxes(116), &
    outflow_transport_fluxes(117), &
    ! Basal plate outlet fluxes.
    outflow_transport_fluxes(211), &
    outflow_transport_fluxes(212), &
    outflow_transport_fluxes(213), &
    outflow_transport_fluxes(214), &
    outflow_transport_fluxes(215), &
    outflow_transport_fluxes(216), &
    outflow_transport_fluxes(217), &
    outflow_transport_fluxes(218), &
    outflow_transport_fluxes(219), &
    outflow_transport_fluxes(220), &
    outflow_transport_fluxes(221), &
    outflow_transport_fluxes(222), &
    outflow_transport_fluxes(223), &
    outflow_transport_fluxes(224), &
    ! Marginal sinus outlet fluxes.
    outflow_transport_fluxes(230), &
    outflow_transport_fluxes(231), &
    ! Septal wall outlet fluxes.
    outflow_transport_fluxes(241), &
    outflow_transport_fluxes(242), &
    outflow_transport_fluxes(243), &
    outflow_transport_fluxes(251), &
    outflow_transport_fluxes(252), &
    outflow_transport_fluxes(253), &
    outflow_transport_fluxes(261), &
    outflow_transport_fluxes(262), &
    outflow_transport_fluxes(263), &
    outflow_transport_fluxes(271), &
    outflow_transport_fluxes(272), &
    outflow_transport_fluxes(273), &
    outflow_transport_fluxes(281), &
    outflow_transport_fluxes(282), &
    outflow_transport_fluxes(283), &
    outflow_transport_fluxes(291), &
    outflow_transport_fluxes(292), &
    outflow_transport_fluxes(293), &
    ! Sum of all fluxes.
    sum_nonzero_transport_fluxes()

    flush(file_no)

  end subroutine

end module