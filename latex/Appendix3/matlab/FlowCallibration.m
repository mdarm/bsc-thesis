% βαθμονόμηση ογκομετρητή θετικής μετατόπισης
for j = 1:2
    
    hFig = figure;
    hAxes = axes('Parent', hFig, 'XGrid', 'on', 'YGrid', 'on', 'Box', 'on', 'linewidth', 1);
    set(hFig, 'Color', 'w');
    hold('on');

    if j == 1
        data = importdata('flowCallibration.csv');
    else
        data = importdata('flowCallibration1.csv');
    end

    anemQ = data(6, :);
    flowmQ = data(7, :);
    y = zeros(1, 8);

    for i = 1:8
        relEr(i) = ( flowmQ(i) - anemQ(i) ) / anemQ(i) * 100
    end

    ind = 3:8;
    RMSE(j) = sqrt( mean( (relEr) .^ 2 ) );
    RMSEr(j) = sqrt( mean( (relEr(ind)) .^ 2 ) );
    
    plot(hAxes, flowmQ, relEr, '-o', 'MarkerEdgeColor', [0, 0.4470, 0.7410], 'MarkerFaceColor', [0, 0.4470, 0.7410], 'Markersize', 6, 'Linewidth', 1.5);
    plot(hAxes, flowmQ, y, '-s', 'MarkerEdgeColor', [0.8500, 0.3250, 0.0980], 'MarkerFaceColor', [0.8500, 0.3250, 0.0980], 'Markersize', 6, 'Linewidth', 1.5);

    ylim([-40 40]);
    xlim([min(flowmQ) max(flowmQ)]);

    xlabel('Volumetric flow rate $[m^3/s]$');
    ylabel('Relative error [\%]');
    
    legend('Flowmeter', 'Hot-wire', 'Location', 'NorthEast');

    PlotDimensions(gcf, 'centimeters', [15.747, 8], 12);
    ChangeInterpreter(gcf, 'Latex');
    Plot2LaTeX(hFig, ['flowcalibration', num2str(j)])
end