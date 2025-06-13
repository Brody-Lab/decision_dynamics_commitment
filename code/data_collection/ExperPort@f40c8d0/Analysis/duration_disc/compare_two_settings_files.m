function [] = compare_two_settings_files()

ratname1 = 'S005';fa = '080619a';
ratname2 = 'Pips'; fb='080619a';

load_datafile(ratname1, fa);
a__saved = saved;
a__sh = saved_history;
a__sa = saved_autoset;

load_datafile(ratname2, fb);
b__saved = saved;
b__sh = saved_history;
b__sa = saved_autoset;

a_t1 = a__saved.ChordSection_tone1_list;
a_t2 = a__saved.ChordSection_tone2_list;

b_t1= b__saved.ChordSection_tone1_list;
b_t2 = b__saved.ChordSection_tone2_list;

clr1 = [0 1 0];
clr2 = [1 0.6 0.3];

% figure;
% plot(a_t1, '.b','Color', clr1);
% hold on; plot(b_t1, '.r', 'Color',clr2);
% title('tone1');
% 
% figure;
% plot(a_t2,'.b','COlor', clr1);
% hold on; plot(b_t2, '.r','Color',clr2);
% title('tone2');

compare_structs(a__sh, b__sh);
compare_structs(a__saved, b__saved);

function [] = compare_structs(structa, structb)
fnames = fieldnames(structa);
for f = 1:length(fnames)

    if ~(strcmpi(fnames{f},'SessionDefinition_train_string_display') || ...
        strcmpi(fnames{f},'dual_discobj_LastTrialEvents') || ...
                strcmpi(fnames{f},'duration_discobj_LastTrialEvents') || ...
        strcmpi(fnames{f}, 'dual_discobj_RealTimeStates') || ...
        strcmpi(fnames{f}, 'duration_discobj_RealTimeStates') || ...        
        strcmpi(fnames{f}, 'SessionDefinition_train_list') || ...
               strcmpi(fnames{f}, 'make_and_upload_state_matrix_white_noise_sound') || ... 
                   strcmpi(fnames{f}, 'make_and_upload_state_matrix_state_matrix_cell') || ... 
        strcmpi(fnames{f},'ChordSection_sound_data') ...
    )

        tmp_a = eval(['structa.' fnames{f}]);
        tmp_b = eval(['structb.' fnames{f}]);
        
        if strcmpi(fnames{f},'ChordSection_volume_factor')
            2;
        end;

        mt = 1;
        try
            if isempty(tmp_a) && isempty(tmp_b)
                mt = 1;
            elseif isnumeric(tmp_a)
                if length(tmp_a) > 1
                    if tmp_a ~= tmp_b, mt = 0; end;
                end;
            elseif ~iscell(tmp_a) % could be a string
                if ~strcmpi(tmp_a, tmp_b), mt = 0; end;
            else
                numa = cell2mat(tmp_a);
                numb = cell2mat(tmp_b);
       %         fprintf(1,'\t%s\n', fnames{f});
                mt = sub__comparenumcells(numa, numb);
            end;
        catch
            mt = sub__comparestrcells(tmp_a, tmp_b);
        end;

        if mt == 0
            fprintf(1,'NOT MATCH: %s\n', fnames{f});
        end;
    end;
end;


function [m] = sub__comparenumcells(ca,cb)

m = 1;
if length(ca) < length(cb),
    cb =cb(1:length(ca));
else
    ca = ca(1:length(cb));
end;

if sum(ca ~= cb) > 0, m= 0; end;


function [m] = sub__comparestrcells(ca, cb)
m = 1;
if length(ca) < length(cb),
    smaller_cell = ca; bigger_cell = cb;
    minl = length(ca);
else
    smaller_cell = cb; bigger_cell = ca;
    minl = length(cb);
end;

ctr = 1;
while (m > 0) && (ctr <=minl)
    tmp_a = ca{ctr};
    tmp_b = cb{ctr};
    if ~strcmpi(tmp_a, tmp_b)
        m = 0;
    end;
    ctr = ctr+1;
end;