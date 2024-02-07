#include $(AptoFEM_DIR)/source/package_defaults/makefile.flags
#include $(AptoFEM_DIR)/source/package_defaults/makefile_openmp.flags
#include $(AptoFEM_DIR)/source/package_defaults/makefile_mpi.flags
include $(AptoFEM_DIR)/source/package_defaults/makefile_mpi.flags

OBJ_DIR=./.obj
MOD_DIR=./.mod
BIN_DIR=./

velocity_assembly  = jacobi_residual_nsb.f90 jacobi_residual_nsb-mm.f90 jacobi_residual_nsb-ss.f90 jacobi_residual_ns_nsb-ss.f90 jacobi_residual_ns-b-ss.f90 matrix_rhs_s-b-ss.f90 
transport_assembly = matrix_rhs_transport.f90 matrix_rhs_transport-ss.f90

storage         = solution-storage_velocity.f90 previous_velocity.f90
fluxes          = crossflow_flux.f90 outflow_flux.f90 outflow_transport_flux.f90 flux_output.f90
problem_options = problem-options.f90 problem-options_geometry.f90 problem-options_velocity.f90 problem-options_transport.f90
miscellaneous   = refine_region.f90 integrate_transport-reaction.f90 integrate_velocity-magnitude.f90 integrate_one.f90 integrate_slow-velocity.f90 integrate_fast-velocity.f90 projections.f90
norms 				  = error_norms.f90

transport_bcs = bcs_transport.f90
#transport_bcs_analytic = 2d-bcs_transport_analytic.f90
transport_bcs_analytic = bcs_transport.f90
velocity_bcs = 2d-bcs_velocity_placenta.f90 2d-bcs_velocity_placentone.f90 3d-bcs_velocity_placentone.f90 2d-bcs_velocity_analytic.f90 2d-bcs_velocity_constant-up.f90 2d-bcs_velocity_constant-diagonal.f90 2d-bcs_velocity_zero.f90 2d-bcs_velocity_poiseuille.f90 2d-bcs_velocity_etienne2009.f90 2d-bcs_velocity_etienne2009_ti.f90 2d-bcs_velocity_shear.f90 velocity_bc_interface.f90

.PHONY: cleanall

MAIN_SOURCES = $(storage) $(fluxes) $(problem_options) $(velocity_bcs) $(transport_bcs) $(velocity_assembly) $(transport_assembly) $(miscellaneous) $(norms) velocity_transport.f90
MAIN_OBJECTS = $(patsubst %.f90,./.obj/%.o,$(MAIN_SOURCES))
CONVERGENCE_SOURCES = $(storage) $(fluxes) $(problem_options) $(velocity_bcs) $(transport_bcs_analytic) $(velocity_assembly) $(transport_assembly) $(miscellaneous) $(norms) velocity-transport_convergence.f90
CONVERGENCE_OBJECTS = $(patsubst %.f90,./.obj/%.o,$(CONVERGENCE_SOURCES))

COMPARISON_SOURCES = $(storage) $(problem_options) $(bcs) $(velocity_assembly) velocity_comparison.f90
COMPARISON_OBJECTS = $(patsubst %.f90,./.obj/%.o,$(COMPARISON_SOURCES))

#FFLAGS = -O3 -fallow-argument-mismatch -cpp -DARPACK -DMETIS_5_64 -DMUMPS -DSPARSKIT -DOPENMP -DLAPACK -fopenmp
FFLAGS = -Og -Wno-argument-mismatch -cpp -DARPACK -DMETIS_5_64 -DMUMPS -DSPARSKIT -DOPENMP -DLAPACK -fopenmp
FFLAGS += -fbounds-check -fbacktrace -ffpe-trap=invalid,zero,overflow -fcheck=bounds,pointer

