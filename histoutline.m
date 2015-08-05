function h = histoutline(xx, num, smooth, varargin)
% Plot a histogram outline.
% h = HISTOUTLINE(xx, num, varargin) Plot a histogram outline.
%
% HISTOUTLINE uses hist to do most of the work:
%
% HISTOUTLINE(...) produces a plot of the outline of the histogram of the
% results. 
%
% Example: 
%     data = randn(100, 1); 
%     histoutline(data, 50);
%
% See also HIST, HISTC, MODE.    
%
% Matt Foster <ee1mpf@bath.ac.uk>

if nargin < 3 || isempty(smooth)
    smooth = false;
end

if nargin < 1
    error('No input given');
end

% Default to standard number of histogram bins.
if nargin < 2
    num = 10;
end

[n,x] = histcounts(xx, num, varargin{:});
if smooth
    h = plot(x, cat(2,0,n));
else
    h = stairs(x, cat(2,0,n));
    % h = stairs(x, cat(2,n(1),n));
end