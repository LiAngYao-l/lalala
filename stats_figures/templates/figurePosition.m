function pos = figurePosition(wh)
%FIGUREPOSITION Return a centered figure Position [left bottom width height].
%   pos = figurePosition([width height]) uses screen size to center the window.
%   Matches makeCombinedFigures.m calls like figurePosition([630 630]).

if nargin < 1 || numel(wh) < 2
    wh = [560 560];
end
w = wh(1);
h = wh(2);

scr = get(0, 'ScreenSize');  % [1 1 width height]
left = max(1, round((scr(3) - w) / 2));
bottom = max(1, round((scr(4) - h) / 2));
pos = [left, bottom, w, h];
end
