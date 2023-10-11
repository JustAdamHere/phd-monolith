def create_new_monolith(monolith_number, overwrite=False):
  import os, subprocess
  
  # Create new directory.
  if os.path.exists(f"../Monolith-{monolith_number}"):
    print(f"Monolith-{monolith_number} already exists.")

    if (not overwrite):
      return False
    else:
      print("I'll overwrite.")
  else:
    print(f"Cloning Monolith-{monolith_number}", end="... ")
    subprocess.run(["git", "clone", "git@gitlab.com:adam.blakey/phd-monolith.git", f"../Monolith-{monolith_number}"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print(f"Done.")
    
  # Copy setup file.
  import shutil
  shutil.copy("./requirements.txt"    , f"../Monolith-{monolith_number}/requirements.txt"    )
  shutil.copy("./setup.py"            , f"../Monolith-{monolith_number}/setup.py"            )
  shutil.copy("./setup_simulations.sh", f"../Monolith-{monolith_number}/setup_simulations.sh")
  os.chmod(f"../Monolith-{monolith_number}/setup_simulations.sh", 0o775)
  
  # Run setup script.
  print(f"Running setup", end="... ")
  subprocess.run(["./setup_simulations.sh"], cwd=f"../Monolith-{monolith_number}", stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
  print(f"Done.")

def run_on_monolith(command, monolith_number):
  return None

def transfer_monolith_files(monolith_number):
  return None

def delete_monolith(monolith_number):
  import os

  if os.path.exists(f"../Monolith-{monolith_number}"):
    print(f"Deleting Monolith-{monolith_number}", end="... ")
    import shutil
    shutil.rmtree(f"../Monolith-{monolith_number}")
    print(f"Done.")
  else:
    print(f"Monolith-{monolith_number} does not exist.")
    return False