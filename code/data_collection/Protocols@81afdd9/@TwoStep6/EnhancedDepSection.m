
function [x, y] = EnhancedDepSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    %% init
    case 'init',
        
        
        ToggleParam(obj,'TwoSessionSave',0,x,y,'OnString','Two Session Save','OffString','Normal Save');
        next_row(y);
        
    case 'pre_saving_settings'
        
        if value(TwoSessionSave) == 1
            % First save the settings file for tomorrow for twostep6
            
            [experimenter, ratname] = SavingSection(obj,'get_info');
            
            save_solouiparamvalues(   ratname, ...
                'experimenter',       experimenter, ...
                'interactive',        0, ...
                'owner',              class(obj), ...
                'commit',             1, ...
                'tomorrow',           1);
            
            % Next save the file for today for RigWaterDelivery
            Solo_datadir=bSettings('get','GENERAL','Main_Data_Directory');
            settings_dir = [Solo_datadir filesep 'Settings' filesep experimenter filesep ratname];
            
            % Find the most recent @RigWaterDelivery settings file
            settings_files = dir(settings_dir);
            settings_files_cell = struct2cell(settings_files);
            settings_filenames = settings_files_cell(1,:);
            settings_fileinds_RigWaterDelivery = ~cellfun('isempty',strfind(settings_filenames,'@RigWaterDelivery'));
            settings_filenames_rwd = settings_files_cell(1,settings_fileinds_RigWaterDelivery);
            settings_datenums_rwd = settings_files_cell(5,settings_fileinds_RigWaterDelivery);
            [max_val,max_ind] = max(cell2mat(settings_datenums_rwd));
            settings_filename_most_recent_rwd = settings_filenames_rwd{max_ind};
            
            % Rename it to today_z, add and commit it
            oldname = [settings_dir filesep settings_filename_most_recent_rwd];
            newname = [settings_dir filesep 'settings_@RigWaterDelivery_' experimenter '_' ratname '_' datestr(today,'yymmdd') 'h.mat'];
            movefile(oldname,newname);
            add_and_commit(newname);
            
        end
end