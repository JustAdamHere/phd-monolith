def set_parameter(program, geometry, line, value):
	import os

	acp_filename = f'./programs/{program}/common/acf_{geometry}.dat'

	arn_file    = open(acp_filename, 'r')
	arn_content = arn_file .readlines()
	arn_file    .close()
	arn_content[line-1] = f'{value}\n'
	arn_file    = open(acp_filename, 'w')
	arn_file    .writelines(arn_content)
	arn_file    .close()

def update_parameter(program, geometry, line, column_min, column_max, value):
	import os

	acp_filename = f'./programs/{program}/common/acf_{geometry}.dat'

	arn_file    = open(acp_filename, 'r')
	arn_content = arn_file .readlines()
	arn_file    .close()
	arn_content[line-1] = arn_content[line-1][:(column_min-1)] + f'{value}' + arn_content[line-1][(column_max):]
	arn_file    = open(acp_filename, 'w')
	arn_file    .writelines(arn_content)
	arn_file    .close()