start_time_cache = {}
end_time_cache = {}

def time(simulation_no, step, terminal_output, post_text=".", clear_existing=False):
	from datetime import datetime
	from miscellaneous import output

	if ((clear_existing) or ((simulation_no, step) not in start_time_cache)):
		output.output(f"Starting {step}", terminal_output, end="... ", flush=True)

		start_time_cache[(simulation_no, step)] = datetime.now()

		return 0
	else:
		import math

		end_time_cache[(simulation_no, step)] = datetime.now()
		time_difference = end_time_cache[(simulation_no, step)] - start_time_cache[(simulation_no, step)]
		time_difference_seconds = math.ceil(time_difference.total_seconds())

		output.output(f"Done in {time_difference_seconds}s{post_text}", terminal_output, flush=True)

		return time_difference_seconds

