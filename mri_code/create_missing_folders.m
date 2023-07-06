function [found] = create_missing_folders(folder_name)

  found = exist(folder_name, 'dir');

  if (~found)
    mkdir(folder_name);
  end

end