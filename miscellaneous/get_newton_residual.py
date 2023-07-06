def get_newton_residual(program, geometry, run_no):
  import os

  newton_residual_line = -114

  ao_output  = f'./output/{program}_{geometry}_{run_no}.txt'

  ao_file    = open(ao_output, 'r')
  ao_content = ao_file.readlines()
  ao_file    .close()

  residual_line = ao_content[newton_residual_line]

  residual = residual_line
  residual = residual[20:32]
  residual = residual.strip()

  return float(residual)