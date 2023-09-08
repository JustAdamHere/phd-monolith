project_name = '2023-09-06 3D solution from Zak'
file_name    = 'slice-animation'
frame_rate   = 25

line_truncation = 100

import subprocess
print("Running ffmpeg... ")
command_list = ['ffmpeg', '-framerate', f'{frame_rate}', '-i', f'"/mnt/c/Users/adam/Dropbox/Documents/PhD/Miscellaneous/{project_name}/images/subplots/{file_name}.%04d.png"', '-vf', '\"drawtext=fontfile=Arial.ttf: text=\'%{frame_num}\': start_number=1: x=(w-tw)/2: y=h-(2*lh): fontcolor=black: fontsize=20: box=1: boxcolor=white: boxborderw=5\"', '-c:v', 'libx264', '-y', f'"/mnt/c/Users/adam/Dropbox/Documents/PhD/Miscellaneous/{project_name}/images/{file_name}.mp4"']
run_process = subprocess.Popen(" ".join(command_list), stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
# run_process = subprocess.run(" ".join(command_list), stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, check=False)

while run_process.poll() is None:
  # For some reason normal output gets put into the error stream.
  line = run_process.stderr.readline().decode('utf-8').rstrip('\r\n')
  print(f">>> {line[:line_truncation]:<{line_truncation}}", end='\r')

if (run_process.returncode != 0):
  print("\n\r⚠️ An error occured:")
  print(run_process.stderr.read().decode('utf-8'))
  print("🧑‍💻 Command run: ", end='')
  #print(" ".join(command_list), )
  print(" ".join(command_list))
else:
  print("Done.")