function [mpmce, mhce]  = fn_calculate_error(testing_return_periods, testing_sites, subset_indices_matlab, subset_weights, IM_full, IM, PM_proxy_full, PM_proxy, w_0_full)
    % Created by Mahalia Miller
    % April 3, 2014

    % This function computes the MHCE and MPMCE(proxy) of Equations 5 and 6 of Miller and Baker 2014.

    %
    % INPUTS:
    % testing_return_periods    R x 1        List of return periods used for testing
    % testing_sites             n x 1        List of sites for testing (all sites usually)
    % subset_indices_matlab     k x 1        List of indices of damage maps
    % selected by optimization (numbers range from 1 to J)
    % subset_weights            k x 1        List of annual rates of occurence for damage maps selected by optimization
    % IM_full               J_full x nu      Ground-motion intensity at sites used in optimization for each damage map
    % IM                    J x nu           Ground-motion intensity at sites used in optimization (a fraction) for each damage map
    % PM_proxy_full         J_full x 1       Proxy performance values for each damage map
    % PM_proxy              J x 1            Proxy performance values for each damage map (a fraction)
    % w_0_full              J_full x 1       Annual rate of occurrence for each damage map

    %
    % OUTPUTS:
    % mpmce                 1                Mean performance measure curve error 
    % mhce                  1                Mean hazard curve error


    %define constants
    R = length(testing_return_periods); %number of return periods
    n = length(testing_sites); %number of sites

    %define output matrices
    Y_irs = zeros(n, R); %each row is a different site and each column has the Y_{i,r} values (see Han and Davidson for an explanation)
    Y_rs = zeros(1, R); %


    %prune Sa_matrix
    IM_subset = IM(subset_indices_matlab, :); 

    hce = 0;
    for index_site = 1:n
        site = testing_sites(index_site);
        [x,y] = fn_loss_exceedance(log(IM_subset(:,site)), subset_weights); %SUBSET only
        x= x(end:-1:1); %lnIM
        y=y(end:-1:1); %rates
        y = y +  linspace(10^(-10), 10^(-9), length(y))'; %'This expects that the  y values extend past the min and max value of the return periods list -> can not interp1 otherwise
        y_hat_irs = interp1(y, x, 1./testing_return_periods); %1xR. y_hat_irs are lnIMs. 
        [x_full,y_full] = fn_loss_exceedance(log(IM_full(:,site)), w_0_full); %FULL
        x_full= x_full(end:-1:1); %lnIM
        y_full=y_full(end:-1:1); %rates
        y_full = y_full +  linspace(10^(-10), 10^(-9), length(y_full))' ;%'
        Y_irs(index_site, :) = interp1(y_full, x_full, 1./testing_return_periods); %whole matrix is IxR and we are filling one row at a time with lnSa
        for index_r = 1:R
            y_hat_ir = y_hat_irs(index_r); %lnIM values.
            Yir = Y_irs(index_site, index_r); %lnIM %1x1
            hce =hce + abs((exp(Yir) - exp(y_hat_ir))/exp(Yir)); %using IM so you need to do exp(lnIM)
            if sum(isnan(abs((exp(Yir) - exp(y_hat_ir))/exp(Yir))))>=1
                disp('oh my. not a number error')
                disp('index r')
                index_r
            end
            if sum(isinf(hce))>=1
                disp('oh my. inf');
            end
        end
    end
    mhce = hce/ (n*R); %normalize

    %now on to the performance metrics
    pmce = 0;

    %prune metric values to only include scenarios in the subset
    vals_subset = PM_proxy(subset_indices_matlab, :);

    [x_pm,y_pm] = fn_loss_exceedance(vals_subset, subset_weights); %SUBSET only
    x_pm= x_pm(end:-1:1);
    y_pm=y_pm(end:-1:1);
    y_pm = y_pm +  linspace(10^(-10), 10^(-9), length(y_pm))'; %'
    y_hat_rs = interp1(y_pm, x_pm, 1./testing_return_periods); %rates

    [x_pm_full,y_pm_full] = fn_loss_exceedance(PM_proxy_full, w_0_full); %FULL
    x_pm_full= x_pm_full(end:-1:1);
    y_pm_full=y_pm_full(end:-1:1);
    y_pm_full = y_pm_full +  linspace(10^(-10), 10^(-9), length(y_pm_full))'; %'
    Y_rs = interp1(y_pm_full, x_pm_full, 1./testing_return_periods); %rates %1xR

    for index_r = 1:R
        y_hat_r = y_hat_rs(index_r);
        yr = Y_rs(index_r);
        pmce = pmce + abs((yr - y_hat_r)/yr); 
    end
    mpmce =   pmce/R;
end
