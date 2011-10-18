
%%

addpath ../../

%%

figure(1);
clf;
im = imread('buildings.jpeg');
image(im);
axis equal;
hold on;

%%

[vanishing_point_1, vp1_l1, vp1_l2, vp1_h] = define_vanishing_point_in_picture('r');
[vanishing_point_2, vp2_l1, vp2_l2, vp2_h] = define_vanishing_point_in_picture('g');
[vanishing_point_3, vp3_l1, vp3_l2, vp3_h] = define_vanishing_point_in_picture('b');

%%

ninf = cross(vanishing_point_2, vanishing_point_3);
%ninfPoints = get_line_intersection_with_axes_boundaries(ninf);
draw_line_into_axes(ninf);

%%

xb = let_the_user_define_points_in_picture(1, false);

%%

xa = let_the_user_define_points_in_picture(1, false);

%%

ob = let_the_user_define_points_in_picture(1, false);
oa = let_the_user_define_points_in_picture(1, false);
p = cross(ob,oa);
m = cross(p,ninf);
h = cross(xb,m);

%%
draw_line_into_axes(p);
draw_line_into_axes(h);

%%

Z = p2e(vanishing_point_1);
la = cross(xa, vanishing_point_1);
U = p2e(cross(h, la));

%%

XA = p2e(xa);
OA = p2e(oa);

cross_ratio = norm(XA-OA)*norm(U-Z) / ( norm(XA-Z)*norm(U-OA) );
building_heights_ratio = cross_ratio;
