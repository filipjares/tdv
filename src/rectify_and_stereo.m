
addpath rectify/

i1 = 6;
i2 = 7;

P1 = K*cameras{i1};
P2 = K*cameras{i2};

im1=images(i1).img;
im2=images(i2).img;

F = cameras2F(P1,P2);

[H1, H2, im1r, im2r] = rectify(F, im1, im2);

D = gcs(im1r, im2r, []);
P1r = H1*P1;
P2r = H2*P2;



