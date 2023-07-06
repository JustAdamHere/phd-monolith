def set_run_numbers(run_no = 0, program = None):
	import os

	if (program == None):
		for program in os.listdir('./' + 'programs' + '/'):
			if os.path.isdir('./' + 'programs' + '/' + program + '/'):
				arn_filename = './' + 'programs' + '/' + program + '/' + 'aptofem_run_number.dat'

				arn_file = open(arn_filename, 'w')
				arn_file .write('          ' + str(run_no))
				arn_file .close()
	else:
		if os.path.isdir('./' + 'programs' + '/' + program + '/'):
			arn_filename = './' + 'programs' + '/' + program + '/' + 'aptofem_run_number.dat'

			arn_file = open(arn_filename, 'w')
			arn_file .write('          ' + str(run_no))
			arn_file .close()