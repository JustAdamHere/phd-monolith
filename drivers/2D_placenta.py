# Nominal values of parameters.
artery_location_nominal   = 0.5
vein_location_1_nominal   = 0.2
vein_location_2_nominal   = 0.8
central_cavity_nominal    = 0.25 # 10mm
central_cavity_transition_nominal = 0.05 # 2mm
pipe_transition_nominal   = 0.03 # 2mm
artery_length_nominal     = 0.05 # 2mm
#mesh_resolution_default   = 0.05
mesh_resolution_default   = 0.1
log_cavity_transition     = False
nsku_reaction_coefficient_nominal = 1.6e5

import numpy as np

# Clean and compile.
from programs import dg_nsku_transport
dg_nsku_transport.setup(clean=True, terminal_output=True, compile=False)

# Vary mesh resolution.
import matplotlib.pyplot as plt
from plotting import calculate_transport_limits
from plotting import calculate_velocity_limits

dg_nsku_transport.run(0, "placenta", artery_location_nominal, vein_location_1_nominal, vein_location_2_nominal, central_cavity_nominal, central_cavity_transition_nominal, pipe_transition_nominal, artery_length_nominal, mesh_resolution_default, log_cavity_transition, nsku_reaction_coefficient_nominal, terminal_output=True, verbose_output=False, velocity_oscillation_tolerance=1e-4, transport_oscillation_tolerance=1e-1, plot=True, rerun_on_oscillation=False)

from miscellaneous import output
output.output("##########################", True)
output.output(f"Fluxes: {dg_nsku_transport.flux_cache}", True)
output.output(f"Integrals: {dg_nsku_transport.integral_cache}", True)

# Save output.
output.save()