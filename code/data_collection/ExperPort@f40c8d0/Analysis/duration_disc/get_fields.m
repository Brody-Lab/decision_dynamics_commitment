function [] = get_fields(ratname, varargin)
% example:
% get_fields(ratname,'use_dateset','given', 'given_dateset', given_dateset,'datafields',datafields);


global output_cell;


pairs = { ...
    'use_dateset', 'range' ; ... [psych_before | psych_after | range | given]
    'given_dateset', {} ; ... % fill with cell array of dates (yymmdd'a' eg. 070401a)
    'from', '000000'; ...
    'to' , '999999'; ...
    'datafields', {} ; ...
    'trim_first', 1; ...
    'remove_Mondays', 0 ; ... % when true, removes all sessions that fall after a weekend
    'suppress_out', 0 ; ... % suppresses output from load_datafile
    'usefid', 1 ; ... % fid to fprintf to
    };
parse_knownargs(varargin,pairs);

ratrow = rat_task_table(ratname, 'get_rat_row');
task = ratrow{1,2};

field_fullnames = { ...
    'bbspl', 'saved_history.TimesSection_BadBoySPL', 'str'; ...
    'blocks_switch','saved_history.BlocksSection_Blocks_Switch','num' ; ...
    'dur_short', 'saved.ChordSection_tone1_list', 'num' ; ...
    'dur_long', 'saved.ChordSection_tone2_list', 'array' ; ...
    'pstruct', '', 'array'; ...
    'flipped', 'saved_history.ChordSection_right_is_low', 'num'; ...
    'events_raw', ['saved_history.' task '_LastTrialEvents'], 'str'; ...
    'host_duration', 'saved.duration_discobj_hostname', 'str'; ...
    'host_pitch', 'saved.dual_discobj_hostname', 'str'; ...
    'rig_hostname', '', 'str'; ...
    'logflag', 'saved_history.ChordSection_vanilla_on', 'num' ; ...
    'logdiff', 'saved_history.ChordSection_logdiff', 'num' ; ...
    'Min_2_GO', 'saved_history.ChordSection_Min_2_GO', 'num' ; ...
    'Max_2_GO', 'saved_history.ChordSection_Min_2_GO', 'num' ; ...
    'MinValidPokeDur', 'saved_history.VpdsSection_MinValidPokeDur', 'num' ; ...
    'MaxValidPokeDur', 'saved_history.VpdsSection_MaxValidPokeDur', 'num' ; ...
    'MP', 'saved_history.ChordSection_MP', 'num';...
    'psych', 'saved_history.ChordSection_psych_on' , 'num' ; ...
    'pitch_low', 'saved.ChordSection_pitch1_list', 'num'; ...
    'pitch_high', 'saved.ChordSection_pitch2_list', 'num' ; ...
    'pitch_tonedurL', 'saved_history.ChordSection_Tone_Dur_L', 'num'; ...
    'pitch_tonedurR','saved_history.ChordSection_Tone_Dur_R','num'; ...
    'pitch_psych', 'saved_history.ChordSection_pitch_psych', 'num' ; ...
    'tones_list','saved.ChordSection_tones_list','num';...
    'prechord', 'saved.ChordSection_prechord_list','num' ; ...
    'sides', 'saved.SidesSection_side_list','num'; ...
    'rts', '', 'array' ; ...
    'tone_spl', 'saved.ChordSection_spl_list', 'num'; ...
    'go_spl','saved_history.ChordSection_SoundSPL','num';...
    'left_prob', 'saved_history.SidesSection_LeftProb','num'; ...
    'Tone_Loc', 'saved_history.ChordSection_Tone_Loc','switch'; ...
    'GO_Loc', 'saved_history.ChordSection_GO_Loc','switch';...
    'SPL_mix','saved_history.ChordSection_SPLmix','num'; ...
    'vpd' ,  'saved.VpdsSection_vpds_list', 'num' ; ...
    'VPDSetPoint', 'saved_history.VpdsSection_VPDSetPoint','num'; ...
    };

