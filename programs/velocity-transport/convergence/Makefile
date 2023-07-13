#include $(AptoFEM_DIR)/source/package_defaults/makefile.flags
include $(AptoFEM_DIR)/source/package_defaults/makefile_openmp.flags
#include $(AptoFEM_DIR)/source/package_defaults/makefile_mpi.flags

mainsources =  

.PHONY: all cleanall

all:: nsku-transport_convergence

nsku-transport_convergence ::
	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
	solution-storage_nsku.f90 problem-options.f90 problem-options_nsku.f90 problem-options_transport.f90 2d-bcs_transport.f90 2d-bcs_nsku_placentone.f90 errors.f90 ../../matrix_rhs/jacobi_residual_navier-stokes-ku.f90 ../../matrix_rhs/jacobi_residual_navier-stokes-ku-ss.f90 ../../matrix_rhs/matrix_rhs_transport.f90 ../../matrix_rhs/matrix_rhs_transport-ss.f90 nsku_transport_convergence.f90 $(AptoFEM) -lpthread -fcheck=bounds)

cleanall ::
	(rm -f *.o)
	(rm -f *~)
	(rm -f *.mod)
	(rm -f *.out)
