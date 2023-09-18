def generate_mesh(simulation_no, geometry, mesh_resolution, artery_location, vein_location_1, vein_location_2, central_cavity_width, central_cavity_height, central_cavity_transition, artery_length, verbose_output, normal_vessels, septal_veins, marginal_sinus, wall_height_ratio, artery_width, no_placentones):
	import subprocess

	if (geometry == "placentone"):
		geo_file = "box-circle.geo"
		dim = 2
	elif (geometry == "placentone-3d"):
		geo_file = "box-circle-3d.geo"
		dim = 3
	elif (geometry == "placenta"):
		#geo_file = "inverted-circle-slice-6_normal-walls.geo"
		geo_file = "inverted-circle-slice-6-flat_normal-walls.geo"
		dim = 2

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

	if (no_placentones == 6):
		wall_height_1 = wall_height_ratio*0.1725
		wall_height_2 = wall_height_ratio*0.35175
		wall_height_3 = wall_height_ratio*0.1725
		wall_height_4 = wall_height_ratio*0.35175
		wall_height_5 = wall_height_ratio*0.1725
		wall_height_6 = 0

		vein_11 = normal_vessels[0][0]
		vein_12 = normal_vessels[0][2]
		vein_21 = normal_vessels[1][0]
		vein_22 = normal_vessels[1][2]
		vein_31 = normal_vessels[2][0]
		vein_32 = normal_vessels[2][2]
		vein_41 = normal_vessels[3][0]
		vein_42 = normal_vessels[3][2]
		vein_51 = normal_vessels[4][0]
		vein_52 = normal_vessels[4][2]
		vein_61 = normal_vessels[5][0]
		vein_62 = normal_vessels[5][2]
		vein_71 = 0
		vein_72 = 0

		artery_11 = normal_vessels[0][1]
		artery_21 = normal_vessels[1][1]
		artery_31 = normal_vessels[2][1]
		artery_41 = normal_vessels[3][1]
		artery_51 = normal_vessels[4][1]
		artery_61 = normal_vessels[5][1]
		artery_71 = 0
	else:
		wall_height_1 = wall_height_ratio*0.1725
		wall_height_2 = wall_height_ratio*0.1725
		wall_height_3 = wall_height_ratio*0.1725
		wall_height_4 = wall_height_ratio*0.1725
		wall_height_5 = wall_height_ratio*0.1725
		wall_height_6 = wall_height_ratio*0.1725

		vein_11 = normal_vessels[0][0]
		vein_12 = normal_vessels[0][2]
		vein_21 = normal_vessels[1][0]
		vein_22 = normal_vessels[1][2]
		vein_31 = normal_vessels[2][0]
		vein_32 = normal_vessels[2][2]
		vein_41 = normal_vessels[3][0]
		vein_42 = normal_vessels[3][2]
		vein_51 = normal_vessels[4][0]
		vein_52 = normal_vessels[4][2]
		vein_61 = normal_vessels[5][0]
		vein_62 = normal_vessels[5][2]
		vein_71 = normal_vessels[6][0]
		vein_72 = normal_vessels[6][2]

		artery_11 = normal_vessels[0][1]
		artery_21 = normal_vessels[1][1]
		artery_31 = normal_vessels[2][1]
		artery_41 = normal_vessels[3][1]
		artery_51 = normal_vessels[4][1]
		artery_61 = normal_vessels[5][1]
		artery_71 = normal_vessels[6][1]
	
	if (no_placentones == 6):
		septal_vein_11 = septal_veins[0][0]
		septal_vein_12 = septal_veins[0][1]
		septal_vein_13 = septal_veins[0][2]
		septal_vein_21 = septal_veins[1][0]
		septal_vein_22 = septal_veins[1][1]
		septal_vein_23 = septal_veins[1][2]
		septal_vein_31 = septal_veins[2][0]
		septal_vein_32 = septal_veins[2][1]
		septal_vein_33 = septal_veins[2][2]
		septal_vein_41 = septal_veins[3][0]
		septal_vein_42 = septal_veins[3][1]
		septal_vein_43 = septal_veins[3][2]
		septal_vein_51 = septal_veins[4][0]
		septal_vein_52 = septal_veins[4][1]
		septal_vein_53 = septal_veins[4][2]
		septal_vein_61 = 0
		septal_vein_62 = 0
		septal_vein_63 = 0
	else:
		septal_vein_11 = septal_veins[0][0]
		septal_vein_12 = septal_veins[0][1]
		septal_vein_13 = septal_veins[0][2]
		septal_vein_21 = septal_veins[1][0]
		septal_vein_22 = septal_veins[1][1]
		septal_vein_23 = septal_veins[1][2]
		septal_vein_31 = septal_veins[2][0]
		septal_vein_32 = septal_veins[2][1]
		septal_vein_33 = septal_veins[2][2]
		septal_vein_41 = septal_veins[3][0]
		septal_vein_42 = septal_veins[3][1]
		septal_vein_43 = septal_veins[3][2]
		septal_vein_51 = septal_veins[4][0]
		septal_vein_52 = septal_veins[4][1]
		septal_vein_53 = septal_veins[4][2]
		septal_vein_61 = septal_veins[5][0]
		septal_vein_62 = septal_veins[5][1]
		septal_vein_63 = septal_veins[5][2]

	ms_1 = marginal_sinus[0]
	ms_2 = marginal_sinus[1]

	options = ['-setnumber', 'h_background', str(h_background),\
		'-setnumber', 'h_vein_top', str(h_vein_top),\
		'-setnumber', 'h_vein_bottom', str(h_vein_bottom),\
		'-setnumber', 'h_artery_top', str(h_artery_top),\
		'-setnumber', 'h_artery_middle', str(h_artery_middle),\
		'-setnumber', 'h_artery_bottom', str(h_artery_bottom),\
		'-setnumber', 'h_cavity_inner', str(h_cavity_inner),\
		'-setnumber', 'h_cavity_outer', str(h_cavity_outer),\
		'-setnumber', 'vein_11', str(vein_11), \
		'-setnumber', 'vein_12', str(vein_12), \
		'-setnumber', 'vein_21', str(vein_21), \
		'-setnumber', 'vein_22', str(vein_22), \
		'-setnumber', 'vein_31', str(vein_31), \
		'-setnumber', 'vein_32', str(vein_32), \
		'-setnumber', 'vein_41', str(vein_41), \
		'-setnumber', 'vein_42', str(vein_42), \
		'-setnumber', 'vein_51', str(vein_51), \
		'-setnumber', 'vein_52', str(vein_52), \
		'-setnumber', 'vein_61', str(vein_61), \
		'-setnumber', 'vein_62', str(vein_62), \
		'-setnumber', 'vein_71', str(vein_71), \
		'-setnumber', 'vein_72', str(vein_72), \
		'-setnumber', 'artery_11', str(artery_11), \
		'-setnumber', 'artery_21', str(artery_21), \
		'-setnumber', 'artery_31', str(artery_31), \
		'-setnumber', 'artery_41', str(artery_41), \
		'-setnumber', 'artery_51', str(artery_51), \
		'-setnumber', 'artery_61', str(artery_61), \
		'-setnumber', 'artery_71', str(artery_71), \
		'-setnumber', 'septal_vein_11', str(septal_vein_11),\
		'-setnumber', 'septal_vein_12', str(septal_vein_12),\
		'-setnumber', 'septal_vein_13', str(septal_vein_13),\
		'-setnumber', 'septal_vein_21', str(septal_vein_21),\
		'-setnumber', 'septal_vein_22', str(septal_vein_22),\
		'-setnumber', 'septal_vein_23', str(septal_vein_23),\
		'-setnumber', 'septal_vein_31', str(septal_vein_31),\
		'-setnumber', 'septal_vein_32', str(septal_vein_32),\
		'-setnumber', 'septal_vein_33', str(septal_vein_33),\
		'-setnumber', 'septal_vein_41', str(septal_vein_41),\
		'-setnumber', 'septal_vein_42', str(septal_vein_42),\
		'-setnumber', 'septal_vein_43', str(septal_vein_43),\
		'-setnumber', 'septal_vein_51', str(septal_vein_51),\
		'-setnumber', 'septal_vein_52', str(septal_vein_52),\
		'-setnumber', 'septal_vein_53', str(septal_vein_53),\
		'-setnumber', 'septal_vein_61', str(septal_vein_61),\
		'-setnumber', 'septal_vein_62', str(septal_vein_62),\
		'-setnumber', 'septal_vein_63', str(septal_vein_63),\
		'-setnumber', 'central_cavity_transition', str(central_cavity_transition),\
		'-setnumber', 'wall_height_1', str(wall_height_1),\
		'-setnumber', 'wall_height_2', str(wall_height_2),\
		'-setnumber', 'wall_height_3', str(wall_height_3),\
		'-setnumber', 'wall_height_4', str(wall_height_4),\
		'-setnumber', 'wall_height_5', str(wall_height_5),\
		'-setnumber', 'wall_height_6', str(wall_height_6),\
		'-setnumber', 'artery_width',  str(artery_width),\
		'-setnumber', 'ms_1', str(ms_1),\
		'-setnumber', 'ms_2', str(ms_2),\
		'-setnumber', 'no_placentones', str(no_placentones),\
	]

	if (type(central_cavity_width) == list):
		assert(len(central_cavity_width) == no_placentones)

		for i in range(no_placentones):
			options += ['-setnumber', f'central_cavity_width_{i+1}', str(central_cavity_width[i])]
	elif (type(central_cavity_width) == float or type(central_cavity_width) == int):
		for i in range(no_placentones):
			options += ['-setnumber', f'central_cavity_width', str(central_cavity_width)]
	else:
		raise ValueError("central_cavity_width must be float or list of length [no_placentones]")
	
	if (type(central_cavity_height) == list):
		assert(len(central_cavity_height) == no_placentones)

		for i in range(no_placentones):
			options += ['-setnumber', f'central_cavity_height_{i+1}', str(central_cavity_height[i])]
	elif (type(central_cavity_height) == float or type(central_cavity_height) == int):
		for i in range(no_placentones):
			options += ['-setnumber', f'central_cavity_height', str(central_cavity_height)]
	else:
		raise ValueError("central_cavity_width must be float or list of length [no_placentones]")

	command = [\
		'/home/pmyambl/software/gmsh-4.11.1-Linux64/bin/gmsh',\
		f'./meshes/{geo_file}',\
		'-string', 'Mesh.MshFileVersion=2;'\
	]

	output = [\
		f'-{dim}',\
		'-o', f'meshes/mesh_{simulation_no}.msh'\
	]

	subprocess.run(command + options + output, stdout=subprocess.DEVNULL)