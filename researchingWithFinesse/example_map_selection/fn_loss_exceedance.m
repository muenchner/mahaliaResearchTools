function [x,y] = fn_loss_exceedance(realizations, weights)
% Created by Mahalia Miller
% April 3, 2014

%This function calculates the loss exceedance curve values. 
%
% INPUTS:
% realizations        J x 1           Values
% weights             J x 1           Annual exceedance values for each realization 
%
% OUTPUTS:
% x                   J+1 x 1         The realization values in ascending order
% y                   J+1 x 1         The corresponding values of the loss exceedance curve

  %sort metric in ascending order (small to big)
  [x,I] = sort(realizations,1,'ascend'); %also returns an index matrix I.
  [r,c]=size(weights);
  new_weights = weights(I); %reordered

  %get cumulative sum of the weights to find annual likelihood of (metric>x)
  y = zeros(r,c);
  y(1) = sum(new_weights);

  for weight_index =1:length(new_weights)
    y(weight_index) =  sum(new_weights(weight_index+1:end));
  end
  y(y==0) = 0.0000000000000001; %log-log plots otherwise undefined
  x(x==0) = 0.0000000000000001; %log-log plots otherwise undefined
  x=[0.0000000000000001; x]; 
  y=[y(1); y];
end
