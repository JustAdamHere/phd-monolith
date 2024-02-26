scan = niftiread('../../../Dropbox/Documents/PhD/Miscellaneous/2022-06-27 George MRI GUI/PiP_Ox_059_WIP_DWI_19bvalues_6_1.nii');

% z-slice, and circle x-y location.
slice_n = 5;
x_val = 190;
y_val = 140;

% Plot typical MRI image.
figure(1)
img_tmp = scan_1(:,:,slice_n,2);
imagesc(img_tmp)
colormap gray
color_cutoff = 30000;
clim([0 color_cutoff])
set(gca,'XTick',[], 'YTick', [])
hold on
plot(x_val,y_val,'o','Color',"#b30002","LineWidth",4,"MarkerSize", 12)
disp([min(img_tmp, [], "all") max(img_tmp, [], "all")])
disp(color_cutoff)

% S-vs-b graph.
figure(2)
b = [0 1 3 9 18 32 54 88 110 147 180 200 230 270 300 350 400 450 500];
S = squeeze(scan(x_val, y_val, slice_n, :))/scan(x_val, y_val, slice_n, 1);
plot(b, S, '.', 'markersize', 20, 'linewidth', 1, 'color', [1 0 0])
hold on
plot(b, S, '--', 'markersize', 20, 'linewidth', 1, 'color', [1 0.25 0])
title("voxel (" + x_val + ', ' + y_val + ', ' + slice_n + ')')
xlabel('b')
ylabel('S/S_0')
ylim([0 1])

