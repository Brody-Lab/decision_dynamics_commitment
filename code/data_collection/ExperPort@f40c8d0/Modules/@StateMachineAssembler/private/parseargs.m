%parseargs   [] = parseargs(arguments, pairs, singles)
%
% Variable argument parsing-- supersedes parseargs_example. This
% function is meant to be used in the context of other functions
% which have variable arguments. Typically, the function using
% variable argument parsing would be written with the following
% header:
%
%    function myfunction(args, ..., varargin)
%
% and would define the variables "pairs" and "singles" (in a
% format described below), and would then include the line
%
%       parseargs(varargin, pairs, singles);
%
% 'pairs' and 'singles' specify how the variable arguments should
% be parsed; their format is decribed below. It is best
% understood by looking at the example at the bottom of these help 
% comments.
%
% PARSEARGS DOES NOT RETURN ANY VALUES; INSTEAD, IT USES ASSIGNIN
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
% -singles       A cell array of all those arguments that are
%                specified by a single flag. The first column must 
%                indicate the flag; the second column must
%                indicate the corresponding variable name that
%                will be affected in the caller's workspace; the
%                third column must indicate the value that that
%                variable will take upon appearance of the flag;
%                and the fourth column must indicate a default
%                value for the variable.
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
% In "singles", the first column is the flag to be looked for in varargin, 
% the second column defines the variable name this flag affects, the third
% column defines the value the variable will take if the flag was found, and
% the last column defines the value the variable takes if the flag was NOT
% found in varargin.
%
%   singles = {'no_plot' 'plot_fg' '0' '1'; ...
%             {'plot'    'plot_fg' '1' '1'};
%
% 
% Now for the function call from the user function:
%
%   parseargs({'blob', 'fuff!', 'no_plot'}, pairs, singles);
%
% This will set, in the caller space, thingy=20, blob='fuff!', and
% plot_fg=0. Since default values are in the second column of "pairs"
% and the fourth column of "singles", and in the call to
% parseargs 'thingy' was not specified, 'thingy' takes on its
% default value of 20. 
%
% Note that the arguments to parseargs may be in any order-- the
% only ordering restriction is that whatever immediately follows
% pair names (e.g. 'blob') will be interpreted as the value to be
% assigned to them (e.g. 'blob' takes on the value 'fuff!');
%
% If you never use singles, you can just call "parseargs(varargin, pairs)"
% without the singles argument.
%


function [] = parseargs(arguments, pairs, singles)
   
   if nargin < 3, singles = {}; end;

   for i=1:size(pairs,1),
      assignin('caller', pairs{i,1}, pairs{i,2});
   end;
   for i=1:size(singles,1),
      assignin('caller', singles{i,2}, singles{i,4});
   end;
   if isempty(singles), singles = {'', '', [], []}; end; 
   if isempty(pairs),   pairs   = {'', []}; end; 
   
   arg = 1; while arg <= length(arguments),
      
      switch arguments{arg},
	 
	 case pairs(:,1),
	 if arg+1 <= length(arguments)
	    assignin('caller', arguments{arg}, arguments{arg+1});
	    arg = arg+1;
	 end;
      
	 case singles(:,1),
	 u = find(strcmp(arguments{arg}, singles(:,1)));
	 assignin('caller', singles{u,2}, singles{u,3});
	 
	 otherwise
	 arguments{arg}
	 mname = evalin('caller', 'mfilename');
	 error([mname ' : Didn''t understand above parameter']);
	 
      end; 
   arg = arg+1; end;
   
   return;
