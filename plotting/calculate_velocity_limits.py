velocity_limits_cache = []

def calculate_limits_from_file(filename):
	# Read in mesh+soln file.
	from vtk import vtkUnstructuredGridReader
	from vtk.util import numpy_support
	try:
		reader = vtkUnstructuredGridReader()
		reader.SetFileName(filename)
		reader.ReadAllVectorsOn()
		reader.ReadAllScalarsOn()
		reader.Update()
	except Exception as e:
		raise_error(e)

	data = reader.GetOutput()

	u = numpy_support.vtk_to_numpy(data.GetPointData().GetArray('u'))
	v = numpy_support.vtk_to_numpy(data.GetPointData().GetArray('v'))

	# Calculate velocity magnitude limits.
	import numpy as np
	u_mag = np.zeros(u.size)
	for i in range(u.size):
		u_mag[i] = (u[i]**2 + v[i]**2)**0.5

	return [u_mag.min(), u_mag.max()]

def calculate_limits(problem, name, run_no, oscillation_tolerance, terminal_output=True):
	import os
	filenames = f"meshandsoln_{problem}_{name}_{run_no}_[0-9]+.vtk"
	directory = os.getcwd() + '/output'

	# Loop over all matched files.
	import os, re
	limits = []
	for filename in os.listdir(directory):
		if re.match(filenames, filename):
			limits.append(calculate_limits_from_file(directory + '/' + filename))

	# Calculate min/max.
	min_velocity = 1
	max_velocity = 0
	for i in range(0, len(limits)):
		if limits[i][0] < min_velocity:
			min_velocity = limits[i][0]
		if limits[i][1] > max_velocity:
			max_velocity = limits[i][1]

	from miscellaneous import output

	velocity_limits_cache.append([min_velocity, max_velocity])

	# Terminal output if requested.
	if ((min_velocity < -oscillation_tolerance) or (max_velocity > 1.0+oscillation_tolerance)):
		output.output(f"⚠ Warning: velocity limits = ({min_velocity:.5f}, {max_velocity:.5f})", terminal_output)
		return True
	else:
		output.output(f"😁 Within tolerance: velocity limits = ({min_velocity:.5f}, {max_velocity:.5f})", terminal_output)
		return False

def raise_error(e):
	print("###########################################")
	print("## ❌ ERROR CAUGHT; STOPPING             ##")
	print("###########################################")
	print(e.output)
	exit()