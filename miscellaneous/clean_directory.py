def clean_directory(directory, file_extension = None):
	import os

	file_move_counter = 0
	for item in os.listdir('./' + directory + '/'):
		if os.path.isfile(os.path.join('./' + directory + '/', item)):
			file_move_counter += 1

	if (file_move_counter > 0):
		from time import gmtime, strftime
		now = strftime("%Y-%m-%d %H%M%S", gmtime())

		from pathlib import Path
		new_directory_name = './' + directory + '/' + directory + '_' + now + '/'

		try:
			Path(new_directory_name).mkdir(exist_ok=False)
		except OSError as e:
			print(f"Error: {e.strerror}.")
			exit()

		import shutil
		file_move_counter = 0
		for item in os.listdir('./' + directory + '/'):
			if (file_extension == None or (file_extension != None and item.endswith(file_extension))):
				if os.path.isfile(os.path.join('./' + directory + '/', item)):
					shutil.move(os.path.join('./' + directory + '/', item), new_directory_name)
					file_move_counter += 1

	return file_move_counter