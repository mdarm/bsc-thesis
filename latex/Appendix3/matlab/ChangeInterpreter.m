function ChangeInterpreter(h, Interpreter)

    % Μεταβλητές τύπου string του γραφήματος
    TexObj = findall(h, 'Type', 'Text');
    LegObj = findall(h, 'Type', 'Legend');
    AxeObj = findall(h, 'Type', 'Axes');  
    ColObj = findall(h, 'Type', 'Colorbar');
    
    Obj = [TexObj; LegObj]; % Ομαδοποίηση Legend και Text 
    
    n_Obj = length(Obj);
    for i = 1:n_Obj
        Obj(i).Interpreter = Interpreter;
    end
    
    Obj = [AxeObj; ColObj]; % Ομαδοποίηση Axes και Colorbar 
    
    n_Obj = length(Obj);
    for i = 1:n_Obj
        Obj(i).TickLabelInterpreter = Interpreter;
    end
end
