function [wvar, wmean, wstd, weights] = WeightedVariance(data, error)
% Συνάρτηση που επιστρέφει τη μέση τιμής καθώς επίσης και τη διασπορά
% δεδομένων που φέρουν αβεβαιότητες.
% Βασισμένο στις σημειώσεις του James Kirchner (Case II)
% http://seismo.berkeley.edu/\sim kirchner/Toolkits/Toolkit\_12.pdf

% Σχετική βιβλιογραφία
% Bevington, P. R., Data Reduction and Error Analysis for the Physical
% Sciences, σελ. 56-59

n = length(data);
weights = (1 ./ error) .^ 2;
wmean = sum(data .* weights) / sum(weights);
wvar = ( sum(weights .* data .^ 2) / sum(weights) - wmean ^ 2 ) * n / (n - 1);
% Τυπικό σφάλμα του μέσου
wstd = sqrt(wvar / n);
end