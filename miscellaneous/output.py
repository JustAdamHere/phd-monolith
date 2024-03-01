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

def display_run_output(run_process, output_filename, terminal_output, verbose_output, end_message=""):
	# Display last line of output to screen, and write lines to file.
	line_truncation = 123
	if (verbose_output):
		end = '\r\n'
	else:
		end = '\r'
	run_output = open(f"./output/{output_filename}.txt", "w")
	output("", terminal_output)
	while run_process.poll() is None:
		line = run_process.stdout.readline().decode('utf-8').rstrip('\r\n')
		if (line != ""):
			output(f">>> {line[:line_truncation]:<{line_truncation}}", terminal_output, end='')
			if (len(line) > line_truncation):
				output("...", terminal_output, end=end)
			else:
				output("", terminal_output, end=end)
			run_output.write(line + '\n')
	run_output.close()
	if (verbose_output):
		output("", terminal_output, end=f'\r{end_message} ')
	else:
		output("", terminal_output, end=f'\x1b[1A\r{end_message} ')