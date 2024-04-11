scan = niftiread('../../../Dropbox/Documents/PhD/Miscellaneous/2022-06-27 George MRI GUI/PiP_Ox_059_WIP_DWI_19bvalues_6_1.nii');

% z-slice, and circle x-y location.
slice_n = 5;
x_val = 190;
y_val = 140;
x_val2 = 192;
y_val2 = 139;
x_range = x_val-25:x_val+25;
y_range = y_val-25:y_val+25;

% Plot typical MRI image.
figure(1)
clf
img_tmp = scan(:,:,slice_n,2);
imagesc(img_tmp)
colormap gray
color_cutoff = 30000;
clim([0 color_cutoff])
set(gca,'XTick',[], 'YTick', [])
hold on
view(90,90)
rectangle('Position', [min(x_range) min(y_range) max(x_range)-min(x_range) max(y_range)-min(y_range)], 'EdgeColor', "#b30002", 'LineWidth', 4, "LineStyle", "-")
axis image
disp([min(img_tmp, [], "all") max(img_tmp, [], "all")])
disp(color_cutoff)

% Zoomed-in MRI image.
figure(2)
clf
img_tmp = scan(y_range,x_range,slice_n,2);
imagesc(img_tmp)
colormap gray
color_cutoff = 30000;
clim([0 color_cutoff])
set(gca,'XTick',[], 'YTick', [])
hold on
view(90,90)
%plot(x_val-min(x_range),y_val-min(y_range),'o','Color',"#b30002","LineWidth",4,"MarkerSize", 12)
rectangle('Position', [1 1 max(x_range)-min(x_range) max(y_range)-min(y_range)], 'EdgeColor', "#b30002", 'LineWidth', 4, "LineStyle", "-")
rectangle('Position', [x_val-min(x_range) y_val-min(y_range) 2 2], 'EdgeColor', "#005992", 'LineWidth', 4)
rectangle('Position', [x_val2-min(x_range) y_val2-min(y_range) 2 2], 'EdgeColor', "#008002", 'LineWidth', 4)
axis image
disp([min(img_tmp, [], "all") max(img_tmp, [], "all")])
disp(color_cutoff)

% S-vs-b graph 1.
figure(3)
clf
b = [0 1 3 9 18 32 54 88 110 147 180 200 230 270 300 350 400 450 500];
S = squeeze(scan(y_val, x_val, slice_n, :))/scan(y_val, x_val, slice_n, 1);
plot(b, S, '--', 'markersize', 20, 'linewidth', 1, 'color', "#0087de")
hold on
plot(b, S, '.', 'markersize', 20, 'linewidth', 1, 'color', "#005992")
title("voxel (" + x_val + ', ' + y_val + ', ' + slice_n + ')')
xlabel('b')
ylabel('S/S_0')
ylim([0 1])

% S-vs-b graph 2.
figure(4)
clf
b = [0 1 3 9 18 32 54 88 110 147 180 200 230 270 300 350 400 450 500];
S = squeeze(scan(y_val2, x_val2, slice_n, :))/scan(y_val2, x_val2, slice_n, 1);
plot(b, S, '--', 'markersize', 20, 'linewidth', 1, 'color', "#00cc03")
hold on
plot(b, S, '.', 'markersize', 20, 'linewidth', 1, 'color', "#008002")
title("voxel (" + x_val2 + ', ' + y_val2 + ', ' + slice_n + ')')
xlabel('b')
ylabel('S/S_0')
ylim([0 1])
