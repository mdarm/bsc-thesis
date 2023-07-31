function [sigma] = InstrumentUncertainty(errVI, errTime, errTemp)
% Η παρούσα συνάρτηση υπολογίζει το συνολικό σφάλμα των χρησιμοποιούμενων
% μετρητικών οργάνων ακολουθώντας την ανάλυση αβεβαιότητας για πειράματα
% περιορισμένου αριθμού λήψης μετρήσεων (single sample experiments)
% όπως ορίζεται από τον Moffat [2]

% Σχετική βιβλιογραφία:
%   [1] Hugh W. Coleman, W. Glenn Steele Experimentation, Validation,
%       and Uncertainty Analysis for Engineers, σελ. 199
%
%   [2] Moffat, Robert J. Describing the uncertainties in experimental results 
%       1988-01
%
%   [3] Serbes, Arda Sefer Halkasal Kesitli Borulardaki Teğetsel Girişli
%       Sönümlü Döngülü Laminer Akışlarda Isı Taşınımı Karakteristiğinin
%       Deneysel Olarak İncelenmesi, σελ. 86 


% \textbf{Εκτίμηση αβεβαιότητας μετρήσεων τάσης και ρεύματος}
vS = 0.01; iS = 0.01; % ευαισθησία μετρητικού

data = importdata(errVI);

vData = data.data(:, 1);
iData = data.data(:, 2);

% Συνολικό σφάλμα
sigma.Volt = sqrt( (vS/2) ^ 2 +  (2.042 * std(vData)) ^ 2 );
sigma.Amp = sqrt( (iS/2) ^ 2 +  (2.042 * std(iData)) ^ 2 );

% \textbf{Εκτίμηση αβεβαιότητας μέτρησης χρόνου}
tS = 0.01; % ευαισθησία μετρητικού

data = importdata(errTime);

tData = data.data(:, 1);

% Συνολικό σφάλμα
sigma.Time = sqrt( (tS/2) ^ 2 + (2.042 * std(tData)) ^ 2 );

% \textbf{Εκτίμηση αβεβαιότητας μετρήσεων θερμοκρασίας (11 θερμοστοιχεία)}
tempS = 0.01; % συστηματικό σφάλμα όπως υπολογίστηκε από Arda[3]

% Σφάλμα $Ν^{ης}$ τάξης
tempVar = zeros(17, 11);
data = readtable(errTemp, 'Sheet', 'axialFlow');
data = table2array(data);
data = [flip( data(:, 1:9), 2 ) data(:, 10:11)];
[numRow, numCol] = size(data);
for k = 1:numCol
    tempVar(17, k) = var(data(:, k));
end

c = 0;
for i = 45:15:90
   for j = 1:4
       data = readtable(errTemp, 'Sheet', +j+'in'+i+'deg');
       data = table2array(data);
       data = [flip( data(:, 1:9), 2 ) data(:, 10:11)];
       c = c + 1;
       for k = 1:numCol
           tempVar(c, k) = var(data(:, k));
       end
   end
end

% Ομαδοποιημένη στατιστική
poolVar = zeros(1, 11);
for k = 1:numCol
    poolVar(1, k) = sqrt( mean(tempVar(:, k)) / ( (c + 1) + numRow ) );
end

% Ο συντελεστής student λαμβάνει τιμή 2.571 για δύο τυπικές αποκλίσεις $(95\%)$
% λόγω αριθμού παρτίδων μετρήσεων (5 στο σύνολό τους).
poolStd = 2.571 * poolVar;

% Συνολικό σφάλμα
sigmaTempTot = sqrt(tempS ^ 2 + poolStd .^ 2)';

rowNames = {
            'uncertTC1', 'uncertTC2',...
            'uncertTC3', 'uncertTC4',...
            'uncertTC5', 'uncertTC6',...
            'uncertTC7', 'uncertTC8',...
            'uncertTC9', 'uncertTCinlet',...
            'uncertTCoutlet'
            };
sigma.Temp = array2table(sigmaTempTot, 'RowNames', rowNames);
end