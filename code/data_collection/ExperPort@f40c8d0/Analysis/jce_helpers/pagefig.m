%pagefig.m  [] = pagefig({'halfpage' | 'fullpage' | ...
%                        'landscape', 'no_size_change'}, ...
%                        {height, 6}, {'width', 6.5}, ...
%                        {'corneroffset', 0.5})
%
% Sets some figure defaults appropriate for printing on white
% pages. 
%
% 'halfpage' is the default, 5 inches tall. 'fullpage' is 10
% inches tall. A number indicates the height. Width is always 6.5 
% inches. 
%
% However, if 'landscape' is indicated, the page is set to be 10
% inches WIDE and 6.5 inches TALL.
%
% If 'no_size_change' is indicated, screen size and position will
% not be changed, though everything else will proceed as normal.
%


function pagefig(varargin)
   
   pairs = { ....
       'height'         6    ; ...
       'width'          6.5  ; ...
       'FontSize'       7    ; ...
       'scale'          100  ; ...
       'corneroffset'   0.5  ; ...
   }; 
   singles = { ...
       'landscape'   'landscape'    'landscape'  'portrait'  ; ...
       'no_size_change'  'no_size_change'  1       []   ; ...
       'halfpage'        'height'          5        6   ; ...
       'fullpage'        'height'          10       6   ; ...
   }; parseargs(varargin, pairs, singles);

   
   
   if strcmp(landscape, 'landscape'),
      if isempty(no_size_change),
	 height = 7.5; width = 10;
	 set(gcf, 'Position', ...
	     [580, 250+(10-height)*57, width*57, height*57]);
      end;
      set(gcf, 'PaperOrientation', 'landscape');
      % set(gcf, 'PaperPosition', ...
      % [0.5+(7.5-height), (11-width)/2, width, height]);
      set(gcf, 'PaperPosition', ...
	  [corneroffset, corneroffset, width, height]);
   else
      if isempty(no_size_change),
	 set(gcf, 'Position', ...
	     [670, 1010-height*scale, width*scale, height*scale]);
      end;
      set(gcf, 'PaperOrientation', 'portrait');
      % set(gcf, 'PaperPosition', ...
      % [(8.5-width)/2, 0.5+(10-height), width, height]);
      set(gcf, 'PaperPosition', ...
	  [corneroffset, corneroffset, width, height]);
   end;

   
   clf;
   set(gcf, 'Color', 'w');
   set(gcf, 'InvertHardCopy', 'off');
   set(gcf, 'DefaultTextColor', 0.01*[1 1 1]);
   set(gcf, 'DefaultAxesFontSize',  FontSize);
   set(gcf, 'DefaultTextFontSize',  FontSize);
   set(gcf, 'DefaultAxesXColor',  0.01*[1 1 1]);
   set(gcf, 'DefaultAxesYColor',  0.01*[1 1 1]);
   set(gcf, 'DefaultAxesZColor',  0.01*[1 1 1]);
   set(gcf, 'DefaultLineColor',   0.01*[1 1 1]);
   set(gcf, 'DefaultAxesTickDir', 'out');

   return;
   
   
   
% -------------------------------------------------------------


function [] = old_parseargs(arguments)
   
   arg = 1; while arg <= length(arguments)
      
      if ~isstr(arguments{arg}),
	 assignin('caller', 'height', arguments{arg});
	 
      else
	 switch arguments{arg}
	    
	    case { 'halfpage' },
	    assignin('caller', 'height', 5);

	    case { 'fullpage' },
	    assignin('caller', 'height', 10);

	    case { 'no_size_change' },
	    assignin('caller', 'no_size_change', 1);
	    
	    case { 'landscape' },
	    assignin('caller', 'height', 7.5);
	    assignin('caller', 'width',  10.5);
	    assignin('caller', 'landscape', 'landscape');
	    
	    case { 'FontSize' 'height' 'width' 'scale'},
	    if length(arguments) >= arg+1,
	       assignin('caller', arguments{arg},arguments{arg+1});
	       arg = arg + 1;
	    end;


	    otherwise
	    arguments{arg},
	    error('Didn''t understand above parameter.');
	    
	 end;

      end;
   arg = arg+1; end;
      
   return;
   
   
   