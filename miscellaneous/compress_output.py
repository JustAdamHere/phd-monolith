def compress(run_no):
  import os 
  import re

  # Checks how many files there are to compress.
  file_counter = 0
  regex_vtk      = re.compile(f'.*_{run_no}_[0-9]*.vtk')
  regex_internal = re.compile(f'.*_{run_no}_[0-9]*.internal')
  regex_dat      = re.compile(f'.*_{run_no}.dat')
  regex_txt      = re.compile(f'.*_{run_no}.txt')
  for item in os.listdir('./output/'):
    if (os.path.isfile(os.path.join('./output/', item))):
      if regex_vtk.match(item) or regex_internal.match(item) or regex_dat.match(item) or regex_txt.match(item):
        file_counter += 1

  import zipfile

  # Compress files.
  zip_file = zipfile.ZipFile(f'./output/output_{run_no}.zip', mode='w', compression=zipfile.ZIP_DEFLATED, compresslevel=9)
  for item in os.listdir('./output/'):
    if (os.path.isfile(os.path.join('./output/', item))):
      if regex_vtk.match(item) or regex_internal.match(item) or regex_dat.match(item) or regex_txt.match(item):
        zip_file.write(os.path.join('./output/', item), arcname=item)
  zip_file.close()

  return file_counter