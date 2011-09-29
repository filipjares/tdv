function edit_lines( obj, styles )
%EDIT_LINES  Edit lines in the plot.
%
%  edit_lines( img [, styles ] )
%  edit_lines( ax  [, styles ] )
%  edit_lines( fig [, styles ] )
%
%  Editation of lines in the plot. New lines of length 2 can be created and
%  edited. Existing lines of arbitrary length can be deleted or edited.
%
%  Input:
%    img     .. image data. In this case the current figure is cleared and a new
%               plot is created.
%
%    ax     .. handle to existing axes. The axes can contain single image.
%
%    fig    .. handle to existing figure. The figure can contain single axes.
%
%    styles .. Optional, up to ten line styles for drawing new lines. Cell
%              matrix of cell matrices of style specifications. Eg. the matrix
%              { {'color', 'r', 'tag', 'A' } { 'color', 'y', 'linewidth', 2 } }
%              defines two styles.
%
%  Keyboard and mouse handling:
%    left click (on an empty area)   .. create a new line using the current
%                                       style. Left click finishes, 
%                                       right click cancels.
%
%    left click (near a line vertex) .. edit line vertex, left click finishes.
%
%    right click (on a line vertex)  .. delete the line.
%
%    middle click (on a line vertex) .. update the line style 
%                                       from the current style
%
%    'b', 'c', 'g', 'k', 'm', 'r', 'y' .. set the current style as normal
%                                         line with the given color
%
%    '1', '2', ... '0'                 .. select the current style from the
%                                         set of styles, if they are given
%
%  Note, that this tool only edit the lines in the plot. The line coordinates
%  for late use must be extracted from the figure. Different groups of lines
%  can be distinguished by color, etc. Using the 'tag' field in the styles
%  can be advantageous.
%
%  Example:
%    image
%    x = xlim; y = ylim;
%    l = line( x(1) + rand( 3 ) * diff(x), y(1) + rand( 3 ) * diff(y) )
%    set( l, 'color', 'y' );
%    edit_lines( gcf, {{ 'color', 'k', 'linewidth', 2, 'tag','a'} ...
%                     {'color','w', 'linewidth', 2, 'tag', 'b'}} )
%
%    % some editation now ...
%
%    % extract some data
%    ha = findobj( gcf, 'tag', 'a' )
%    hb = findobj( gcf, 'tag', 'b' )
%    hl = findobj( gcf, 'color', 'y' )
%
%    get( hl, 'xdata' )
%    get( hl, 'ydata' )

% (c) 2010-09-15, Martin Matousek
% Last change: $Date::                            $
%              $Revision$
% Permissions to use:
%   This software can be used for educational purposes by FEE students. 
%   Other use requires a licence.

stat = [];
stat.style = { 'color', 'b' };
if( nargin < 2 ), styles = {}; end
stat.styles = styles;
if( ~isempty( styles ) )
  stat.style = styles{1};
end
stat.line = 0;


if( ishandle( obj ) ) % edit existing plot
  switch( get( obj, 'type' ) )
    case 'axes'
      stat.ax = obj;
      fig = get( stat.ax, 'parent' );
    case 'figure'
      fig = obj;
      set( 0, 'currentfigure', fig );
      stat.ax = gca;
    otherwise
      error( 'Don''t know what to do for %s.', get( obj, 'type' ) );
  end
  
  him = findobj( stat.ax, 'type', 'image' );
  if( numel( him ) > 1 )
    error( 'Cannot work on axes with more than one image.' );
  end
  
  if( isempty( him ) )
    button_handle = stat.ax;
  else
    button_handle = him;
  end
  
  set( findobj( stat.ax, 'type', 'line' ), 'buttondownfcn', @line_callback );
else % create new plot with image
  clf
  fig = gcf;
  stat.ax = gca;
  button_handle = image( obj );
end

set( fig, 'resizefcn', @(a,b) setpxsize( fig ) );
set( fig, 'WindowKeyPressFcn', @(a, key) keypress_callback( fig, key ) );
set( button_handle, 'buttondownfcn', @(a,b) button_callback( fig ) )
set( fig, 'WindowButtonMotionFcn', [] );

