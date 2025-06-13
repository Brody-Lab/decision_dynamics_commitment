function [hfrac] = exponential_hitfrac(type_history, hit_history, tau, uts,varargin)

pairs={'separate' 0};
parseargs(varargin,pairs);
 
 if isempty(hit_history), hfrac = []; return; end;
 
 if numel(type_history) ~= numel(hit_history),
   error('Exponential_Hitfrac:Invalid', ...
     'Need type_history to be either empty or same length as hit_history');
 end;
 
 kernel = exp(-(0:5*tau)/tau); kernel = kernel(end:-1:1);
 
 % if inputs are column vectors, make kernel one too
 if rows(hit_history) > cols(hit_history),
	 kernel = kernel(:);
 end;
 
 gd=~isnan(hit_history);
 hit_history=hit_history(gd);
 type_history=type_history(gd);
 
 
 k = min(length(hit_history), length(kernel));
 kernel       = kernel(end-k+1:end);
 hit_history  = hit_history(end-k+1:end);
 type_history = type_history(end-k+1:end);

 hfrac = ones(size(uts));

 for tx=1:length(uts),
   u = find(type_history==uts(tx));
   if isempty(u), hfrac(tx) = 1;  % Assume all hits if last trial was outside the kernel
   else
     if separate,
       hfrac(tx) = sum(hit_history(u).*kernel(end-length(u)+1:end))/sum(kernel(end-length(u)+1:end));
     else
       hfrac(tx) = sum(hit_history(u).*kernel(u))/sum(kernel(u));
     end;
   end;
 end;
 