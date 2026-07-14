function savefigure(filepath)
%SAVEFIGURE Save the current figure to filepath (creates parent folders).
%   savefigure(filepath) writes PNG by default when the extension is .png,
%   otherwise uses the extension MATLAB recognizes. Matches usage in
%   makeCombinedFigures.m (dual export with / without legend).

if nargin < 1 || isempty(filepath)
    error('savefigure:MissingPath', 'Provide an output filepath.');
end

outdir = fileparts(filepath);
if ~isempty(outdir) && ~exist(outdir, 'dir')
    mkdir(outdir);
end

[~, ~, ext] = fileparts(filepath);
if isempty(ext)
    filepath = [filepath, '.png'];
    ext = '.png';
end

fig = gcf;
set(fig, 'PaperPositionMode', 'auto');

switch lower(ext)
    case {'.png'}
        print(fig, filepath, '-dpng', '-r300');
    case {'.pdf'}
        print(fig, filepath, '-dpdf', '-painters');
    case {'.eps'}
        print(fig, filepath, '-depsc', '-painters');
    case {'.fig'}
        savefig(fig, filepath);
    otherwise
        print(fig, filepath, '-dpng', '-r300');
end
end
