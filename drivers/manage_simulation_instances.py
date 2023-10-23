from miscellaneous import manage_monoliths

for i in [1, 2, 3, 4, 7, 8, 9, 10, 11, 12]:
  print(f"## Monolith {i} ##")
  manage_monoliths.create_new_monolith(i, True)
  manage_monoliths.run_on_monolith(i, f'vary_run_{i}.py', False)

  manage_monoliths.transfer_monolith_files(i, output=True, images=True)
  #manage_monoliths.delete_monolith(i)