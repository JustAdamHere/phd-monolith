#include $(AptoFEM_DIR)/source/package_defaults/makefile.flags
include $(AptoFEM_DIR)/source/package_defaults/makefile_openmp.flags
#include $(AptoFEM_DIR)/source/package_defaults/makefile_mpi.flags

assembly =  ../../matrix_rhs/jacobi_residual_nsb.f90 ../../matrix_rhs/jacobi_residual_nsb-ss.f90 ../../matrix_rhs/matrix_rhs_s-b-ss.f90 ../../matrix_rhs/matrix_rhs_transport.f90 ../../matrix_rhs/matrix_rhs_transport-ss.f90


storage         = ./common/solution-storage_velocity.f90
fluxes          = ./common/crossflow_flux.f90 ./common/outflow_flux.f90 ./common/outflow_transport_flux.f90
problem_options = ./common/problem-options.f90 ./common/problem-options_velocity.f90 ./common/problem-options_transport.f90
miscellaneous   = ./common/refine_region.f90 ./common/integrate_transport-reaction.f90
driver          = ./common/velocity_transport.f90

placentone_bcs = ./common/2d-bcs_transport.f90 ./common/2d-bcs_velocity_placentone.f90
placenta_bcs   = ./common/2d-bcs_transport.f90 ./common/2d-bcs_velocity_placenta.f90

.PHONY: all cleanall

all:: nsb-transport_placentone nsb-transport_placenta s-b-transport_placentone s-b-transport_placenta

nsb-transport_placentone ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	 ./common/assembly-name_nsb.f90 ./common/program-name_placentone.f90 $(storage) $(fluxes) $(problem_options) $(placentone_bcs) $(assembly) $(miscellaneous) $(driver) $(AptoFEM) -lpthread)

nsb-transport_placenta ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	 ./common/assembly-name_nsb.f90 ./common/program-name_placenta.f90 $(storage) $(fluxes) $(problem_options) $(placenta_bcs) $(assembly) $(miscellaneous) $(driver) $(AptoFEM) -lpthread)

s-b-transport_placentone ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	 ./common/assembly-name_s-b.f90 ./common/program-name_placentone.f90 $(storage) $(fluxes) $(problem_options) $(placentone_bcs) $(assembly) $(miscellaneous) $(driver) $(AptoFEM) -lpthread)

s-b-transport_placenta ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	 ./common/assembly-name_s-b.f90 ./common/program-name_placenta.f90 $(storage) $(fluxes) $(problem_options) $(placenta_bcs) $(assembly) $(miscellaneous) $(driver) $(AptoFEM) -lpthread)

cleanall ::
	(rm -f *.o)
	(rm -f *~)
	(rm -f *.mod)
	(rm -f *.out)
