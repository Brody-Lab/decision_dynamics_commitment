% [] = move(sph, x, y)    Moves a SoloParamHandle by a specified number of pixels in x and y. Both
%  the GUI and the label move, together.

function [] = move(sph, x, y)

if isempty(get_type(sph)), return; end;

gh = get_ghandle(sph); 
ghpos = get(gh, 'Position');
set(gh, 'Position', [ghpos(1)+x ghpos(2)+y ghpos(3:4)]);

lh = get_lhandle(sph); 
if ~isempty(lh),
   lhpos = get(lh, 'Position');
   set(lh, 'Position', [lhpos(1)+x lhpos(2)+y lhpos(3:4)]);
end;


