def save_local_variables(variables, program, geometry, run_no):
  file = open(f"./output/variables_{program}_{geometry}_{run_no}.txt", "w")
  for variable in variables:
    file.write(f"{variable} = {variables[variable]}\n")
  file.close()