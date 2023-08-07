include $(AptoFEM_DIR)/source/package_defaults/makefile.flags
#include $(AptoFEM_DIR)/source/package_defaults/makefile_openmp.flags
#include $(AptoFEM_DIR)/source/package_defaults/makefile_mpi.flags

.PHONY: all cleanall

all:: evaluate-solution_placentone evaluate-solution_placenta

evaluate-solution_placentone ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	../velocity-transport/common/program-name_placentone.f90 ../velocity-transport/common/problem-options.f90 ../velocity-transport/common/problem-options_velocity.f90 ../velocity-transport/common/refine_region.f90 ../velocity-transport/common/2d-bcs_velocity_placentone.f90 evaluate-solution_bb.f90 $(AptoFEM) -lpthread)

evaluate-solution_placenta ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	../velocity-transport/common/program-name_placenta.f90 ../velocity-transport/common/problem-options.f90 ../velocity-transport/common/problem-options_velocity.f90 ../velocity-transport/common/refine_region.f90 ../velocity-transport/common/2d-bcs_velocity_placenta.f90 evaluate-solution_bb.f90 $(AptoFEM) -lpthread)

cleanall ::
	(rm -f *.o)
	(rm -f *~)
	(rm -f *.mod)
	(rm -f *.out)
