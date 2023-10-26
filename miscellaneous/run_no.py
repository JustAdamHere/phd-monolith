def set_completed_run_no(simulation_no):
  file = open(f"./output/monolith_simulation_number.txt", "w")
  file.write(f"{simulation_no}")
  file.close()

def get_completed_run_no():
  try:
    file = open(f"./output/monolith_simulation_number.txt", "r")
  except:
    file = open(f"./output/monolith_simulation_number.txt", "w")
    file.write(f"0")
    file.close()
    file = open(f"./output/monolith_simulation_number.txt", "r")
  
  simulation_no = int(file.read())
  file.close()

  return simulation_no