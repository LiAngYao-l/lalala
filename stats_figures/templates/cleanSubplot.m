function cleanSubplot(fs)
%CLEANSUBPLOT Apply LiAng default axes styling for publication figures.
%   cleanSubplot(fs) sets font size fs (default 26), box on, tick direction
%   out, and Interpreter none — matching makeCombinedFigures.m usage.
%
%   Place this folder on the MATLAB path, or call from stats_figures/templates/.

if nargin < 1 || isempty(fs)
    fs = 26;
end

ax = gca;
set(ax, ...
    'FontSize', fs, ...
    'FontName', 'Arial', ...
    'LineWidth', 1.5, ...
    'TickDir', 'out', ...
    'Box', 'on', ...
    'TickLabelInterpreter', 'none');
set(get(ax, 'XLabel'), 'FontSize', fs, 'Interpreter', 'none');
set(get(ax, 'YLabel'), 'FontSize', fs, 'Interpreter', 'none');
set(get(ax, 'Title'),  'FontSize', fs, 'Interpreter', 'none');
end
