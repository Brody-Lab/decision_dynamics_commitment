function [] = impair_runner

% % >>> MASTER Copy of params to set and code to run. 
% % Copy paste this section and document to 
% % runs fit_slopebias to compute and store impair metric
% area_filter='ACx';
% psychthresh=0;
% postpsych=0;
% ignore_trialtype = 1;
% addfname = 'forcelinear_alltrials';
% icalc=7;
% first save fit data
% gnames =  {'ACx','ACx2','ACxallsaline'};
% 
% for g=1:length(gnames)
%     fit_slopebias(gnames{g}, 'save', ...
%         'addfname', addfname, ...
%         'postpsych', postpsych, 'psychthresh', psychthresh, ...
%         'ignore_trialtype', ignore_trialtype);
% end;
% % now compute and save impair data
%  fit_slopebias('ACx', 'impair', 'addfname', addfname,'icalc', icalc);
%  fit_slopebias('ACx2', 'impair', 'addfname', addfname,'icalc', icalc);
% % << End master

 
% % SET 2>> Configuration used for paper - 6 July 09
% % icalc=7 was slope+hitrate
% area_filter='ACx';
% psychthresh=0;
% postpsych=0;
% ignore_trialtype = 1;
% addfname = 'forcelinear_alltrials';
% icalc=7;
% gnames =  {'ACx','ACx2'};
% 
% fit_slopebias('ACxall', 'impair', 'addfname', addfname,'icalc', icalc);
% fit_slopebias('ACxallsaline', 'impair', 'addfname', addfname,'icalc', icalc);

% SET 3 Configuration used for paper - 6 July 09
% % icalc=8 was hitrate (endpoints only)
% area_filter='ACx';
% psychthresh=0;
% postpsych=0;
% ignore_trialtype = 1;
% addfname = 'forcelinear_alltrials';
% icalc=8;
% gnames =  {'ACx','ACx2'};
% 
% fit_slopebias('ACxall', 'impair', 'addfname', addfname,'icalc', icalc);
% fit_slopebias('ACxallsaline', 'impair', 'addfname', addfname,'icalc', icalc);
% <<

% SET 4 Configuration used for mPFC lesion calculation
% icalc=7 was slope+hitrate
% area_filter='mPFC';
% psychthresh=0;
% postpsych=0;
% ignore_trialtype = 1;
% addfname = 'forcelinear_alltrials';
% icalc=7;
% gnames =  {'mPFC'};
% % 
% % % for g=1:length(gnames)
% % %     fit_slopebias(gnames{g}, 'save', ...
% % %         'addfname', addfname, ...
% % %         'postpsych', postpsych, 'psychthresh', psychthresh, ...
% % %         'ignore_trialtype', ignore_trialtype);
% % % end;
% % 
%  fit_slopebias('mPFC', 'impair', 'addfname', addfname,'icalc', icalc);

% % % % SET 4 Configuration used for mPFC lesion calculation
% % % % icalc=7 was slope+hitrate
% area_filter='mPFC';
% psychthresh=0;
% postpsych=0;
% ignore_trialtype = 1;
% addfname = 'last7_first1';
% icalc=9;
% gnames =  {'mPFC'};
% % % % 
% % for g=1:length(gnames)
% %     fit_slopebias(gnames{g}, 'save', ...
% %         'addfname', addfname, ...
% %         'postpsych', postpsych, 'psychthresh', psychthresh, ...
% %         'ignore_trialtype', ignore_trialtype);
% % end;
% % 
%      fit_slopebias('ACx2', 'impair', 'addfname', addfname,'icalc', icalc);


% % SET 5 Configuration used for ACx lesion calculation
% % icalc=9 was bias
% area_filter='ACxall';
% psychthresh=0;
% postpsych=0;
% ignore_trialtype = 1;
% addfname = 'last7_first1';
% icalc=9;
% gnames =  {'ACx','ACx2'};

% for g=1:length(gnames)
%     fit_slopebias(gnames{g}, 'save', ...
%         'addfname', addfname, ...
%         'postpsych', postpsych, 'psychthresh', psychthresh, ...
%         'ignore_trialtype', ignore_trialtype);
% end;

%     fit_slopebias('ACxall', 'impair', 'addfname', addfname,'icalc', icalc);

% % SET 6 -- ACx3
% area_filter='ACx';
% psychthresh=0;
% postpsych=0;
% ignore_trialtype = 1;
% addfname = 'forcelinear_alltrials';
% icalc=7; % slope plus hr_for_endpoints
% % first save fit data
% % gnames =  {'ACx3'};
% % 
% % for g=1:length(gnames)
% %     fit_slopebias(gnames{g}, 'save', ...
% %         'addfname', addfname, ...
% %         'postpsych', postpsych, 'psychthresh', psychthresh, ...
% %         'ignore_trialtype', ignore_trialtype);
% % end;
% % now compute and save impair data
% fit_slopebias('ACx3', 'impair', 'addfname', addfname,'icalc', icalc);
% % fit_slopebias('ACx2', 'impair', 'addfname', addfname,'icalc', icalc);
% % << End master

% SET 7 -- ACx - IMPAIR=bias term only
% area_filter='ACx';
% psychthresh=0;
% postpsych=0;
% ignore_trialtype = 1;
% addfname = 'forcelinear_alltrials';
% icalc=9; % bias
% 
% 
% % now compute and save impair data
% fit_slopebias('ACxallsaline', 'impair', 'addfname', addfname,'icalc', icalc);
% fit_slopebias('ACx', 'impair', 'addfname', addfname,'icalc', icalc);
% fit_slopebias('ACx2', 'impair', 'addfname', addfname,'icalc', icalc);
% fit_slopebias('ACx3', 'impair', 'addfname', addfname,'icalc', icalc);
% % fit_slopebias('ACx2', 'impair', 'addfname', addfname,'icalc', icalc);
% % << End master

% % SET 8 -- ACx - IMPAIR=slope term only
% area_filter='ACx';
% psychthresh=0;
% postpsych=0;
% ignore_trialtype = 1;
% addfname = 'forcelinear_alltrials';
% icalc=10; % bias
% 
% 
% % now compute and save impair data
% fit_slopebias('ACxallsaline', 'impair', 'addfname', addfname,'icalc', icalc);
% fit_slopebias('ACx', 'impair', 'addfname', addfname,'icalc', icalc);
% fit_slopebias('ACx2', 'impair', 'addfname', addfname,'icalc', icalc);
% fit_slopebias('ACx3', 'impair', 'addfname', addfname,'icalc', icalc);
% % fit_slopebias('ACx2', 'impair', 'addfname', addfname,'icalc', icalc);
% % << End master

% SET 9 -- ACx - IMPAIR=hrate term only
% area_filter='ACx';
% psychthresh=0;
% postpsych=0;
% ignore_trialtype = 1;
% addfname = 'forcelinear_alltrials';
% icalc=8; % bias
% 
% 
% % now compute and save impair data
% fit_slopebias('ACxallsaline', 'impair', 'addfname', addfname,'icalc', icalc);
% fit_slopebias('ACx', 'impair', 'addfname', addfname,'icalc', icalc);
% fit_slopebias('ACx2', 'impair', 'addfname', addfname,'icalc', icalc);
% fit_slopebias('ACx3', 'impair', 'addfname', addfname,'icalc', icalc);
% % fit_slopebias('ACx2', 'impair', 'addfname', addfname,'icalc', icalc);
% % << End master