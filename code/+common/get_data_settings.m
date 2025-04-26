function settings = get_data_settings(settingsname)
% Retrieve the parameters under a configuration of data processing
%
% ARGUMENT
%
%   settingsname
%       A char row array identifying a configuration
%
% RETURN
%   
%   settings
%       A struct containing the settings with the following parameters:
settingstable = common.tabulate_data_settings;
settings = settingstable(settingstable.settingsname == settingsname, :);
settings = table2struct(settings);