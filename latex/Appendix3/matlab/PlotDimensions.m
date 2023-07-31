function PlotDimensions(h, Units, Plotsize, Fontsize)

    h.Units = Units; % μονάδες μέτρησης διαστάσεων
    h.Position(2) = (h.Position(2) - 8.5); % θέση γραφήματος
    h.Position((3:4)) = Plotsize; % προσδιορισμός διαστάσεων 
    set(findall(h, '-property', 'FontSize'), 'FontSize',...
        Fontsize); % μέγεθος φόντου
end 
