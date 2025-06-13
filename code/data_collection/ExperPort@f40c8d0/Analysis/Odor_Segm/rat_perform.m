function [L_Score, R_Score, Score, score_blk] = rat_perform(saved, saved_history,taskname,moving_avg,varargin)

if isempty(varargin) % && strcmpi(endt,'end')
    startt = 1;
    endt = saved.RewardsSection_TrialTracker;
else
    startt = varargin{1}; endt = varargin{2};
end
block_size = 20;
% extract information from saved Solo variables.
Trials = (startt: endt);
events = eval(['saved_history.' taskname 'obj_LastTrialEvents']);

% to eliminate the trials in which rats did not response...
wfapk = saved.make_and_upload_state_matrix_RealTimeStates.wait_for_apoke;
dummy_trials = [];
% to find the dummy trials....
for i = startt: endt,
    temp = events{i};
    a = temp(temp(:,1) == wfapk, 2);
    if ~isempty(a)
        if a(end) == 7
            dummy_trials = [dummy_trials i];
        end
    else
        dummy_trials = [dummy_trials i];
    end
end
% now eliminate the dummy trials...

if moving_avg
    Trials(ismember(Trials,dummy_trials)) = [];
    side_list = saved.SidesSection_side_list(Trials);
    L_Rew = saved.RewardsSection_LeftRewards(Trials);
    R_Rew = saved.RewardsSection_RightRewards(Trials);
    Rewards = L_Rew + R_Rew;
    
    L_Trials = find(side_list);
    L_Score = zeros(length(L_Trials),2);
    L_Score(:,1) = L_Trials;
    R_Trials = find(side_list ==0);
    R_Score = zeros(length(R_Trials),2);
    R_Score(:,1) = R_Trials;
    Score = zeros(length(Trials), 2);    
    for i = 1:length(L_Trials),
        if i >= block_size/2
            L_Score(i,2) = sum(L_Rew(L_Trials((i+1-block_size/2):i)))/(block_size/2)*100;
        end
    end
    
    for i = 1:length(R_Trials),
        if i >= block_size/2
            R_Score(i,2) = sum(R_Rew(R_Trials((i+1-block_size/2):i)))/(block_size/2)*100;
        end
    end
    Score(:,1) = Trials';
    for i = 1:length(Trials),
        if i >= block_size,
            Score(i,2) = sum(Rewards((i+1-block_size):i))/block_size*100;
        end
    end
    % now plot the results
    h1 = plot(L_Score(block_size/2:end,1),L_Score(block_size/2:end,2), 'bo'); hold on;
    h2 = plot(R_Score(block_size:end,1),R_Score(block_size:end,2), 'ro'); hold on;
    h3 = plot(Score(block_size:end,1), Score(block_size:end,2),'g-', 'LineWidth',2.5); hold on;
    legend([h1 h2 h3], 'Left Score', 'Right Score', 'Total Score','Location','SouthWest');
else
    L_Score = []; R_Score = []; Score = [];
end;

