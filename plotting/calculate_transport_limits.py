transport_limits_cache = []

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

	c = numpy_support.vtk_to_numpy(data.GetPointData().GetArray('c'))

	return [c.min(), c.max()]

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
	min_transport = 1
	max_transport = 0
	for i in range(0, len(limits)):
		if limits[i][0] < min_transport:
			min_transport = limits[i][0]
		if limits[i][1] > max_transport:
			max_transport = limits[i][1]

	from miscellaneous import output

	transport_limits_cache.append([min_transport, max_transport])

	# Terminal output if requested.
	if ((min_transport < -oscillation_tolerance) or (max_transport > 1.0+oscillation_tolerance)):
		output.output(f"⚠ Warning: transport limits = ({min_transport}, {max_transport})", terminal_output)
		return True
	else:
		output.output(f"😁 Within tolerance: transport limits = ({min_transport}, {max_transport})", terminal_output)
		return False