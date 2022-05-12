function [sigma] = InstrumentUncertainty(errVI, errTime, errTemp)

%% Εκτίμηση αβεβαιότητας μετρήσεων τάσης και ρεύματος

vS = 0.01; iS = 0.01; % ευαισθησία μετρητικού
data = importdata('errorVI.csv');
%data = importdata(errVI);

vData = data.data(:, 1);
iData = data.data(:, 2);

% συνολικό σφάλμα
sigma.volt = sqrt( (vS/2) ^ 2 +  (1.96 * std(vData)) ^ 2 );
sigma.amp = sqrt( (iS/2) ^ 2 +  (1.96 * std(iData)) ^ 2 );

%% Εκτίμηση αβεβαιότητας μέτρησης χρόνου

tS = 0.01; % ευαισθησία μετρητικού
data = importdata('errorTime.csv');
%data = importdata(errTime);

tData = data.data(:, 1);

% συνολικό σφάλμα
sigma.time = sqrt( (tS/2) ^ 2 + (1.96 * std(tData)) ^ 2 );

%% Εκτίμηση αβεβαιότητας μετρήσεων θερμοκρασίας (11 θερμοστοιχεία)

tempS = 0.01; % συστηματικό σφάλμα όπως sυπολογίστηκε από Arda[3]

% σφάλμα Ν^{ης} τάξης
tempVar = zeros(17, 11);
data = readtable(errTemp, 'Sheet', 'axialFlow');
data = table2array(data);
data = [flip(data(:, 1:9), 2) data(:, 10:11)];
[numRow, numCol] = size(data);
for k = 1:numCol
    tempVar(17, k) = var(data(:, k));
end

c = 0;
for i = 45:15:90
   for j = 1:4
       data = readtable('errorTemp.xlsx', 'Sheet', +j+"in"+i+"deg");
       data = table2array(data);
       data = [flip( data(:, 1:9), 2 ) data(:, 10:11)];
       c = c + 1;
       for k = 1:numCol
           tempVar(c, k) = var(data(:, k));
       end
   end
end

poolVar = zeros(1, 11);
for k = 1:numCol
    poolVar(1, k) = sqrt( mean(tempVar(:, k)) / ((c + 1) * numRow));
end

poolStd = 2.36 * poolVar;

% συνολικό σφάλμα
sigmaTempTot = sqrt(tempS ^ 2 + poolStd .^ 2)';

rowNames = {'uncertTC1', 'uncertTC2', 'uncertTC3', 'uncertTC4',...
    'uncertTC5', 'uncertTC6', 'uncertTC7', 'uncertTC8', 'uncertTC9',...
    'uncertTCinlet', 'uncertTCoutlet'};
sigma.temp = array2table(sigmaTempTot, 'RowNames', rowNames);
end
