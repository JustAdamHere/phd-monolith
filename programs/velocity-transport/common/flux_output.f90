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
  'velocity-crossflow-flux_301-302_positive', &
  'velocity-crossflow-flux_302-303_positive', &
  'velocity-crossflow-flux_303-304_positive', &
  'velocity-crossflow-flux_304-305_positive', &
  'velocity-crossflow-flux_305-306_positive', &
  'velocity-crossflow-flux_306-307_positive', &
  'velocity-crossflow-flux_301-302_negative', &
  'velocity-crossflow-flux_302-303_negative', &
  'velocity-crossflow-flux_303-304_negative', &
  'velocity-crossflow-flux_304-305_negative', &
  'velocity-crossflow-flux_305-306_negative', &
  'velocity-crossflow-flux_306-307_negative', &
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
  'velocity-sum-flux', &
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
  'transport-sum-flux', &
  !! TOTAL ENERGY (PRESSURE PART) !!
  ! Inlet fluxes.
  'pe-outflow-flux_111', &
  'pe-outflow-flux_112', &
  'pe-outflow-flux_113', &
  'pe-outflow-flux_114', &
  'pe-outflow-flux_115', &
  'pe-outflow-flux_116', &
  'pe-outflow-flux_117', &
  ! Basal plate outlet fluxes.
  'pe-outflow-flux_211', &
  'pe-outflow-flux_212', &
  'pe-outflow-flux_213', &
  'pe-outflow-flux_214', &
  'pe-outflow-flux_215', &
  'pe-outflow-flux_216', &
  'pe-outflow-flux_217', &
  'pe-outflow-flux_218', &
  'pe-outflow-flux_219', &
  'pe-outflow-flux_220', &
  'pe-outflow-flux_221', &
  'pe-outflow-flux_222', &
  'pe-outflow-flux_223', &
  'pe-outflow-flux_224', &
  ! Marginal sinus outlet fluxes.
  'pe-outflow-flux_230', &
  'pe-outflow-flux_231', &
  ! Septal wall outlet fluxes.
  'pe-outflow-flux_241', &
  'pe-outflow-flux_242', &
  'pe-outflow-flux_243', &
  'pe-outflow-flux_251', &
  'pe-outflow-flux_252', &
  'pe-outflow-flux_253', &
  'pe-outflow-flux_261', &
  'pe-outflow-flux_262', &
  'pe-outflow-flux_263', &
  'pe-outflow-flux_271', &
  'pe-outflow-flux_272', &
  'pe-outflow-flux_273', &
  'pe-outflow-flux_281', &
  'pe-outflow-flux_282', &
  'pe-outflow-flux_283', &
  'pe-outflow-flux_291', &
  'pe-outflow-flux_292', &
  'pe-outflow-flux_293', &
  ! Sum of all fluxes.
  'pe-sum-flux', &
  !! KINETIC ENERGY !!
  ! Inlet fluxes.
  'ke-outflow-flux_111', &
  'ke-outflow-flux_112', &
  'ke-outflow-flux_113', &
  'ke-outflow-flux_114', &
  'ke-outflow-flux_115', &
  'ke-outflow-flux_116', &
  'ke-outflow-flux_117', &
  ! Basal plate outlet fluxes.
  'ke-outflow-flux_211', &
  'ke-outflow-flux_212', &
  'ke-outflow-flux_213', &
  'ke-outflow-flux_214', &
  'ke-outflow-flux_215', &
  'ke-outflow-flux_216', &
  'ke-outflow-flux_217', &
  'ke-outflow-flux_218', &
  'ke-outflow-flux_219', &
  'ke-outflow-flux_220', &
  'ke-outflow-flux_221', &
  'ke-outflow-flux_222', &
  'ke-outflow-flux_223', &
  'ke-outflow-flux_224', &
  ! Marginal sinus outlet fluxes.
  'ke-outflow-flux_230', &
  'ke-outflow-flux_231', &
  ! Septal wall outlet fluxes.
  'ke-outflow-flux_241', &
  'ke-outflow-flux_242', &
  'ke-outflow-flux_243', &
  'ke-outflow-flux_251', &
  'ke-outflow-flux_252', &
  'ke-outflow-flux_253', &
  'ke-outflow-flux_261', &
  'ke-outflow-flux_262', &
  'ke-outflow-flux_263', &
  'ke-outflow-flux_271', &
  'ke-outflow-flux_272', &
  'ke-outflow-flux_273', &
  'ke-outflow-flux_281', &
  'ke-outflow-flux_282', &
  'ke-outflow-flux_283', &
  'ke-outflow-flux_291', &
  'ke-outflow-flux_292', &
  'ke-outflow-flux_293', &
  ! Sum of all fluxes.
  'ke-sum-flux', &
  !! ONE INTEGRAL (SIZES) !!
  ! Inlet fluxes.
  'one-outflow_111', &
  'one-outflow_112', &
  'one-outflow_113', &
  'one-outflow_114', &
  'one-outflow_115', &
  'one-outflow_116', &
  'one-outflow_117', &
  ! Basal plate outlet fluxes.
  'one-outflow_211', &
  'one-outflow_212', &
  'one-outflow_213', &
  'one-outflow_214', &
  'one-outflow_215', &
  'one-outflow_216', &
  'one-outflow_217', &
  'one-outflow_218', &
  'one-outflow_219', &
  'one-outflow_220', &
  'one-outflow_221', &
  'one-outflow_222', &
  'one-outflow_223', &
  'one-outflow_224', &
  ! Marginal sinus outlet fluxes.
  'one-outflow_230', &
  'one-outflow_231', &
  ! Septal wall outlet fluxes.
  'one-outflow_241', &
  'one-outflow_242', &
  'one-outflow_243', &
  'one-outflow_251', &
  'one-outflow_252', &
  'one-outflow_253', &
  'one-outflow_261', &
  'one-outflow_262', &
  'one-outflow_263', &
  'one-outflow_271', &
  'one-outflow_272', &
  'one-outflow_273', &
  'one-outflow_281', &
  'one-outflow_282', &
  'one-outflow_283', &
  'one-outflow_291', &
  'one-outflow_292', &
  'one-outflow_293', &
  ! Sum of all fluxes.
  'one-sum', &
  !! VELOCITY VALUES !!
  ! Inlets.
  'velocity-outflow-value_111', &
  'velocity-outflow-value_112', &
  'velocity-outflow-value_113', &
  'velocity-outflow-value_114', &
  'velocity-outflow-value_115', &
  'velocity-outflow-value_116', &
  'velocity-outflow-value_117', &
  ! Basal plate outlets.
  'velocity-outflow-value_211', &
  'velocity-outflow-value_212', &
  'velocity-outflow-value_213', &
  'velocity-outflow-value_214', &
  'velocity-outflow-value_215', &
  'velocity-outflow-value_216', &
  'velocity-outflow-value_217', &
  'velocity-outflow-value_218', &
  'velocity-outflow-value_219', &
  'velocity-outflow-value_220', &
  'velocity-outflow-value_221', &
  'velocity-outflow-value_222', &
  'velocity-outflow-value_223', &
  'velocity-outflow-value_224', &
  ! Marginal sinus outlets.
  'velocity-outflow-value_230', &
  'velocity-outflow-value_231', &
  ! Septal wall outlets.
  'velocity-outflow-value_241', &
  'velocity-outflow-value_242', &
  'velocity-outflow-value_243', &
  'velocity-outflow-value_251', &
  'velocity-outflow-value_252', &
  'velocity-outflow-value_253', &
  'velocity-outflow-value_261', &
  'velocity-outflow-value_262', &
  'velocity-outflow-value_263', &
  'velocity-outflow-value_271', &
  'velocity-outflow-value_272', &
  'velocity-outflow-value_273', &
  'velocity-outflow-value_281', &
  'velocity-outflow-value_282', &
  'velocity-outflow-value_283', &
  'velocity-outflow-value_291', &
  'velocity-outflow-value_292', &
  'velocity-outflow-value_293', &
  !! TRANSPORT VALUES !!
  ! Inlets.
  'transport-outflow-value_111', &
  'transport-outflow-value_112', &
  'transport-outflow-value_113', &
  'transport-outflow-value_114', &
  'transport-outflow-value_115', &
  'transport-outflow-value_116', &
  'transport-outflow-value_117', &
  ! Basal plate outlets.
  'transport-outflow-value_211', &
  'transport-outflow-value_212', &
  'transport-outflow-value_213', &
  'transport-outflow-value_214', &
  'transport-outflow-value_215', &
  'transport-outflow-value_216', &
  'transport-outflow-value_217', &
  'transport-outflow-value_218', &
  'transport-outflow-value_219', &
  'transport-outflow-value_220', &
  'transport-outflow-value_221', &
  'transport-outflow-value_222', &
  'transport-outflow-value_223', &
  'transport-outflow-value_224', &
  ! Marginal sinus outlets.
  'transport-outflow-value_230', &
  'transport-outflow-value_231', &
  ! Septal wall outlets.
  'transport-outflow-value_241', &
  'transport-outflow-value_242', &
  'transport-outflow-value_243', &
  'transport-outflow-value_251', &
  'transport-outflow-value_252', &
  'transport-outflow-value_253', &
  'transport-outflow-value_261', &
  'transport-outflow-value_262', &
  'transport-outflow-value_263', &
  'transport-outflow-value_271', &
  'transport-outflow-value_272', &
  'transport-outflow-value_273', &
  'transport-outflow-value_281', &
  'transport-outflow-value_282', &
  'transport-outflow-value_283', &
  'transport-outflow-value_291', &
  'transport-outflow-value_292', &
  'transport-outflow-value_293'

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
    calculate_crossflow_flux(mesh_data, solution_velocity, 301, 302, 'positive'), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 302, 303, 'positive'), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 303, 304, 'positive'), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 304, 305, 'positive'), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 305, 306, 'positive'), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 306, 307, 'positive'), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 301, 302, 'negative'), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 302, 303, 'negative'), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 303, 304, 'negative'), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 304, 305, 'negative'), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 305, 306, 'negative'), &
    calculate_crossflow_flux(mesh_data, solution_velocity, 306, 307, 'negative'), &
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
    sum_nonzero_transport_fluxes(), &
    !! TOTAL ENERGY (PRESSURE PART) !!
    ! Inlet fluxes.
    pe_outflow_fluxes(111), &
    pe_outflow_fluxes(112), &
    pe_outflow_fluxes(113), &
    pe_outflow_fluxes(114), &
    pe_outflow_fluxes(115), &
    pe_outflow_fluxes(116), &
    pe_outflow_fluxes(117), &
    ! Basal plate outlet fluxes.
    pe_outflow_fluxes(211), &
    pe_outflow_fluxes(212), &
    pe_outflow_fluxes(213), &
    pe_outflow_fluxes(214), &
    pe_outflow_fluxes(215), &
    pe_outflow_fluxes(216), &
    pe_outflow_fluxes(217), &
    pe_outflow_fluxes(218), &
    pe_outflow_fluxes(219), &
    pe_outflow_fluxes(220), &
    pe_outflow_fluxes(221), &
    pe_outflow_fluxes(222), &
    pe_outflow_fluxes(223), &
    pe_outflow_fluxes(224), &
    ! Marginal sinus outlet fluxes.
    pe_outflow_fluxes(230), &
    pe_outflow_fluxes(231), &
    ! Septal wall outlet fluxes.
    pe_outflow_fluxes(241), &
    pe_outflow_fluxes(242), &
    pe_outflow_fluxes(243), &
    pe_outflow_fluxes(251), &
    pe_outflow_fluxes(252), &
    pe_outflow_fluxes(253), &
    pe_outflow_fluxes(261), &
    pe_outflow_fluxes(262), &
    pe_outflow_fluxes(263), &
    pe_outflow_fluxes(271), &
    pe_outflow_fluxes(272), &
    pe_outflow_fluxes(273), &
    pe_outflow_fluxes(281), &
    pe_outflow_fluxes(282), &
    pe_outflow_fluxes(283), &
    pe_outflow_fluxes(291), &
    pe_outflow_fluxes(292), &
    pe_outflow_fluxes(293), &
    ! Sum of all fluxes.
    sum_nonzero_pe_fluxes(), &
    !! KINETIC ENERGY !!
    ! Inlet fluxes.
    ke_outflow_fluxes(111), &
    ke_outflow_fluxes(112), &
    ke_outflow_fluxes(113), &
    ke_outflow_fluxes(114), &
    ke_outflow_fluxes(115), &
    ke_outflow_fluxes(116), &
    ke_outflow_fluxes(117), &
    ! Basal plate outlet fluxes.
    ke_outflow_fluxes(211), &
    ke_outflow_fluxes(212), &
    ke_outflow_fluxes(213), &
    ke_outflow_fluxes(214), &
    ke_outflow_fluxes(215), &
    ke_outflow_fluxes(216), &
    ke_outflow_fluxes(217), &
    ke_outflow_fluxes(218), &
    ke_outflow_fluxes(219), &
    ke_outflow_fluxes(220), &
    ke_outflow_fluxes(221), &
    ke_outflow_fluxes(222), &
    ke_outflow_fluxes(223), &
    ke_outflow_fluxes(224), &
    ! Marginal sinus outlet fluxes.
    ke_outflow_fluxes(230), &
    ke_outflow_fluxes(231), &
    ! Septal wall outlet fluxes.
    ke_outflow_fluxes(241), &
    ke_outflow_fluxes(242), &
    ke_outflow_fluxes(243), &
    ke_outflow_fluxes(251), &
    ke_outflow_fluxes(252), &
    ke_outflow_fluxes(253), &
    ke_outflow_fluxes(261), &
    ke_outflow_fluxes(262), &
    ke_outflow_fluxes(263), &
    ke_outflow_fluxes(271), &
    ke_outflow_fluxes(272), &
    ke_outflow_fluxes(273), &
    ke_outflow_fluxes(281), &
    ke_outflow_fluxes(282), &
    ke_outflow_fluxes(283), &
    ke_outflow_fluxes(291), &
    ke_outflow_fluxes(292), &
    ke_outflow_fluxes(293), &
    ! Sum of all fluxes.
    sum_nonzero_ke_fluxes(), &
    !! ONE INTEGRAL (SIZES) !!
    ! Inlet fluxes.
    one_integral(111), &
    one_integral(112), &
    one_integral(113), &
    one_integral(114), &
    one_integral(115), &
    one_integral(116), &
    one_integral(117), &
    ! Basal plate outlet fluxes.
    one_integral(211), &
    one_integral(212), &
    one_integral(213), &
    one_integral(214), &
    one_integral(215), &
    one_integral(216), &
    one_integral(217), &
    one_integral(218), &
    one_integral(219), &
    one_integral(220), &
    one_integral(221), &
    one_integral(222), &
    one_integral(223), &
    one_integral(224), &
    ! Marginal sinus outlet fluxes.
    one_integral(230), &
    one_integral(231), &
    ! Septal wall outlet fluxes.
    one_integral(241), &
    one_integral(242), &
    one_integral(243), &
    one_integral(251), &
    one_integral(252), &
    one_integral(253), &
    one_integral(261), &
    one_integral(262), &
    one_integral(263), &
    one_integral(271), &
    one_integral(272), &
    one_integral(273), &
    one_integral(281), &
    one_integral(282), &
    one_integral(283), &
    one_integral(291), &
    one_integral(292), &
    one_integral(293), &
    ! Sum of all fluxes.
    sum_nonzero_one()

    flush(file_no)

  end subroutine

end module