def plot(sim_no: str, problem: str, name: str, run_no: str, mesh_no : str, log_coloring: str, colorbar_fontsize: str, plot_type: str, time_fontsize: str, time_shift: str, time_scale: str, framerate: int, delete_pngs: bool, ss_transport: bool):
	import os
	paraview_binary = '/home/pmyambl/software/ParaView-5.10.0-osmesa-MPI-Linux-Python3.9-x86_64/bin/pvpython'

	base_directory         = os.getcwd() + '/'
	filename_no_ext_regex  = f'meshandsoln_{problem}_{name}_{run_no}_{mesh_no}'
	filename_no_ext_output = f'meshandsoln_{problem}_{name}_{sim_no}'

	import subprocess
	try:
		paraview_output = subprocess.run([paraview_binary, './plotting/pvplot_transport.py', filename_no_ext_regex, filename_no_ext_output, base_directory, log_coloring, colorbar_fontsize, plot_type, time_fontsize, time_shift, time_scale], cwd=os.getcwd(), stdout=subprocess.PIPE, check=True)
	except subprocess.CalledProcessError as e:
		raise_error(e)

	if (log_coloring == '1'):
		coloring = 'log'
	else:
		coloring = 'linear'

	if (not ss_transport):
		try:
			ffmpeg_output = subprocess.run(['ffmpeg', '-framerate', str(framerate), '-pattern_type', 'glob', '-i', f'{base_directory}images/{filename_no_ext_output}_transport-{coloring}.*.png', '-c:v', 'libx264', '-pix_fmt', 'rgb24', '-y', '-loglevel', 'error', '-hide_banner', f'{base_directory}images/{filename_no_ext_output}_transport-{coloring}.mp4'], cwd=os.getcwd(), stdout=subprocess.PIPE, check=True)
		except subprocess.CalledProcessError as e:
			raise_error(e)

		if delete_pngs:
			import glob, os
			for file in glob.glob(f'{base_directory}images/{filename_no_ext_output}_transport-{coloring}.*.png'):
				os.remove(file)


def raise_error(e):
	print("##########################################################")
	print("## ❌ ERROR CAUGHT IN PVPYTHON PLOT TRANSPORT; STOPPING ##")
	print("##########################################################")
	print(e.output)
	exit()

