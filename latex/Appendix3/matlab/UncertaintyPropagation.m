function [value, uncert] = UncertaintyPropagation(func, vals, uncerts, corrmat)
% PropUncertainty() διαδίδει τα σφάλματα της εκάστοτε συνάρτησης func 
% χρησιμοποιώντας την αριθμητική προσέγγιση πεπερασμένων διαφορών
% για τον προσδιορισμό της συνάρτησης Root Sum of Squares, όπως ορίζεται
% από
%
%   [1] S. J. Kline and F.A. McClintoc, Describing Uncertainties in 
%       Single-Sample Experiments, Mech. Eng., σελ. 3-8
%
% και σε μορφή πινάκων
%
%   [2] Benjamin Ochoa and Serge Belongie, Covariance Propagation for Guided Matching
%
%   [3] Lyons Louis, Statistics for Nuclear and Particle Physicists,
%       κεφ. 3.5 (Using the error matrix), σελ. 62
%
% Σημειώστε ότι η σειρά των στοιχείων στα ανύσματα 'vals', 'uncerts' και
% 'corrmat' πρέπει να αντιστοιχεί με αυτή των μεταβλητων '@(x,y,z)' στην
% εκάστοτε συνάρτηση 'func'

cellVals = num2cell(vals);
N = numel(cellVals);
value = func(cellVals{:});

% Προσδιορισμός Ιακωβιανού πίνακα κάνοντας χρήση πεπερασμένων διαφορών
jacob = zeros(1, N);
for i = 1:N
    if(uncerts(i) == 0)
        % Δεν θέλουμε να διαιρέσουμε με το μηδέν (γραμμή 32)
        jacob(i) = 0;
    else
    temp = cellVals{i};
    cellVals{i} = temp + uncerts(i);
    term1 = func( cellVals{:} );
    cellVals{i} = temp - uncerts(i);
    jacob(i) = (term1 - func( cellVals{:} )) / (2 * uncerts(i));
    cellVals{i} = temp;
    end
end

if (~exist('corrMat', 'var')) 
    uncert = sqrt( sum( (jacob .* uncerts) .^ 2 ) );
else
    % Δημιουργία πίνακα συσχέτισης
    covar = corrmat;
    for i = 1:N
        covar(i, :) = covar(i, :) .* uncerts(i);
        covar(:, i) = covar(:, i) .* uncerts(i);
    end
    uncert = sqrt(jacob * covar * transpose(jacob));
end
end