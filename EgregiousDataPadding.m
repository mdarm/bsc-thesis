%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Title:            EgregiousDataPadding.m
% Version:          1.2
% Author:           Michael Darmanis
% Date:             5 December 2021
% Description:      Script for calculating the temperature homogeneity;
%                   the dimensionless Nusselt and Reynolds numbers; and the
%                   required power for achieving specific flow conditions.
%                   Results are saved in the file results.txt
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Acquire file path and set it as current directory 

% Returns the full path of the current script 
folder = fileparts( which(mfilename) ); 

% Adds all subdirectories 
addpath( genpath(folder) );

%% Data input 

tic;                            % timing the script 

dInner = 22 * 10 ^ -3;          % inner cylinder diameter, [m]
dOuter = 40 * 10 ^ -3;          % outer cylinder diameter, [m]
voltRes = 29.5;                 % voltage of resistance, [V]
ampRes = 0.63;                  % current of reistance, [A]
position = 0.05:0.1:0.9;        % axial positions of thermocouples, [m]
subsystems = 0:0.1:0.9;         % nine subsystems of control volume 

tempData = zeros(11, 4, 17);    % steady-state temperature measurements, [degree Celsius]
                                % columns 1-9: resistance temperature along axial coordinate 
                                % column 10: inlet temperature 
                                % column 11: outlet temperature 
                                
timeData = zeros(1, 4, 17);     % time, [sec]
voltFan = zeros(1, 4, 17);      % voltage of fan, [V]
ampFan  = zeros(1, 4, 17);      % current of fan, [A]
c = 0;

% Data input for swirling-decaying flow 
for j = 45:15:90
    for i = 1:4
        c = c + 1;
        data = importdata(+j+"Degrees"+i+"inlets.csv");
        
        % Temperature measurements 
        tempData(:, :, c) = data.data((4:14), :);
        
        % Time measurements 
        timeData(1, :, c) = data.data(3, :);
        
        % Volt and current measurements 
        voltFan(1, :, c) = data.data(1, :);
        ampFan(1, :, c)  = data.data(2, :);
    end
end

% Data input for axial flow 
data = importdata('Axial.csv');

% Temperature, time, volt and current measurements 
tempData(:, :, 17) = data.data((4:14), :);
timeData(1, :, 17) = data.data(3, :);
voltFan(1, :, 17) = data.data(1, :);
ampFan(1, :, 17) = data.data(2, :);

% Color coding for segregating the use of various numbers of inlet slots 
% in the upcoming plots 
colorsErr = [140 45 4; 204 76 2;...        % one and two inlet slots 
             236 112 20; 254 153 41;...    % three and four inlet slots 
             99 99 99];                    % axial flow 
         
% Same as above but with different opacities
colorsFit = [140 45 4 153; 204 76 2 153;...
             236 112 20 153; 254 153 41 153;... 
             99 99 99 153];

%% Aβεβαιότητες δεδομένων

[sigma] = InstrumentUncertainty('errorVI.csv', 'errorTime.csv',...
    'errorTemp.xlsx');

% Συνολική αβεβαιότητα κάθε θερμοστοιχείου
uTemp = table2array(sigma.temp);
uTemp = uTemp(1:11);

% Συνολική αβεβαιότητα μετρήσεων τάσης και έντασης
uAmp = sigma.amp;
uVolt = sigma.volt;

% Συνολική αβεβαιότητα χρονομέτρου
uTime = sigma.time;

% Συνολική αβεβαιότητα διαστάσεων (σφάλμα ευαισθησίας ουσιαστικά)
uDim = 0.5 * 10 ^ -3;

% Αβεβαιότητα ειδικής θερμότητας αέρα (σφάλμα εύρους)
uCp = 0.001;

%% Θερμοκρασιακή ομοιογένεια

% Αντιπροσωπευτικές μέσες τιμές και τυπικές αποκλίσεις για κάθε διάταξη
TempStd  = zeros(1, 4, 17);
TempMean = zeros(1, 4, 17);
ApparStd = zeros(1, 1, 17);
ApparMean = zeros(1, 1, 17);

% Aκρότατες τιμές εφ όλων των δεδομένων για κοινό colobar
minColorLimit = min( min( min(tempData) ) );
maxColorLimit = max( max( max(tempData) ) );

