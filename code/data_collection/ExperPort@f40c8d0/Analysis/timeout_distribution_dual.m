function [to] = timeout_distribution_dual(p, sound_evs)

% Given:
% p, the output of Analysis/parse_trials.m and
% sound_evs, the output of parse_sound_evs_*.m,
% returns the number of times timeout occurred during each of the event
% types as defined by sound_evs
%
% e.g.
% if sound_evs has fields "pre_sound", "cue", "pre_go" and "go",
% the script will return
% a rows(p)-by-1 cell array where each entry is a struct with keys
% "pre_sound", "cue", "pre_go", "go", and values are the number of times
% that timeout occurred during that event in that trial.

if rows(p) ~= rows(sound_evs)
    error('Sorry, p and sound_evs should have an equal number of trials');
end;

to = cell(rows(p),1);
for k = 1:rows(p)
    fnames = fieldnames(sound_evs{k});
    for f = 1:rows(fnames), eval(['to{k}.' fnames{f} ' = 0;']); end;

    if rows(p{k}.pre_chord) ~= rows(sound_evs{k}.pre_sound)
        error('Rows in the ''pre_chord'' state do not match rows of individual pre_sound events');
    end;
    for m = 1:rows(p{k}.pre_chord) % look to see if timed out during this stage
        conditions(1,1:3) = {'out', '>=',  p{k}.pre_chord(m,1)};    % cout during the event
        conditions(2,1:3) = {'out', '<=',  p{k}.pre_chord(m,2)};
        % eliminate spurious pokes during timeout, which would otherwise
        % be counted
        %         if rows(p{k}.timeout) >=m, conditions(3,1:3) = {'out', '<=', p{k}.timeout(m,1)};end;
        couts = get_pokes_fancy(p{k}, 'center', conditions, 'all');
        if rows(couts) > 0, couts = 1; else couts = 0; end;
        to{k}.pre_sound = to{k}.pre_sound + couts;
    end;

    ignore_me = [];
    for m = 1:rows(p{k}.chord)
        for f = 2:rows(fnames)
            if ~ismember(m, ignore_me)
                evt = eval(['sound_evs{k}.' fnames{f}]);
                if rows(p{k}.chord) ~= rows(evt)
                    error('Rows in the ''chord'' state do not match rows of individual events within chord state');
                end;

                conditions(1,1:3) = {'out', '>=' , evt(m,1) };  % cout during the event
                conditions(2,1:3) = {'out', '<=', evt(m,2) };
                couts = get_pokes_fancy(p{k},'center', conditions, 'all');
                if rows(couts) > 0
                    couts = 1;
                    ignore_me = [ignore_me m];
                else
                    couts = 0;
                end;
                eval(['to{k}.' fnames{f} '= to{k}.' fnames{f} '+' num2str(couts) ';']);
            end;
        end;
    end;
end;