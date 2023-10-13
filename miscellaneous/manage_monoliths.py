def create_new_monolith(monolith_number, overwrite=False):
  import os, subprocess
  
  # Create new directory.
  if os.path.exists(f"../Monolith-{monolith_number}"):
    print(f"Monolith-{monolith_number} already exists.")

    if (not overwrite):
      return
    else:
      print("I'll overwrite.")
  else:
    print(f"Cloning Monolith-{monolith_number}", end="... ", flush=True)
    subprocess.run(["git", "clone", "git@gitlab.com:adam.blakey/phd-monolith.git", f"../Monolith-{monolith_number}"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    print(f"Done.")
    
  # Copy setup file.
  import shutil
  shutil.copy("./requirements.txt"    , f"../Monolith-{monolith_number}/requirements.txt"    )
  shutil.copy("./setup.py"            , f"../Monolith-{monolith_number}/setup.py"            )
  shutil.copy("./setup_simulations.sh", f"../Monolith-{monolith_number}/setup_simulations.sh")
  os.chmod(f"../Monolith-{monolith_number}/setup_simulations.sh", 0o775)
  
  # Run setup script.
  print(f"Running setup", end="... ", flush=True)
  subprocess.run(["./setup_simulations.sh"], cwd=f"../Monolith-{monolith_number}", stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
  print(f"Done.")

def run_on_monolith(monolith_number, driver, run_driver):
  import os, shutil, subprocess

  print("Transferring driver", end="... ", flush=True)
  shutil.copy(os.path.join('./drivers/', driver), f'../Monolith-{monolith_number}/drivers/{driver}')
  print("Done.")

  if (run_driver):
    print("Running simulation", end="... ", flush=True)
    subprocess.run(["./.python3-venv/bin/python", f"./drivers/{driver}"], cwd=f"../Monolith-{monolith_number}", stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print("Done.")

def transfer_monolith_files(monolith_number, output=True, images=True):
  from miscellaneous import clean_directory

  print("Transferring files", end="... ", flush=True)
  if (output):
    clean_directory.clean_directory(f'../Monolith-{monolith_number}/output', file_extension=None,  mode='copy', to=f'./output/', prepend=f'm{monolith_number}', exist_ok=True)
  if (images):
    clean_directory.clean_directory(f'../Monolith-{monolith_number}/images', file_extension='png', mode='copy', to=f'./images/', prepend=f'm{monolith_number}', exist_ok=True)
  print("Done.")

def delete_monolith(monolith_number):
  import os

  if os.path.exists(f"../Monolith-{monolith_number}"):
    print(f"Deleting Monolith-{monolith_number}", end="... ", flush=True)
    import shutil
    shutil.rmtree(f"../Monolith-{monolith_number}")
    print(f"Done.")
  else:
    print(f"Monolith-{monolith_number} does not exist, cannot delete.")
    return False