
%% Known matrices K*R produce Q

K = [...
    1 0 400;
    0 1 600;
    0 0 1];

R = [0.8047   -0.5059   -0.3106; ...
     0.3106    0.8047   -0.5059; ...
     0.5059    0.3106    0.8047];
 
Q = K*R

%% Now, we will decompose Q back to K*R where R = R32*R31*R21

% multiplication Q*R32 has to produce result with zero on position 3,2
den = sqrt(Q(3,2)^2 + Q(3,3)^2);
c = Q(3,3)/den;
s = Q(3,2)/den;

R32 = [ ...
    1  0 0; ...
    0  c s; ...
    0 -s c]

B = Q*R32;

% multiplication Q*R32*Q31 has to produce result
% with zeros on positions 3,1 and 3,2
den = sqrt(B(3,1)^2 + B(3,3)^2);
c = B(3,3)/den;
s = B(3,1)/den;

R31 = [ ...
     c 0 s; ...
     0 1 0; ...
    -s 0 c]

C = B*R31;

% now K = Q*R32*R31*R21 should be upper triangular
den = sqrt(C(2,1)^2 + C(2,2)^2);
c = C(2,2)/den;
s = C(2,1)/den;

R21 = [ ...
     c s 0; ...
    -s c 0; ...
     0 0 1]
 
R = R32*R31*R21;
K = C*R21;          % K = Q*R

%% Results:
%
% K =
% 
%     1.0000   -0.0000  399.9899
%          0    1.0000  599.9848
%     0.0000    0.0000    1.0000
%
% R = R32*R31*R21
% 
%     0.8047    0.3106    0.5059
%    -0.5059    0.8047    0.3106
%    -0.3106   -0.5059    0.8047

