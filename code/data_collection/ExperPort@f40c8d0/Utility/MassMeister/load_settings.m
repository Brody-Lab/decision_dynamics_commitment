function handles = load_settings(handles)

try pname = bSettings('get','GENERAL','Main_Code_Directory'); 
    pname = [pname,filesep,'Utility',filesep,'MassMeister']; 
catch %#ok<CTCH>
    pname = 'C:\ratter\ExperPort\Utility\MassMeister';
end

file = [pname,filesep,'Properties.mat'];
handles.file = file;
if exist(file,'file') == 2
    properties = [];
    load(file);
    
    if ~isfield(properties,'precision')
        properties.precision = 0;
    end
    
    if isfield(handles,'minmass_edit')
        set(handles.minmass_edit,  'string',num2str(properties.minmass));
        set(handles.rate_edit,     'string',num2str(properties.rate));
        set(handles.numreads_edit, 'string',num2str(properties.numreads));
        set(handles.threshold_edit,'string',num2str(properties.threshold));
        set(handles.error_edit,    'string',num2str(properties.error));
        set(handles.smallrat_edit, 'string',num2str(properties.smallrat));
        set(handles.precision_edit,'string',num2str(properties.precision));
        set(handles.scale_edit,    'string',properties.scale);
        set(handles.comscale_edit, 'string',properties.comscale);
        set(handles.comrfid_edit,  'string',properties.comrfid);
        
    else
        handles.minmass   = properties.minmass;
        handles.rate      = properties.rate;
        handles.numreads  = properties.numreads;
        handles.threshold = properties.threshold;
        handles.error     = properties.error;
        handles.smallrat  = properties.smallrat;
        handles.scale     = properties.scale;
        handles.comscale  = properties.comscale;
        handles.comrfid   = properties.comrfid;
        handles.precision = properties.precision;
    end
else
    if ~isfield(handles,'minmass_edit')
        handles.minmass   = 100;
        handles.rate      = 5;
        handles.numreads  = 20;
        handles.threshold = 0.4;
        handles.error     = 5;
        handles.smallrat  = 225;
        handles.precision = 0;
        handles.scale     = 'SPE6000';
        handles.comscale  = 'COM3';
        handles.comrfid   = 'COM51';
    end
end