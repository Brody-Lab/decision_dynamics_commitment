% [pos, pos2] = gui_position({'get_width'}, {'get_height'}, {'get_default_width'}, {'get_default_height'}, ...
%                    {'set_width'}, {'set_height'}, {'reset_width'}, {'reset_height'}, ..
%                    {'addrows', nrows, x, y}, {'addcols', ncols, x, y}, {x, y});
%
% Helper function for dealing with positioning of GUI items. This function
% keeps an internal record of a standard GUI item WIDTH and a standard gui
% item HEIGHT, and does simple calculations like adding these standards to
% a given position.
%
% If the function is called with two arguments, gui_position(x, y), where x
% and y are positiive integers, it returns a 1-by-4 vector, [x y w h] 
% where w and h are the standard width and the standard height. 
%
% If the firs parameters passed to this function is not a number but a
% string, behavior depends on this string:
%
%  'get_width'    Returns the standard width
%
%  'get_height'   Returns the standard height
%
%  'set_width' w  This requires an extra argument, which will henceforth be
%                 used as the standard width in future calls.
% 
%  'set_height' h This requires an extra argument, which will henceforth be
%                 used as the standard height in future calls.
%
%  'reset_width'  Set the standard width back to its default (200 px)
%
%  'reset_height' Set the standard height bac to its default (20 px)
%
%  'get_default_width'    Returns 200, the default width (which may be
%                 different to the current standard if the standard was
%                 changed using 'set_width').
%
%  'get_default_height'   Returns 20, the default height (which may be
%                 different to the current standard if the standard was
%                 changed using 'set_width').
%
%  'addrows' nrows x y    Requires three more arguments, the number of rows
%                 of standard height to add, current x position, and
%                 current y position. Returns two parameters, [newx newy],
%                 which are the new position after adding nrows of standard
%                 height to position x y.
%
%  'addcols' ncols x y    Requires three more arguments, the number of cols
%                 of standard width to add, current x position, and
%                 current y position. Returns two parameters, [newx newy],
%                 which are the new position after adding ncols of standard
%                 width to position x y.
%

function [pos, pos2] = gui_position(varargin)

persistent itemwidth;
persistent itemheight;

DEFAULT_WIDTH = 200;
DEFAULT_HEIGHT = 20;

if isempty(itemwidth),  itemwidth = DEFAULT_WIDTH; end;
if isempty(itemheight), itemheight = DEFAULT_HEIGHT; end;

if nargin==0, error('Need at least one arg'); end;
if isstr(varargin{1}),
  switch varargin{1},
    case 'set_width',     itemwidth = varargin{2};
    case 'reset_width',   itemwidth = DEFAULT_WIDTH;
    case 'reset_height',  itemwidth = DEFAULT_HEIGHT;
    case 'set_height',   itemheight = varargin{2};
    case 'get_default_width',   pos = DEFAULT_WIDTH;
    case 'get_default_height',  pos = DEFAULT_HEIGHT;
    case 'get_height',          pos = itemheight;
    case 'get_width',           pos = itemwidth;
    case 'addrows',
      pos = varargin{3}; pos2 = varargin{4} + varargin{2}*itemheight;
    case 'addcols',
      pos = varargin{3}+varargin{2}*(itemwidth*1.03); pos2 = varargin{4};
    otherwise,
      error(['Don''t know how to deal with ' varargin{1}]);
  end;
  return;
end;

if nargin > 1
  x = varargin{1}; y = varargin{2};

  pos = [x y itemwidth itemheight];

end;

return;
