#include $(AptoFEM_DIR)/source/package_defaults/makefile.flags
#include $(AptoFEM_DIR)/source/package_defaults/makefile_openmp.flags
#include $(AptoFEM_DIR)/source/package_defaults/makefile_mpi.flags
include $(AptoFEM_DIR)/source/package_defaults/makefile.flags

velocity_assembly  =  ../../matrix_rhs/jacobi_residual_nsb.f90 ../../matrix_rhs/jacobi_residual_nsb-ss.f90 ../../matrix_rhs/jacobi_residual_ns_nsb-ss.f90 ../../matrix_rhs/jacobi_residual_ns-b-ss.f90 ../../matrix_rhs/matrix_rhs_s-b-ss.f90 
transport_assembly = ../../matrix_rhs/matrix_rhs_transport.f90 ../../matrix_rhs/matrix_rhs_transport-ss.f90

storage         = ./common/solution-storage_velocity.f90
fluxes          = ./common/crossflow_flux.f90 ./common/outflow_flux.f90 ./common/outflow_transport_flux.f90
problem_options = ./common/problem-options.f90 ./common/problem-options_velocity.f90 ./common/problem-options_transport.f90
miscellaneous   = ./common/refine_region.f90 ./common/integrate_transport-reaction.f90

placentone_bcs    = ./common/bcs_transport.f90 ./common/2d-bcs_velocity_placentone.f90
placenta_bcs      = ./common/bcs_transport.f90 ./common/2d-bcs_velocity_placenta.f90
placentone_3d_bcs = ./common/bcs_transport.f90 ./common/3d-bcs_velocity_placentone.f90

.PHONY: all cleanall

all:: nsb-transport_placentone nsb-transport_placenta s-b-transport_placentone s-b-transport_placenta ns-b-transport_placentone ns-b-transport_placenta ns-nsb-transport_placentone ns-nsb-transport_placenta nsb-transport_placentone-3d ns-b-transport_placentone-3d s-b-transport_placentone-3d velocity-comparison_placentone velocity-comparison_placenta
comparison :: velocity-comparison_placentone velocity-comparison_placenta

nsb-transport_placentone ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	 ./common/velocity_assembly-name_nsb.f90 ./common/program-name_placentone.f90 $(storage) $(fluxes) $(problem_options) $(placentone_bcs) $(velocity_assembly) $(transport_assembly) $(miscellaneous) ./common/velocity_transport.f90 $(AptoFEM) -lpthread -L/home/pmyambl/AptoFEM-Helios-20230815/aptofem/dependencies/petsc/arch-linux-c-opt/externalpackages/git.parmetis/libparmetis/ -lparmetis)

nsb-transport_placenta ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	 ./common/velocity_assembly-name_nsb.f90 ./common/program-name_placenta.f90 $(storage) $(fluxes) $(problem_options) $(placenta_bcs) $(velocity_assembly) $(transport_assembly) $(miscellaneous) ./common/velocity_transport.f90 $(AptoFEM) -lpthread)

nsb-transport_placentone-3d ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	 ./common/velocity_assembly-name_nsb.f90 ./common/program-name_placentone-3d.f90 $(storage) $(fluxes) $(problem_options) $(placentone_3d_bcs) $(velocity_assembly) $(transport_assembly) $(miscellaneous) ./common/velocity_transport.f90 $(AptoFEM) -lpthread -L/home/pmyambl/AptoFEM-Helios-20230815/aptofem/dependencies/petsc/arch-linux-c-opt/externalpackages/git.parmetis/libparmetis/ -lparmetis)

ns-b-transport_placentone ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	 ./common/velocity_assembly-name_ns-b.f90 ./common/program-name_placentone.f90 $(storage) $(fluxes) $(problem_options) $(placentone_bcs) $(velocity_assembly) $(transport_assembly) $(miscellaneous) ./common/velocity_transport.f90 $(AptoFEM) -lpthread)

ns-b-transport_placenta ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	 ./common/velocity_assembly-name_ns-b.f90 ./common/program-name_placenta.f90 $(storage) $(fluxes) $(problem_options) $(placenta_bcs) $(velocity_assembly) $(transport_assembly) $(miscellaneous) ./common/velocity_transport.f90 $(AptoFEM) -lpthread)

ns-b-transport_placentone-3d ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	 ./common/velocity_assembly-name_ns-b.f90 ./common/program-name_placentone-3d.f90 $(storage) $(fluxes) $(problem_options) $(placentone_3d_bcs) $(velocity_assembly) $(transport_assembly) $(miscellaneous) ./common/velocity_transport.f90 $(AptoFEM) -lpthread)

ns-nsb-transport_placentone ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	 ./common/velocity_assembly-name_ns-nsb.f90 ./common/program-name_placentone.f90 $(storage) $(fluxes) $(problem_options) $(placentone_bcs) $(velocity_assembly) $(transport_assembly) $(miscellaneous) ./common/velocity_transport.f90 $(AptoFEM) -lpthread)

ns-nsb-transport_placenta ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	 ./common/velocity_assembly-name_ns-nsb.f90 ./common/program-name_placenta.f90 $(storage) $(fluxes) $(problem_options) $(placenta_bcs) $(velocity_assembly) $(transport_assembly) $(miscellaneous) ./common/velocity_transport.f90 $(AptoFEM) -lpthread)

ns-nsb-transport_placentone-3d ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	 ./common/velocity_assembly-name_ns-nsb.f90 ./common/program-name_placentone-3d.f90 $(storage) $(fluxes) $(problem_options) $(placentone_3d_bcs) $(velocity_assembly) $(transport_assembly) $(miscellaneous) ./common/velocity_transport.f90 $(AptoFEM) -lpthread)

s-b-transport_placentone ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	 ./common/velocity_assembly-name_s-b.f90 ./common/program-name_placentone.f90 $(storage) $(fluxes) $(problem_options) $(placentone_bcs) $(velocity_assembly) $(transport_assembly) $(miscellaneous) ./common/velocity_transport.f90 $(AptoFEM) -lpthread)

s-b-transport_placenta ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	 ./common/velocity_assembly-name_s-b.f90 ./common/program-name_placenta.f90 $(storage) $(fluxes) $(problem_options) $(placenta_bcs) $(velocity_assembly) $(transport_assembly) $(miscellaneous) ./common/velocity_transport.f90 $(AptoFEM) -lpthread)

s-b-transport_placentone-3d ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	 ./common/velocity_assembly-name_s-b.f90 ./common/program-name_placentone-3d.f90 $(storage) $(fluxes) $(problem_options) $(placentone_3d_bcs) $(velocity_assembly) $(transport_assembly) $(miscellaneous) ./common/velocity_transport.f90 $(AptoFEM) -lpthread)

velocity-comparison_placentone ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
		./common/program-name_placentone.f90 ./common/problem-options.f90 ./common/problem-options_velocity.f90 $(placentone_bcs) $(velocity_assembly) ./comparison/velocity-comparison.f90 $(AptoFEM) -lpthread)

velocity-comparison_placenta ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
		./common/program-name_placenta.f90 ./common/problem-options.f90 ./common/problem-options_velocity.f90 $(placenta_bcs) $(velocity_assembly) ./comparison/velocity-comparison.f90 $(AptoFEM) -lpthread)

cleanall ::
	(rm -f *.o)
	(rm -f *~)
	(rm -f *.mod)
	(rm -f *.out)
