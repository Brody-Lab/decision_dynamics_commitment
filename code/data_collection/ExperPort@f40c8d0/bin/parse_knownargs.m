%parse_knownargs   [] = parse_knownargs(arguments, pairs)
%
% Variable argument parsing-- enables passing ('ParameterName',
% ParameterValue) pairs, in any order, and setting default values
% for them. This is exactly like parseargs.m, but names that don't find a
% match in the name-value listing are simply skipped and ignored, without
% causing an error or a warning.
%
% EXAMPLE: you write the function blooh.m as:
%
% function blooh(varargin)
%    pairs = { ...
%       'npoints'   10  ; ...
%       'names'     {'Karl', 'Frederic'} ; ...
%    }; parse_knownargs(varargin, pairs);
%    % ... further code of your own ...
%
% Then, the following calls will instantiate variables inside the
% function as follows:
%
%   >> blooh;  % npoints = 10; names = {'Karl' 'Frederic'};
%  
%   >> blooh('names', 'none');   % npoints=10;  names='none';
%
%   >> blooh('names', 'none', 'guu', 10);   % npoints=10;  names='none'; (guu
%                                           % is unknown therefore ignored).
%
%   >> blooh('names', 34, 'npoints', 300);  %npoints=300; names=34;
%
%
% etc. etc.
% 
%
% KNOWN BUG: if one of the variable names is a Matlab reserved
% word, it doesn't get instantiated correctly unless you reassign
% it before the call to parse_knownargs. 
% WORKAROUND: say you want to use the variable isa (which is a
% Matlab function). Then set isa=[]; before defining 'pairs', and
% everything will work fine.
% BUG SOLUTION: This is a Matlab bug. Maybe future versions will 
% correct it.
%
%
% PARSE_KNOWNARGS DOES NOT RETURN ANY VALUES; INSTEAD, IT USES ASSIGNIN
% COMMANDS TO CHANGE OR SET VALUES OF VARIABLES IN THE CALLING
% FUNCTION'S SPACE.  
%
%
%
% PARAMETERS:
% -----------
%
% -arguments     The varargin list, I.e. a row cell array.
%
% -pairs         A cell array of all those arguments that are
%                specified by argument-value pairs. First column
%                of this cell array must indicate the variable
%                names; the second column must indicate
%                correponding default values. 
%
%
%
% Example:
% --------
%
% In "pairs", the first column defines both the variable name and the 
% marker looked for in varargin, and the second column defines that
% variable's default value:
%
%   pairs = {'thingy'  20 ; ...
%            'blob'    'that'};
%
%
%   parse_knownargs({'blob', 'fuff!'}, pairs);
%
% This will set, in the caller space, thingy=20, blob='fuff!', and
% plot_fg=0. Since default values are in the second column of "pairs", and in
% the call to parse_knownargs 'thingy' was not specified, 'thingy' takes on its
% default value of 20.
%
% Note that the arguments to parse_knownargs may be in any order-- the
% only ordering restriction is that whatever immediately follows
% pair names (e.g. 'blob') will be interpreted as the value to be
% assigned to them (e.g. 'blob' takes on the value 'fuff!');
%
%


function [] = parse_knownargs(arguments, pairs)
   
   for i=1:size(pairs,1),
      assignin('caller', pairs{i,1}, pairs{i,2});
   end;
   if isempty(pairs),   pairs   = {'', []}; end; 
   

   for arg = 1:2:length(arguments)-1
      switch arguments{arg},
	 
       case pairs(:,1),
	 if arg+1 <= length(arguments)
	    assignin('caller', arguments{arg}, arguments{arg+1});
	 end;
      
       otherwise
	 
      end; 
   end;
   
   return;
