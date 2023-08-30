def select_no_threads(prev_threads, load_avg, max_threads, min_threads):
  import math

  a = max(min_threads, max_threads-load_avg+prev_threads)
  b = min(max_threads, a)
  no_threads = math.floor(b)

  return no_threads