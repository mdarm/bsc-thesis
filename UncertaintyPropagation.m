function [value, uncert] = UncertaintyPropagation(func, vals, uncerts, corrMat)
% PropUncertainty() διαδίδει τα σφάλματα της εκάστοτε συνάρτησης func 
% χρησιμοποιώντας την αριθμητική προσέγγιση πεπερασμένων διαφορών
% για τον προσδιορισμό της συνάρτησης Root Sum of Squares, όπως ορίζεται από τους
%
% S. J. Kline and F.A. McClintoc, Describing Uncertainties in 
% Single-Sample Experiments, Mech. Eng., pp. 3-8, Jan. 1953
%
% και
%
% Robert J. Moffat, Describing the Uncertainties in Experimental Results,
% Exp. Thermal Fluid Sci., volume 1, pp. 3–17, Jan. 1988
%
% ή σε μορφή πινάκων
%
% Lyons Louis, Statistics for Nuclear and Particle Physicists, σελ. 63

valCells = num2cell(vals);
N = numel(valCells);
value = func(valCells{:});

% Προσδιορισμός Ιακωβιανού πίνακα
jacob = zeros(1, N);
for i = 1:N
    if(uncerts(i) == 0)
        % Δεν θέλουμε να διαιρέσουμε με το μηδέν
        jacob(i) = 0;
    else
    temp = valCells{i};
    valCells{i} = temp + uncerts(i);
    term1 = func(valCells{:});
    valCells{i} = temp - uncerts(i);
    jacob(i) = (term1 - func(valCells{:}))/(2*uncerts(i));
    valCells{i} = temp;
    end
end

if (~exist('corrMat', 'var')) 
    uncert = sqrt( sum( (jacob .* uncerts) .^ 2) );
else
    % Δημιουργία πίνακα συσχέτισης
    covar = corrMat;
    for i = 1:N
        covar(i, :) = covar(i, :).*uncerts(i);
        covar(:, i) = covar(:, i).*uncerts(i);
    end
    uncert = sqrt( jacob * covar * transpose(jacob) );
end
end