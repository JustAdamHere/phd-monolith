#include $(AptoFEM_DIR)/source/package_defaults/makefile.flags
include $(AptoFEM_DIR)/source/package_defaults/makefile_openmp.flags
#include $(AptoFEM_DIR)/source/package_defaults/makefile_mpi.flags

mainsources =  ../../matrix_rhs/jacobi_residual_navier-stokes-ku.f90 ../../matrix_rhs/jacobi_residual_navier-stokes-ku-ss.f90 ../../matrix_rhs/matrix_rhs_transport.f90 ../../matrix_rhs/matrix_rhs_transport-ss.f90

.PHONY: all cleanall

all:: nsku-transport_placentone nsku-transport_placenta

test ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	program-name_placentone.f90 solution-storage_nsku.f90 crossflow_flux.f90 outflow_flux.f90 outflow_transport_flux.f90 problem-options.f90 problem-options_nsku.f90 problem-options_transport.f90 2d-bcs_transport.f90 2d-bcs_navier-stokes-ku_placentone.f90 $(mainsources) refine_region.f90 test.f90 $(AptoFEM) -lpthread -fcheck=bounds)

nsku-transport_placentone ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	program-name_placentone.f90 solution-storage_nsku.f90 crossflow_flux.f90 outflow_flux.f90 outflow_transport_flux.f90 problem-options.f90 problem-options_nsku.f90 problem-options_transport.f90 2d-bcs_transport.f90 2d-bcs_navier-stokes-ku_placentone.f90 $(mainsources) refine_region.f90 integrate_transport-reaction.f90 nsku_transport.f90 $(AptoFEM) -lpthread)

nsku-transport_placenta ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	program-name_placenta.f90 solution-storage_nsku.f90 crossflow_flux.f90 outflow_flux.f90 outflow_transport_flux.f90 problem-options.f90 problem-options_nsku.f90 problem-options_transport.f90 2d-bcs_transport.f90 2d-bcs_navier-stokes-ku_placenta.f90 $(mainsources) refine_region.f90 integrate_transport-reaction.f90 nsku_transport.f90 $(AptoFEM) -lpthread)

cleanall ::
	(rm -f *.o)
	(rm -f *~)
	(rm -f *.mod)
	(rm -f *.out)
