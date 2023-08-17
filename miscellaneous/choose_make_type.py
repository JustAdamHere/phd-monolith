def choose_make_type(make_type, program):
	import os

	program_directory = os.getcwd() + f'/programs/{program}/'

	if os.path.isdir(program_directory):
		make_filename = program_directory + 'Makefile'

		make_file   = open(make_filename, 'r')
		lines       = make_file.readlines()
		serial_line = lines[0]
		openmp_line = lines[1]
		mpi_line    = lines[2]
		make_file   .close()

		if (serial_line[0] != '#' or openmp_line[0] != '#' or mpi_line[0] != '#'):
			raise Exception('Please comment out first 3 lines of Makefile.')
		else:
			if make_type == 'serial':
				make_type_line = serial_line[1:]
			elif make_type == 'openmp':
				make_type_line = openmp_line[1:]
			elif make_type == 'mpi':
				make_type_line = mpi_line[1:]			
			else:
				raise Exception('Unknown make type.')
		
		make_file = open(make_filename, 'w')
		lines[3] 	= make_type_line
		make_file .writelines(lines)
		make_file .close()

		return True
	else:
		return False