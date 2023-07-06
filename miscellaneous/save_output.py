def save_output(run_output, program, geometry, run_no):
	open(f"./output/{program}_{geometry}_{run_no}.txt", "w").write(run_output.stdout.decode("utf-8"))