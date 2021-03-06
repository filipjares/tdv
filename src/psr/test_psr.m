% PSR test
clear all; close all;
%% get image grid
[mX,mY] = meshgrid(-2:.05:2, -2:.04:2);                                
mZ = 3*mX .* exp(-mX.^2 - mY.^2);                                        

%% prepare data points
X{1} = zeros(size(mX,1),size(mX,2),3);

X{1}(:,:,1) = mX;
X{1}(:,:,2) = mY;
X{1}(:,:,3) = mZ;

%% flat in the middle

H = size(X{1},1);
W = size(X{1},2);
Hr = round(H/2);
Hh = round(H/5);

for x=(Hr-Hh):(Hr+Hh)
    for y=(Hr-Hh):(Hr+Hh)
        X{1}(x,y,3) = 0;
    end
end

%% some empty lines

X{1}(Hh,:,:) = NaN;
X{1}(H-Hh,:,:) = NaN;

%% some random holes

for i=1:100
   x = round(1+rand*(H-1));
   y = round(1+rand*(W-1));
   X{1}(x,y,:) = NaN;
end


%% plot it
surf(X{1}(:,:,1),X{1}(:,:,2),X{1}(:,:,3));

%% run
psr(X);

