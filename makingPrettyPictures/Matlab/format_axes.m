function format_axes(axis_size, label_size, my_font, hx, hy)
% function format_axes(axis_size, label_size)
% formats fontsize of all current axis elements
% 
% INPUTS
% axis_size = fontsize for axis and legend
% label_size = fontsize for axis labels
% 
% Lynne Burks
% Stanford University 
% September 19, 2013

%remove bounding box
box off

%set the font. Default is helvetica
if nargin<3
    my_font = 'Helvetica';
end

% set fontsize for axis and all labels
set(gca, 'fontsize', axis_size, 'fontname', my_font);
set(get(gca, 'xlabel'), 'fontsize', label_size, 'fontname', my_font);
set(get(gca, 'ylabel'), 'fontsize', label_size, 'fontname', my_font);
set(get(gca, 'zlabel'), 'fontsize', label_size, 'fontname', my_font);
set(get(gca, 'title'), 'fontsize', label_size, 'fontname', my_font);
if nargin > 3
    set(hx, 'fontsize', label_size, 'fontname', my_font);
end
if nargin > 4
    set(hy, 'fontsize', label_size, 'fontname', my_font);
end

% set fontsize for legend, if it exist
legh = findobj(gcf, 'type', 'axes', 'tag', 'legend');
if ~isempty(legh)
    set(legh, 'fontsize', axis_size, 'fontname', my_font);
    legend('boxoff')
end