ratrow = rat_task_table({ratname});
task = ratrow{1,2};
switch use_dateset
    case 'psych_before'
        psych = ratrow{1,rat_task_table('','action','get_prepsych_col')};
        dates = get_files(ratname, 'fromdate', psych{1}, 'todate', psych{2});

    case 'psych_after'
        psych = ratrow{1,rat_task_table('','action','get_postpsych_col')};
        dates = get_files(ratname, 'fromdate', psych{1}, 'todate', psych{2});

    case 'range'
        dates = get_files(ratname, 'fromdate', from, 'todate', to);

    case 'given'
        if cols(given_dateset) > 1, given_dateset= given_dateset'; end;
        dates = given_dateset;
    otherwise
        error('use_dateset should be [psych_before | psych_after | range | given');
end;

start_idx = 1;
if trim_first > 0, start_idx = 2; end;

% return cell
% each row contains data for one field
% first column contains field name
% second column contains an array or cell with field values across days
% The first three rows are special
%   Row 1 always stores # trials per session
%   Row 2 always stores hit history
%   Row 3 always stores the dates for which data was retrieved
output_cell = {};
output_cell{1,1} = 'numtrials'; output_cell{1,2} = [];
output_cell{2,1} = 'hit_history'; output_cell{2,2} = [];
output_cell{3,1} = 'dates'; output_cell{3,2} = dates;

%dates


newdates = {};
TRUNC_TR = []; % used only when datafile is malformed by the last trial being recorded in some params and not others (should rarely happen)

for d = 1:rows(dates)
 %   try
    tmp = dates{d}; prevtmp='';
    % fprintf(usefid, '\t%s\n',tmp);
    if d > 1, prevtmp = dates{d-1}; end;
    if strcmpi(tmp(1:end-1),prevtmp(1:end-1))
        warning('Potential duplicate: %s & %s found. Skipping %s.\n', prevtmp, tmp, tmp);
    else
        wkday = weekday(sprintf('%s-%s-20%s', tmp(3:4), tmp(5:6), tmp(1:2)));

        if (remove_Mondays > 0) && (wkday == 2)
            fprintf(usefid, 'Removing Monday of %s....\n',tmp);
        else
           
            load_datafile(ratname, dates{d},'suppress_out',suppress_out);
            tr = eval(['saved.' task '_n_done_trials']);
            if trim_first> 0,
                store_output('numtrials', max(tr-1,0));
            else
                store_output('numtrials', tr);
            end;

            if tr >= start_idx
 newdates{end+1,1} = dates{d};
                hit_history = eval(['saved.' task '_hit_history']);

                store_output('hit_history',hit_history(start_idx:tr));
                %fprintf(usefid, '%s: hh count = %i\n', dates{d}, (tr-start_idx)+1);


                for f = 1:length(datafields)
                    idx = find(strcmpi(field_fullnames(:,1),datafields(f)));

                    if isempty(idx),
                        error(sprintf('%s does not exist!', datafields{f}));
                    end;
                    

                    if strcmpi(datafields{f},'rts')
                        rts = eval(['saved_history.' task '_RealTimeStates']);
                        evs = eval(['saved_history.' task '_LastTrialEvents']);
                        if rows(rts) == rows(evs)+1, rts=rts(1:end-1);
                        elseif rows(rts) ~= rows(evs)
                            warning('rts rows do not match evs! Careful with your analysis');
                        end;
                        fval = rts;
                        fval=fval(start_idx:tr,:);
                    elseif strcmpi(datafields{f},'pstruct')
                        rts = eval(['saved_history.' task '_RealTimeStates']);
                        evs = eval(['saved_history.' task '_LastTrialEvents']);
                        if rows(rts) == rows(evs)+1, rts=rts(1:end-1);end;
                        fval = parse_trial(evs, rts);
                        try
                        fval=fval(start_idx:tr,:);
                        catch
                            warning('%s:%s:pstruct too short! Adding blank ending', ratname, dates{d});
                            fval{end+1}=[];
                            fval=fval(start_idx:tr,:);
                        end;
                    elseif strcmpi(datafields{f},'rig_hostname')
                        fval = eval(['saved.' task '_hostname;']);
                        
                    elseif strcmpi(datafields{f},'tones_list')
                          myfield = field_fullnames{idx,2};
                        dotidx = strfind(myfield,'.');
                        if ~isfield(eval(myfield(1:dotidx-1)), myfield(dotidx+1:end))
                            sides=saved.SidesSection_side_list;
                            n=eval(['saved.' task '_n_done_trials;']);
                            
                            if strcmpi(task(1:3),'dur')
                                leftt=saved.ChordSection_tone1_list;
                                rightt=saved.ChordSection_tone2_list;                                
                            else
                                leftt=saved.ChordSection_pitch1_list;
                                rightt=saved.ChordSection_pitch2_list;
                            end;
                            tones_list=NaN(size(sides));
                            tones_list(sides==1)=leftt(sides==1);
                            tones_list(sides==0)=rightt(sides==0);
                            tones_list=tones_list(1:n);
                            fval=tones_list(start_idx:tr);
                            
                            
                        else
                            fval = eval(field_fullnames{idx,2});
                            fval=fval(start_idx:tr);
                        end;
                        
                    else
                        myfield = field_fullnames{idx,2};
                        dotidx = strfind(myfield,'.');
                        if isfield(eval(myfield(1:dotidx-1)), myfield(dotidx+1:end)) % it's a valid field but some files may be prior
                            fval = eval(field_fullnames{idx,2});                      % to its implementationß
                        else
                            fval = NaN;
                        end;

                        if iscell(fval) && strcmpi(field_fullnames{idx,3},'num'), fval = cell2mat(fval);
                            try
                            fval = fval(start_idx:tr,:);
                            catch
                                2;
                            end;
                        elseif strcmpi(field_fullnames{idx,3},'switch'),
                            tmp = zeros(size(fval)); tmp(find(strcmpi(fval,'on')))=1;
                            fval = tmp;

                            fval = fval(start_idx:tr,:);                               
                        elseif  ~iscell(fval) & isnan(fval)
                            % do nothing
                        elseif ~isstr(fval)
                            if rows(fval) == 1 && cols(fval) > 1
                                fval = fval';
                            end;
                                fval = fval(start_idx:tr,:);
                        end;
                    end;
                         %fprintf(usefid, '\t %s = %i\n', datafields{f}, length(fval));
                    store_output(datafields{f},fval);
                end;
            end;
        end;
    end;
