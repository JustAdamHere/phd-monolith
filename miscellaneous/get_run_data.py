def get_run_data(program, geometry, run_no, time_step):
  import os

  filename = f'./output/simulation-data_{program}_{run_no}.dat'

  with open(filename, 'r') as file:
    content = file.readlines()

    headers = content[0]

    if (time_step > len(content)):
      from miscellaneous import raise_error
      raise_error(f"Error in get_run_data: time step {time_step} is out of range.")
    else:
      data = content[time_step+1].split('\t')
 
      velocity_dofs     = int(data[0])
      transport_dofs    = int(data[1])
      newton_residual   = float(data[2])
      newton_iterations = int(data[3])
      no_elements       = int(data[4])
  
    return velocity_dofs, transport_dofs, newton_residual, newton_iterations, no_elements

  return 0, 0, 0.0, 0