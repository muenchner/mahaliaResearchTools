% Example calculations to demonstrate using optimization to choose a set of k damage maps and corresponding ground-motion intensity maps, each with a corresponding adjusted annual rate of occurrence, from a set of J candidate maps that provides a good representation of the earthquake hazard and performance risk. These calculations are based on the following paper:

%Miller, M. K. and Baker, J. W. (2014). ��Ground-motion intensity and damage map selection for probabilistic infrastructure network risk assessment using optimization.” Earthquake Engineering and Structural Dynamics, (in review).
%
% Created by Mahalia Miller
% April 3, 2014


%This code requires CVX with the Gurobi solver. More details for installation into Matlab including license information (free for academic use) is available at: http://cvxr.com/cvx/doc/gurobi.html
%Note: a common problem with installation is that you get an error, "Gurobi MEX file could not find Gurobi License". If this error occurs, here is what you do to solve it. In the process of the instructions linked above, you run cvx_grbgetkey in Matlab with the proper license code. The result is that Gurobi and Matlab download a license file. If the license is not detected when you type cvx_setup in Matlab (as part of the instructions linked above), the license may be in the wrong location and/or have the wrong name. What to do? Figure out what your home directory is by typing getenv('userprofile') in Matlab. Then, move the downloaded license file (as described earlier in this paragraph) to this home directory. Finally, rename the file to gurobi.lic. The result is that when you call cvx_setup again from Matlab, it should work. Still have issues? Email support@cvxr.com. If you have trouble after that, you can email me at mahaliakmiller@gmail.com.

clear all;
close all;
clc;

%This code corresponds to Equation 3 of the paper.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INPUTS
load map_selection_example 
%a Matlab workspace containing example data that is used in the subset selection files above. There are three matrices in the workspace:
	%IM_full = ground-motion intensity at sample sites (n=3 for illustration, which correspond to Sa(T=1s) at sites 778, 61 and 856 of the paper dataset). Each row is a different ground-motion intensity map (m=2110,c=1 for illustration) and each column corresponds to a different site. 

	%PM_proxy_full = proxy performance measure values for each earthquake event. These are some easy to compute measure for your network, such as shortest path length between two nodes or the percentage of components damaged, here: (c=1 per event, i.e. one damage map per ground-motion intensity map) and the proxy performance measure is the percentage of bridges damaged. Each entry refers to one damage map.

	%w_0_full = annual rate of occurrence for each of the damage maps.

%example_data: sites at which the optimization will try to match the intensity measure exceedance curve (could be less than the total (see paper for K-Means clustering technique) to reduce error and promote convergence). Sites defined by column index (1, ..., n) of the IM matrix
optimization_site_indices = [1,3]; %This can be changed!

%define minimum aannual rate of occurrence for ground-motion intensity map in IM_full
thresh = 10^(-5); %This can be changed!

%define fraction of the ground-motion intensity maps that will be inputted into the optimization (1 ground-motion intensity map per earthquake scenario works well in practice)
b = 5; %number of ground-motion intensity maps per earthquake scenario. Recommended value in practice is 5+. %This can be changed!
fraction = 1/b; %This can be changed!
IM  = IM_full(1:size(IM_full,1)*fraction,:);
PM_proxy = PM_proxy_full(1:size(PM_proxy_full,1)*fraction,:);
w_0 = w_0_full(1:size(w_0_full,1)*fraction, :).*b; %filter and re-weight

%filter IM_full matrix and PM_proxy_full to ground-motion intensity maps with an annual rate of occurrence greater than threshold
IM = IM(w_0>thresh, :);
PM_proxy = PM_proxy(w_0>thresh, :);
w_0 = w_0(w_0>thresh,:);

%define the return periods where you would like the loss exceedance curves
%to match.
min_return_period = 100; %years
max_return_period = 2500; %years
num_return_periods = 50; %number
testIng_return_periods = logspace(log10(min_return_period), log10(max_return_period), num_return_periods);  %50 return periods equally spaced in base 10 log space between 100 and 2500 years. (Can be changed if need be, but should not be necessary)
optimization_return_periods = testing_return_periods; %define the return periods at which the optimization will try to match the intensity measure exceedance curve (could be less than the total) to promote convergence. This can be changed!

k = 25; %target number of pairs of damage maps and ground-motion intensity values in final output. This can be changed!
alpha = 5/9; %This controls the contribution from the ground-motion intensity versus the performance measure. This can be changed! 
MIP_gap = 0.2; %sets the optimality gap as 20% instead of the default of 0.01%. This can be changed! 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PRE-PROCESSING
%The equation below follows equation 3 of this paper

n = size(IM,2); %define the number of sites
J = length(PM_proxy);
candidate_map_indices = 1:J;
testing_site_indices = 1:n; %all site indices
R= length(optimization_return_periods);
nu = length(optimization_site_indices);

%Define THETA and PSI (equation 3)
THETA = zeros(nu*R,J);

%for the first site, also get the performance metric value for the whole network.
site = optimization_site_indices(1);
[THETA_1, PSI] = fn_populate_matrices(site, IM_full, IM, PM_proxy_full, PM_proxy, w_0_full,  optimization_return_periods, 1);
THETA(1:R, :) = THETA_1; %each submatrix piece is R x J

%since the performance metric values are independent of the site, the following loop does not recompute them. 
for i=2:nu
    site = optimization_site_indices(i);
    [THETA_i, ~ ] = fn_populate_matrices(site, IM_full, IM, PM_proxy_full, PM_proxy, w_0_full,  optimization_return_periods, 0);
    THETA(1+(i-1)*R:i*R, :) =THETA_i; %each submatrix piece is R x J
