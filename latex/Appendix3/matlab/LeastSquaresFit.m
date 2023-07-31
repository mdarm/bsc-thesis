function [c, c_sig, stats, eqn] = LeastSquaresFit(xdata, ydata, xerr, yerr, model)
% Συνάρτηση γραμμικής παρεμβολής, χρησιμοποιώντας τη μέθοδο Ελαχίστων
% Τετραγώνων, λαμβάνοντας υπόψη αβεβαιότητες και των δύο μεταβλητών $(x_i, y_i)$.
% Για μη γραμμικά μοντέλα της μορφής $y = \alpha x ^ {\beta}$, προηγείται
% γραμμικός μετασχηματισμός.

% O κώδικας είναι μια προέκταση της συνάρτησης
% \verb!https://github.com/tamaskis/lsqcurvefit_approx-MATLAB!

% Σχετική βιβλιογραφία:
%   [1] Hugh W. Coleman, W. Glenn Steele Experimentation, Validation,
%       and Uncertainty Analysis for Engineers, σελ. 246 
%
%   [2] Bevington, Philip R. / Robinson, D. Keith Data Reduction and Error
%       Analysis for the Physical Sciences, σελ. 102
%
%   [3] Taylor, John R. Introduction to Error Analysis, The Study of Uncertainties
%       in Physical Measurements, σελ. 181
%
%   [4] Linearizing the Equation. MacEwan University Physics Laboratories.
%       \textrm{https://academic.macewan.ca/physlabs/Linearization.pdf} (accessed: October 31, 2021).
%
%   [5] Linear Models (Stat 305a). Stanfor University.
%       \textrm{https://statweb.stanford.edu/~owen/courses/305a/ch2.pdf}
%       (accessed: October 31, 2021).
%
%   [6] Lyons, Louis A Practical Guide to Data Analysis for Physical Science Students,
%       σελ. 44 

    % Αναστροφή πινάκων (αν χρειαστεί)
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
    
    % Αυτόματη επιλόγη
    if nargin == 4
        model = 'linear';
    end
    
    % Συνεισφορά αβεβαιότητας x (xerr) στη συνολική αβεβαιότητα του y (sigma)
    show_warning = false;
    if strcmpi(model, 'linear')
        X       = [ones( size(xdata) ) xdata];
        a_fit   = X\ydata; 
        sigmaTr = abs( a_fit(2) ) * xerr; % $\sigma_{tra} = |\sigma_x| \frac{d (mx + b)}{d x}$
        sigma   = sqrt(yerr .^ 2 + sigmaTr .^ 2);
    % Γραμμικός μετασχηματισμός    
    elseif strcmpi(model, 'power')
        if (sum(xdata < 0) > 0) || (sum(ydata < 0) > 0), show_warning = true; end
        yerr    = yerr ./ ydata; % $\sigma_{lny} = |\sigma_y| \frac{d (lny)}{d y}$
        xerr    = xerr ./ xdata; % $\sigma_{lnx} = |\sigma_x| \frac{d (lnx)}{d x}$
        xdata   = real( log(xdata) );
        ydata   = real( log(ydata) );
        X       = [ones( size(xdata) ) xdata];
        a_fit   = X\ydata;
        sigmaTr = abs( a_fit(2) ) * xerr; % $\sigma_{tra} = |\sigma_x| \frac{d (mx + b)}{d x}$
        sigma   = sqrt(yerr .^ 2 + sigmaTr .^ 2);
    end
    
    % Προειδοποίηση αν τα στοιχεία των δεδομένων είναι αρνητικά με το πέρας
    % του γραμμικού μετασχηματισμού
    if show_warning
        warning('One or more linearized data points were complex. '+ 'Only the real part of these points will be used.');
    end

    % Προσδιορισμός αριθμού δεδομένων και δημιουργία πίνακα αβεβαιότητας
    M = length(ydata);
    b = ydata ./ sigma;
    
    % Δημιουργία Χ πίνακα
    X = zeros(M, 2);
    for i = 1:M
        for j = 1:2
            X(i,j) = xdata(i) ^ (j-1) / sigma(i);
        end
    end
    
    % Δημιουργία πίνακα συσχέτισης
    Corr = inv(X' * X);
    
    % Λύση ελαχίστων τετραγώνων γραμμικού συστήματος (βλ. [5])
    a_hat = X\b;
    
    % Αβεβαιότητα συντελεστών γραμμικής παρεμβολής
    c_sig = zeros(2, 1);
    for j = 1:2
        c_sig(j) = sqrt( Corr(j, j) );
    end
    
    % Τιμές υπολογισθείσας συνάρτησης
    func = zeros(length(xdata), 1);
    for i = 1:2
        func = func + a_hat(i) * xdata .^ (i-1);
    end
    
    y_bar = mean(ydata);
    
    % Στατιστικά γραμμικής παρεμβολής
    SS_tot = sum( ((ydata - y_bar) ./ sigma) .^ 2 );
    chisqr = sum( ((ydata - func) ./ sigma) .^ 2 );
    rsqr = 1 - (chisqr/SS_tot);
    rmse = sqrt( sum( ((ydata - func) .^ 2) / M ) );
    stats = [rsqr, chisqr, rmse];
    
    % Συντελεστές γραμμικής παρεμβολής
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
    
    % Αποθήκευση μορφής συναρτήσεων
    if strcmpi(model, 'linear')
        if b >= 0
            eqn = '\$y =' +M+ 'x' + '+' +b+ '\$';
        else
            eqn = '\$y =' +M+ 'x' +b+ '\$';
        end
    elseif strcmpi(model, 'power')
        eqn = '\$y =' +a+ 'x^{'+b+'}\$';
    end
end