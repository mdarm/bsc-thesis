function [wmean, wvar, wstd, weights] = WeightedVariance(data, error)
% according to Prof. James Kirchner's notes
% http://seismo.berkeley.edu/~kirchner/Toolkits/Toolkit_12.pdf

% References
% Bevington, P. R., Data Reduction and Error Analysis for the
% Physical Sciences, σελ. 56-59
n = length(data);
weights = (1 ./ error) .^ 2;
wmean = sum(data .* weights) / sum(weights);
wvar = ( sum(weights .* data .^ 2) /...
    sum(weights) - wmean ^ 2 ) * n / (n - 1);
% Standard error of the mean
wstd = sqrt(wvar / n);
end