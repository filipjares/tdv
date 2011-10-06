function indices = fits_into_image(A, obj)

    if (nargin < 2)
        Xs = xlim;
        Ys = ylim;
    else
        if (~ishandle(obj) || ~strcmp(get(obj, 'type'), 'axes'))
            error('The obj parameter has to be axes handle.');
        end
        Xs = get(obj, 'XLim');
        Ys = get(obj, 'YLim');
    end

    Eps = eps*10^3;
    
    X_LO = Xs(1) - Eps;
    X_HI = Xs(2) + Eps;
    Y_LO = Ys(1) - Eps;
    Y_HI = Ys(2) + Eps;

    indices = A(1,:) >= X_LO & A(1,:) <= X_HI & A(2,:) >= Y_LO & A(2,:) <= Y_HI;

end