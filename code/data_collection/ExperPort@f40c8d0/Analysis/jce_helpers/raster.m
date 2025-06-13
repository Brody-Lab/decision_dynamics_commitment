% RASTER                     Raster plot of spike data
% 
%     raster(spk_times,h);
%
%     INPUTS
%     spk_times - spike times either as:
%                 1) cell array with separate cell for each trial
%                 2) array with separate column for each trial,
%                    in this case, data is binary with 1 for spike
%                    and zero otherwise.
%  
%     OPTIONAL
%     h         - figure handle

%     $ Copyright 2001-2003 Brian Lau <blau@cns.nyu.edu> $
%
%     REVISION HISTORY:
%     brian 11.15.01 written
%     brian 10.29.03 added color argument

function raster(spk_times,xax,h,col);

%----- Globals & constants
STYLE = 'pont';  % set this to 'point' to get points, set it
                 % to something else to get tick marks
HEIGHT = .50;    % controls the height of the tick marks
WIDTH = 1.25;    % controls the line thickness


if nargin >= 3
   axes(h);
else
   figure; 
end
%plot(xax./1E6,zeros(1,length(xax)),'-')
hold on;

if nargin < 4
   col = 'k';
end

tind = 1;
if iscell(spk_times) % Raw spike times
   for i = 1:length(spk_times)
      if ~isempty(spk_times{i})
         if strcmp(STYLE,'point')
            plot(spk_times{i}(:) , tind*ones(size(spk_times{i}(:))),[col '.'],'Markersize',2);
         else
            plot([spk_times{i}(:) , spk_times{i}(:)]', ...
               [(tind*ones(size(spk_times{i}(:))) - HEIGHT),...
                (tind*ones(size(spk_times{i}(:))) + HEIGHT)]',...
               [col '-'],'Linewidth',WIDTH);
         end
      end
      tind = tind + 1;
   end
else % Binary coding
   for i = 1:size(spk_times,2)
      temp = find(spk_times(:,i));
      if ~isempty(temp)
         plot([temp' ; temp'], ...
            [(tind*ones(size(temp)) - HEIGHT) , (tind*ones(size(temp)) + HEIGHT)]',...
            'k-','Linewidth',WIDTH);
      end
      tind = tind + 1;
   end
end
%axis([get(gca,'xlim') 0 (tind)]);

return
