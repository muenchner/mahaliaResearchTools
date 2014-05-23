% This is code by Mahalia Miller
%make x and y data
x = linspace(-20, 20, 500); %500 linearly-spaced points between -20 and 20
a = 2;
b = 20;
y = a.*(x.^2) + b;

%now let us plot!
myfigure(3,2.5);%will output figure that is 3 inches wide, 2.5 inches tall
%the corresponding Latex command is: \includegraphics[width=3in]{test_fig_stable.pdf} 
filename = 'test_fig_stable';

plot(x,y, '-k',  'linewidth', 2)
% hold on 
% loglog(otherx, othery, '--b', 'linewidth', 2)
% hold off

hx = xlabel('k');
hy = ylabel('Energy');
% legh = legend('data', 'other data')
xlim([-10 10])
ylim([0 250])

preformat %defines axis_fontsize and label_fontsize
format_axes(axis_fontsize, label_fontsize, my_font, hx, hy);
print_figure(filename) %saves picture of size defined above as png and pdf

%make x and y data
x = linspace(-20, 20, 500); %500 linearly-spaced points between -20 and 20
a = 50;
b = 2;
c = 700;
y1 = a.*(x.^2) ;
y2=  a.*(x.^2)+500;

%now let us plot!
myfigure(3,2.5);%will output figure that is 3 inches wide, 2.5 inches tall
%the corresponding Latex command is: \includegraphics[width=3in]{test_fig_unstable.pdf} 
filename = 'test_fig_unstable';

plot(x,y1, '-k',  'linewidth', 2)
hold on 
% loglog(otherx, othery, '--b', 'linewidth', 2)
% hold off
plot(x,y2, '-k',  'linewidth', 2)
hx = xlabel('k');
hy = ylabel('Energy(k)');
% legh = legend('data', 'other data')
xlim([-10 10])
ylim([0 2500])

preformat %defines axis_fontsize and label_fontsize
format_axes(axis_fontsize, label_fontsize, my_font, hx, hy);
print_figure(filename) %saves picture of size defined above as png and pdf