end

lambdas_R = diag(optimization_return_periods);
lambdas_IR =  diag(repmat(optimization_return_periods,1,nu));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%OPTIMIZATION (Equation 3)
fprintf(1,'Here are your [nu, J, R]: [%3.4f, %3.4f, %3.4f]\n', [nu, J, R]);
fprintf(1,'The desired k is %3.4f.\n', k);

cvx_solver gurobi %If this does not work, you need to get a license and install. Instructions here: http://cvxr.com/cvx/doc/gurobi.html
%read how it works here: http://www.gurobi.com/resources/getting-started/mip-basics
cvx_solver_settings( 'MIPgap', MIP_gap) %this sets the optimality gap instead of the default 0.01%. The MIP solver will terminate (with an optimal result) when the relative gap between the lower and upper objective bound is less than MIPGap times the upper bound.
tic %start counting time
cvx_begin

% Define optimization variables
variable w(J,1)
variable z(J,1) binary %forces these to be 0 or 1
%Define the objective function (Equation 3a)
minimize( alpha * norm(ones(R,1) - lambdas_R * PSI * w, 1)+ (1 - alpha) *norm(ones(nu*R,1) - lambdas_IR * THETA * w, 1)) 

%Define the constraints 
subject to
sum(z) <= k; %Based on Equation 3b
0 <=  w    <= z; %Inequality and equality constraints are applied in an elementwise fashion %Based on Equation 3c
sum(z) <= k;

cvx_end
toc %stop counting time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%POST-PROCESSING
tot = round(sum(z(w>thresh))); %count the nubmer of maps greater than annual rate of occurrence threshold
fprintf(1,'The number of maps greater than threshold is %3.4f ', tot);
fprintf(1,'out of %3.4f.\n', round(sum(z)));

%determine the indices of the selected maps and the adjusted annual rates of occurrence of each 
relevant_weights = w(z==1);
subset_weights = relevant_weights(w(z==1)>thresh);
subset_indices_matlab = candidate_map_indices(z==1);
subset_indices_matlab = subset_indices_matlab(w(z==1)>thresh);
fprintf(1,'The sum of relevant weights is %3.4f.\n', sum(subset_weights));
fprintf(1,'And to check the number of maps greater than the threshold is consistent, the final number of maps is %3.4f.\n', length(subset_weights));

%compute the MHCE (Equation 5) and MPMCE (Equation 6)
[mpmce, mhce]  = fn_calculate_error(testing_return_periods, testing_site_indices, subset_indices_matlab, subset_weights, IM_full, IM, PM_proxy_full, PM_proxy, w_0_full); 
fprintf(1,'MPMCE (proxy): %3.4f.\n', mpmce);
fprintf(1,'MHCE: %3.4f.\n', mhce);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FIGURES

%plot loss exceedance curve of the full set and the selected subset (IM at third site)
[x_full, y_full] = fn_loss_exceedance(IM_full(:,optimization_site_indices(2)), w_0_full);
[x_subset, y_subset] = fn_loss_exceedance(IM(subset_indices_matlab,optimization_site_indices(2)),subset_weights); 

figure
loglog(x_subset, y_subset, '-k', 'linewidth', 2)
hold on
h0 = fill([0.001 0.001 10 10], [1/max(optimization_return_periods) 1/min(optimization_return_periods) 1/min(optimization_return_periods) 1/max(optimization_return_periods)], [0.95 0.95 0.95],  'EdgeColor', 'none');
hold on
h2 = loglog(x_full, y_full, '--k', 'linewidth', 1);
hold on
h1 = loglog(x_subset, y_subset, '-k', 'linewidth', 2);
hold off
legh = legend([h1,h2,h0],{'Subset', 'Baseline','Range where optimization relevant'});
set(legh, 'fontsize', 12);
hx = xlabel('IM', 'Fontsize', 14);
hy = ylabel('Annual exceedance rate, \lambda_Y', 'Fontsize', 14);
ylim([thresh 0.2])
xlim([0.01 5])

%plot loss exceedance curve of the proxy performance measure
[x_full, y_full] = fn_loss_exceedance(PM_proxy_full, w_0_full);
[x_subset, y_subset] = fn_loss_exceedance(PM_proxy(subset_indices_matlab), subset_weights);

figure
loglog(x_subset, y_subset, '-k', 'linewidth', 2);
hold on
h0 = fill([0.001 0.001 10 10], [1/max(optimization_return_periods) 1/min(optimization_return_periods) 1/min(optimization_return_periods) 1/max(optimization_return_periods)], [0.95 0.95 0.95],  'EdgeColor', 'none');
hold on 
h2 = loglog(x_full, y_full, '--k', 'linewidth', 1);
hold on 
h1= loglog(x_subset, y_subset, '-k', 'linewidth', 2);
hold off
legh = legend([h1,h2,h0],{'Subset', 'Baseline','Range where optimization relevant'});
set(legh, 'fontsize', 12);
hx = xlabel('Proxy performance measure', 'Fontsize', 14);
hy = ylabel('Annual exceedance rate, \lambda_X', 'Fontsize', 14);
ylim([thresh 0.2])
xlim([0.01 0.5])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NEXT STEPS
%The next step is to compute the target performance measure for the damage
%maps of the indices in the subset_indices_matlab variable. Enjoy!