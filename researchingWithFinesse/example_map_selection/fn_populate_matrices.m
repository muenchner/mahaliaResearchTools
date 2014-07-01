function [ THETA_I, PSI ] = fn_populate_matrices(site, IM_full, IM, PM_proxy_full, PM_proxy, w_0_full,  return_periods, do_pm_boolean)
% Created by Mahalia Miller
% April 3, 2014

% This function populates some of the matrices required as input into the optimization formulation

%
% INPUTS:
% site 				1 					Index of the site of interest
% IM_full            J_full x nu         Ground-motion intensity at sites used in optimization for each damage map
% IM       			J x nu  			Ground-motion intensity at sites used in optimization (a fraction) for each damage map
% PM_proxy_full 	J_full x 1          Proxy performance values for each damage map
% PM_proxy 			J x 1 				Proxy performance values for each damage map (a fraction)
% w_0_full			J_full x 1 			Annual rate of occurrence for each damage map
% return_periods 	R x 1 				List of return periods used in optimization
% do_pm_boolean  	1 					Boolean that is 1 when calculating the performance value is desired and 0 otherwise. (saves computational expense)
%
% OUTPUTS:
% THETA_I       	R x J           	Each entry is the theta(i,r,j') ground-motion intensity-related values for the ith site (see paper, section 3)
% PSI         		R x J           	Each entry is the psi(r,j') performance measure-related values (see paper, section 3)


	%define constants
	R = length(return_periods);
	J = size(IM,1);
	%first, determine what the Y_ir values are, in other words what the "true" IM values should be at a given site and return period
	[x_full,y_full] = fn_loss_exceedance(log(IM_full(:,site)), w_0_full); %FULL
	%We are assuming that x is the IM
	x_full= x_full(end:-1:1);
	y_full=y_full(end:-1:1);
	y_full = y_full +  linspace(10^(-10), 10^(-9), length(y_full))'; 
	Y_irs= interp1(y_full, x_full, 1./return_periods); %interpolate to find the IM values at these return periods

	%now populate matrix piece
	THETA_I = zeros(R, J); %just a piece of the total
	for index_j = 1:J
	    for index_r = 1:R
	        y_ij = log(IM(index_j, site));
	        Y_ir = Y_irs(index_r);
	        if y_ij >= Y_ir
	            THETA_I(index_r, index_j) = 1;
	        end
	    end
	end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%now do performance matrix piece (called PSI in Section 3 of Miller and Baker paper, the R x J matrix in equation 3(a))
	if do_pm_boolean == 1
		%now, again, the first thing to do is to determine what the Y_r values are, in other words what the "true" performance metric values should be at a given return period
		[x_pm_full,y_pm_full] = fn_loss_exceedance(PM_proxy_full, w_0_full); %FULL
		x_pm_full= x_pm_full(end:-1:1);
		y_pm_full=y_pm_full(end:-1:1);
		y_pm_full = y_pm_full +  linspace(10^(-10), 10^(-9), length(y_pm_full))'; 
		Y_rs = interp1(y_pm_full, x_pm_full, 1./return_periods); %interpolate to find the PM values at these return periods

		%now populate matrix 
		PSI = zeros(R, J); 
		for index_j = 1:J
		    for index_r = 1:R
		        y_j = PM_proxy(index_j);
		        Y_r = Y_rs(index_r);
		        if y_j >= Y_r
		            PSI(index_r, index_j) = 1;
		        end
		    end
        end
	else
		PSI = [];
	end
end
