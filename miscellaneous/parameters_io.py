def save_parameters(variables, program, geometry, run_no):
  import json
  import jsbeautifier

  with open(f"./output/variables_{program}_{geometry}_{run_no}.txt", "w") as file:
    options             = jsbeautifier.default_options()
    options.indent_size = 2

    output_string = jsbeautifier.beautify(json.dumps(variables), options)

    file.write(output_string)

def load_parameters(program, geometry, run_no, subfolder=None):
  import json
  
  if subfolder is None:
    filename = f"./output/variables_{program}_{geometry}_{run_no}.txt"
  else:
    filename = f"./output/{subfolder}/variables_{program}_{geometry}_{run_no}.txt"
  
  with open(filename, "r") as file:
    return json.loads(file.read())