include $(AptoFEM_DIR)/source/package_defaults/makefile.flags
#include $(AptoFEM_DIR)/source/package_defaults/makefile_openmp.flags
#include $(AptoFEM_DIR)/source/package_defaults/makefile_mpi.flags

.PHONY: all cleanall

all:: evaluate-solution_placentone evaluate-solution_placenta

evaluate-solution_placentone ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	../dg_nsku_transport/program-name_placentone.f90 ../dg_nsku_transport/problem-options.f90 ../dg_nsku_transport/refine_region.f90 ../dg_nsku_transport/2d-bcs_navier-stokes-ku_placentone.f90 evaluate-solution_bb.f90 $(AptoFEM) -lpthread)

evaluate-solution_placenta ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	../dg_nsku_transport/program-name_placenta.f90 ../dg_nsku_transport/problem-options.f90 ../dg_nsku_transport/refine_region.f90 ../dg_nsku_transport/2d-bcs_navier-stokes-ku_placenta.f90 evaluate-solution_bb.f90 $(AptoFEM) -lpthread)

cleanall ::
	(rm -f *.o)
	(rm -f *~)
	(rm -f *.mod)
	(rm -f *.out)
