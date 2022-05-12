function PlotDimensions(h, Units, Plotsize, Fontsize)

    h.Units = Units;
    h.Position(2) = (h.Position(2) - 8.5); 
    h.Position((3:4)) = Plotsize; %σύνηθες [15.747, 9] 
    set(findall(h, '-property', 'FontSize'), 'FontSize', Fontsize);

end 
