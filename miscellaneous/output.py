output_cache = []

def output(output_string, output_on, **kwargs):
	if output_on:
		print(output_string, **kwargs)

	if ('end' in kwargs):
		end = kwargs['end']
	else:
		end = '\n'

	output_cache.append(output_string + end)

def save(name = "output_run-all.txt"):
	global output_cache

	with open(f"./output/{name}", 'w', encoding='utf-8') as file:
		for line in output_cache:
			file.write(line)

def end_execution(sig, frame):
  from miscellaneous import output
  output.output("⚠️ Termination signal received! Saving output so far...", True)
  output.save()
  exit(0)