% Next for the odor segmentation data.
score_blk = {};
odorsegmplot = 0;
Trials = (startt: endt);
side_list = saved.SidesSection_side_list(Trials);
L_Rew = saved.RewardsSection_LeftRewards(Trials);
R_Rew = saved.RewardsSection_RightRewards(Trials);
Rewards = L_Rew + R_Rew;
blk_update = saved_history.BlockControl_block_update;
OdorSampTime = []; 
% sampling_min = saved_history.TimesSection_valid_samp_time;
if strncmpi(taskname, 'odorsegm',8)
        odorsegmplot = 1;
        names = saved.OdorSection_Bgrd_Names;
        ids = saved_history.OdorSection_bgrd_ID(Trials);
        water_del = saved_history.SidesSection_WaterDelivery(Trials);
        probe = 0; 
        x1 = 0; x2 = 0; % start and end of a probe trial block.
        n_bgrds = 1;
        b1 = length(Trials);  % initialize the x of bgrd name labeling
        % text(5,25,names{ids{1}},'FontSize',13);
        for i = 1: length(Trials),
            % This loop marks the probe trials, and finds out odor sampling time of each
            % trials
            t = SamplingTime(events{i});
            OdorSampTime = [OdorSampTime t];
            if strcmpi(water_del{i}, 'probe')
                if ~probe
                    x1 = i;
                    probe = 1;
                elseif i == length(Trials)
                    x2 = i;
                end;
            else
                probe = 0;
                if i> 1 && strcmpi(water_del{i-1}, 'probe')
                    x2 = i-1;
                end;
            end;
            if x2>x1
                fill([x1 x1 x2 x2], [0 100 100 0],[1 1 0.6],'LineStyle','none');
                text(x1+2, 15, 'Probe','FontSize',15,'Color', 'r');
            end;
        end;
        
        % next mark the background odor names, and calculate the score
        % of each block with different bgrds.
        for i = 1: length(Trials),
            if ids{i} > length(names), continue; end;
            if i == 1 || ids{i-1}~=ids{i}
                b1 = i; % mark the start trial of a background
                n_bgrds = n_bgrds + 1;
            elseif i == length(Trials) || (ids{i}~= ids{i+1} && i>b1)  % which means we reached the end of the bgrd.
                b2 = i; % mark the end of a background
              % next we divide the trials of this bgrds into blocks, and
                % calculate the score of each blocks.
                for j =  1: floor((b2-b1)/block_size)+1 % number of blocks for this bgrd.
                    % next we go through every blcok and calculate the
                    % block score
                    if (b2+1-b1-(j-1)*block_size)>=block_size % if what left is more than one block 
                        blk_range = (b1+(j-1)*block_size : b1+j*block_size-1); % range of this block with trial ID
                    elseif (b2+1-b1-(j-1)*block_size)>=block_size/2 % if what is left is more than half a block
                        blk_range = (b1+(j-1)*block_size : b2);
                    else
                        continue;
                    end
                    n_eff_trials = block_size - length(blk_range(ismember(blk_range, dummy_trials)));
                    % number of effective trials (without the dummy trials)
                    bk_lft_trials = find(side_list(blk_range)); bk_lft_trials(ismember(bk_lft_trials, dummy_trials)) = [];
                    bk_rt_trials = find(side_list(blk_range) == 0); bk_rt_trials(ismember(bk_rt_trials, dummy_trials)) = [];
                    bks_lft = sum(L_Rew(blk_range))/length(bk_lft_trials)*100;
                    bks_rt = sum(R_Rew(blk_range))/length(bk_rt_trials)*100;
                    s_blk = sum(Rewards(blk_range))/n_eff_trials*100;
                    x_blk = blk_range(floor(length(blk_range)/2));
                  
                    % Mean odor sampling time of this block, exluding zeros in OdorSampTime.
                    blk_samptime = sum(OdorSampTime(blk_range))/length(find(OdorSampTime(blk_range)));
                    isrand = 0;
                    if strcmpi(blk_update(x_blk),'random_bg')
                        text(x_blk, s_blk-3, 'Random', 'FontSize', 13, 'Color', 'g','Rotation', 30);
                        isrand = 1;
                    end;
                    bgname_blk = names{ids{b1}};
                    if s_blk>100, keyboard; end;
                    score_blk = [score_blk; {bgname_blk, x_blk, s_blk, isrand, bks_lft, bks_rt,blk_samptime}];
                end;
                line([b1 b1], [0 100], 'Color','b'); % mark the border of the bgrd
                text(b1+2, 25+(-1)^n_bgrds*10, names{ids{b1}},'FontSize',13,'Rotation',330); % label the name of the bgrd
            end;
        end;
end;

if odorsegmplot
    X = cell2mat(score_blk(:,2));
    Y = cell2mat(score_blk(:,3)); Y_lft = cell2mat(score_blk(:,5)); Y_rt = cell2mat(score_blk(:,6));
    h4 = plot(X,Y,'co-','MarkerFaceColor',[.5 .9 .7],'MarkerEdgeColor','k','MarkerSize',10); hold on;
    h5 = plot(X,Y_lft,'*','Color',[.1 .5 .9],'MarkerSize',10);
    h6 = plot(X,Y_rt,'*','Color',[.9 .1 .1],'MarkerSize',10);
end;
set(gca,'Xlim',[0 length(Trials)+5],'YLim',[0 100]);
set(get(gca,'XLabel'),'String','Trials','FontSize',18);
set(get(gca,'YLabel'),'String','Correct Choice %','FontSize',18);
    


    
      