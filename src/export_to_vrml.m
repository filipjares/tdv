function export_to_vrml(filename, cameras, X, Xcolors)

    if ~iscell(cameras)
        error('The cameras parameter has to be cell array containing camera matrices.');
    end
    
    for i = 1:length(cameras)
        if ~all(size(cameras{i}) == [3 4])
            error('Invalid camera. Camera has to be a 3x4 matrix.');
        end
    end
    
    if size(X,1) == 4
        X = p2e(X);
    end
    
    if size(X,1) ~= 3
        error('The X parameter representing points has to be 3xn or 4xn matrix.');
    end
    
    if nargin > 3
        if (size(Xcolors,1) ~= 3)
            error('Xcolors parameter has to be 3xn array');
        end
        if (size(X,2) ~= size(Xcolors,2))
            error('Different number of points and colors');
        end
    else
        colors = ones(3, size(X,2));
    end
    
    sel = X(1,:) > -15 & X(1,:) < 15 & ...  
          X(2,:) > -15 & X(2,:) < 15 & ...  
          X(3,:) > -15 & X(3,:) < 15;
      
    ge = ge_vrml(filename);
    ge = ge_cams(ge, cameras, 'plot', 1);       % P1, P2 jsou kamery bez K ([I 0], [R t])
    ge = ge_points(ge, X(:,sel), 'color', colors(:,sel));   % predavame euklidovske body
    ge = ge_close(ge);

end