# $(OBJ_DIR)/%.o: ./common/%.f90 $(MOD_DIR)/%.mod 
# 	@echo "Compiling $@... "
# 	@($(FC) $(FFLAGS) $(MODFLAGS) -J$(MOD_DIR) -c $< -o $@ $(AptoFEM) -lpthread)

# $(OBJ_DIR)/%.o: ../../matrix_rhs/%.f90 $(MOD_DIR)/%.mod 
# 	@echo "Compiling $@... "
# 	@($(FC) $(FFLAGS) $(MODFLAGS) -J$(MOD_DIR) -c $< -o $@ $(AptoFEM) -lpthread)

# $(MOD_DIR)/%.mod: ./common/%.f90
# 	@echo "Compiling $@... "
# 	@($(FC) $(FFLAGS) $(MODFLAGS) -fsyntax-only -J$(MOD_DIR) -c $< -o $@ $(AptoFEM) -lpthread)

# $(MOD_DIR)/%.mod: ../../matrix_rhs/%.f90
# 	@echo "Compiling $@... "
# 	@($(FC) $(FFLAGS) $(MODFLAGS) -fsyntax-only -J$(MOD_DIR) -c $< -o $@ $(AptoFEM) -lpthread)

$(OBJ_DIR)/%.o: ./common/%.f90
	@echo "Compiling $<... "
	@($(FC) $(FFLAGS) $(MODFLAGS) -J$(MOD_DIR) -c $< -o $@ $(AptoFEM) -lpthread)

$(OBJ_DIR)/%.o: ../../matrix_rhs/%.f90
	@echo "Compiling $<... "
	@($(FC) $(FFLAGS) $(MODFLAGS) -J$(MOD_DIR) -c $< -o $@ $(AptoFEM) -lpthread)

$(OBJ_DIR)/%.o: ./comparison/%.f90
	@echo "Compiling $<... "
	@($(FC) $(FFLAGS) $(MODFLAGS) -J$(MOD_DIR) -c $< -o $@ $(AptoFEM) -lpthread)

$(OBJ_DIR)/%.o: ./convergence/%.f90
	@echo "Compiling $<... "
	@($(FC) $(FFLAGS) $(MODFLAGS) -J$(MOD_DIR) -c $< -o $@ $(AptoFEM) -lpthread)

velocity-transport :: $(MAIN_OBJECTS)
	@echo "Linking $@... "
	@($(FC) $(FFLAGS) $(MODFLAGS) -I$(MOD_DIR) -o $(BIN_DIR)/$@.out $(MAIN_OBJECTS) $(AptoFEM) -lpthread)

velocity-comparison :: $(COMPARISON_OBJECTS)
	@echo "Linking $@... "
	@($(FC) $(FFLAGS) $(MODFLAGS) -I$(MOD_DIR) -o $(BIN_DIR)/$@.out $(COMPARISON_OBJECTS) $(AptoFEM) -lpthread)

# velocity-comparison_placentone ::
# 	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
# 		./common/program-name_placentone.f90 ./common/problem-options.f90 ./common/problem-options_velocity.f90 $(placentone_bcs) $(velocity_assembly) ./comparison/velocity-comparison.f90 $(AptoFEM) -lpthread)

# velocity-comparison_placenta ::
# 	($(FC) $(FFLAGS) $(MODFLAGS) -o $@.out \
# 		./common/program-name_placenta.f90 ./common/problem-options.f90 ./common/problem-options_velocity.f90 $(placenta_bcs) $(velocity_assembly) ./comparison/velocity-comparison.f90 $(AptoFEM) -lpthread)

velocity-transport_convergence :: $(CONVERGENCE_OBJECTS)
	@echo "Linking $@... "
	@($(FC) $(FFLAGS) $(MODFLAGS) -I$(MOD_DIR) -o $(BIN_DIR)/$@.out $(CONVERGENCE_OBJECTS) $(AptoFEM) -lpthread)

cleanall ::
	(rm -f *.out)
	(rm -f ./.obj/*.o)
	(rm -f ./.mod/*.mod)
