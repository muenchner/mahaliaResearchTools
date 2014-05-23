function h = myfigure(xsize, ysize, varargin)
% function h = myfigure(xsize, ysize, varargin)
% myfigures creates a figure with width xsize (in inches) and height ysize
% (in inches)
%
% varargin can be anything that would normally be input to figure command
%
% Lynne Burks
% Stanford University
% September 19, 2013

htemp = figure('visible', 'off', 'units', 'inches', varargin{:});
pos = get(htemp, 'position');
close(htemp);

% xsize = xsize*1.15; % amplify slightly to account for matlab whitespace
% h = figure('units', 'inches', 'color', 'w', 'position', [pos(1:2), xsize, xsize * yamp * (pos(4)/pos(3))], varargin{:});
h = figure('units', 'inches', 'color', 'w', 'position', [pos(1:2), xsize, ysize], varargin{:});



