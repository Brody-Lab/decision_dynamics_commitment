function [bg_score] = bgscore(ratname, taskname,varargin)

% This function extract block score of each background odor, from all
% sessions of the same ratname, and taskname. The output varialbe is a
% structure with 4 fields.
% Field 1: bg_name, contain all the background odor names
% Field 2: blkscr_ses1, contain the block scores for corresponding bg_names
%           within on session.
% Field 3: blkst_ses1, contain the block averge of sampling time for a particular bkgrnd odor.

% Field 4: blkscr_ses2, some bg odor appeared in more than one session.
%           This field contain block socres of corresponding bg odor at the second
%           session.
% Field 5: blkst_ses2
% Field 6: mandat_st, valid odor sampling time.
% Field 7: name of the session that contains corresponding odors.

bg_score = struct;
bg_score.bg_name = {}; bg_score.blkscr_ses1 = []; bg_score.blkst_ses1 = [];
bg_score.blkscr_ses2 = []; bg_score.blkst_ses2 = [];
bg_score.mandat_st = [];
bg_score.sesname = {};
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
   % Next calculate thing of each block, and sort them by odor name. 
    % indicator of different bgrds.
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
            %next assign the bgname to the field variable bg_name
            if ~strcmp(bgrds(b1),bgrds(b2)) &&  b1 ==1
                tmpbgname = bgrds(b2);
            elseif ~strcmp(bgrds(b1),bgrds(b2)) && strcmp(bgrds(b1),bgrds(b1-1))
                tmpbgname = bgrds(b2);                
            else % strcmp(bgrds(b1),bgrds(b2)) || strcmp(bgrds(b2),bgrds(b2+1))
                tmpbgname = bgrds(b1);
            end;
            if strcmpi(tmpbgname, 'Pure'), continue; end;
  % Next put things with the same bgname together
            if ~ismember(tmpbgname, [bg_score.bg_name]) % if the bgrd name has not appeared before
                bgid = bgid+1;
                bg_score(bgid,1).bg_name = tmpbgname;
                % next calculate the block scores of this bgrd
                [bg_score(bgid,1).blkscr_ses1, bg_score(bgid,1).blkst_ses1] = block_score(taskname,saved,saved_history,b1,b2);
            elseif ismember(bg_score(bgid,1).bg_name, bgrds) % same bgrdname appears again in the same session
                [scr, st] = block_score(taskname, saved,saved_history,b1,b2);
                bg_score(bgid,1).blkscr_ses1 = [bg_score(bgid,1).blkscr_ses1 scr];
                bg_score(bgid,1).blkst_ses1 = [bg_score(bgid,1).blkst_ses1 st];
                % disp(bg_score(bgid,1).bg_name); disp(block_score(taskname, saved,saved_history,b1,b2)); disp(b1);disp(b2);
            else
                bg_score(bgid,1).blkscr_ses2 = block_score(taskname, saved,saved_history,b1,b2);
            end;
            bg_score(bgid,1).mandat_st = saved.TimesSection_valid_samp_time;
            bg_score(bgid,1).sesname = session;
        end;
        
    end;
end;
save([data_path filesep 'analyse' filesep taskname '_bgodor_score'], 'bg_score');
%load([data_path filesep 'analyse' filesep taskname '_bgodor_score'], 'bg_score');
    
    
    