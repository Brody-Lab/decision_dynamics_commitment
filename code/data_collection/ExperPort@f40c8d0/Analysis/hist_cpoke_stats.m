% [handles] = hist_cpoke_stats(cpokestats, handles)
%
% Produces a histogram of which states there were center pokes in.
%
% CARLOS: DOCUMENT ME!!!
%

function [hhandles] = hist_cpoke_stats(cpokestats, varargin)

   pairs = { ...
     'handles'            []   ; ...
     'custom_colors'      []   ; ...
     'plottables'         []   ; ...
   }; 

   if nargin==2, 
      parseargs({}, pairs);
      handles = varargin{1}; 
   else
      parseargs(varargin, pairs);
   end;
   
   if isempty(custom_colors)
       state_colors; % This script determines vars "plottables" and "SC"
   else
      SC = custom_colors;
      if isempty(plottables), 
         error('When custom state colours are provided, custom plottables must be, too!');
      end;
   end;   
   
   nbars = size(plottables,1);

   if isstr(cpokestats) && strcmp(cpokestats, 'make_labels');
      for i=1:nbars,
         fill([i-0.9 i-0.9 i-0.1 i-0.1], [0 1 1 0], SC.(plottables{i,1}));
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
   
   if isempty(handles),
      handles = zeros(nbars,1); 
   end;
   
   mx = 0.1; for i=1:nbars,
      if isfield(cpokestats, plottables{i,1}), 
         hght = cpokestats.(plottables{i,1}); 
      else
         hght = 0;
      end;
      mx = max(mx, hght);
      if handles(i)==0,
         handles(i) = ...
             fill([i-1 i-1 i i], [0 hght hght 0], SC.(plottables{i,1}));
      else 
         set(handles(i), 'YData', [0 hght hght 0]);
      end;
   end;
   
   set(get(handles(1), 'Parent'), 'Ylim', [0 mx], 'Xlim', [0, nbars], ...
                     'XTick', 0.5:1:nbars, 'XtickLabel', '', 'TickDir', ...
                     'out');

   
   if nargout > 0, hhandles = handles; end;
   
