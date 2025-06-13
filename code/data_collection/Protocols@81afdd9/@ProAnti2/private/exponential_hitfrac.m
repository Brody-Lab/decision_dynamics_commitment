function [hfrac] = exponential_hitfrac(type_history, hit_history, tau, varargin)

   pairs = { ...
     'separate'    0   ; ...
     'total_types' 1   ; ...
   }; parseargs(varargin, pairs);
     % 'pad_ones'    0   ; ...

 if isempty(hit_history), hfrac = []; return; end;
 if size(hit_history, 1) > size(hit_history, 2), hit_history  = hit_history';  end;
 if size(type_history,1) > size(type_history,2), type_history = type_history'; end;
 if length(type_history) ~= length(hit_history),
   error('Exponential_Hitfrac:Invalid', ...
     'Need type_history to be either empty or same length as hit_history');
 end;

 if isempty(type_history), uts = 1; 
 else                      uts = unique(type_history);
 end;
 
 if length(uts) > total_types, total_types = length(uts); end;
 
 kernel = exp(-(0:5*tau)/tau); kernel = kernel(end:-1:1);
 
% if pad_ones==1 &&  length(hit_history) < length(kernel);
%   hit_history = [ones(1, length(kernel)-length(hit_history)) hit_history];
% end;

 k = min(length(hit_history), length(kernel));
 kernel       = kernel(end-k+1:end);
 hit_history  = hit_history(end-k+1:end);
 type_history = type_history(end-k+1:end);

 % if there are more total types than unique types already presented, pad
 % the unpresented trial types with ones.
 hfrac = ones(total_types, 1);
 
%  if length(uts)==1,
%    hfrac = sum(hit_history.*kernel)/sum(kernel);
%    return;
%  end;

 for i=1:length(uts),
   u = find(type_history==uts(i));
   if isempty(u), hfrac(i) = 1;  % Assume all hits if last trial was outside the kernel
   else
     if separate,
       hfrac(i) = sum(hit_history(u).*kernel(end-length(u)+1:end))/sum(kernel(end-length(u)+1:end));
     else
       hfrac(i) = sum(hit_history(u).*kernel(u))/sum(kernel(u));
     end;
   end;
 end;
 
