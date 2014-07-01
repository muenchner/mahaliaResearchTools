Created by Mahalia Miller
April 3, 2014

This folder contains example calculations to demonstrate using optimization to choose a set of k damage maps and corresponding ground-motion intensity maps, each with a corresponding adjusted annual rate of occurrence, from a set of J candidate maps that provides a good representation of the earthquake hazard and performance risk. These calculations are based on the following paper:

Miller, M. K. and Baker, J. W. (2014). “Ground-motion intensity and damage map selection for probabilistic infrastructure network risk assessment using optimization.” Earthquake Engineering and Structural Dynamics, (in review).

Running this code uses the CVX modeling system for solving optimization problems together with the Gurobi solver, which is an industry performance leader in linear, quadratic, and mixed-integer programming. Both can be used in Matlab. 

Academic licenses for both CVX and Gurobi (which have full functionality for this application) are available for free (at no charge), and commercial licenses for both CVX and Gurobi can be purchased. Information about requesting the licenses and installing the packages for use in Matlab (or Python) is available here: http://cvxr.com/cvx/doc/gurobi.html

Note: a common problem with installation is that you get an error, "Gurobi MEX file could not find Gurobi License". If this error occurs, here is what you do to solve it. In the process of the instructions linked above, you run cvx_grbgetkey in Matlab with the proper license code. The result is that Gurobi and Matlab download a license file. If the license is not detected when you type cvx_setup in Matlab (as part of the instructions linked above), the license may be in the wrong location and/or have the wrong name. What to do? Figure out what your home directory is by typing getenv('userprofile') in Matlab. Then, move the downloaded license file (as described earlier in this paragraph) to this home directory. Finally, rename the file to gurobi.lic. The result is that when you call cvx_setup again from Matlab, it should work. Still have issues? Email support@cvxr.com. If you have trouble after that, you can email me at mahaliakmiller@gmail.com.

The following files are included in this folder:

subset_selection_main.m   	-- the main script to run the demonstration analyses (Equation 3 of the paper)
subset_selection_main_alternative.m   	-- the main script to run the demonstration analyses (Equation 4 of the paper)
fn_calculate_error.m  		-- a function that calculates the post-optimization error metrics defined in the above paper, MHCE and MPMCE
fn_loss_exceedance.m		-- a function that computes a loss exceedance curve, which is an intermediate step in the MHCE and MPMCE calculations 
fn_populate_matrices.m 		-- a function for pre-processing in both subset_selection_main.m and subset_selection_main_alternative.m
README_map_selection.txt	-- description of file contents and how to use the code
map_selection_example.mat -- a Matlab workspace containing sample input data that is used in the subset selection files above. There are three matrices in the workspace:
	%IM_full = ground-motion intensity at sample sites (n=3 for illustration, which correspond to Sa(T=1s) at sites 778, 61 and 856 of the paper dataset). Each row is a different ground-motion intensity map (m=2110,c=1 for illustration) and each column corresponds to a different site. 

	%PM_proxy_full = proxy performance measure values for each earthquake event. These are some easy to compute measure for your network, such as shortest path length between two nodes or the percentage of components damaged, here: (c=1 per event, i.e. one damage map per ground-motion intensity map) and the proxy performance measure is the percentage of bridges damaged. Each entry refers to one damage map.

	%w_0_full = annual rate of occurrence for each of the damage maps.

To run this with your own data, you'll first want to get ground motions for each of your sites (i.e., create a new IM_full) for a range of events (=ground-motion intensity maps). Each column of the IM_full matrix is a different site/component of interest and each row is a different ground-motion intensity map. Second, you need to calculate a summary statistic about your network performance for each of the ground-motion intensity maps (or multiple per ground-motion intensity maps if you want to do multiple realizations of damage maps per ground-motion intensity map, i.e. c>1). This summary statistic can be found by using a fragility function to sample a damage state realization at each site. Then, you can measure performance as percentage of sites in a specific damage state or worse. Or, you might want to damage the network based on the damage state at each component/site, and then calculate some easy-to-measure version of network performance, such as shortest path length between two nodes. You want to then create the PM-proxy_full matrix variable where each row corresponds to a different damage map (in the same order as the IM_full ground-motion intensity maps). This variable has only one column, since there is one number per damage map that summarizes network performance. Third, you need to have an annual rate of occurence for each of the damage maps. So, you want to create the variable w_0_full, which is a matrix with one column and each row corresponds to the damage maps in the rows of PM_proxy_full (same order).





