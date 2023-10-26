def select_no_threads(prev_threads, load_avg, max_threads, min_threads):
  import math

  a = max(min_threads, max_threads-load_avg+prev_threads)
  b = min(max_threads, a)
  no_threads = math.floor(b)

  return no_threads

def read_no_threads(default_no_threads):
  try:
    file = open(f"./output/monolith_no_threads.txt", "r")
  except:
    file = open(f"./output/monolith_no_threads.txt", "w")
    file.write(f"{default_no_threads}")
    file.close()
    file = open(f"./output/monolith_no_threads.txt", "r")
    
  no_threads = int(file.read())
  file.close()

  return int(no_threads)