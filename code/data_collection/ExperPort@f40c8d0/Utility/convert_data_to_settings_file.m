function settingsfile = convert_data_to_settings_file(datafile)

settingsfile = datafile;
Dpos = strfind(settingsfile,'\Data\');
settingsfile = [settingsfile(1:Dpos),'Settings',settingsfile(Dpos+5:end)];
dpos = strfind(settingsfile,'\data_');
settingsfile = [settingsfile(1:dpos),'settings',settingsfile(dpos+5:end)];