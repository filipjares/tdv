function lines = image_lines( img, lines )
%IMAGE_LINES  Edit two groups of lines in the image. 
%
%  lines = image_lines( img, lines )
%
%  Edit two groups of lines in the image. Demonstration of EDIT_LINES usage.
%
%  Input:
%    lines .. structure, fields:
%      .x1, .y1 .. end points of the lines from the first group
%      .x2, .y2 .. end points of the lines from the second group
%
%    Coordinates are in the form [ ... [beg_i;end_i] ... ] where
%    beg_i is the i-th line start point and end_i is the i-th line end point.
%
%  Output:
%    lines .. modified structure

% (c) 2010-09-16, Martin Matousek
% Last change: $Date::                            $
%              $Revision$
% Permissions to use:
%   This software can be used for educational purposes by FEE students. 
%   Other use requires a licence.

if( ~exist( 'lines', 'var' ) || isempty( lines ) )
  lines = struct;
end

style1 = { 'color', 'r', 'linewidth', 2, 'tag', '1' };
style2 = { 'color', 'y', 'linewidth', 2, 'tag', '2' };

f = figure;
imagesc( img );
hold on
if( isfield( lines, 'x1' ) )
  plot( lines.x1', lines.y1', style1{:} );
end

if( isfield( lines, 'x2' ) )
  plot( lines.x2', lines.y2', style2{:} );
end
hold off
edit_lines( gcf, { style1 style2 } );

input( 'Edit the lines and then press Enter when done.' );

h1 = findobj( gcf, 'tag', '1' );
lines.x1 = cell2mat( get( h1, 'xdata' ) );
lines.y1 = cell2mat( get( h1, 'ydata' ) );

h2 = findobj( gcf, 'tag', '2' );
lines.x2 = cell2mat( get( h2, 'xdata' ) );
lines.y2 = cell2mat( get( h2, 'ydata' ) );

close( f );