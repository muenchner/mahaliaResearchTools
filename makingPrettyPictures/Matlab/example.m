% this script gives an example usage of the figure formatting options

clear; clc; close all

axis_fontsize = 9;
label_fontsize = 10;
subplot_fontsize = 12;

myfigure(6, 2.5);% 6 inches wide, 2.5 inches tall
x = 0:10;
y = 0:10;

subplot(1,2,1)
plot(x, y, '-ok');
hold on
plot(x, y.^2, '-*r');
xlabel('x');
ylabel('y');
legend('linear', 'quadratic');
format_axes(axis_fontsize, label_fontsize);

subplot(1,2,2)
plot(x, y, '-ok');
hold on
plot(x, y.^3, '-*r');
xlabel('x');
ylabel('y');
legend('linear', 'cubic');
format_axes(axis_fontsize, label_fontsize);

subplot_labels(subplot_fontsize);

% print_figure(mfilename('fullpath'));





print_figure('test')