from miscellaneous import manage_monoliths

for i in range(1, 2):
  print(f"## Monolith {i} ##")
  manage_monoliths.create_new_monolith(i, True)
  manage_monoliths.run_on_monolith(i, 'vary_run.py', False)
  manage_monoliths.transfer_monolith_files(i, output=True, images=True)
  #manage_monoliths.delete_monolith(i)