%     catch 
%         error('get_fields:%s:%s', dates{d}, datafields{f});
%     end;
end;

output_cell{3,2} = newdates;
dates = newdates;
total_trials = output_cell{1,2}; total_trials = sum(total_trials);
fprintf(usefid, '%s\n\tTotal trials: %i\n', mfilename, total_trials);

% now assign in caller namespace
for r = 1:rows(output_cell)
    if strcmpi(output_cell{r,1}, 'host_duration') || ...
            strcmpi(output_cell{r,1},'host_pitch') || ...
            strcmpi(output_cell{r,1},'rig_hostname') || ...
            strcmpi(output_cell{r,1},'dates')
        if (length(output_cell{r,2}) ~= length(dates))
            error('Data for %s does not match # sessions', output_cell{r,1});
        end;
    elseif ~iscell(output_cell{r,2})
        if (sum(~isnan(output_cell{r,2})) > 0) && r > 1 && (length(output_cell{r,2}) ~= total_trials),
            error('Data for %s does not match # trials', output_cell{r,1});
        end;
    elseif r > 1 && (length(output_cell{r,2}) ~= total_trials),
        error('Data for %s does not match # trials', output_cell{r,1});

    end;
    assignin('caller', output_cell{r,1}, output_cell{r,2});
end;

% stores field value in appropriate place in output_cell
function [] = store_output(fname, fval)
global output_cell;
idx = find(strcmpi(output_cell(:,1),fname));
if isempty(idx)
    output_cell{rows(output_cell)+1,1} = fname;
    if isstr(fval),
        output_cell{rows(output_cell), 2} = {fval};
        return;
    end;
    output_cell{rows(output_cell),2} = [];
    idx = rows(output_cell);
end;

if ~iscell(fval) && rows(fval) > 1,
    fval = fval';
end;

if iscell(fval)% all cells should be rx1. Not 1xc cell matrices.
    if iscell(fval(1)) % a cell of cells
        tmp = output_cell{idx,2}; % get back an empty array or a cell array
        tmp = vertcat(tmp, fval); % append cell array to cell array, getting a cell array
        output_cell{idx,2} = tmp;
    else
        output_cell(idx,2) = vertcat(output_cell(idx,2),fval);
    end;
elseif isstr(fval)
    tmp = output_cell{idx,2};
    tmp{end+1,1} = fval;
    output_cell{idx,2} = tmp;
else    % is array
    output_cell{idx,2} = [output_cell{idx,2} fval];
end;