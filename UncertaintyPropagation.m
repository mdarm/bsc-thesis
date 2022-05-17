function [value, uncert] = UncertaintyPropagation(func, vals, uncerts, corrMat)
% UncertaintyPropagation() propagates the variables' error of the function, func,
% using the arithmetic method of finite differences; this method is also known as
% Root Sum of Squares, as defined by Kline and McClintoc [1]

% Bibliography
%   [1] S. J. Kline and F.A. McClintoc, Describing Uncertainties in 
%       Single-Sample Experiments, Mech. Eng., pp. 3-8, Jan. 1953
%
%   [2] Robert J. Moffat, Describing the Uncertainties in Experimental Results,
% 	Exp. Thermal Fluid Sci., volume 1, pp. 3–17, Jan. 1988
%
%   [3] Lyons Louis, Statistics for Nuclear and Particle Physicists, p. 63

valCells = num2cell(vals);
N = numel(valCells);
value = func(valCells{:});

% Creating the Jacobian matrix 
jacob = zeros(1, N);
for i = 1:N
    if(uncerts(i) == 0)
        % Lets not divide by zero 
        jacob(i) = 0;
    else
    temp = valCells{i};
    valCells{i} = temp + uncerts(i);
    term1 = func( valCells{:} );
    valCells{i} = temp - uncerts(i);
    jacob(i) = ( term1 - func(valCells{:}) )/( 2*uncerts(i) );
    valCells{i} = temp;
    end
end

if (~exist('corrMat', 'var')) 
    uncert = sqrt( sum( (jacob .* uncerts) .^ 2) );
else
    % Creating the corellation matrix 
    covar = corrMat;
    for i = 1:N
        covar(i, :) = covar(i, :).*uncerts(i);
        covar(:, i) = covar(:, i).*uncerts(i);
    end
    uncert = sqrt( jacob * covar * transpose(jacob) );
end
end
