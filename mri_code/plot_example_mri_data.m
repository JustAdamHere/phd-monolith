scan = niftiread('../../../Dropbox/Documents/PhD/Miscellaneous/2022-06-27 George MRI GUI/PiP_Ox_059_WIP_DWI_19bvalues_6_1.nii');
%scan = niftiread('./PiP_Ox_059_WIP_DWI_19bvalues_6_1.nii');

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
thres_S = 30000;
clim([0 thres_S])
set(gca,'XTick',[], 'YTick', [])
hold on
view(90,90)
rectangle('Position', [min(x_range) min(y_range) max(x_range)-min(x_range) max(y_range)-min(y_range)], 'EdgeColor', "#b30002", 'LineWidth', 4, "LineStyle", "-")
axis image
disp([min(img_tmp, [], "all") max(img_tmp, [], "all")])
disp(color_cutoff)
%exportgraphics(gca, './figure1.png')

% Zoomed-in MRI image.
figure(2)
clf
img_tmp = scan(y_range,x_range,slice_n,2);
imagesc(img_tmp)

% Custom colour map.
colormap gray
N = 256;
colors = [linspace(0, 1, ceil(N*thres_S/max_S)) linspace(1, 1, N - ceil(N*thres_S/max_S))];
cm = interp1(linspace(0, 1, N), colors, linspace(0, 1, N));
colormap([cm', cm', cm'])
clim([0 max_S])
cb = colorbar('eastoutside');
xlabel(cb, "$S$", 'Interpreter', 'latex')

set(gca,'XTick',[], 'YTick', [])
hold on
view(90,90)
%plot(x_val-min(x_range),y_val-min(y_range),'o','Color',"#b30002","LineWidth",4,"MarkerSize", 12)
rectangle('Position', [1 1 max(x_range)-min(x_range) max(y_range)-min(y_range)], 'EdgeColor', "#b30002", 'LineWidth', 4, "LineStyle", "-")
rectangle('Position', [x_val-min(x_range) y_val-min(y_range) 2 2], 'EdgeColor', "#005992", 'LineWidth', 4)
rectangle('Position', [x_val2-min(x_range) y_val2-min(y_range) 2 2], 'EdgeColor', "#008002", 'LineWidth', 4)
axis image
%disp([min(img_tmp, [], "all") max(img_tmp, [], "all")])
%disp(color_cutoff)
%exportgraphics(gca, './figure2.png')

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
%exportgraphics(gca, './figure3.png')

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
%exportgraphics(gca, './figure4.png')

% IVIM.
figure(5)
clf
load('../output/ivim_example-mri.mat')
% ivim_fit = zeros(256, 256, 4);
% parfor i = 1:256
%     for j = 1:256
%         S = squeeze(scan(j, i, slice_n, :));
% 
%         ivim_fit(i, j, :) = f_ivim_fit(S, b');
%     end
% end
colormap autumn
imagesc(ivim_fit(:, :, 2))
set(gca, 'XTick', [], 'YTick', [])
set(gca, 'YDir', 'normal')
axis equal
axis tight
% cb = colorbar('southoutside');
% clim([0 1])
% xlabel(cb, "$f_{\mathrm{IVIM}}$", 'Interpreter', 'latex')
rectangle('Position', [min(y_range) min(x_range) max(x_range)-min(x_range) max(y_range)-min(y_range)], 'EdgeColor', "#b30002", 'LineWidth', 4, "LineStyle", "-")
view(180,90)
%exportgraphics(gca, './figure5.png')

% IVIM.
figure(6)
clf
load('../output/ivim_example-mri.mat')
% ivim_fit = zeros(256, 256, 4);
% parfor i = 1:256
%     for j = 1:256
%         S = squeeze(scan(j, i, slice_n, :));
% 
%         ivim_fit(i, j, :) = f_ivim_fit(S, b');
%     end
% end
colormap autumn
imagesc(ivim_fit(x_range, y_range, 2))
set(gca, 'XTick', [], 'YTick', [])
set(gca, 'YDir', 'normal')
axis equal
axis tight

cb = colorbar('eastoutside');
clim([0 1])
xlabel(cb, "$f_{\mathrm{IVIM}}$", 'Interpreter', 'latex')

view(180,90)
rectangle('Position', [1 1 max(x_range)-min(x_range) max(y_range)-min(y_range)], 'EdgeColor', "#b30002", 'LineWidth', 4, "LineStyle", "-")
rectangle('Position', [y_val-min(y_range) x_val-min(x_range) 2 2], 'EdgeColor', "#005992", 'LineWidth', 4)
rectangle('Position', [y_val2-min(y_range) x_val2-min(x_range) 2 2], 'EdgeColor', "#008002", 'LineWidth', 4)
%exportgraphics(gca, './figure6.png')