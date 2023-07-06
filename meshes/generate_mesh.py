def generate_mesh(simulation_no, geometry, mesh_resolution, artery_location, vein_location_1, vein_location_2, central_cavity_width, central_cavity_transition, artery_length, verbose_output):
	import subprocess

	if (geometry == "placentone"):
		geo_file = "box-circle.geo"
		# geo_file = "box-circle_1-vein.geo"
	else:
		#geo_file = "inverted-circle-slice-6_normal-walls.geo"
		geo_file = "inverted-circle-slice-6_removed-veins_normal-walls.geo"

	# Generate corresponding .msh file.
	subprocess.run([\
		'/home/pmyambl/software/gmsh-4.11.1-Linux64/bin/gmsh',\
		f'./meshes/{geo_file}',\
		'-string', 'Mesh.MshFileVersion=2;',\
		'-setnumber', 'h', str(mesh_resolution),\
		'-setnumber', 'h_refine', str(mesh_resolution),\
		'-setnumber', 'location_11', str(vein_location_1),\
		'-setnumber', 'location_12', str(artery_location),\
		'-setnumber', 'location_13', str(vein_location_2),\
		'-setnumber', 'location_21', str(vein_location_1),\
		'-setnumber', 'location_22', str(artery_location),\
		'-setnumber', 'location_23', str(vein_location_2),\
		'-setnumber', 'location_31', str(vein_location_1),\
		'-setnumber', 'location_32', str(artery_location),\
		'-setnumber', 'location_33', str(vein_location_2),\
		'-setnumber', 'location_41', str(vein_location_1),\
		'-setnumber', 'location_42', str(artery_location),\
		'-setnumber', 'location_43', str(vein_location_2),\
		'-setnumber', 'location_51', str(vein_location_1),\
		'-setnumber', 'location_52', str(artery_location),\
		'-setnumber', 'location_53', str(vein_location_2),\
		'-setnumber', 'location_61', str(vein_location_1),\
		'-setnumber', 'location_62', str(artery_location),\
		'-setnumber', 'location_63', str(vein_location_2),\
		'-setnumber', 'central_cavity_width', str(central_cavity_width),\
		'-setnumber', 'central_cavity_transition', str(central_cavity_transition),\
		'-2',\
		'-o', f'meshes/mesh_{simulation_no}.msh'\
	],
	stdout=subprocess.DEVNULL)