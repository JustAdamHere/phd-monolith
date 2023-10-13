def clean_directory(directory, file_extension = None, mode = 'move', to = None, prepend = '', exist_ok=False):
	import os

	# Checks how many files there are to move.
	file_counter = 0
	for item in os.listdir('./' + directory + '/'):
		if os.path.isfile(os.path.join('./' + directory + '/', item)):
			file_counter += 1

	if (file_counter > 0):
		from time import gmtime, strftime
		now = strftime("%Y-%m-%d %H%M%S", gmtime())

		# Deletes files.
		if (mode == 'delete'):
			for item in os.listdir('./' + directory + '/'):
				if (file_extension == None or (file_extension != None and item.endswith(file_extension))):
					if os.path.isfile(os.path.join('./' + directory + '/', item)):
						os.remove(os.path.join('./' + directory + '/', item))
						file_counter += 1
		# Moves or copies files.
		else:
			# Decide on target directory name.
			if to == None:
				new_directory_name = './' + directory + '/' + directory + '_' + now + '/'
			else:
				new_directory_name = to

			# Create the new directory.
			from pathlib import Path
			try:
				Path(new_directory_name).mkdir(exist_ok=exist_ok)
			except OSError as e:
				print(f"Error: {e.strerror}.")
				exit()

			# Perform the move or copy based on the chosen mode, and potentially rename with the prepended name.
			import shutil
			file_counter = 0
			for item in os.listdir('./' + directory + '/'):
				if (file_extension == None or (file_extension != None and item.endswith(file_extension))):
					if os.path.isfile(os.path.join('./' + directory + '/', item)):
						if (mode == 'move'):
							shutil.move(os.path.join('./' + directory + '/', item), new_directory_name)
						else:
							shutil.copy(os.path.join('./' + directory + '/', item), new_directory_name)
						if (prepend != ''):
							os.rename(os.path.join(new_directory_name + '/' + item), os.path.join(new_directory_name + '/' + prepend + '_' + item))
						file_counter += 1

	return file_counter