function [sigma] = InstrumentUncertainty(errVI, errTime, errTemp)
% This functions estimates the total measurement error of the multimeter,
% the timer and all eleven thermocouples. The method is known as single-
% sample uncertainty analysis, as defined by Moffat [2]

% Bibliography 
%   [1] Hugh W. Coleman, W. Glenn Steele Experimentation, Validation,
%       and Uncertainty Analysis for Engineers, p. 199
%
%   [2] Moffat, Robert J. Describing the uncertainties in experimental
%	results 1988-01, https://doi.org/10.1016/0894-1777(88)90043-X 
%
%   [3] Serbes, Arda Sefer Halkasal Kesitli Borulardaki Teğetsel Girişli
%       Sönümlü Döngülü Laminer Akışlarda Isı Taşınımı Karakteristiğinin
%       Deneysel Olarak İncelenmesi, p. 86 


%% Error estimate of Voltage and Current 

vS = 0.01; iS = 0.01; % sensor sensitivity 
data = importdata('errorVI.csv');

vData = data.data(:, 1);
iData = data.data(:, 2);

% total error 
sigma.volt = sqrt( (vS/2) ^ 2 +  (1.96 * std(vData)) ^ 2 );
sigma.amp = sqrt( (iS/2) ^ 2 +  (1.96 * std(iData)) ^ 2 );

%% Error estimate of time measurements 

tS = 0.01; % sensor sensitivity 
data = importdata('errorTime.csv');

tData = data.data(:, 1);

% total error
sigma.time = sqrt( (tS/2) ^ 2 + (1.96 * std(tData)) ^ 2 );

%% Error estimate of temperature measurements (11 thermocouples)

tempS = 0.01; % 0th-Order error as calculated by Arda[3]

% 1st-Order error 
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

% pooled statistics
poolVar = zeros(1, 11);
for k = 1:numCol
    poolVar(1, k) = sqrt( mean(tempVar(:, k)) / ((c + 1) * numRow));
end

poolStd = 2.36 * poolVar;

% total error 
sigmaTempTot = sqrt(tempS ^ 2 + poolStd .^ 2)';

% save errors in table 
rowNames = {'uncertTC1', 'uncertTC2', 'uncertTC3', 'uncertTC4',...
    'uncertTC5', 'uncertTC6', 'uncertTC7', 'uncertTC8', 'uncertTC9',...
    'uncertTCinlet', 'uncertTCoutlet'};
sigma.temp = array2table(sigmaTempTot, 'RowNames', rowNames);
end
