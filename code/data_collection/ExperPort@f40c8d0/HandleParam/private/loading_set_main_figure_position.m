%  [] = loading_set_main_figure_position(owner, fig_position)  
%
% Helper function for load_soloparamvalues.m and load_solouiparamvalues.m 
% Args:
%    owner should be a string idenifying an SPH owner
%    fig_position should be a 1-by-4 integer vector: [x, y, width, height], in
%      pixels.
%

function [] = loading_set_main_figure_position(owner, fig_position)   

   protocol_name = get_sphandle('owner', owner, 'name', 'protocol_name');
   if ~isempty(protocol_name) && ~isempty(fig_position),
      protocol_name = protocol_name{1};
      % Get the main figure for this protocol and set its position
      f = findobj(get(0, 'Children'), 'Name', value(protocol_name));
      set(f, 'Position', fig_position); drawnow;
      % If window is too big, Macs automatically move it after drawnow and
      % can be a little off-screen. Check the position and correct if needed.
      pos = get(f, 'Position');
      if pos(2)<0, % If bottom is below screen make window shorter and move up
         pos(4) = pos(4) + pos(2); pos(2) = 0;
         set(f, 'Position', pos); drawnow;
      end;
   end;
   return;
   
  