% [history] = get_history({'name', '.*',}, {'fullname', '.*'}, ...
%        {'owner', '.*'}, {'handlelist', {}}, {'first', 0}, {'nth', 0}, ...
%        {'drop_last_trial', 1})    
%
% Given some search parameters, this function first finds the SoloParamHandle(s)
% that fit those parameters. If there is only one SPH that fits, returns its
% history. If the history can be returned in a doubles vector, does so;
% otherwise it is returned in a cell vector.
%
% This function is useful for analysis (e.g., from the command window), but
% is not recommended for runtime while a protocol is going, since it uses
% get_sphandle.m, which is (a) slow and (b) gets around the variable
% ownership controls that try to keep things clean-- that is, this function
% can help you write spaghetti code.
%
% If more than one param fits the search terms, alerts the user and returns
% nothing.
%
% If an odd number of parameters are passed, and the first is a string, the 
% first is assumed to be a string to match to a name (not a fullname).
%
% OPTIONAL PARAMETERS:
% ---------------------
%
% 'name'       A string that will be matched (using regexp.m) to the name
%              of the SoloParamHandle-- e.g., if a SoloParamHandle with
%              name 'nombre' was created in function
%              @myobject/myfunction.m, then the name is 'nombre'. Thus  the
%              strings 'nombre' and 'nom' and 'ombr' will all match it.
%              To match the exact name, use '^nombre$' (see help
%              regexp.m). Default value of this optional param is '.*',
%              i.e., all names.
%
% 'fullname'   A string that will be matched (using regexp.m) to the fullname
%              of the SoloParamHandle-- e.g., if a SoloParamHandle with
%              name 'nombre' was created in function
%              @myobject/myfunction.m, then the fullname is
%              'myfunction_nombre'. Thus the strings 'myfunc' and
%              'tion_nom' and 'ombr' will all match it. To match the exact
%              fullname, use '^myfunction_nombre$' (see help regexp.m).
%              Default value of this optional param is '.*', i.e., all
%              fullnames.
%
% 'owner'      A string that will be matched (using regexp.m) to the owner of
%              the SoloParamHandle. Typically the owner is the class of the
%              object that created the SoloParamHandle-- e.g., if a
%              SoloParamHandle with name 'nombre' was created in function
%              @myobject/myfunction.m, then the owner is 'myobject'. Thus
%              the strings 'myobj' and 'obje' and 'ct' will all match it.
%              To match the exact owner string, use '^myobject$' (see help
%              regexp.m). Default value of this optional param is '.*',
%              i.e., all owners.
%
% 'handlelist' A cell vector, each entry of which is a SoloParamHandle.
%              Default value of this parameter is an empty cell. When
%              handlelist is an empty cell, all existing SoloParamHandles
%              are searched. When handlelist is not empty, only
%              SoloParamHandles *within* the list will be searched.
%              Limiting the search this way can be useful when trying to
%              speed things up.
%
% 'nth'        An integer, default value is 0. The value 0 means "perform
%              as normal." A non-zero integer means "if you find many
%              matching SPHs, return the history of the nth one."
%
% 'drop_last_trial'   Either 0 or 1, by default 0.  Many SoloParamHandles
%              that are used for settings have a history that is one trial
%              longer than the number of done trials in a session. This is
%              because the session ended during the last trial (which was
%              therefore nt completed). If this parameter is passed as 1,
%              the last trial is dropped from the history.
%
% `return_n_done_trials` Either 0 or 1, by deault 0. This is a more
%              specific way to drop any extra trials that may be in the
%              history of a variable so that what is returned is
%              n_done_trials long. This is especially helpful in a case
%              where a crash occured that killed a session.
%
%
% RETURNS:
% --------
%
% history      Usually a cell vector, containing the history of entries for the 
%              matched SoloParamHandle. If cell2mat can be successfully run
%              on this vector, it is run, and the doubles vector is
%              returned instead.
%
%
% EXAMPLE:
% ---------
%
% >> history = get_sphandle('name', 'this')
%
% Will return the history of the SoloParamHandle that has the string 'this' in their
% name, regardless of owner or fullname. 
%
% >> history = get_sphandle('parsed_events')
%
% will find both latest_parsed_events and parsed_events. However, the
% regexp caret ^ to indicate start of string, like this:
%
% >> history = get_sphandle('^parsed_events') 
%
% will find just parsed_events and return its history.
%
%
% See get_sphandle.m for mroe info on search terms.
%

% Written by Carlos Brody 2009
% Edited by Jess Breda 2023

function [history] = get_history(varargin)

if rem(nargin,2)==1 && ischar(varargin{1}),
  name_default = varargin{1};
  varargin = varargin(2:end);
else
  name_default = '.*';
end;

pairs = { ...
  'owner'                '.*'   ; ...
  'fullname'             '.*'   ; ...
  'handlelist'           {}    ; ...
  'nth'                  []    ; ...
  'name'                 name_default   ; ...
  'drop_last_trial'      0     ; ...
  'return_n_done_trials' 0 ;...
}; parseargs(varargin, pairs);
   
sps = get_sphandle('owner', owner, 'name', name,  'fullname', fullname, 'handlelist', handlelist);

if numel(sps)>1
  if ~isempty(nth),
    if nth < 1 || numel(sps) < nth,
      error('Only found %d matches, you asked for nth=%g', numel(sps), nth);
    end;
    sps = sps(nth);
  else
    fprintf(1, 'get_history.m found more than one match:\n');
    for i=1:numel(sps),
      fprintf(1, '   Fullname "%s"\n', get_fullname(sps{i}));
    end;
    history = [];
    return;
  end;
end;

if isempty(sps),
  history = []; fprintf(1, 'No matches found\n');
  return;
end;
 
try
  history = cell2mat(get_history(sps{1}));
  if isstruct(history), 
     history = get_history(sps{1});
  end;
catch %#ok<CTCH>
  history = get_history(sps{1});
end;

if drop_last_trial, history = history(1:end-1); end;

if return_n_done_trials, history = history(1:get_value('n_done_trials')); end;
    
