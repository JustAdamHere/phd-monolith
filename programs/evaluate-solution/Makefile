include $(AptoFEM_DIR)/source/package_defaults/makefile.flags
#include $(AptoFEM_DIR)/source/package_defaults/makefile_openmp.flags
#include $(AptoFEM_DIR)/source/package_defaults/makefile_mpi.flags

OBJ_DIR=./.obj
MOD_DIR=./.mod
BIN_DIR=./

velocity_problem_options = problem-options.f90 problem-options_geometry.f90 problem-options_velocity.f90
refine_region            = refine_region.f90

velocity_bcs = 2d-bcs_velocity_placenta.f90 2d-bcs_velocity_placentone.f90 3d-bcs_velocity_placentone.f90 2d-bcs_velocity_tb_free_lr_solid.f90 velocity_bc_interface.f90

.PHONY: cleanall

SOURCES = $(velocity_problem_options) $(velocity_bcs) $(refine_region) evaluate-solution_bb.f90
OBJECTS = $(patsubst %.f90,./.obj/%.o,$(SOURCES))

$(OBJ_DIR)/%.o: ./%.f90
	@echo "Compiling $<... "
	@($(FC) $(FFLAGS) $(MODFLAGS) -J$(MOD_DIR) -c $< -o $@ $(AptoFEM) -lpthread)

$(OBJ_DIR)/%.o: ../velocity-transport/common/%.f90
	@echo "Compiling $<... "
	@($(FC) $(FFLAGS) $(MODFLAGS) -J$(MOD_DIR) -c $< -o $@ $(AptoFEM) -lpthread)

evaluate-solution_bb :: $(OBJECTS)
	@echo "Linking $@... "
	@($(FC) $(FFLAGS) $(MODFLAGS) -I$(MOD_DIR) -o $(BIN_DIR)/$@.out $(OBJECTS) $(AptoFEM) -lpthread)

cleanall ::
	(rm -f *.out)
	(rm -f ./.obj/*.o)
	(rm -f ./.mod/*.mod)
