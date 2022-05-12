% Δεδομένα μετρήσεων και αβεβαιότητες σχετικών μετρητικών
[sigma] = InstrumentUncertainty('errorVI.csv', 'errorTime.csv', 'errorTemp.xlsx');
sigma_Te = table2array(sigma.temp);
sigma_Te = sigma_Te(1:9)';
weights  = (1 ./ sigma_Te) .^ 2;

TempData = zeros(9, 4, 17);
TempStd  = zeros(1, 4, 17);
TempMean = zeros(1, 4, 17);
ApparStd = zeros(1, 1, 17);
ApparMean = zeros(1, 1, 17);
c = 0;

% Εισαγωγή όλων των μετρήσεων θερμοκρασίας
for j = 45:15:90
    for i = 1:4
        c = c + 1;
        data = importdata(+j+"Degrees"+i+"inlets.csv");
        TempData(:, :, c) = data.data((4:12), :);
    end
    data = importdata('Axial.csv');
    TempData(:, :, 17) = data.data((4:12), :);
end

% Aκρότατες τιμές εφ όλων των δεδομένων
minColorLimit = min( min( min(TempData) ) );
maxColorLimit = max( max( max(TempData) ) );

% Θερμοκρασιακή ομοιογένεια και γραφήματα κυλίνδρων αξονικής ροής
for i = 1:4
   figure(i);
   dummydata = TempData(:, i, 17)';
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
   
   [wvariance, wmean] = WeightedVariance(dummydata, weights);
   
   TempMean(1, i, 17) = wmean;
   TempStd(1, i, 17) = sqrt( wvariance );
end

ApparStd(1, 1, 17) = mean( TempStd(1, :, 17) );
ApparMean(1, 1, 17) = mean( TempMean(1, :, 17) );

% Θερμοκρασιακή ομοιογένεια και γραφήματα κυλίνδρων για περιδινούμενες ροές
for k = 1:16
    for i = 1:4
        figure('Name', +i+"in"+k+"case");
        dummydata = TempData(:, i, k)';
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
        
        [wvariance, wmean] = WeightedVariance(dummydata, weights);
        
        TempMean(1, i, k) = wmean;
        TempStd(1, i, k) = sqrt( wvariance );
    end
    ApparStd(1, 1, k) = mean( TempStd(1, :, k) );
    ApparMean(1, 1, k) = mean( TempMean(1, :, k) );
end

% Δημιουργία αρχείου δεδομένων data.txt
apparatusMean(:, 1) = ApparMean(1, 1, :);
axialMean(:, 1) = ApparMean(1, 1, 17) * ones(17, 1);

% Σχετική μέση θερμοκρασία
relmean = apparatusMean - axialMean;

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

writetable(relData, 'data.txt', 'Delimiter', 'tab');
