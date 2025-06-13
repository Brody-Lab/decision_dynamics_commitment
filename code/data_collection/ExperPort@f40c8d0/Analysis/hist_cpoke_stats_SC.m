% [handles] = hist_cpoke_stats(cpokestats, varargin)
%
% Produces a histogram of which states there were center pokes in.
%
% This version of hist_cpoke_stats gets the state colours
% directly from the calling object; it does not read the file in the current directory
%

function [hhandles] = hist_cpoke_stats(cpokestats, varargin)

pairs = { ...
	'handles'	, []  		; ...
	'SC'		, struct()	; ...
	'plottables'	, []		; ...	
};

	parse_knownargs(varargin, pairs);
	if isempty(fieldnames(SC)) || isempty(plottables)
		error('State colours have not been loaded.');
	end;
	
   	nbars = size(plottables,1);
	
	no_input_handles = 0;
	if isempty(handles) 
	   handles = zeros(nbars,1); 
	   no_input_handles = 1;
	end;
   %state_colors;

   if isstr(cpokestats) && strcmp(cpokestats, 'make_labels');
      for i=1:nbars,
         p = fill([i-0.9 i-0.9 i-0.1 i-0.1], [0 1 1 0], SC.(plottables{i,1}));
	 set(p,'ButtonDownFcn', {''});
         hold on;
         t = text(i-0.5, -0.5, plottables{i,1});
         set(t, 'Interpreter', 'none', ...
                'HorizontalAlignment', 'right', ...
                'VerticalAlignment', 'middle', 'Rotation', 90);
         set(gca, 'Visible', 'off');
      end;
      ylim([0 1]); xlim([0 nbars]);
      return;
   end;
   
   %if nargin<2, 
   %   handles = zeros(nbars,1); 
   %end;
   
   mx = 0.1; for i=1:nbars,
      hght = cpokestats.(plottables{i,1}); 
      mx = max(mx, hght);
      if no_input_handles % nargin<2,
         handles(i) = ...
             fill([i-1 i-1 i i], [0 hght hght 0], SC.(plottables{i,1}));
      else 
         set(handles(i), 'YData', [0 hght hght 0]);
%	 set(handles(i),'ButtonDownFcn', {@hist_cpoke_npokeDisp, cpokestats.(plottables{i,1})});
      end;
   end;

   set(get(handles(1), 'Parent'), 'Ylim', [0 mx], 'Xlim', [0, nbars], ...
                     'XTick', 0.5:1:nbars, 'XtickLabel', '', 'TickDir', ...
                     'out');

   
   if nargout > 0, hhandles = handles; end;
   
