% [obj] = jump(obj, ['to', idx | 'offset', idx])
%
% jump(obj, 'to', idx) allows moving back and forward in training stages
%             idx: The index of the training stage to jump back/forward to
%
% jump(obj, 'offset', idx) jumps relative to the current training stage.
%
% example: in a set with 5 entries, suppose the 3th stage is actively being
% evaluated
%  >> jump(obj, 'offset', -1) ---> marks stage 1 as complete, and sets
%  stage 2 as currently active stage
%  >> jump(obj, 'to', 1) ---> marks stages 1, 2, 3 as being incomplete and sets 1 as
% being the currently active stage
%  >> jump(obj, 'to', 5) --> marks stages 3, 4 as being complete and sets 5 as the
% currently active stage
% 
%
% All stages *before* the active stage are marked as completed; the
% stage you jump to, the currently active stage, is marked as not
% complete.If you want to mark ALL stages as complete, jump to one more
% than the number of stages your session model has. E.g.:
%
%  >> jump(obj, 'to', 6) --> marks all stages, 1 through 5, as
%         complete. Since we only have 5 stages total, stage 5 is also
%         the current one.
%
%


function [obj] = jump(obj, varargin)

  pairs = { ...
      'to', []; ...
      'offset', []; ...
      };
  parse_knownargs(varargin, pairs);

if isempty(to) & isempty(offset),
  error(['Either jump ''to'' an index or specify an ''offset'' from the ' ...
         'current stage to jump to.']);
elseif ~isempty(to) & ~isempty(offset)
  error(['Please use _either_ the ''to'' functionality, or the ''offset'' ' ...
         'functionality; not both!']);
elseif ~isempty(to)
  idx = to;
else   % only option left is that offset is not-empty
  idx = get_current_training_stage(obj);
  idx = idx + offset;
end;  

ts = get_training_stages(obj);
% Translate 'offset' requests to 'to' requests, which work:
if ~isempty(offset),
   if get_current_training_stage(obj) == rows(ts)  &&  ...
          ts{end, obj.is_complete_COL}==1, idx = idx+1; 
   end;
   obj = jump(obj, 'to', idx);
   return;
end;


if idx < 1,
    error('Index should be a natural number');
elseif idx > rows(ts)+1,
    error('Index exceeds training stages!');
end;

curr = get_current_training_stage(obj);

% if jump backwards
if idx <= curr
    for k = idx:curr
        ts{k, obj.is_complete_COL} = 0; % mark everybody "ahead" as being incomplete
    end;
elseif idx > curr   % elseif jump forward
    for k = curr:idx-1
        ts{k, obj.is_complete_COL} = 1; % mark everybody "behind" as being complete
    end;
else
    % do nothing
end;

obj = set_current_training_stage(obj, min(idx, rows(ts)));
obj.training_stages = ts;
