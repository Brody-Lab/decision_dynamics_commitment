% [isbroken, brokelen, saveable, unsaveable] = cpoke_diagnostics(obj, pe, ...
%                  {'savetau', 0.05}, {'unsavetau', 0.15}, ...
%                  {'break_distrib', 0})
%
% Runs diagnostics on center poking quality. For each cpoke1 state, this
% method returns whether there were legal_cbreaks within center pokes, and
% what the mean length of those was. For cpokes that end in a violation,
% the method also probes whether a slight extension of the legal_cbreak
% would have prevented that violation, as well as whether it is known that
% extending the legal_cbreak would *not* have prevented the violation.
%
% PARAMETERS:
% -----------
%
% obj     A SameDifferent object, possibly empty, necessary only to run
%         this function as a method of the @SameDifferent class.
%
% pe      A parsed_events structure. Can also be a cell, in which case each
%         entry of the cell should be a parsed_events structure, and all
%         results will be of the same size as the cell, one result per
%         entry.
%
% RETURNS:
% --------
%
% isbroken    1 if the center poke had an interruption in it, 0 if it
%             didn't. Counts only from the beginning of the first cpoke to
%             the end of the last cpoke within the cpoke1 state: does not
%             count the last break if it was infinitely long (i.e.,
%             resulted in violation).  If there is more than one cpoke1
%             state in the trial, returns the average over these states.
%
% breaklen    Mean duration of breaks within center pokes, as in isbroken
%             above. Returns zero if there was no break. If the optional
%             param 'break_distrib' is passed as 1, then doesn't return the
%             mean put returns a column vector with an entry for the length
%             of each break. If there were no breaks, the vector returns
%             empty.
%
% saveable    if the cpoke1 state did not result in violation, returns NaN.
%             If it did result in violation, then returns 1 if there was
%             another C poke in savetau seconds after the end of the
%             cpoke1. Returns 0 otherwise (or if there was a side poke
%             anywhere in the trial).
%
% unsaveable  if the cpoke1 state did not result in violation, returns NaN.
%             If it did result in violation, then returns 1 if there was a
%             side poke anywhere withing the cpoke1 or within unsavetau
%             seconds after its end.
%
%  (Note: a trial can have both saveable=0 and unsaveable=0. But if it has
%  unsaveable=1, then it will be set to have saveable=0.)
%
%
% OPTIONAL PARAMS:
% ----------------
%
% savetau     By default 0.050, the number of seconds after the end of
%             cpoke1 that ended in violation within which to look for
%             another C poke which might have saved this from violation.
%
% unsavetau   By default 0.015, the number of seconds after the end of
%             cpoke1 that ended in violation within which to look for
%             a side poke that confirms that no extension of legal_cbreak 
%             could have saved this from being a violation.
%
% break_distrib  Integer, default 0. If this is 0, the rrteun parameter
%             "brokelen" will be the mean of the break lengths in the
%             trial, If this is 1, brokelen will be a column vector, length
%             numbero-of-breaks, each entry the length of the corresponding
%             break.
%

% written by Carlos Brody April 2009

function [isbroken, brokelen, saveable, unsaveable] = cpoke_diagnostics(obj, pe, varargin) %#ok<INUSL>


% 'cpokes_todo'       'all'   ;  ...
%   'violation_state'   'violation_state'      ;  ...
pairs = { ...
  'savetau'            0.05   ;  ...
  'unsavetau'          0.15   ;  ...
  'break_distrib'      0      ;  ...
}; parseargs(varargin, pairs);

if iscell(pe),
  isbroken   = zeros(size(pe));
  brokelen   = cell(size(pe));
  saveable   = zeros(size(pe));
  unsaveable = zeros(size(pe));

  for i=1:numel(pe),
    [a, b, c, d] = cpoke_diagnostics_core(pe{i}, ...
      savetau,  unsavetau, break_distrib);
    isbroken(i)   = a;
    brokelen{i}   = b;
    saveable(i)   = c;
    unsaveable(i) = d;
  end;
  
  if ~break_distrib, brokelen = cell2mat(brokelen); end;
  return;
end;

% pe not a cell: we're doing only a single trial
[isbroken, brokelen, saveable, unsaveable] = cpoke_diagnostics_core(pe, ...
  savetau, unsavetau, break_distrib);
return;


% -----------------------------------------
%% cpoke_diagnostics_core

function [isbroken, brokelen, saveable, unsaveable] = cpoke_diagnostics_core(pe, ...
  savetau, unsavetau, break_distrib)


states = pe.states;
pokes  = pe.pokes;

if isempty(states.cpoke1),
  isbroken = NaN; brokelen = NaN; saveable = NaN; unsaveable = NaN;
  return;
end;
  
% switch cpokes_todo,
%   case 'all',          guys = 1:size(states.cpoke1,1);
%   case 'first',        guys = 1;
%   case 'last',         guys = size(states.cpoke1,1);
% end;

isbroken = []; brokelen = []; saveable = []; unsaveable = [];
% fnames = fieldnames(states);

for i=1:size(states.cpoke1,1),
  cpoke1 = states.cpoke1(i,:);
  % for j=1:numel(fnames),
  %  if any(states.(fnames{j})(:,1) == cpoke1(2)),
  %    next_state = fnames{j}; break;
  %  end;
  % end;
  
  u = find(cpoke1(1) < pokes.C(:,1) & pokes.C(:,1) < cpoke1(2));
  if isempty(u),
    isbroken = [isbroken 0];  %#ok<AGROW>
    if ~break_distrib, brokelen = [brokelen ; 0]; end; %#ok<AGROW>
  else
    isbroken = [isbroken 1]; %#ok<AGROW>
    break_durations = pokes.C(u,1) - pokes.C(u-1,2);
    if break_distrib,
      brokelen = [brokelen ; break_durations]; %#ok<AGROW>
    else      
      brokelen = [brokelen ; mean(break_durations)]; %#ok<AGROW>
    end;
  end;
  
  if i<size(states.cpoke1,1) || size(states.violation_state,1) > 0,
    spk = [pokes.L(:,1) ; pokes.R(:,1)];
    if ~isempty(find(cpoke1(1) < spk & spk < cpoke1(2) + unsavetau, 1))
      unsav = 1; sav = 0;
    elseif ~isempty(find(cpoke1(2) < pokes.C(:,1) & pokes.C(:,1) < cpoke1(2) + savetau, 1))
      unsav = 0; sav = 1;
    else
      unsav = 0; sav = 0;
    end;
  else
    unsav = []; sav = [];
  end;
  
  unsaveable = [unsaveable unsav]; %#ok<AGROW>
  saveable   = [saveable     sav];  %#ok<AGROW>
end;

isbroken   = mean(isbroken);
if ~break_distrib, brokelen   = mean(brokelen); end;
if isempty(saveable), saveable = NaN; 
else                  saveable = mean(saveable);
end;
if isempty(unsaveable), unsaveable = NaN;
else                    unsaveable = mean(unsaveable);
end;
