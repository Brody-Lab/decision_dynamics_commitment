

function [x] = StimulusSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,
    
    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------
    
    case 'init'
        
        [expmtr, ratname]=SavingSection(obj, 'get_info');
        [sessids] = bdata(['select sessid from sessions where ratname = "{S}" and protocol = "{S}" and sessiondate > "{S}" and n_done_trials > "{S}"'], ratname, 'ProspectForaging', '2015-11-19', 100);
        S = get_sessdata(sessids);
        if ~isempty(S.pd)
            if isfield(S.pd{1}, 'risky_prob_options');
                probs = S.pd{1}.risky_prob_options(1,:);
            else probs = [0.1:0.1:1];
            end
            if isfield(S.pd{1}, 'reward_options');
                rewards = S.pd{1}.reward_options(1,:);
            else
                rewards = [15, 25, 35, 50, 60];
            end
            CE = cell(length(rewards), length(probs));
            WR = cell(length(rewards), length(probs));
            
            
            
            for i = 1:length(S.sessid)
                if  S.sessid(i) ~=386389 || 386918 || 386933;  %these were days when J259's or F064's rig broke and they were super biased.
                    
                    num_conditions = numel(find(abs(diff(S.pd{i}.risky_prob)) > 0)) + 1;
                    transitions = [1; find(abs(diff(S.pd{i}.risky_prob)))];
                    wndw = 20;
                    if ~strcmp(S.pd{i}.safe_side, 'right');
                        wr = S.pd{i}.went_right;
                    elseif ~strcmp(S.pd{i}.safe_side, 'left');
                        wr = S.pd{i}.went_left;
                    end
                    av = nan(length(wr), 1);
                    %
                    %                 for t = wndw+1:length(wr);
                    %                     av(t) = nanmean(wr(t-wndw:t));
                    %                 end
                    %
                    %
                    %                 %% Slow moving average: choose window size
                    %                 n = 40; % window = 20 days
                    %                 longalpha = n/(n+1);
                    %                 %% Fast moving average: choose window size
                    %                 s = 10; % window = 3 days
                    %                 shortalpha = s/(s+1);
                    %                 for mm = 1:length(S.pd{i}.safe_amount);
                    %                     if mm==1
                    %                         long_m(mm) = S.pd{i}.safe_amount(mm);
                    %                         short_m(mm) = S.pd{i}.safe_amount(mm);
                    %                     else
                    %                         long_m(mm) = longalpha*long_m(mm-1) + (1-longalpha)*S.pd{i}.safe_amount(mm);
                    %                         short_m(mm) = shortalpha*short_m(mm-1) + (1-shortalpha)*S.pd{i}.safe_amount(mm);
                    %                     end
                    %                 end
                    %plot(long_m, 'b');
                    %plot(short_m, 'r');
                    
                    
                    for j = 1:num_conditions;
                        
                        %find trials corresponding to each conditions
                        if j~=num_conditions;
                            t = transitions(j):transitions(j+1)-1;
                        else
                            t = transitions(j):length(av);
                        end
                        
                        if length(t)>=50;
                            %unfortunately,the safe amount is sometimes an
                            %int64, so we have to do this annoying thing..
                            if  isa(S.pd{i}.safe_amount,'double')
                                int64(S.pd{i}.safe_amount);
                            end
                            %get rid of violations
                            vios = find(isnan(S.pd{i}.went_right(t)));
                            t(vios) = [];
                            
                            midrun = find(abs(diff(S.pd{i}.safe_amount(t(1:end-1))) - diff(S.pd{i}.safe_amount(t(2:end))))>eps);
                            
                            midrun = midrun+1;
                            if ~isempty(midrun)
                                if midrun(end) > length(t);
                                    midrun(end) = [];
                                end
                                
                                
                                if nanmean(S.pd{i}.went_right(t(midrun))) > .45 && nanmean(S.pd{i}.went_right(t(midrun))) < .55
                                    % if nanmean(S.pd{1}.went_right(t)) > .45 && nanmean(S.pd{1}.went_right(t)) < .55;
                                    thisr = S.pd{i}.risky_amount(t(2));
                                    thisp = S.pd{i}.risky_prob(t(2));
                                    trow = find(thisr==rewards);
                                    tcol = find(thisp==probs);
                                    if ~isempty(trow) && ~isempty(tcol)
                                        if ~isempty(CE{trow, tcol});
                                            CE{trow, tcol} = [CE{trow, tcol}; nanmean(S.pd{i}.safe_amount(t(midrun)))];
                                            WR{trow, tcol} = [WR{trow, tcol}; nanmean(S.pd{i}.went_right(t(midrun)))];
                                        else
                                            
                                            CE{trow, tcol} =  nanmean(S.pd{i}.safe_amount(t(midrun)));
                                            WR{trow, tcol} = nanmean(S.pd{i}.went_right(t(midrun)));
                                        end
%                                     else
%                                         CE{trow, tcol} = nan; %nanmean(S.pd{i}.safe_amount(t(midrun)));
%                                         WR{trow, tcol} = nan;%nanmean(S.pd{i}.went_right(t(midrun)));
                                    end
                                    
                                end
                            end
                        end
                    end
                end
            end
            
            %c = find(cellfun(@(x)isempty(x), CE));
            %CE(c) = {nan};
            meanWR = nan(length(rewards), length(probs));
            meanCE = nan(length(rewards), length(probs));
            for i = 1:length(rewards);
                for j = 1:length(probs);
                    if ~isempty(CE{i,j});
                        if numel(CE{i,j})>1;
                            if iscell(CE{i,j})
                                x = cellfun(@(x)x, CE{i,j});
                                meanCE(i,j) = mean(x);
                                x = cellfun(@(x)x, WR{i,j});
                                meanWR(i,j) = mean(x);
                            else
                                meanCE(i,j) = mean(CE{i,j});
                                meanWR(i,j) = mean(WR{i,j});
                            end
                        else
                            meanCE(i,j) = CE{i,j};
                            meanWR(i,j) = WR{i,j};
                        end
                    end
                end
            end
            
            x = meanCE;
            
        else
            x = nan(length(reward_options), length(risky_prob_options));
        end
end
