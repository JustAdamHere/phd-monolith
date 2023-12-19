def compress(run_no):
  import os 
  import re

  # Checks how many files there are to compress.
  file_counter = 0
  regex_vtk      = re.compile(f'_{run_no}_[0-9]*.vtk')
  regex_internal = re.compile(f'_{run_no}_[0-9]*.internal')
  regex_dat      = re.compile(f'_{run_no}.dat')
  regex_txt      = re.compile(f'_{run_no}.txt')
  for item in os.listdir('./output/'):
    if regex_vtk.match(item) or regex_internal.match(item) or regex_dat.match(item) or regex_txt.match(item):
      file_counter += 1

  import shutil

  # Compress files.
  shutil.make_archive(f'output_{run_no}', 'zip', './output/')

  return file_counter