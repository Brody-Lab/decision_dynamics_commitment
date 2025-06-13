% [sp] = adaptive_mult(sp, hit, {'hit_frac', 0}, {'stableperf', 0.75}, ...
%                         {'mx', 1}, {'mn', 0}, {'do_callback', 0})
% 
% Implements multiplicative staircase adaptation of a SoloParamHandle. sp
% can also be a simple scalar (Matlab type "double"), in which case
% callbacks are ignored, and the updated scalar is returned.
%
% PARAMETERS:
% -----------
%
% sp        The SoloParamHandle to be adapted. If sp is a scalar, the
%           updated, post-adaptation scalar is returned.
%
% hit       Pass this as 1 if latest trial was in the positive adaptation
%           direction; passit as 0 if it was in the negative direction
%
% OPTIONAL PARAMETERS
% -------------------
%
% hit_frac    Fraction extra to add to the parameter when
%             hit==1. That is, when hit==1, the parameter gets
%             multiplied by (1+hit_frac). Default value is 0, meaning
%             no adaptation whatsoever. hit_frac can be less than 0. 
%
% stableperf  The percentage of positive trials that would lead to no
%             movement on average. stableperf is used to calculate the
%             size of how much the SPH is divided when
%             hit==0. Default value is 75%. Performance below this will
%             (on average) lead to motion in the -hit_frac direction;
%             performance above this will lead to motion in the
%             hit_frac direction.  
%
% mx          Maximum bound on the SPH: value cannot go above this
%
% mn          Minimum bound on the SPH: value cannot go below this
%
% do_callback If 1, at the end of the adaptive mult calls the sp's
%             callback, i.e. does callback(sp);. By default this optional
%             param is 0, i.e. the callback is NOT called.
%                If sp is not a SoloParamHandle but is a scalar,
%             do_callback is ignored.
%
%
% RETURNS:
% --------
%
% sp          The SoloParamHandle. If sp was a scalar, then the return is
%             the updated, post-adaptation scalar.
%
%
%
% EXAMPLE CALL:
% -------------
%
%  >> adaptive_mult(my_sph, hit, 'hit_frac', 0.1, 'stableperf', 0.75, 'mx, ...
%                   100, 'mn', 90)
%
% Will increase my_sph by 10% every time hit==1, and will decrease it
% by 30% every time hit==0. my_sph will be bounded within 90 and 100.
%


function [sp] = adaptive_mult(sp, hit, varargin)
   
   pairs = { ...
     'hit_frac'      0    ; ...
     'stableperf',   0.75 ; ...
     'mx'            1    ; ...
     'mn'            0    ; ...
     'do_callback'   0    ; ...
   }; parseargs(varargin, pairs);


   log_hit_step  = log10(1 + hit_frac);
   log_miss_step = stableperf*log_hit_step/(1-stableperf); 

   
   if isa(sp, 'SoloParamHandle'), 
     if hit==1,      sp.value = sp * (10.^log_hit_step);
     else            sp.value = sp / (10.^log_miss_step);
     end;

     if sp > mx, sp.value = mx; end;
     if sp < mn, sp.value = mn; end;

     if do_callback,
       callback(sp);
     end;
   else  % ------ assume sp is a regular scalar.
     if hit==1,      sp = sp * (10.^log_hit_step);
     else            sp = sp / (10.^log_miss_step);
     end;

     if sp > mx, sp = mx; end;
     if sp < mn, sp = mn; end;
   end;
   
