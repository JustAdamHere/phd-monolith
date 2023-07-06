def get_current_run_no(program):
	import os

	program_directory = os.getcwd() + f'/programs/{program}/'

	run_no = -1
	if os.path.isdir(program_directory):
		arn_filename = program_directory + 'aptofem_run_number.dat'

		arn_file = open(arn_filename, 'r')
		run_no   = int(arn_file.readlines()[0].strip())
		arn_file .close()

	return run_no