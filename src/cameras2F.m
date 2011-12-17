function F = cameras2F(P1, P2)

    e2 = P2*null(P1);
    F = sqc(e2)*P2*pinv(P1);
    F = F/norm(F);

end