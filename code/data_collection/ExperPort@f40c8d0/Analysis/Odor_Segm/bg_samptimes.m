function [samptimes, bgnames] = bg_samptimes(ratname, taskname,varargin)

% This function odor smapling time of each trial, and group them for each
% background odors. 
% Output is two cell arrays, which will be saved.
% varargin is the start and end of the datafile name to be analysed.

bgnames = {}; samptimes = {};
taskname1 = ['@' taskname 'obj'];
data_path = [pwd filesep '..' filesep 'SoloData' filesep 'data' filesep ratname]; 
u = dir([data_path filesep 'data_' taskname1 '*.mat']);
[filenames{1: length(u)}] = deal(u.name);
filenames = sort(filenames');
bgid = 0; 
start_load = 0; stop_load = 0; % determine whether or not to start or stop load datafiles
for i = 1: length(filenames)
    if stop_load
        continue; % skip loading files
    end;
    fname = filenames{i}; session = fname(end-10:end-4);
    if length(varargin)==2
        if ~strcmpi(session, varargin{1}) && ~start_load
            continue;
        else
            start_load = 1;
        end
        if strcmpi(session, varargin{2})
            stop_load = 1;
        end;
    elseif length(varargin) == 1
        if strcmpi(session, varargin{1}) || stop_load
            stop_load = 1;
        end;
    end;
    load([data_path filesep fname]);
    % block_size = 20;
   % Next find indicator of background odors, and sort random trials
    if isfield(saved_history,'OdorSection_BG_valve'),
        bg_idx = saved_history.OdorSection_BG_valve; 
    else
        bg_idx = saved_history.OdorSection_L_valve; 
    end;
    events = eval(['saved_history.' taskname 'obj_LastTrialEvents']);
    if isfield(saved_history, 'OdorSection_bkg_odor')
        bgrds = saved_history.OdorSection_bkg_odor;
    else
        bgrds = saved_history.OdorSection_bgrd_name;
    end;
    if isfield(saved_history, 'BlockControl_block_update'),
      if ismember('random_bg', saved_history.BlockControl_block_update)
        rand_trial = find(strcmpi(saved_history.BlockControl_block_update, 'random_bg'));
        if rand_trial(end)> saved.RewardsSection_TrialTracker % in case there is one empty trial in the end
            x = rand_trial(end) - saved.RewardsSection_TrialTracker;
            rand_trial = rand_trial(1:end-x);
        end;
        [tmp, idx] = sort(cell2mat(saved_history.OdorSection_bgrd_ID(rand_trial)));
        bg_idx = sort_rand_trials(bg_idx, rand_trial, idx);
        bgrds = sort_rand_trials(bgrds, rand_trial, idx);
      end;
    end;
    
    for j = 1: size(events,1)
        % Find the trial id of the start of a bgrd odor
        if j == 1
            b1 = j;
        elseif bg_idx{j} ~= bg_idx{j-1}
            b1 = j;
        end;
        % Find the trial id of the end of a bgrd odor
        if j == size(events,1) || bg_idx{j} ~= bg_idx{j+1}
            b2 = j;
            if b2-b1 < 10
                continue;
            end;
        % Next find odor sampling times of the trial range of b1:b2
            st = [];
            for j = b1:b2,
                    t = SamplingTime(events{j}); % sampling time of this trial 
                    if t~=0, st = [st t]; end;
            end;
            %next assign the bgname to the bgnames
            if ~strcmp(bgrds(b1),bgrds(b2)) &&  b1 ==1
                tmpbgname = bgrds(b2);
            elseif ~strcmp(bgrds(b1),bgrds(b2)) && strcmp(bgrds(b1),bgrds(b1-1))
                tmpbgname = bgrds(b2);                
            else % strcmp(bgrds(b1),bgrds(b2)) || strcmp(bgrds(b2),bgrds(b2+1))
                tmpbgname = bgrds(b1);
            end;
            if strcmpi(tmpbgname, 'Pure'), continue; end;
            
                
  % Next put things with the same bgname together
            if ~ismember(tmpbgname, bgnames) % if the bgrd name appears the first time
                bgid = bgid+1;
                bgnames = [bgnames; tmpbgname];
                samptimes = [samptimes; {st}];
            elseif ismember(bgnames{bgid}, bgrds) % same bgrdname appears again in the same session
                samptimes{bgid} = [samptimes{bgid} st];
            else
                % do nothing;
            end;
        end;
        
    end;
end;
save([data_path filesep 'analyse' filesep taskname '_bg_st'], 'bgnames','samptimes');