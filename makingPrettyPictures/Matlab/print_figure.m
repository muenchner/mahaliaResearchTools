% This is code by Jack Baker, Lynne Burks and Mahalia Miller
function print_figure(filename)
% function print_figure(filename)
% prints figure to eps filetype
% don't include *.eps extension in filename!
% 
% based on code by Lynne Burks
% Stanford University


set(gcf, 'paperpositionmode', 'auto');
% print('-depsc', [filename '.eps'], '-loose');
print('-depsc', [filename '.eps']);
print('-dpng', [filename '.png']);
print('-dpdf', [filename '.pdf']);
print('-dtiff', [filename '.tiff'])
% print(gcf,'-depsc2','-adobecset','-painter', [filename '.ai'], '-loose');
