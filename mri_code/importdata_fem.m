function velocity = importdata_fem(dim, x_sample, filename_no_ext, aptofem_run_no, L, U, recompute_v_sample, type)
  % Assert it's either a placentone or a placenta simulation, or nothing if samples aren't recomputed.
  assert(type == "placentone" || type == "placenta" || (type == "" && ~recompute_v_sample));

  x_size = size(x_sample{1});

  if (recompute_v_sample)
    % Output the points we want.
    fileID = fopen(strcat('../output/mri-points_', filename_no_ext,'_',int2str(aptofem_run_no),'.dat'), 'w');

    if (dim == 2)
      x = reshape(x_sample{1}, x_size(1)*x_size(2), 1)./L;
      y = reshape(x_sample{2}, x_size(1)*x_size(2), 1)./L;

      fprintf(fileID, '%d\n', x_size(1)*x_size(2));
      for i = 1:x_size(1)*x_size(2)
        fprintf(fileID, '%16.8f\t%16.8f\n', x(i), y(i));
      end
    elseif (dim == 3)
      x = reshape(x_sample{1}, x_size(1)*x_size(2)*x_size(3), 1)./L;
      y = reshape(x_sample{2}, x_size(1)*x_size(2)*x_size(3), 1)./L;
      z = reshape(x_sample{3}, x_size(1)*x_size(2)*x_size(3), 1)./L;

      fprintf(fileID, '%d\n', x_size(1)*x_size(2)*x_size(3));
      for i = 1:x_size(1)*x_size(2)*x_size(3)
        fprintf(fileID, '%16.8f\t%16.8f\t%16.8f\n', x(i), y(i), z(i));
      end
    end

    fclose(fileID);

    fprintf('Running: ./evaluate-solution_bb.out %s %s %s %d > NUL\n', 'nsb', type, filename_no_ext, aptofem_run_no);

    % Call to program to evaluate the velocity field.
    system(sprintf('make -C ../programs/evaluate-solution > NUL'));
    cd    ('../programs/evaluate-solution/')
    system(sprintf('./evaluate-solution_bb.out %s %s %s %d > NUL', 'nsb', type, filename_no_ext, aptofem_run_no));
    cd    ('../../mri_code/')
  end

  % Import the solution data.
  data = readtable(strcat('../output/mri-solution_', filename_no_ext,'_',int2str(aptofem_run_no),'.dat'), "NumHeaderLines", 1, "ReadVariableNames", false);

  % Output
  velocity = cell(dim, 1);
  if (dim == 2)
    velocity{1} = U.*reshape(table2array(data(:, 1)), x_size(1), x_size(2));
    velocity{2} = U.*reshape(table2array(data(:, 2)), x_size(1), x_size(2));
  else if (dim == 3)
    velocity{1} = U.*reshape(table2array(data(:, 1)), x_size(1), x_size(2), x_size(3));
    velocity{2} = U.*reshape(table2array(data(:, 2)), x_size(1), x_size(2), x_size(3));
    velocity{3} = U.*reshape(table2array(data(:, 3)), x_size(1), x_size(2), x_size(3));
  end

end