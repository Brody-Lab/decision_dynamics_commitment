function [final_chunks] = show_localisation(rat, task, date, varargin)

% Divides a given day's session by localisation type (primary conditioning
% with GO or cue+GO localised, secondary conditioning with only relevant
% cue localised, and final with no localisation cues).
%
% By setting 'plot_final_hits', the program returns an r-by-2 cell array
% where the rows contain:
% column 1: contiguous trials with final task settings
% column 2: hit rate for each of these blocks

pairs = { ...
    'plot_final_hits', 0 ; ...
    'verbose', 1 ; ...
    };
parse_knownargs(varargin, pairs);

load_datafile(rat, task, date);

tone_loc = saved_history.ChordSection_Tone_Loc;
go_loc = saved_history.ChordSection_GO_Loc;
hh = eval(['saved.' task '_hit_history']); hh = hh(find(~isnan(hh)));

types = {'prime_one', 'prime_both', 'sec', 'final'};
loc_types = { ...
    'off', 'on' ; ...
    'on', 'on'  ; ...
    'on', 'off' ; ...
    'off', 'off' ; ...
    };

final_chunks = cell(0,0);
chunk_ctr = 1;

for k = 1:length(types)
    eval([ types{k} ' = intersect(find(strcmp(tone_loc, ''' loc_types{k,1} ''')), find(strcmp(go_loc, ''', loc_types{k,2} ''')));']);
    if verbose, fprintf(1, '%s: # trials: %i \n', types{k}, length(eval(types{k})));end;

    diffya =diff(eval(types{k}));
    blah = find(diffya > 1); stt = 1;
    if blah > 0
        for m = 1:length(blah),
            if m > 1, eval([ types{k} '_cell{m} = ' types{k} '(blah(m-1)+1:blah(m));']);
            else eval([ types{k} '_cell{m} = ' types{k} '(1:blah(1));']);
            end;
            eval(['temp = ' types{k} '_cell{m};']);

            if eval('temp(end)') > length(hh), hits = eval('hh(temp(1):temp(end-1))');
            else hits = eval('hh(temp(1):temp(end))');
            end;
            if verbose, fprintf(1, '\tChunk %i: Trials %i-%i (%2.1f%%)\n', m, eval('temp(1)'), eval('temp(end)'), mean(hits)*100);end;
            if k == 4 & plot_final_hits > 0,
                final_chunks{chunk_ctr, 1} = eval('temp(1):temp(end)');
                final_chunks{chunk_ctr, 2} = mean(hits)*100;
                chunk_ctr = chunk_ctr+1;
            end;
        end;

        eval([types{k} '_cell{length(blah)+1} = ' types{k} '(blah(end)+1:end);']);
        eval(['temp = ' types{k} '_cell{length(blah)+1};']);

        if eval('temp(end)') > length(hh),hits = eval('hh(temp(1):temp(end-1))');
        else hits = eval('hh(temp(1):temp(end))');
        end;

        if verbose, fprintf(1, '\tChunk %i: Trials %i-%i (%2.1f%%)\n', length(blah)+1, eval('temp(1)'), eval('temp(end)'), mean(hits)*100);end;
        if k == 4 & plot_final_hits > 0,
            final_chunks{chunk_ctr, 1} = eval('temp(1):temp(end)');
            final_chunks{chunk_ctr, 2} = mean(hits)*100;
            chunk_ctr = chunk_ctr+1;
        end;
    else
        eval(['nada = isempty(' types{k} ');']);
        if ~nada,
            if eval([types{k} '(end)']) > length(hh), hits = eval(['hh(' types{k} '(1):' types{k} '(end-1))']);
            else hits = eval(['hh(' types{k} '(1):' types{k} '(end))']);
            end;
            if verbose, fprintf(1, '\tChunk %i: Trials %i-%i (%2.1f%%)\n', 1, eval([ types{k} '(1)']), eval([types{k} '(end)']), mean(hits)*100);end;
            if k == 4 & plot_final_hits > 0,
                final_chunks{chunk_ctr, 1} = eval([types{k} '(1):' types{k} '(end)']);
                final_chunks{chunk_ctr, 2} = mean(hits)*100;
                chunk_ctr = chunk_ctr+1;
            end;
        end;
    end;
end;