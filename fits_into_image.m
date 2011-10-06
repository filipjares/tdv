function indices = fits_into_image(A)

    Eps = eps*10^3;
    
    Xs = xlim;
    Ys = ylim;
    
    X_LO = Xs(1) - Eps;
    X_HI = Xs(2) + Eps;
    Y_LO = Ys(1) - Eps;
    Y_HI = Ys(2) + Eps;

    indices = A(1,:) >= X_LO & A(1,:) <= X_HI & A(2,:) >= Y_LO & A(2,:) <= Y_HI;

end