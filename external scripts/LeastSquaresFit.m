function [c, c_sig, stats, eqn] = LeastSquaresFit(xdata, ydata, xerr, yerr, model)
% LeastSquaresFit() fits the data on a line using the least squares method. The 
% errors of both variables are taken into account. 
% For non-linear fits, i.e. of the form y = ax^b, a linear transformation is  
% performed a priori. So, in a sense, in these special cases, the fit is not a
% least squares fit but an approximation.

% This code is an extenstion of: 
% https://github.com/tamaskis/lsqcurvefit_approx-MATLAB

% Bibliography:
%   [1] Hugh W. Coleman, W. Glenn Steele Experimentation, Validation,
%       and Uncertainty Analysis for Engineers, p. 246 

%   [2] Bevington, Philip R. / Robinson, D. Keith 
%       Data Reduction and Error Analysis for the Physical Sciences, p. 102

%   [3] Taylor, John R. Introduction to Error Analysis, The Study of Uncertainties
%       in Physical Measurements, p. 181

%   [4] Linearizing the Equation. MacEwan University Physics Laboratories.
%       \textrm{https://academic.macewan.ca/physlabs/Linearization.pdf} (accessed: October 31, 2021).

%   [5] Linear Models (Stat 305a). Stanford University.
%       \textrm{https://statweb.stanford.edu/~owen/courses/305a/ch2.pdf}
%       (accessed: October 31, 2021).

%   [6] Lyons, Louis A Practical Guide to Data Analysis for Physical Science Students, p. 44 
    
    % reverse the vector data (if needed) 
    if size(xdata, 1) < length(xdata)
        xdata = xdata(:);
    end
    if size(ydata, 1) < length(ydata)
        ydata = ydata(:);
    end
    if size(xerr, 1) < length(xerr)
        xerr = xerr(:);
    end
    if size(yerr, 1) < length(yerr)
        yerr = yerr(:);
    end
    
    % default fit 
    if nargin == 4
        model = 'linear';
    end
    
    % error contribution of x (xerr) to the total uncertainty y (sigma)
    show_warning = false;
    if strcmpi(model, 'linear')
        X       = [ones( size(xdata) ) xdata];
        a_fit   = X \ ydata; 
        sigmaTr = abs( a_fit(2) ) * xerr; % absolute value of the derivative of y = mx + b
        sigma   = sqrt(yerr .^ 2 + sigmaTr .^ 2); % total error 

    % linear transformation    
    elseif strcmpi(model, 'power')
        if (sum(xdata < 0) > 0) || (sum(ydata < 0) > 0),...
                show_warning = true; end
        yerr    = yerr./ydata;  
        xerr    = xerr./xdata;  
        xdata   = real( log(xdata) );
        ydata   = real( log(ydata) );
        X       = [ones( size(xdata) ) xdata];
        a_fit   = X \ ydata;
        sigmaTr = abs( a_fit(2) ) * xerr; %
        sigma   = sqrt(yerr .^ 2 + sigmaTr .^ 2);
    end
    
    % warning in case the linearised data points are negative 
    if show_warning
        warning("One or more linearized data points were complex. "+...
            "To proceed, only the real part of these points were used.");
    end

    % pairs of data and creating the error matrix 
    M = length(ydata);
    b = ydata ./ sigma;
    
    % create X matrix 
    X = zeros(M, 2);
    for i = 1:M
        for j = 1:2
            X(i,j) = xdata(i)^(j-1)/sigma(i);
        end
    end
    
    % correlation matrix 
    Corr = inv(X' * X);
    
    % solution to least square problem (see [5])
    a_hat = X\b;
    
    % uncertainties of linear fit coefficients 
    c_sig = zeros(2, 1);
    for j = 1:2
        c_sig(j) = sqrt( Corr(j, j) );
    end
    
    % values of fitted data 
    func = zeros(length(xdata), 1);
    for i = 1:2
        func = func + a_hat(i) * xdata .^ (i-1);
    end
    
    y_bar = mean(ydata);
    
    % statistics of linear fit 
    SS_tot = sum( ((ydata - y_bar) ./ sigma) .^ 2 );
    chisqr = sum( ((ydata - func) ./ sigma) .^ 2 );
    rsqr = 1 - (chisqr/SS_tot);
    rmse = sqrt( sum( ((ydata - func) .^ 2) / M ) );
    stats = [rsqr, chisqr, rmse];
    
    % linear fit coefficients 
    if strcmpi(model, 'linear')
        m = a_hat(2);
        b = a_hat(1);
    elseif strcmpi(model, 'power')
        c_sig(1) = c_sig(1) * exp( a_hat(1) );
        a = exp( a_hat(1) );
        b = a_hat(2);
    end
    
    if strcmpi(model, 'linear')
        c = [m;b];
    elseif strcmpi(model, 'power')
        c = [a;b];
    end
    
    % fitted equations 
    if strcmpi(model, 'linear')
        if b >= 0
            eqn = "$y="+M+"x"+"+"+b+"$";
        else
            eqn = "$y="+M+"x"+b+"$";
        end
    elseif strcmpi(model, 'power')
        eqn = "$y="+a+"x^{"+b+"}$";
    end
end
