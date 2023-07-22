def get_newton_iterations(program, geometry, run_no):
  import os

  newton_iteration_line = -114 + 42

  ao_output  = f'./output/{program}_{geometry}_{run_no}.txt'

  ao_file    = open(ao_output, 'r')
  ao_content = ao_file.readlines()
  ao_file    .close()

  iteration_line = ao_content[newton_iteration_line]

  iteration = iteration_line
  iteration = iteration[0:8]
  iteration = iteration.strip()

  return int(iteration)