setappdata( fig, 'stat', stat )
setpxsize( fig )  

% ------------------------------------------------------------------------------
function keypress_callback( fig, key )
%
stat = get_stat_pt( fig );

switch( key.Character )
  case { 'b', 'c', 'g', 'k', 'm', 'r', 'y' }
    stat.style = { 'color', key.Character };
    fprintf( 'New line color set: %s.\n', key.Character );
  case { '0', '1', '2', '3','4', '5', '6', '7', '8' ,'9' };
    num = str2double( key.Character );
    if( num == 0 ), num = 10; end
    if( length( stat.styles ) >= num )
      stat.style = stat.styles{num};
      fprintf( 'New line style set: %i.\n', num );
    else
      fprintf( 'No predefined line style %i.\n', num );
    end
  otherwise
    fprintf( 'No action for key ''%s''.\n', key.Character );
end

setappdata( fig, 'stat', stat );

% ------------------------------------------------------------------------------
function button_callback( fig )
%
[stat pt seltype] = get_stat_pt( fig );
  
if( stat.line  )
  if( isequal( seltype, 'normal' ) )
    x = get( stat.line, 'xdata' );
    y = get( stat.line, 'ydata' );
    x(stat.inx) = pt(1);
    y(stat.inx) = pt(2);
    set( stat.line, 'xdata', x, 'ydata', y );
    set( stat.line, 'ButtonDownFcn', @line_callback );
  else
    delete( stat.line )
  end
  set( fig, 'WindowButtonMotionFcn', [] );
  stat.line = 0;
else
  if( ~isequal( seltype, 'normal' ) ), return; end
  % new line
  set( fig, 'WindowButtonMotionFcn', @(a,b) motion_callback( fig ) );
  stat.line = line( pt([1 1]), pt([2 2]) );
  set( stat.line, stat.style{:} );
  stat.inx = 2;
  set( stat.line, 'buttondownfcn', @(a,b) button_callback( fig ) );
end
  
setappdata( fig, 'stat', stat );

% ------------------------------------------------------------------------------
function motion_callback( fig )
%
[stat pt] = get_stat_pt( fig );
if( ~stat.line )
  fprintf( 'Internal error - motion callback but no line selected.\n' );
  return
end

x = get( stat.line, 'xdata' );
y = get( stat.line, 'ydata' );

x(stat.inx) = pt(1);
y(stat.inx) = pt(2);
set( stat.line, 'xdata', x, 'ydata', y );
  
% ------------------------------------------------------------------------------
function line_callback( hline, dummy )
%
fig = gcbf;
[stat pt seltype] = get_stat_pt( fig );
if( stat.line ) % line is beeing edited
  return
end

switch( seltype )
  case 'alt'
    delete( hline );
  case 'normal'
    dx = ( get( hline, 'xdata' ) - pt(1) ) / stat.pxsize(1);
    dy = ( get( hline, 'ydata' ) - pt(2) ) / stat.pxsize(2);

    d = sqrt( dx.^2 + dy.^2 );
    if( any( d < 10 ) )
      [ dummy, stat.inx ] = min( d );
      stat.line = hline;
      set( fig, 'WindowButtonMotionFcn', @(a,b) motion_callback( fig ) );
      set( hline, 'buttondownfcn', @(a,b) button_callback( fig ) );
      setappdata( fig, 'stat', stat );
    end
  case 'extend'
    set( hline, stat.style{:} );
end
   
% ------------------------------------------------------------------------------
function [stat pt seltype] = get_stat_pt( fig )
%
stat = getappdata( fig, 'stat' );
pt = get( stat.ax, 'currentpoint' );
pt = pt( [1 3] )';
seltype = get( fig, 'SelectionType' );

% ------------------------------------------------------------------------------
function setpxsize(fig)
%
stat = getappdata( fig, 'stat' );

u = get( stat.ax, 'units' );
set( stat.ax, 'units', 'pixels' );
pos = get( stat.ax, 'pos' );
set( stat.ax, 'units', u );

stat.pxsize = [ diff( xlim ) / pos(3);
                diff( ylim ) / pos(4) ];

setappdata( fig, 'stat', stat );