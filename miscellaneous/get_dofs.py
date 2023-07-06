# TODO: only true for steady-state 0 time-steps.
def get_velocity_dofs(program, geometry, run_no):
  import os

  velocity_dofs_line = -101

  ao_output  = f'./output/{program}_{geometry}_{run_no}.txt'

  ao_file    = open(ao_output, 'r')
  ao_content = ao_file.readlines()
  ao_file    .close()

  dofs_line = ao_content[velocity_dofs_line]

  no_dofs = dofs_line
  no_dofs = no_dofs[14:-3]
  no_dofs = no_dofs.strip()

  return int(no_dofs)

def get_transport_dofs(program, geometry, run_no):
  import os

  transport_dofs_line = -55

  ao_output  = f'./output/{program}_{geometry}_{run_no}.txt'

  ao_file    = open(ao_output, 'r')
  ao_content = ao_file.readlines()
  ao_file    .close()

  dofs_line = ao_content[transport_dofs_line]

  no_dofs = dofs_line
  no_dofs = no_dofs[14:-3]
  no_dofs = no_dofs.strip()

  return int(no_dofs)
