def add_option(options, option, value):
	options += [f'-setnumber', option, str(value)]

def generate_simple_mesh(simulation_no, geometry, mesh_resolution):
	import subprocess

	if (geometry.startswith("square")):
		geo_file = "square.geo"
		# geo_file = "l-shape.geo"
		dim = 2
	else:
		raise ValueError("geometry must be 'square*'")

	mesh_command = [\
		'/home/pmyambl/software/gmsh-4.11.1-Linux64/bin/gmsh',\
		f'./meshes/{geo_file}',\
		'-string', 'Mesh.MshFileVersion=2;',\
		'-tol', '1e-12',\
	]

	mesh_output = [\
		f'-{dim}',\
		'-o', f'meshes/mesh_{simulation_no}.msh'\
	]

	stdout = subprocess.DEVNULL # None
	subprocess.run(mesh_command + ['-setnumber', 'h', str(mesh_resolution)] + mesh_output, stdout=stdout)


def generate_mesh(simulation_no, geometry, mesh_resolution, central_cavity_width, central_cavity_height, central_cavity_transition, artery_length, verbose_output, basal_plate_vessels, septal_veins, marginal_sinus, wall_height_ratio, artery_width, artery_width_sm, no_placentones, vessel_fillet_radius, basal_plate_vessel_locations, septal_vein_locations, equal_wall_heights, generate_outline_mesh):
	import subprocess

	if (geometry == "placentone" or geometry == "placentone-3d"):
		assert(no_placentones == 1)

	# Mesh files for each geometry.
	if (geometry == "placentone"):
		geo_file = "box-circle.geo"
		dim = 2
	elif (geometry == "placentone-3d"):
		geo_file = "box-circle-3d.geo"
		dim = 3
	elif (geometry == "placenta"):
		geo_file = "inverted-circle-slice-6-flat_normal-walls.geo"
		dim = 2
	else:
		raise ValueError("geometry must be 'placentone', 'placentone-3d', 'placenta', or 'square'")

	# Set mesh resolution.
	if (mesh_resolution == -1):
		h_background    = 0.1
		h_vein_top      = h_background/10
		h_vein_bottom   =	h_background/10
		h_artery_top    = h_background/10
		h_artery_middle = h_background/10
		h_artery_bottom = h_background/10
		h_cavity_inner  = h_background/10
		h_cavity_outer  = h_background/2
	elif (type(mesh_resolution) == list):
		assert(len(mesh_resolution) == 8)
		h_background    = mesh_resolution[0]
		h_vein_top      = mesh_resolution[1]
		h_vein_bottom   =	mesh_resolution[2]
		h_artery_top    = mesh_resolution[3]
		h_artery_middle = mesh_resolution[4]
		h_artery_bottom = mesh_resolution[5]
		h_cavity_inner  = mesh_resolution[6]
		h_cavity_outer  = mesh_resolution[7]
	elif (type(mesh_resolution) == float or type(mesh_resolution) == int):
		h_background    = mesh_resolution
		h_vein_top      = mesh_resolution/10
		h_vein_bottom   =	mesh_resolution/10
		h_artery_top    = mesh_resolution/10
		h_artery_middle = mesh_resolution/10
		h_artery_bottom = mesh_resolution/10
		h_cavity_inner  = mesh_resolution/10
		h_cavity_outer  = mesh_resolution/2
	else:
		raise ValueError("mesh_resolution must be float or list of length 8")

	# Set wall widths.
	if (no_placentones == 6 and geometry == "placenta" and equal_wall_heights):
		wall_height_1 = wall_height_ratio*0.35175
		wall_height_2 = wall_height_ratio*0.35175
		wall_height_3 = wall_height_ratio*0.35175
		wall_height_4 = wall_height_ratio*0.35175
		wall_height_5 = wall_height_ratio*0.35175
		wall_height_6 = 0
	elif (no_placentones == 6 and geometry == "placenta" and not equal_wall_heights):
		wall_height_1 = wall_height_ratio*0.1725
		wall_height_2 = wall_height_ratio*0.35175
		wall_height_3 = wall_height_ratio*0.1725
		wall_height_4 = wall_height_ratio*0.35175
		wall_height_5 = wall_height_ratio*0.1725
		wall_height_6 = 0
	elif (no_placentones == 7 and geometry == "placenta"):
		wall_height_1 = wall_height_ratio*0.1725
		wall_height_2 = wall_height_ratio*0.1725
		wall_height_3 = wall_height_ratio*0.1725
		wall_height_4 = wall_height_ratio*0.1725
		wall_height_5 = wall_height_ratio*0.1725
		wall_height_6 = wall_height_ratio*0.1725

	# Mesh resolution.
	options = []
	add_option(options, 'h_background',    h_background)
	add_option(options, 'h_vein_top',      h_vein_top)
	add_option(options, 'h_vein_bottom',   h_vein_bottom)
	add_option(options, 'h_artery_top',    h_artery_top)
	add_option(options, 'h_artery_middle', h_artery_middle)
	add_option(options, 'h_artery_bottom', h_artery_bottom)
	add_option(options, 'h_cavity_inner',  h_cavity_inner)
	add_option(options, 'h_cavity_outer',  h_cavity_outer)

	# Geometry measurements.
	add_option(options, 'central_cavity_transition', central_cavity_transition)
	add_option(options, 'artery_width',              artery_width)
	add_option(options, 'artery_width_sm',           artery_width_sm)
	add_option(options, 'vessel_fillet_radius',      vessel_fillet_radius)

	# Miscellaneous.
	add_option(options, 'no_placentones', no_placentones)
	add_option(options, 'ms_1', 					marginal_sinus[0])
	add_option(options, 'ms_2', 					marginal_sinus[1])

	# Loop over placentones.
	if (geometry == 'placenta'):
		assert(len(basal_plate_vessels) == no_placentones)
		assert(len(basal_plate_vessel_locations) == no_placentones)
		for i in range(no_placentones):
			add_option(options, f'vein_{i+1}1',   basal_plate_vessels[i][0])
			add_option(options, f'artery_{i+1}1', basal_plate_vessels[i][1])
			add_option(options, f'vein_{i+1}2',   basal_plate_vessels[i][2])

			add_option(options, f'vessel_locations_{i+1}1', basal_plate_vessel_locations[i][0])
			add_option(options, f'vessel_locations_{i+1}2', basal_plate_vessel_locations[i][1])
			add_option(options, f'vessel_locations_{i+1}3', basal_plate_vessel_locations[i][2])

	# Loop over walls.
	if (geometry == 'placenta'):
		for i in range(no_placentones):
			wall_heights = [wall_height_1, wall_height_2, wall_height_3, wall_height_4, wall_height_5, wall_height_6]
		assert(len(septal_veins) == no_placentones-1)
		assert(len(septal_vein_locations) == no_placentones-1)
		for i in range(no_placentones-1):
			add_option(options, f'septal_vein_{i+1}1', septal_veins[i][0])
			add_option(options, f'septal_vein_{i+1}2', septal_veins[i][1])
			add_option(options, f'septal_vein_{i+1}3', septal_veins[i][2])

			add_option(options, f'septal_vein_position_{i+1}1', septal_vein_locations[i][0])
			add_option(options, f'septal_vein_position_{i+1}2', septal_vein_locations[i][1])
			add_option(options, f'septal_vein_position_{i+1}3', septal_vein_locations[i][2])

			add_option(options, f'wall_height_{i+1}', wall_heights[i])

	# Cavity widths.
	if (type(central_cavity_width) == list):
		assert(len(central_cavity_width) == no_placentones)

		for i in range(no_placentones):
			add_option(options, f'central_cavity_width_{i+1}', central_cavity_width[i])
	elif (type(central_cavity_width) == float or type(central_cavity_width) == int):
		add_option(options, f'central_cavity_width', central_cavity_width)
	else:
		raise ValueError("central_cavity_width must be float or list of length [no_placentones]")
	
	# Cavity heights.
	if (type(central_cavity_height) == list):
		assert(len(central_cavity_height) == no_placentones)

		for i in range(no_placentones):
			add_option(options, f'central_cavity_height_{i+1}', central_cavity_height[i])
	elif (type(central_cavity_height) == float or type(central_cavity_height) == int):
		add_option(options, f'central_cavity_height', central_cavity_height)
	else:
		raise ValueError("central_cavity_width must be float or list of length [no_placentones]")

	# Generate full mesh.
	full_mesh_command = [\
		'/home/pmyambl/software/gmsh-4.11.1-Linux64/bin/gmsh',\
		f'./meshes/{geo_file}',\
		'-string', 'Mesh.MshFileVersion=2;',\
		'-tol', '1e-12',\
	]

	full_mesh_output = [\
		f'-{dim}',\
		'-o', f'meshes/mesh_{simulation_no}.msh'\
	]

	stdout = subprocess.DEVNULL # None
	subprocess.run(full_mesh_command + options + full_mesh_output, stdout=stdout)

	# Generate outline mesh.
	if (generate_outline_mesh):
		outline_mesh_command = [\
			'/home/pmyambl/software/gmsh-4.11.1-Linux64/bin/gmsh',\
			f'./meshes/{geo_file}',\
		]

		outline_mesh_output = [\
			f'-1',\
			'-o', f'meshes/outline-mesh_{simulation_no}.vtk'\
		]

		stdout = subprocess.DEVNULL # None
		subprocess.run(outline_mesh_command + options + outline_mesh_output, stdout=stdout)