% Θερμοκρασιακή ομοιογένεια και γραφήματα κυλίνδρων αξονικής ροής
for i = 1:4
   figure(i);
   dummydata = tempData(1:9, i, 17)';
   [X, Y, Z] = cylinder( ones( size(dummydata) ) );
   Z = 20 * Z;
   C = repmat(dummydata', 1, size(X, 2));
   hm = surf(X, Y, Z, C);
   caxis([minColorLimit, maxColorLimit]);
   
   shading interp;
   colormap jet;
   axis equal;
   
   set(findobj(gcf, 'type', 'axes'), 'Visible', 'off');
   PlotDimensions(gcf, 'centimeters', [15.747, 9], 12);
   ChangeInterpreter(gcf, 'Latex');
   colorbar;
   
   [wmean, wvariance] = WeightedVariance(dummydata', uTemp(1:9, 1));
   
   TempMean(1, i, 17) = wmean;
   TempStd(1, i, 17) = sqrt( wvariance );
end

ApparStd(1, 1, 17) = mean( TempStd(1, :, 17) );
ApparMean(1, 1, 17) = mean( TempMean(1, :, 17) );

% Θερμοκρασιακή ομοιογένεια και γραφήματα κυλίνδρων για περιδινούμενες ροές
for k = 1:16
    for i = 1:4
        figure('Name', +i+"in"+k+"case");
        dummydata = tempData(1:9, i, k)';
        [X, Y, Z] = cylinder( ones( size(dummydata) ) );
        Z = 20 * Z;
        C = repmat(dummydata', 1, size(X, 2));
        hm = surf(X, Y, Z, C);
        caxis([minColorLimit, maxColorLimit]);
   
        shading interp;
        colormap jet;
        axis equal;
   
        set(findobj(gcf, 'type', 'axes'), 'Visible', 'off');
        PlotDimensions(gcf, 'centimeters', [3.8, 3.8], 12);
        ChangeInterpreter(gcf, 'Latex');
        
        [wmean, wvariance] = WeightedVariance(dummydata', uTemp(1:9, 1));
        
        TempMean(1, i, k) = wmean;
        TempStd(1, i, k) = sqrt( wvariance );
    end
    ApparStd(1, 1, k) = mean( TempStd(1, :, k) );
    ApparMean(1, 1, k) = mean( TempMean(1, :, k) );
end

% Προετοιμασία μεταβλητών για εύρεση σχετικών τιμών
apparatusMean(:, 1) = ApparMean(1, 1, :);
axialMean(:, 1) = ApparMean(1, 1, 17) * ones(17, 1);

% Σχετική μέση θερμοκρασία
relmean = apparatusMean - axialMean;

% Σχετική τυπική απόκλιση
apparatusStd(:, 1) = ApparStd(1, 1, 1:16);
axialStd = ApparStd(1, 1, 17);

% Σχετικές τυπικές αποκλίσεις θερμοκρασίας
lci = relmean(1:16, 1) - apparatusStd;
lci(17, 1) = -axialStd;
uci = relmean(1:16, 1) + apparatusStd;
uci(17, 1) = axialStd;

% Το σύμβολο \$ μπαίνουν διότι το αρχείο θα επεξεργαστεί με LaTeX
name = {
        '$45-1$', '$45-2$', '$45-3$', '$45-4$',...
        '$60-1$', '$60-2$', '$60-3$', '$60-4$',...
        '$75-1$', '$75-2$', '$75-3$', '$75-4$',...
        '$90-1$', '$90-2$', '$90-3$', '$90-4$'...
        '\textit{\textbf{αξονική}}'
        }';
    
colNames = {'name', 'mean', 'lci', 'uci'};
relData = table(name, round(relmean, 2), round(lci, 2),...
    round(uci, 2), 'Variablenames', colNames);

% Δημιουργία αρχείου δεδομένων data.txt για περαιτέρω επεξεργασία
writetable(relData, 'data.txt', 'Delimiter', 'tab');

%% Heat-transfer evaluation

Reynolds = zeros(1, 4, 17);       % Reynolds, [αδιάστατο]
ReynoldsErr = zeros(1, 4, 17);    % Σφάλμα Reynolds, [αδιάστατο]
Nusselt = zeros(9, 4, 17);        % Τοπικός Nusselt, [αδιάστατο]
NusseltAvg = zeros(1, 4, 17);     % Μέσος Nusselt, [αδιάστατο]
NusseltErr = zeros(9, 4, 17);     % Σφάλμα τοπικού Nusselt, [αδιάστατο]
NusseltAvgErr = zeros(1, 4, 17);  % Σφάλμα μέσου Nusselt, [αδιάστατο]
relThermal = zeros(1, 1, 17);     % Ανηγμένος Nusselt, [αδιάστατο]
relThermalErr = zeros(1, 1, 17);  % Σφάλμα ανηγμένου Nusselt, [αδιάστατο]
thermalEn = zeros(1, 4, 17);      % Θερμική ισχύς, [Watt]
thermalEnErr = zeros(1, 4, 17);   % Σφάλμα θερμικής ισχύος, [Watt]
thermcoupl = zeros(9, 4, 17);    % Διαφορά θερμοκρασιών

% Θερμική αγωγιμότητα (W/m K) - εξίσωση Kannuluik
kappa = @(T) 5.75e-5 * (1 + 317e-5 * T - 21e-7 * T^2) * 418.4; 

% Πυκνότητα (kg/m^3) - νόμος ιδανικών αερίων
rho = @(T) 1.02e5 / (287.05 * (T + 273.15));

% Δυναμικό ιξώδες (kg/m s) - εξίσωση Sutherland 
mu = @(T) 1.716e-5 * ((T + 273.15) / 273.15) ^ (3 / 2) *...
    ((273.15 + 110.56) / (T + 110.56 + 273.15));

% Ειδική θερμότητα (μέση τιμή για 50 Κ διαφορά)
Cp = 1.008;

% Προετοιμασία "παλέτας" για γραφήματα
name = {
    'Nu = f(Re) 45deg',...
    'Nu = f(Re) 60deg',...
    'Nu = f(Re) 75deg',...
    'Nu = f(Re) 90deg'
    };

for i =1:4
    handles(1).hFig{i} = figure('Name', name{i});
    handles(1).hAxes{i} = axes('Parent', handles(1).hFig{i});
    set(handles(1).hFig{i}, 'Color', 'w');
    hold on;
end

% Συνάρτηση υπολογισμού παροχής
flowFunc = @(time) 0.1 / time;

% Συνάρτηση υπολογισμού αριθμού Reynolds
Re = @(Q, density, dviscosity, dOuter, dInner) 4 * Q * density /...
    (pi * dviscosity * (dOuter + dInner));

% Συνάρτηση υπολογισμού συντελεστή μετάδοσης θερμότητας
h = @(voltRes, ampRes, dInner, Tres, Tair) voltRes * ampRes /...
    (pi * dInner * 0.1 * (Tres - Tair));

% Συνάρτηση υπολογισμού τοπικού αριθμού Nusselt
Nu = @(h, dOuter, dInner, kappa) h * (dOuter - dInner) / kappa;

% Συνάρτηση υπολογισμού θερμικής ενέργειας
Qen = @(rho, flow, Cp, Tout, Tin) rho * flow * Cp * (Tout - Tin);
for k = 1:17
    for i = 1:4
        [flowrate, uflowrate] = UncertaintyPropagation(flowFunc,...
            timeData(1, i, k), uTime);
        
        % Θερμοδυναμικές ιδιότητες αέρα για Tavg
        tfunc = @(Tin, Tout) (Tin + Tout) / 2;
        
        [Tavg, uTavg] = UncertaintyPropagation(tfunc,...
            [tempData(10, i, k) tempData(11, i, k)],...
            [uTemp(10, 1) uTemp(11, 1)]);
        
        % Πυκνότητα
        [density, udensity] = UncertaintyPropagation(rho, Tavg, uTavg);
        % Δυναμικό ιξώδες
        [dviscosity, udviscosity] = UncertaintyPropagation(mu, Tavg, uTavg);
        % Θερμική αγωγιμότητα
        [tcond, utcond] = UncertaintyPropagation(kappa, Tavg, uTavg);
        
        % Θερμική ενέργεια
        [thermalEn(1, i, k), thermalEnErr(1, i, k)] =...
            UncertaintyPropagation(Qen,...
            [density flowrate Cp tempData(11, i, k) tempData(10, i, k)],...
            [udensity uflowrate uCp uTemp(11, 1) uTemp(10, 1)]);
        
        % Reynolds
        [Reynolds(1, i, k), ReynoldsErr(1, i, k)] =...
            UncertaintyPropagation(Re,...
            [flowrate density dviscosity dOuter dInner],...
            [uflowrate udensity udviscosity uDim uDim]);
        
        % Προσδιορισμός θερμοκρασίας αέρα
        [const, uconst] = LeastSquaresFit([0 0.9],...
            [tempData(10, i, k) tempData(11, i, k)],...
            [0 0], [uTemp(10, 1) uTemp(11, 1)], 'linear');
        
        Tair = const(1) * position + const(2);
        uTair = sqrt( (position .* uconst(1)) .^ 2 + uconst(2) ^ 2 );
        for j =1:9
            % Συντελεστή συναγωγής
            Tres = tempData(j, i, k);
            uTres = uTemp(j, 1);
            
            [htc, uhtc] = UncertaintyPropagation(h,...
                [voltRes ampRes dInner Tres Tair(j)],...
                [uVolt uAmp uDim uTres uTair(j)]);
            
            % Τοπικός Nusselt
            [Nusselt(j, i, k), NusseltErr(j, i, k)] =...
                UncertaintyPropagation(Nu,...
                [htc dOuter dInner tcond],...
                [uhtc uDim uDim utcond]);
            
                thermcoupl(j, i, k) = Tres - Tair(j);
        end
        % Μέσοι Nusselt
        [wmean, wvar, wstd, weights] =...
            WeightedVariance(Nusselt(:, i, k), NusseltErr(:, i, k));
        
        NusseltAvg(1, i, k) = wmean;
        NusseltAvgErr(1, i, k) = sqrt(1 / sum(weights));
    end
    
    reynolds = Reynolds(1, :, k);
    reynoldserr = ReynoldsErr(1, :, k);
    
    nusselt = NusseltAvg(1, :, k);
    nusselterr = NusseltAvgErr(1, :, k);
    
    [cc, cerrr, statt] = LeastSquaresFit(reynolds, nusselt,...
        reynoldserr, nusselterr, 'power');
    
    % Όρια οριζοντίου άξονα
    rFit = linspace(1000, 2000, 1000);

    % Υπολογισθείσες τιμές ισχύος
    nFit = cc(1) * rFit .^ cc(2);
    
    % Κατασκευή διαγραμμάτων
    if k <= 4
        a = k;
        handles(1).hE{k} = errorbar(handles(1).hAxes{1}, reynolds, nusselt,...
                         nusselterr, nusselterr, reynoldserr,...
                         reynoldserr, '*', 'Color', colorsErr(a, :) / 255);
        handles(1).hP{k} = plot(handles(1).hAxes{1}, rFit, nFit, '-', 'Color',...
                          colorsFit(a, :) / 255);
    elseif (k > 4) && (k <= 8)
        a = k - 4;
        handles(1).hE{k} = errorbar(handles(1).hAxes{2}, reynolds, nusselt,...
                         nusselterr, nusselterr, reynoldserr,...
                         reynoldserr, '*', 'Color', colorsErr(a, :) / 255);
        handles(1).hP{k} = plot(handles(1).hAxes{2}, rFit, nFit, '-', 'Color',...
                          colorsFit(a, :) / 255);           
    elseif (k > 8) && (k <= 12)
        a = k - 8;
        handles(1).hE{k} = errorbar(handles(1).hAxes{3}, reynolds, nusselt,...
                         nusselterr, nusselterr, reynoldserr,...
                         reynoldserr, '*', 'Color', colorsErr(a, :) / 255);
        handles(1).hP{k} = plot(handles(1).hAxes{3}, rFit, nFit, '-', 'Color',...
                          colorsFit(a, :) / 255);   
    elseif (k > 12) && (k <= 16)
        a = k - 12;
        handles(1).hE{k} = errorbar(handles(1).hAxes{4}, reynolds, nusselt,...
                         nusselterr, nusselterr, reynoldserr,...
                         reynoldserr, '*', 'Color', colorsErr(a, :) / 255);
        handles(1).hP{k} = plot(handles(1).hAxes{4}, rFit, nFit, '-', 'Color',...
                          colorsFit(a, :) / 255);
    else
        for i = 1:4
            a = 16 + i;
            handles(1).hE{a} = errorbar(handles(1).hAxes{i}, reynolds,...
                         nusselt, nusselterr, nusselterr, reynoldserr,...
                         reynoldserr, '*', 'Color', colorsErr(5, :) / 255);
            handles(1).hP{a} = plot(handles(1).hAxes{i}, rFit, nFit, '-',...
                         'Color', colorsFit(5, :) / 255);
        end
    end
 
    % Αποθήκευση δεδομένων παρεμβολών
    stats(1).c(k, :) = cc'; stats(1).cerr(k, :) = cerrr';
    stats(1).stat(k, :) = statt;
    
    % Υπολογισμός μέσου Nusselt, και του αντίστοιχου σφάλματος, για κάθε
    % διάταξη
    g1 = fit(reynolds', nusselt', 'power1');
    a = g1.a;
    b = g1.b;
    
    func = @(x) a*x^b;
    
    uNu = zeros(1, 4);
    for i = 1:4
        [Nuu, uNu(1, i)] = UncertaintyPropagation(func, reynolds(1, i), reynoldserr(1, i)); 
    end
    
    error = sqrt(nusselterr .^ 2 + uNu .^ 2);
    weights = 1 ./ error .^ 2;

    g2 = fit(reynolds', nusselt', 'power1', 'weight', weights);

    yhat = g2.a * rFit .^ g2.b;
    CIO = predint(g2, rFit, 0.95, 'obs');
    
    relThermal(1, 1, k) = trapz(rFit, yhat) / (max(rFit) - min(rFit));
    relThermalErr(1, 1, k) = trapz(rFit, CIO(:, 2)) / (max(rFit) - min(rFit)) - trapz(rFit, yhat) / (max(rFit) - min(rFit));
end

latextbl1 = [stats(1).c(:, 1) stats(1).cerr(:, 1) stats(1).c(:, 2) stats(1).cerr(:, 2) stats(1).stat(:, 1)];
nussavg(:, 1) = relThermal(1, 1, 1:16);
nussavg(:, 2) = relThermalErr(1, 1, 1:16);

% Ποσοστιαία μεταβολή μέσων Nusselt διατάξεων βρόγχου, συγκριτικά με τον
% αντίστοιχο της διάταξης αξονικής ροής
swirlNu(:, 1) = relThermal(1, 1, 1:16);
swirlNu(:, 2) = relThermalErr(1, 1, 1:16);
axialNu(1, 1) = relThermal(1, 1, 17);
axialNu(1, 2) = relThermalErr(1, 1, 17);

relswirlNu = zeros(16, 2);
relpower = @(swirlNu, axialNu) (swirlNu / axialNu - 1) * 100;
for i = 1:16
    [relswirlNu(i, 1), relswirlNu(i, 2)] = UncertaintyPropagation(...
        relpower, [swirlNu(i, 1) axialNu(1, 1)],...
        [swirlNu(i, 2) axialNu(1, 2)]);
end 

handles(1).hFig{5} = figure('Name', 'bar chart');
handles(1).hAxes{5} = axes('Parent', handles(1).hFig{5});
set(handles(1).hFig{5}, 'Color', 'w');
hold on;

nuss = [relswirlNu(1:4, 1)'; relswirlNu(5:8, 1)';...
         relswirlNu(9:12, 1)'; relswirlNu(13:16, 1)'];

nusserr = [relswirlNu(1:4, 2)'; relswirlNu(5:8, 2)';...
         relswirlNu(9:12, 2)'; relswirlNu(13:16, 2)'];

bar(handles(1).hAxes{5}, nuss);
ngroups = size(nuss, 1);
nbars = size(nuss, 2);

% Calculating the width of each group of bars
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    handles(1).hPe{i} = errorbar(handles(1).hAxes{5}, x,...
        nuss(:, i), nusserr(:, i), '.');
end
hold off

xlabel(handles(1).hAxes{5}, 'Inlet angle [degrees]');
ylabel(handles(1).hAxes{5}, 'Relative thermal performance [$\%$]');
legend(handles(1).hAxes{5}, {'1 inlet', '2 inlets', '3 inlets', '4 inlets'},...
          'orientation', 'horizontal', 'Location', 'Northoutside');
      
colororder(colorsFit(1:4, 1:3) / 255);
set(handles(1).hAxes{5}, 'XTick', 1:4, 'XTickLabel', {'45$^o$', '60$^o$', '75$^o$',...
        '90$^o$'});
handles(1).hAxes{5}.XAxis.TickLength = [0 0];

for i = 1:nbars
   set(handles(1).hPe{i}, 'Color', colorsErr(5, :) / 255); 
end

PlotDimensions(handles(1).hFig{5}, 'centimeters', [15.747, 8], 12);
ChangeInterpreter(handles(1).hFig{5}, 'latex');

%% Fan-power-consumption evaluation

wattFan = zeros(1, 4, 17);       % Ισχύς σε Watt, [W]
wattFanErr = zeros(1, 4, 17);    % Σφάλμα ισχύος, [W]
relWattFan = zeros(1, 1, 17);    % Ανηγμένη ισχύς, [αδιάστατο]
relWattFanErr = zeros(1, 1, 17); % Σφάλμα ανηγμένης ισχύος, [αδιάστατο]

flowFan = zeros(1, 4, 17);       % Παροχή, [m^3/s]
flowFanErr = zeros(1, 4, 17);    % Σφάλμα παροχής, [m^3/s]

% Προετοιμασία "παλέτας" για γραφήματα
name = {
    'P = f(Q) 45deg',...
    'P = f(Q) 60deg',...
    'P = f(Q) 75deg',...
    'P = f(Q) 90deg'
    };

for i =1:4
    handles(2).hFig{i} = figure('Name', name{i});
    handles(2).hAxes{i} = axes('Parent', handles(2).hFig{i});
    set(handles(2).hFig{i}, 'Color', 'w');
    hold on;
end

% Συνάρτηση υπολογισμού ισχύος
wattFunc = @(voltFan, ampFan) voltFan * ampFan;

% Συνάρτηση υπολογισμού παροχής
flowFunc = @(time) 0.1 / time;

for k = 1:17
    for i = 1:4
        [wattFan(1, i, k), wattFanErr(1, i, k)] =...
            UncertaintyPropagation(wattFunc,...
            [voltFan(1, i, k) ampFan(1, i, k)], [uVolt uAmp]);
        
        [flowFan(1, i, k), flowFanErr(1, i, k)] = ...
            UncertaintyPropagation(flowFunc, ...
            timeData(1, i, k), uTime);
    end
    
    wattdata = wattFan(1, :, k);
    watterr = wattFanErr(1, :, k);
    
    flowdata = flowFan(1, :, k);
    flowerr = flowFanErr(1, :, k);
    
    [cc, cerrr, statt] = LeastSquaresFit(flowdata,...
        wattdata, flowerr, watterr, 'power');
    
    % Όρια οριζοντίου άξονα
    qFit = linspace(0.0008, 0.0016, 1000);

    % Υπολογισθείσες τιμές ισχύος
    pFit = cc(1) * qFit .^ cc(2);
    
    % Κατασκευή διαγραμμάτων
    if k <= 4
        a = k;
        handles(2).hE{k} = errorbar(handles(2).hAxes{1}, flowdata, wattdata,...
                         watterr, watterr, flowerr,...
                         flowerr, '*', 'Color', colorsErr(a, :) / 255);
        handles(2).hP{k} = plot(handles(2).hAxes{1}, qFit, pFit, '-', 'Color',...
                          colorsFit(a, :) / 255);
    elseif (k > 4) && (k <= 8)
        a = k - 4;
        handles(2).hE{k} = errorbar(handles(2).hAxes{2}, flowdata, wattdata,...
                         watterr, watterr, flowerr,...
                         flowerr, '*', 'Color', colorsErr(a, :) / 255);
        handles(2).hP{k} = plot(handles(2).hAxes{2}, qFit, pFit, '-', 'Color',...
                         colorsFit(a, :) / 255);             
    elseif (k > 8) && (k <= 12)
        a = k - 8;
        handles(2).hE{k} = errorbar(handles(2).hAxes{3}, flowdata, wattdata,...
                         watterr, watterr, flowerr,...
                         flowerr, '*', 'Color', colorsErr(a, :) / 255);
        handles(2).hP{k} = plot(handles(2).hAxes{3}, qFit, pFit, '-', 'Color',...
                         colorsFit(a, :) / 255);      
    elseif (k > 12) && (k <= 16)
        a = k - 12;
        handles(2).hE{k} = errorbar(handles(2).hAxes{4}, flowdata, wattdata,...
                         watterr, watterr, flowerr,...
                         flowerr, '*', 'Color', colorsErr(a, :) / 255);
        handles(2).hP{k} = plot(handles(2).hAxes{4}, qFit, pFit, '-', 'Color',...
                         colorsFit(a, :) / 255);
    else
        for i = 1:4
            a = 16 + i;
            handles(2).hE{a} = errorbar(handles(2).hAxes{i}, flowdata, wattdata,...
                         watterr, watterr, flowerr,...
                         flowerr, '*', 'Color', colorsErr(5, :) / 255);
            handles(2).hP{a} = plot(handles(2).hAxes{i}, qFit, pFit, '-',...
                         'Color', colorsFit(5, :) / 255);
        end
    end
 
    % Αποθήκευση δεδομένων παρεμβολών
    stats(2).c(k, :) = cc'; stats(2).cerr(k, :) = cerrr';
    stats(2).stat(k, :) = statt;
    
    % Υπολογισμός μέσης ισχύος, και του αντίστοιχου σφάλματος, για κάθε
    % διάταξη
    g1 = fit(flowdata', wattdata', 'exp1');
    a = g1.a;
    b = g1.b;
    
    func = @(x) a*exp(x*b);
    
    uP = zeros(1, 4);
    for i = 1:4
        [Puu, uP(1, i)] = UncertaintyPropagation(func, flowdata(1, i), flowerr(1, i)); 
    end
    
    error = sqrt(watterr .^ 2 + uP .^ 2);
    weights = 1 ./ error .^ 2;

    g2 = fit(flowdata', wattdata', 'exp1', 'weight', weights);

    yhat = g2.a * exp(qFit * g2.b);
    CIO = predint(g2, qFit, 0.95, 'obs');
    
    relWattFan(1, 1, k) = trapz(qFit, yhat) / (max(qFit) - min(qFit));
    relWattFanErr(1, 1, k) = trapz(qFit, CIO(:, 2)) / (max(qFit) - min(qFit)) - trapz(qFit, yhat) / (max(qFit) - min(qFit));
end

pwavg(:, 1) = relWattFan(1, 1, 1:16); 
pwavg(:, 2) = relWattFanErr(1, 1, 1:16);

% Ποσοστιαία μεταβολή ισχύος διατάξεων, συγκριτικά με την αντίστοιχη της
% διάταξης αξονικής ροής
swirlpower(:, 1) = relWattFan(1, 1, 1:16);
swirlpower(:, 2) = relWattFanErr(1, 1, 1:16);
axialpower(1, 1) = relWattFan(1, 1, 17);
axialpower(1, 2) = relWattFanErr(1, 1, 17);

relswirlpower = zeros(16, 2);
relpower = @(swirlpower, axialpower) (1 - swirlpower / axialpower) * 100;
for i = 1:16
    [relswirlpower(i, 1), relswirlpower(i, 2)] = UncertaintyPropagation(...
        relpower, [swirlpower(i, 1) axialpower(1, 1)],...
        [swirlpower(i, 2) axialpower(1, 2)]);
end 

handles(2).hFig{5} = figure('Name', 'bar chart');
handles(2).hAxes{5} = axes('Parent', handles(2).hFig{5});
set(handles(2).hFig{5}, 'Color', 'w');
hold on;

power = [relswirlpower(1:4, 1)'; relswirlpower(5:8, 1)';...
         relswirlpower(9:12, 1)'; relswirlpower(13:16, 1)'];

powererr = [relswirlpower(1:4, 2)'; relswirlpower(5:8, 2)';...
         relswirlpower(9:12, 2)'; relswirlpower(13:16, 2)'];

bar(handles(2).hAxes{5}, power);
ngroups = size(power, 1);
nbars = size(power, 2);

% Calculating the width of each group of bars
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    handles(2).hPe{i} = errorbar(handles(2).hAxes{5}, x, power(:, i), powererr(:, i), '.');
end
hold off

xlabel(handles(2).hAxes{5}, 'Inlet angle [degrees]');
ylabel(handles(2).hAxes{5}, 'Relative power consumption [$\%$]');
legend(handles(2).hAxes{5}, {'1 inlet', '2 inlets', '3 inlets', '4 inlets'},...
          'orientation', 'horizontal', 'Location', 'Northoutside');
      
colororder(colorsFit(1:4, 1:3) / 255);
set(handles(2).hAxes{5}, 'XTick', 1:4, 'XTickLabel', {'45$^o$', '60$^o$', '75$^o$',...
        '90$^o$'});
handles(2).hAxes{5}.XAxis.TickLength = [0 0];

for i = 1:nbars
   set(handles(2).hPe{i}, 'Color', colorsErr(5, :) / 255); 
end

PlotDimensions(handles(2).hFig{5}, 'centimeters', [15.747, 8], 12);
ChangeInterpreter(handles(2).hFig{5}, 'latex');

%% Αισθητική και ευπαρουσίαστα γραφήματα

n_hE = length(handles(2).hE);
for i = 1:n_hE
   for k = 1:2
       set(handles(k).hE{i}, 'Capsize', 0, 'LineWidth', 0.6,...
           'MarkerSize', 4);
       set(handles(k).hP{i}, 'linewidth', 2);
   end
end

n_hFig = length(handles(1).hFig) - 1;
for i = 1:n_hFig
    for k = 1:2
        % Ίδια όρια για όλα τα γραφήματα
        hor_lim = {[1000 2000] [8.0000e-04 0.0016]};
        vert_lim = {[80 200] [0 40]};
        set(handles(k).hAxes{i}, 'XLim', hor_lim{k}, 'YLim', vert_lim{k},...
                    'Box', 'off', 'XMinorTick', 'on', 'YMinorTick', 'on',...
                    'TickDir', 'out', 'TickLength', [.02 .02],...
                    'LineWidth', 1, 'XColor', [.3 .3 .3],...
                    'YColor', [.3 .3 .3], 'YGrid', 'on');
        % Υπόμνημα
        legend(handles(k).hAxes{i}, [handles(k).hE{1}, handles(k).hP{17},...
                    handles(2).hP{1:4}], 'Data ({$\it\mu$} $\pm$ {$\it\sigma$})',...
                    'axial flow', '1 inlet', '2 inlets', '3 inlets', '4 inlets',...
                    'Location', 'NorthOutside', 'Orientation', 'horizontal',...
                     'NumColumns', 3);
              
        % Ονομασία αξόνων
        if k == 1
            xlabel(handles(k).hAxes{i}, 'Re');
            ylabel(handles(k).hAxes{i}, '$\bar{Nu}$');
        else
            xlabel(handles(k).hAxes{i}, 'Flowrate [$m^3$/s]');
            ylabel(handles(k).hAxes{i}, 'Power consumption [Watt]');
        end
        
        PlotDimensions(handles(k).hFig{i}, 'centimeters', [15.747, 8], 12);
        ChangeInterpreter(handles(k).hFig{i}, 'latex');
    end
end

%% Potential energy efficiency index

% Ποσοστιαία μεταβολή, συγκριτικά με
% την αντίστοιχη της διάταξης αξονικής ροής

potentialEn = zeros(1, 1, 17);
potentialEnErr = zeros(1, 1, 17);

%Συνάρτηση ωφέλιμου δυναμικού
pee = @(Q, W) Q / W;

for k = 1:17
   for i = 1:4
       [potentialEn(1, i, k), potentialEnErr(1, i, k)] =...
           UncertaintyPropagation(pee,...
           [thermalEn(1, i, k) wattFan(1, i, k)],...
           [thermalEnErr(1, i, k) wattFanErr(1, i, k)]);
   end
end 

swirlTh(:, 1) = potentialEn(1, 1, 1:16);
swirlTh(:, 2) = potentialEnErr(1, 1, 1:16);
axialTh(1, 1) = potentialEn(1, 1, 17);
axialTh(1, 2) = potentialEnErr(1, 1, 17);

relswirlTh = zeros(16, 2);
relthermal = @(swirlTh, axialTh) (swirlTh / axialTh - 1) * 100;
for i = 1:16
    [relswirlTh(i, 1), relswirlTh(i, 2)] = UncertaintyPropagation(...
        relthermal, [swirlTh(i, 1) axialTh(1, 1)],...
        [swirlTh(i, 2) axialTh(1, 2)]);
end 

handles(1).hFig{6} = figure('Name', 'bar chart');
handles(1).hAxes{6} = axes('Parent', handles(1).hFig{6});
set(handles(1).hFig{6}, 'Color', 'w');
hold on;

therm = [relswirlTh(1:4, 1)'; relswirlTh(5:8, 1)';...
         relswirlTh(9:12, 1)'; relswirlTh(13:16, 1)'];
thermerr = [relswirlTh(1:4, 2)'; relswirlTh(5:8, 2)';...
         relswirlTh(9:12, 2)'; relswirlTh(13:16, 2)'];

bar(handles(1).hAxes{6}, therm);
ngroups = size(therm, 1);
nbars = size(therm, 2);

% Calculating the width of each group of bars
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    handles(1).hPe{i} = errorbar(handles(1).hAxes{6}, x,...
        therm(:, i), thermerr(:, i), '.');
end
hold off

xlabel(handles(1).hAxes{6}, 'Inlet angle [degrees]');
ylabel(handles(1).hAxes{6}, 'Potential energy efficiency [$\%$]');
legend(handles(1).hAxes{6}, {'1 inlet', '2 inlets', '3 inlets', '4 inlets'},...
          'orientation', 'horizontal', 'Location', 'Northoutside');
      
colororder(colorsFit(1:4, 1:3) / 255);
set(handles(1).hAxes{6}, 'XTick', 1:4, 'XTickLabel', {'45$^o$', '60$^o$', '75$^o$',...
        '90$^o$'});
handles(1).hAxes{6}.XAxis.TickLength = [0 0];

for i = 1:nbars
   set(handles(1).hPe{i}, 'Color', colorsErr(5, :) / 255); 
end

PlotDimensions(handles(1).hFig{6}, 'centimeters', [15.747, 8], 12);
ChangeInterpreter(handles(1).hFig{6}, 'latex');

toc;                        % λήξη χρονομέτρησης κώδικα
runningTime = toc;

%% Αποθήκευση αποτελεσμάτων στο αρχείο results.txt

res = fopen('results.txt', 'w'); 
disp('Results printed in the file: results.txt ');
fprintf(res, 'Analysis output report, written on %s\n', datetime('now'));
fprintf(res, 'Elapsed time: %4.2f seconds \n \n', runningTime);
fprintf(res, 'Results are printed in a way that greatly simplifies their implementation in a LaTeX table \n \n');

latextbl2 = [stats(2).c(:, 1) .* 10e-10 stats(2).cerr(:, 1) .* 10e-10 stats(2).c(:, 2) stats(2).cerr(:, 2) stats(2).stat(:, 1)];
latextbl = [latextbl1 latextbl2];
fprintf(res, '------------------------------------------------------ \n');
fprintf(res, 'Power fit curves for Nu = aRe^b and P = aQ^b; columns: a ua b ub r^2 \n \n');
fprintf(res, '%5.2f & %5.2f & %5.2f & %5.2f & %5.4f && %5.2f & %5.2f & %5.2f & %5.2f & %5.4f \\\\ \n', latextbl');
fprintf(res, '\n');

latexnu = zeros(4, length(nussavg(1:4, 1)) * 2);
latexpw = zeros(4, length(pwavg(1:4, 1)) * 2);
c = 0;
for i = 1:4
    
    if i == 1
    else
    c = c + 4;
    end
    
   latexpw(i, 1:2:end-1) = pwavg(1+c:4+c, 1);
   latexpw(i, 2:2:end) = pwavg(1+c:4+c, 2);
   latexnu(i, 1:2:end-1) = nussavg(1+c:4+c, 1);
   latexnu(i, 2:2:end) = nussavg(1+c:4+c, 2);
end

%latexnu = [nussavg(1:4, 1) nussavg(1:4, 2) nussavg(5:8, 1) nussavg(5:8, 2) nussavg(9:12, 1) nussavg(9:12, 2) nussavg(13:16, 1) nussavg(13:16, 2)];
fprintf(res, '------------------------------------------------------ \n');
fprintf(res, 'Average Nusselt numbers; rows: angle degrees, columns: number of inlets\n \n');
fprintf(res, '& %5.2f & %5.2f && %5.2f & %5.2f && %5.2f & %5.2f && %5.2f & %5.2f \\\\ \n', latexnu');
fprintf(res, '\n');

% Τύπωμα αποτελεσμάτων για μεταφορά σε LaTeX
%latexpw = [pwavg(1:4, 1) pwavg(1:4, 2) pwavg(5:8, 1) pwavg(5:8, 2) pwavg(9:12, 1) pwavg(9:12, 2) pwavg(13:16, 1) pwavg(13:16, 2)];
fprintf(res, '------------------------------------------------------ \n');
fprintf(res, 'Average Power values; rows: angle degrees, columns: number of inlets\n \n');
fprintf(res, '& %5.2f & %5.2f && %5.2f & %5.2f && %5.2f & %5.2f && %5.2f & %5.2f \\\\ \n', latexpw');
fprintf(res, '\n');

latextbl = [nuss(:, 1) nusserr(:, 1) nuss(:, 2) nusserr(:, 2) nuss(:, 3) nusserr(:, 3) nuss(:, 4) nusserr(:, 4)];
fprintf(res, '------------------------------------------------------ \n');
fprintf(res, 'Thermal improvement index; rows: angle degrees, columns: number of inlets\n \n');
fprintf(res, '& %5.2f & %5.2f && %5.2f & %5.2f && %5.2f & %5.2f && %5.2f & %5.2f \\\\ \n', latextbl');
fprintf(res, '\n');


latextbl = [power(:, 1) powererr(:, 1) power(:, 2) powererr(:, 2) power(:, 3) powererr(:, 3) power(:, 4) powererr(:, 4)];
fprintf(res, '------------------------------------------------------ \n');
fprintf(res, 'Power improvement index; rows: angle degrees, columns: number of inlets \n \n');
fprintf(res, '& %5.2f & %5.2f && %5.2f & %5.2f && %5.2f & %5.2f && %5.2f & %5.2f \\\\ \n', latextbl');
fprintf(res, '\n');

% Τύπωμα αποτελεσμάτων για μεταφορά σε LaTeX
latextbl = [therm(:, 1) thermerr(:, 1) therm(:, 2) thermerr(:, 2) therm(:, 3) thermerr(:, 3) therm(:, 4) thermerr(:, 4)];
fprintf(res, '------------------------------------------------------ \n');
fprintf(res, 'Potential efficiency index; rows: angle degrees, columns: number of inlets \n \n');
fprintf(res, '& %5.2f & %5.2f && %5.2f & %5.2f && %5.2f & %5.2f && %5.2f & %5.2f \\\\ \n', latextbl');

fclose(res);
