function [p,errorflag] = stitch_chunks(sma, p1, p2)

%This function takes 2 packets of parsed events p1 and p2, and stitches
%them together.  On rare occasions a packet is dropped and p1 and p2 do not
%match.  Previously this would throw an error and halt training.  However,
%now we throw a warning, log the trial as having an error, and continue on.
%RunninSection through Bpod now has the ability to terminate a trial if an
%error occurs and move on to the next trial.  It does this by forcing the
%state machine to end.  This results in p1 and p2 not matching.
%
%Originally written in ancient times
%Modified by Chuck 2020

errorflag = 0;

% If either or both chunks are empty, not much work to do:
if  (isempty(p1) || isempty(p1.states.starting_state))  &&  ...
    (isempty(p2) || isempty(p2.states.starting_state)),   p = p1; return;
elseif isempty(p1) || isempty(p1.states.starting_state),  p = p2; return;
elseif isempty(p2) || isempty(p2.states.starting_state),  p = p1; return;
end;

% Ok, both chunks have content, let's get to work:
if ~strcmp(p1.states.ending_state, p2.states.starting_state),
  warning('Ending state of chunk 1 ("%s") not the same as the starting state of chunk 2 ("%s")!\n', ...
    p1.states.ending_state, p2.states.starting_state);
  errorflag = 1;
end;
if ~isempty(setdiff(fieldnames(p1.pokes.ending_state), fieldnames(p2.pokes.starting_state))),
  warning('chunk 1 and chunk 2 appear to have different poke names!');
  errorflag = 1;
end;

%     Make sure that whichever pokes were [currently-poked-in at the
%       end of the 1st chunk] were also [currently-poked-in at the
%       beginning of the 2nd chunk], and whichever pokes were not [...]
%       were not [...].
pnames = fieldnames(p1.pokes.ending_state);
for i=1:length(pnames),
  if  ~isempty(p1.pokes.  ending_state.(pnames{i}))  &&  ...
      ~isempty(p2.pokes.starting_state.(pnames{i}))  &&  ...
      ~strcmp(p1.pokes.ending_state.(pnames{i}), p2.pokes.starting_state.(pnames{i})),
    warning(['Ending state of %s poke in chunk 1 (%s) is not compatible with the same poke''s\n' ...
      'starting state in chunk 2 (%s)!\n'], pnames{i}, p1.pokes.ending_state.(pnames{i}), ...
      p2.pokes.starting_state.(pnames{i}));
    errorflag = 1;
  end;
end;

% do the same check with scheduled waves
wnames = fieldnames(p1.waves.ending_state);
for i=1:length(wnames),
    if ~isempty(p1.waves.  ending_state.(wnames{i})) && ...
       ~isempty(p2.waves.starting_state.(wnames{i})) && ...
       ~strcmp(p1.waves.  ending_state.(wnames{i}), p2.waves.starting_state.(wnames{i})),
        warning(['Ending state of %s scheduled wave in chunk 1 (%s) is not compatible with the same\n' ...
            'scheduled wave in chunk 2 (%s)!\n' ...
            'Most recent state is %s '], wnames{i}, p1.waves.  ending_state.(wnames{i}), ...
            p2.waves.starting_state.(wnames{i}),p2.states.starting_state);
        errorflag = 1;
    end
end

% If there were state changes in the starting state of p2, then finish the corresponding ending state of p1:
if ~isempty(p2.states.(p2.states.starting_state)),
  if ~isempty(p1.states.(p1.states.ending_state)),
    p1.states.(p1.states.ending_state)(end,2) = p2.states.(p2.states.starting_state)(1,2);
  else
    p1.states.(p1.states.ending_state) = p2.states.(p2.states.starting_state)(1,:);
  end;
  % Delete the starting line from chunk 2, this is the one now finished in chunk 1:
  p2.states.(p2.states.starting_state) = p2.states.(p2.states.starting_state)(2:end,:);
end;


% Now same deal for the pokes:
pnames = fieldnames(p1.pokes.ending_state);
for i=1:length(pnames),
  if   strcmp(p1.pokes.ending_state.(pnames{i}), 'in')  && ... % We ended IN the poke in p1
      ~isempty(p2.pokes.(pnames{i}))                    && ... % And stuff happened to this poke in p2
      ~isempty(p1.pokes.(pnames{i})),                          % And there's stuff to finish w/this poke in p1
        p1.pokes.(pnames{i})(end,2) = p2.pokes.(pnames{i})(1,2);
        p2.pokes.(pnames{i})        = p2.pokes.(pnames{i})(2:end,:);
  end;
end;
   
% And also for the scheduled waves:
wnames = fieldnames(p1.waves.ending_state);
for i=1:length(wnames),
    if strcmp(p1.waves.ending_state.(wnames{i}), 'in') && ... % we wave came 'in' in p1
      ~isempty(p2.waves.(wnames{i}))                  && ... % and stuff happened to this wave in p2
      ~isempty(p1.waves.(wnames{i})),                        % and there's stuff to finish in this wave in p1
        p1.waves.(wnames{i})(end,2) = p2.waves.(wnames{i})(1,2);
        p2.waves.(wnames{i})        = p2.waves.(wnames{i})(2:end,:); 
    end
end

% Now fix any unknown starting/ending info
fnames = fieldnames(p1.pokes.ending_state);
for i=1:length(fnames),
  if isempty(p1.pokes.starting_state.(fnames{i})),
    p1.pokes.starting_state.(fnames{i}) = p2.pokes.starting_state.(fnames{i});
  end;
  if isempty(p2.pokes.ending_state.(fnames{i})),
    p2.pokes.ending_state.(fnames{i})   = p1.pokes.ending_state.(fnames{i});
  end;
end;

wnames = fieldnames(p1.waves.ending_state);
for i=1:length(wnames),
    if isempty(p1.waves.starting_state.(wnames{i})),
        p1.waves.starting_state.(wnames{i}) = p2.waves.starting_state.(wnames{i});
    end
    if isempty(p2.waves.ending_state.(wnames{i})),
        p2.waves.ending_state.(wnames{i})   = p1.waves.ending_state.(wnames{i});
    end
end
  

% Now put together all the pieces:
p = p1;
guys = {'states' 'pokes' 'waves'};
for j=1:length(guys),
  fnames = setdiff(fieldnames(p.(guys{j})), {'starting_state' 'ending_state'});
  for i=1:length(fnames),
    if     ~isempty(p1.(guys{j}).(fnames{i})) && ~isempty(p2.(guys{j}).(fnames{i})),
      p.(guys{j}).(fnames{i}) = [p1.(guys{j}).(fnames{i}) ; p2.(guys{j}).(fnames{i})];
    elseif  isempty(p1.(guys{j}).(fnames{i})) && ~isempty(p2.(guys{j}).(fnames{i})),
      p.(guys{j}).(fnames{i}) = p2.(guys{j}).(fnames{i});
    elseif ~isempty(p1.(guys{j}).(fnames{i})) &&  isempty(p2.(guys{j}).(fnames{i})),
      p.(guys{j}).(fnames{i}) = p1.(guys{j}).(fnames{i});
    else
      p.(guys{j}).(fnames{i}) = zeros(0,2);
    end; % end if
  end; % end fnames loop
  p.(guys{j}).ending_state = p2.(guys{j}).ending_state;
end; % end guys loop


