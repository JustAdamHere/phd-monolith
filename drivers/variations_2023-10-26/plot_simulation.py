from plotting import plot_velocity
from plotting import plot_transport
from miscellaneous import output_timer

run_nos = [1]

for run_no in run_nos:
  output_timer.time(run_no, "plotting", True)
  plot_velocity .plot(run_no,  "dg_velocity",  "placenta", str(run_no), '0', '1', '24', '1', '1', "placenta", '24', '0.0', '0.01', 25, False, True)
  plot_velocity .plot(run_no,  "dg_velocity",  "placenta", str(run_no), '0', '0', '24', '1', '1', "placenta", '24', '0.0', '0.01', 25, False, True)
  plot_transport.plot(run_no,  "dg_transport", "placenta", str(run_no), '0', '0', '24',           "placenta", '24', '0.0', '0.01', 25, False, True)
  output_timer.time(run_no, "plotting", True)