% Should be same for each voxel.
voxel = 1;

fig = figure();
plot(b, max(G{voxel}, [], 2))
hold on
plot(b, min(G{voxel}, [], 2))
print(fig, '-dpng', strcat('../', 'images/', filename_no_ext, '_g-vs-b_', num2str(voxel), '.png'))
close(fig)
pause(0.01)