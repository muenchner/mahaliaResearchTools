function subplot_labels(fontsize, xtext, ytext, varargin)
% function subplot_labels(hfig, xtext, ytext)
% adds labels like (a), (b), (c), ... (z) on subplots of current figure
% 
%
% OPTIONAL INPUTS
% fontsize = fontsize for label, default = 28
% xtext = x location of text label (normalized units), default = 0.02
% ytext = y location of text label (normalized units), default = 0.98
% varargin = other inputs to the 'text' function, in the same format as
%            required by 'text', ex) 'fontsize', 14
%
% Lynne Burks
% Stanford University
% September 19, 2013

% make compatible with previous version (first arguent was figure handle)
if ishandle(fontsize)
    if nargin==1
        fontsize = 28;
        xtext = 0.02;
        ytext = 0.98;
    else
        fontsize = 28;
    end
end

% new version
if nargin==0
    fontsize = 28;
    xtext = 0.02;
    ytext = 0.98;
elseif nargin==1
    xtext = 0.02;
    ytext = 0.98;
end

ch = findall(gcf, 'type', 'axes');
ch = ch(~ismember(get(ch, 'tag'), {'legend', 'colobar'}));
% ch = ch(~ismember(get(ch, 'visible'), {'off'}));
for i=1:length(ch)
    set(gcf, 'currentaxes', ch(i));
    text(xtext, ytext, ['(' char(97 + length(ch) - i) ')'], 'units', 'normalize', 'verticalalignment', 'top', 'fontsize', fontsize, varargin{:});
end
    