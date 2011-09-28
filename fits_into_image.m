function indices = fits_into_image(A)

    Eps = eps*10^3
    X_LO = 1 - Eps;
    X_HI = 800 + Eps;
    Y_LO = 1 - Eps;
    Y_HI = 600 + Eps;

    indices = A(1,:) >= X_LO & A(1,:) <= X_HI & A(2,:) >= Y_LO & A(2,:) <= Y_HI;

end