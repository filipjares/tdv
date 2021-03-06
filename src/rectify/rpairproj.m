function [i1,i2,cmin1,cmin2] = rpairproj( img1, img2, H1, H2, common )
%

if( nargin < 5 ), common = 0; end

i1 = [];
i2 = [];
cmin1 = [];
cmin2 = [];

[xcmin1, xcmax1, xcsz1, corners11, corners12, ...
 xcmin2, xcmax2, xcsz2, corners21, corners22] = ...
    rpairbb( H1, H2, size( img1 ), size( img2 ), common );

if( isempty( xcmin1 ) )
  return;
end

[i1, cmin1] = rimgproj( img1, H1, xcmin1, xcmax1 );
[i2, cmin2] = rimgproj( img2, H2, xcmin2, xcmax2 );

if( isempty( i1 ) || isempty (i2 ) ) 
  i1 = [];
  i2 = [];
end


if( ( cmin1(1) - cmin2(1) ) ~= 0 || ...
    ( size( i1, 1 ) - size( i2, 1 ) ) ~= 0 )
  fprintf( 'RPAIRPROJ: INTERNAL ERROR: images not row-aligned' )
  keyboard;
end


function [img2, cmin, c1, c2] = rimgproj( img1, H, acmin, acmax )
%

img1 = im2double( img1 );
if( nargin > 3 )
  c1 = [];
  c2 = [];
  cmin = acmin;
  cmax = acmax;
  sz = cmax - cmin + 1;
else
  [cmin cmax sz c1 c2] = rbb( H, size( img1 ) );
end

if( size( img1, 3 ) > 1 ), img1 = rgb2gray( img1 ); end

[u1 v1] = rcoordproj( inv(H), [cmin(:) sz(:)] );

img2 = interp2( img1, v1, u1 );
img2(isnan(img2)) = 0;

