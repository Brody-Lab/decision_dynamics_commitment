function [] = newrat_setup(varargin)

pairs = { ...
    'skip_classical', 0 ;...
    };
parse_knownargs(varargin,pairs);

% ratname, date for classical left, date for classical right, type of final
% task, date for final task
ratlist = { ...
    'Ginny', '070829a', '070830a','p', '070831b' ; ...
    'Luna', '070829a', '070830a','p', '070831b' ; ...
    'Petunia', '070829a', '070830a','p', '070831b' ; ...
    'Myrtle', '070829a', '070830a','p', '070831b' ; ...
    'Fred', '070829a', '070830a','d', '070831b' ; ...
    'George', '070829a', '070830a','d', '070831b' ; ...
    };


% file and directory names
src_dir = '~/SoloData/Settings/template_rat/';
target_dir = '~/PrincetonCVS/SoloData/Settings/Shraddha/';
classical_left = 'classical2afc_leftside.mat';
classical_right = 'classical2afc_rightside.mat';
duration = 'FINAL_duration.mat';
pitch = 'FINAL_pitch.mat';

response = questdlg('Have you made sure that PITCH and DURATION files have the latest settings?', 'Latest settings check', 'Yes, proceed!', 'ER, no, let me change that!', 'Yes, proceed!');

if ~strcmpi(response(1:3), 'Yes')
    fprintf(1,'Exiting without making new files ...\n');
    return;
end;

fprintf(1,'Making files ...\n');
for r = 1:rows(ratlist)
    curr_rat = ratlist{r,1};
    fprintf(1,'\t%s...\n', curr_rat);

    if skip_classical < 1
    % first left
    cp_cmd = ['cp ' src_dir classical_left ' ' target_dir curr_rat filesep];
    cp_cmd = [cp_cmd 'settings_@classical2afc_soloobj_Shraddha_' curr_rat '_' ratlist{r,2} '.mat'];
    system(cp_cmd);
    change_ratname_settings(curr_rat, ratlist{r,2});

    % then right
    cp_cmd = ['cp ' src_dir classical_right ' ' target_dir curr_rat filesep];
    cp_cmd = [cp_cmd 'settings_@classical2afc_soloobj_Shraddha_' curr_rat '_' ratlist{r,3} '.mat'];
    system(cp_cmd);
    change_ratname_settings(curr_rat, ratlist{r,3});
    end;
    
    % now set up the task file
    task_fname = 'FINAL_duration'; task_name = '@duration_discobj';
    if strcmpi(ratlist{r,4},'p'), task_fname = 'FINAL_pitch'; task_name = '@dual_discobj'; end;
    cp_cmd = ['cp ' src_dir task_fname '.mat' ' ' target_dir curr_rat filesep];
    cp_cmd = [cp_cmd 'settings_' task_name '_Shraddha_' curr_rat '_' ratlist{r,5} '.mat'];
    system(cp_cmd);
    change_ratname_settings(curr_rat, ratlist{r,5},'classical',0);

end;