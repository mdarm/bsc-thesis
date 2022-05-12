function ChangeInterpreter(h, Interpreter)
% ChangeInterpreter αλλάζει τον μεταγλωτιστή της εικόνας h

    TexObj = findall(h, 'Type', 'Text');
    LegObj = findall(h, 'Type', 'Legend');
    AxeObj = findall(h, 'Type', 'Axes');  
    ColObj = findall(h, 'Type', 'Colorbar');
    
    Obj = [TexObj; LegObj]; % Αντικείμενα τύπου Tex και Legend λαμβάνουν ίδιας μεταχείρισης
    
    n_Obj = length(Obj);
    for i = 1:n_Obj
        Obj(i).Interpreter = Interpreter;
    end
    
    Obj = [AxeObj; ColObj]; % Αντικείμενα τύπου Axes και Colorbar λαμβάνουν ίδιας μεταχείρισης
    
    n_Obj = length(Obj);
    for i = 1:n_Obj
        Obj(i).TickLabelInterpreter = Interpreter;
    end
end