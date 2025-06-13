function varargout = pokesplot_preferences_pane(obj, action, varargin)

try
    
    GetSoloFunctionArgs(obj);
    
    booleanstr = {'off', 'on'};
    
    switch action
        
        %% CASE init
        case 'init'
            if nargin < 6
                error('Invalid number of arguments. The number of arguments has to be 6.');
            elseif ~any(strcmpi('Position', varargin)) || ~any(strcmpi('Parent', varargin))
                error('It is compulsory to specify the position and the parent');
            end
            
            if ~exist('btnPreferencesPane', 'var') || ~isa(btnPreferencesPane, 'SoloParamHandle') || ~ishandle(get_ghandle(btnPreferencesPane))
                ToggleParam(obj, 'btnPreferencesPane', false, 1, 1, 'OnString', 'Preferences Pane Showing', 'OffString', 'Preferences Pane Hidden');
                set_callback(btnPreferencesPane, {mfilename, 'show_hide'});
            end
            set(get_ghandle(btnPreferencesPane), ...
                'Units', 'normalized', ...
                varargin{:});
            
            if ~exist('myfig_preferences', 'var') || ~isa(myfig_preferences, 'SoloParamHandle') || ~ishandle(value(myfig_preferences))
                SoloParamHandle(obj, 'myfig_preferences', ...
                    'value', double(figure('CloseRequestFcn', [mfilename '(' class(obj) ', ''hide'');'], ...
                    'MenuBar', 'none', ...
                    'Name', mfilename, ...
                    'Units', 'normalized')), ...
                    'saveable', false);
            end
            set(value(myfig_preferences), 'Visible', booleanstr{double(value(btnPreferencesPane))+1});
            
            visible_states_indices = zeros(length(VISIBLE_STATES_LIST), 1);
            for ctr = 1:length(VISIBLE_STATES_LIST)
                if ismember(VISIBLE_STATES_LIST{ctr}, fieldnames(value(STATE_COLORS)))
                    visible_states_indices(ctr) = find(strcmp(VISIBLE_STATES_LIST{ctr}, fieldnames(value(STATE_COLORS))));
                end
            end
            visible_pokes_indices = zeros(length(VISIBLE_POKES_LIST), 1);
            for ctr = 1:length(VISIBLE_POKES_LIST)
                if ismember(VISIBLE_POKES_LIST{ctr}, fieldnames(value(POKE_COLORS)))
                    visible_pokes_indices(ctr) = find(strcmp(VISIBLE_POKES_LIST{ctr}, fieldnames(value(POKE_COLORS))));
                end
            end
            visible_waves_indices = zeros(length(VISIBLE_WAVES_LIST), 1);
            for ctr = 1:length(VISIBLE_WAVES_LIST)
                if ismember(VISIBLE_WAVES_LIST{ctr}, fieldnames(value(WAVE_COLORS)))
                    visible_waves_indices(ctr) = find(strcmp(VISIBLE_WAVES_LIST{ctr}, fieldnames(value(WAVE_COLORS))));
                end
            end
            
            
            SoloParamHandle(obj, 'lbxPokes_Selected', 'value', visible_pokes_indices);
            
            SoloParamHandle(obj, 'lbxStates_Selected', 'value', visible_states_indices);
            
            SoloParamHandle(obj, 'lbxWaves_Selected', 'value', visible_waves_indices);
            
            
            %% GUI ELEMENTS SECTION
            set(value(myfig_preferences), 'Position', [0.50573     0.24417      0.3651     0.45917]);
            
            COMMON_PROPERTIES = {'Parent', value(myfig_preferences), ...
                'Units', 'normalized'};
            
            %editSmoother
            if ~exist('editSmoother', 'var') || ~isa(editSmoother, 'SoloParamHandle') || ~ishandle(get_ghandle(editSmoother))
                if exist('editSmoother', 'var') && isa(editSmoother, 'SoloParamHandle')
                    val = value(editSmoother);
                else
                    val = 0.1;
                end
                NumeditParam(obj, 'editSmoother', val, 1, 1);
                set_saveable(editSmoother, true);
            end
            set(get_ghandle(editSmoother), ...
                COMMON_PROPERTIES{:}, ...
                'Position', [0.66334    0.076225      0.0699    0.036298], ...
                'Tag', 'editSmoother');
            set(get_lhandle(editSmoother), 'String', 'Smoother', COMMON_PROPERTIES{:}, 'Tag', 'textSmoother', 'Position', [0.58203     0.07441    0.079886    0.038113]);
            
            
            %btnPlotPSTH
            PushbuttonParam(obj, 'btnPlotPSTH', 1, 1);
            set(get_ghandle(btnPlotPSTH), ...
                COMMON_PROPERTIES{:}, ...
                'Position', [0.73609     0.07441     0.11698    0.041742], ...
                'Tag', 'btnPlotPSTH', ...
                'String', 'Plot PSTH', ...
                'TooltipString', 'Plot PSTH');
            set_callback(btnPlotPSTH, {mfilename, 'btnPlotPSTHCallback'});
            
            %btnExport
            PushbuttonParam(obj, 'btnExport', 1, 1);
            set(get_ghandle(btnExport), ...
                COMMON_PROPERTIES{:}, ...
                'Position', [0.28388     0.07078     0.18688    0.041742], ...
                'Tag', 'btnExport', ...
                'TooltipString', 'Export MSV and SC to the base workspace', ...
                'String', 'Export');
            set_callback(btnExport, {mfilename, 'btnExportCallback'});
            
            %btnCollapse
            if ~exist('btnCollapse', 'var') || ~isa(btnCollapse, 'SoloParamHandle') || ~ishandle(get_ghandle(btnCollapse))
                if exist('btnCollapse', 'var') && isa(btnCollapse, 'SoloParamHandle')
                    val = value(btnCollapse);
                else
                    val = false;
                end
                ToggleParam(obj, 'btnCollapse', val, 1, 1, 'OnString', 'Don''t Collapse', 'OffString', 'Collapse');
                set_saveable(btnCollapse, true);
            end
            set(get_ghandle(btnCollapse), ...
                COMMON_PROPERTIES{:}, ...
                'Position', [0.0699     0.07078     0.18688    0.041742], ...
                'Tag', 'btnCollapse');
            
            
            %btnRefreshPlot
            PushbuttonParam(obj, 'btnRefreshPlot', 1, 1);
            set(get_ghandle(btnRefreshPlot), ...
                COMMON_PROPERTIES{:}, ...
                'Position', [0.0699     0.13    0.14408    0.05], ...
                'String', 'Refresh Plot', ...
                'TooltipString', 'Refresh plot after making changes to any of the parameters in the preferences pane', ...
                'Tag', 'btnRefreshPlot');
            set_callback(btnRefreshPlot, {mfilename, 'btnRefreshPlotCallback'});
            
            
            if ~exist('editMainSort', 'var') || ~isa(editMainSort, 'SoloParamHandle') || ~ishandle(get_ghandle(editMainSort))
                if exist('editMainSort', 'var') && isa(editMainSort, 'SoloParamHandle')
                    val = value(editMainSort);
                else
                    val = '0;';
                end
                EditParam(obj, 'editMainSort', val, 1, 1);
                set_saveable(editMainSort, true);
            end
            set(get_ghandle(editMainSort), ...
                COMMON_PROPERTIES{:}, ...
                'Position', [0.21255     0.36116     0.71469     0.09256], ...
                'Max', 9999999, ...
                'Min', 0, ...
                'FontName', 'monospaced', ...
                'FontSize', 10.0, ...
                'HorizontalAlignment', 'left', ...
                'Tag', 'editMainSort', ...
                'TooltipString', 'Main sort criterion', ...
                'Visible', 'on');
            set(get_lhandle(editMainSort), ...
                COMMON_PROPERTIES{:}, ...
                'Position', [0.0699     0.36116     0.14408     0.09256], ...
                'HorizontalAlignment', 'right', ...
                'String', 'Main Sort: ');
            
            
            if ~exist('editSubSort', 'var') || ~isa(editSubSort, 'SoloParamHandle') || ~ishandle(get_ghandle(editSubSort))
                if exist('editSubSort', 'var') && isa(editSubSort, 'SoloParamHandle')
                    val = value(editSubSort);
                else
                    val = 'trialnum;';
                end
                EditParam(obj, 'editSubSort', val, 1, 1);
                set_saveable(editSubSort, true);
            end
            set(get_ghandle(editSubSort), ...
                COMMON_PROPERTIES{:}, ...
                'Position', [0.21255     0.27223     0.71469     0.09256], ...
                'Max', 9999999, ...
                'Min', 0, ...
                'FontName', 'monospaced', ...
                'FontSize', 10.0, ...
                'HorizontalAlignment', 'left', ...
                'Tag', 'editSubSort', ...
                'TooltipString', 'Sub sort criterion', ...
                'Visible', 'on');
            set(get_lhandle(editSubSort), ...
                COMMON_PROPERTIES{:}, ...
                'Position', [0.0699     0.27223     0.14408     0.09256], ...
                'HorizontalAlignment', 'right', ...
                'String', 'Sub Sort: ');
            
            
            if ~exist('editTrialSelector', 'var') || ~isa(editTrialSelector, 'SoloParamHandle') || ~ishandle(get_ghandle(editTrialSelector))
                if exist('editTrialSelector', 'var') && isa(editTrialSelector, 'SoloParamHandle')
                    val = value(editTrialSelector);
                else
                    val = 'true;';
                end
                EditParam(obj, 'editTrialSelector', val, 1, 1);
                set_saveable(editTrialSelector, true);
            end
            set(get_ghandle(editTrialSelector), ...
                COMMON_PROPERTIES{:}, ...
                'Position', [0.21255     0.18149     0.71469     0.09256], ...
                'Max', 9999999, ...
                'Min', 0, ...
                'FontName', 'monospaced', ...
                'FontSize', 10.0, ...
                'HorizontalAlignment', 'left', ...
                'Tag', 'editTrialSelector', ...
                'TooltipString', 'Trial selector field. Trials for which this field evaluates to ''true'' will be shown.', ...
                'Visible', 'on');
            set(get_lhandle(editTrialSelector), ...
                COMMON_PROPERTIES{:}, ...
                'Position', [0.0699     0.18149     0.14408     0.09256], ...
                'HorizontalAlignment', 'right', ...
                'String', 'Trial Selector: ');
            
            
            PushbuttonParam(obj, 'btnSelectNoneWaves', 1, 1);
            set(get_ghandle(btnSelectNoneWaves), ...
                COMMON_PROPERTIES{:}, ...
                'Tag', 'btnSelectNoneWaves', ...
                'String', 'None', ...
                'TooltipString', 'Hide all scheduled waves', ...
                'Position', [0.78174     0.52813    0.098431    0.039927]);
            set_callback(btnSelectNoneWaves, {mfilename, 'btnSelectNoneWavesCallback'});
            
            
            PushbuttonParam(obj, 'btnSelectAllWaves', 1, 1);
            set(get_ghandle(btnSelectAllWaves), ...
                COMMON_PROPERTIES{:}, ...
                'Tag', 'btnSelectAllWaves', ...
                'String', 'All', ...
                'TooltipString', 'Show all scheduled waves', ...
                'Position', [0.68474     0.52813    0.098431    0.039927]);
            set_callback(btnSelectAllWaves, {mfilename, 'btnSelectAllWavesCallback'});
            
            
            PushbuttonParam(obj, 'btnSelectAllPokes', 1, 1);
            set(get_ghandle(btnSelectAllPokes), ...
                COMMON_PROPERTIES{:}, ...
                'Tag', 'btnSelectAllPokes', ...
                'String', 'All', ...
                'TooltipString', 'Show all pokes', ...
                'Position', [0.38374     0.52813    0.098431    0.039927]);
            set_callback(btnSelectAllPokes, {mfilename, 'btnSelectAllPokesCallback'});
            
            
            PushbuttonParam(obj, 'btnSelectNonePokes', 1, 1);
            set(get_ghandle(btnSelectNonePokes), ...
                COMMON_PROPERTIES{:}, ...
                'Tag', 'btnSelectNonePokes', ...
                'String', 'None', ...
                'TooltipString', 'Hide all pokes', ...
                'Position', [0.48074     0.52813    0.098431    0.039927]);
            set_callback(btnSelectNonePokes, {mfilename, 'btnSelectNonePokesCallback'});
            
            
            PushbuttonParam(obj, 'btnSelectNoneStates', 1, 1);
            set(get_ghandle(btnSelectNoneStates), ...
                COMMON_PROPERTIES{:}, ...
                'Tag', 'btnSelectNoneStates', ...
                'String', 'None', ...
                'TooltipString', 'Hide all states', ...
                'Position', [0.1669     0.52813    0.098431    0.039927]);
            set_callback(btnSelectNoneStates, {mfilename, 'btnSelectNoneStatesCallback'});
            
            PushbuttonParam(obj, 'btnSelectAllStates', 1, 1);
            set(get_ghandle(btnSelectAllStates), ...
                COMMON_PROPERTIES{:}, ...
                'Tag', 'btnSelectAllStates', ...
                'String', 'All', ...
                'TooltipString', 'Show all states', ...
                'Position', [0.0699     0.52813    0.098431    0.039927]);
            set_callback(btnSelectAllStates, {mfilename, 'btnSelectAllStatesCallback'});
            
            HeaderParam(obj, 'textScheduledWaves', 'Scheduled Waves', 1, 1);
            set(get_ghandle(textScheduledWaves), ...
                COMMON_PROPERTIES{:}, ...
                'Tag', 'textScheduledWaves', ...
                'String', 'Scheduled Waves', ...
                'HorizontalAlignment', 'center', ...
                'Position', [0.68331      0.8167     0.24251    0.036298]);
            
            HeaderParam(obj, 'textPokes', 'Pokes', 1, 1);
            set(get_ghandle(textPokes), ...
                COMMON_PROPERTIES{:}, ...
                'Tag', 'textPokes', ...
                'String', 'Pokes', ...
                'HorizontalAlignment', 'center', ...
                'Position', [0.38231      0.8167     0.24251    0.036298]);
            
            
            HeaderParam(obj, 'textStates', 'States', 1, 1);
            set(get_ghandle(textStates), ...
                COMMON_PROPERTIES{:}, ...
                'Tag', 'textStates', ...
                'String', 'States', ...
                'HorizontalAlignment', 'center', ...
                'Position', [0.0699      0.8167     0.24251    0.036298]);
            
            SoloParamHandle(obj, 'lbxPokes', 'value', ...
                uicontrol(COMMON_PROPERTIES{:}, ...
                'Style', 'listbox', ...
                'Tag', 'lbxPokes', ...
                'String', fieldnames(value(POKE_COLORS)), ...
                'Value', value(lbxPokes_Selected), ...
                'Max', 2, ...
                'Min', 0, ...
                'TooltipString', 'List of pokes that can be displayed', ...
                'Callback', [mfilename '(' class(obj) ', ''lbxPokesCallback'')'], ...
                'Position', [0.38231     0.57713     0.24251     0.23956]), ...
                'saveable', false);
            
            SoloParamHandle(obj, 'lbxStates', 'value', ...
                uicontrol(COMMON_PROPERTIES{:}, ...
                'Style', 'listbox', ...
                'Tag', 'lbxStates', ...
                'String', fieldnames(value(STATE_COLORS)), ...
                'Value', value(lbxStates_Selected), ...
                'Max', 2, ...
                'Min', 0, ...
                'TooltipString', 'List of states that can be displayed', ...
                'Callback', [mfilename '(' class(obj) ', ''lbxStatesCallback'')'], ...
                'Position', [0.0699     0.57713     0.24251     0.23956]), ...
                'saveable', false);
            
            SoloParamHandle(obj, 'lbxWaves', 'value', ...
                uicontrol(COMMON_PROPERTIES{:}, ...
                'Style', 'listbox', ...
                'Tag', 'lbxWaves', ...
                'String', fieldnames(value(WAVE_COLORS)), ...
                'Value', value(lbxWaves_Selected), ...
                'Max', 2, ...
                'Min', 0, ...
                'TooltipString', 'List of scheduled waves that can be displayed', ...
                'Callback', [mfilename '(' class(obj) ', ''lbxWavesCallback'')'], ...
                'Position', [0.68331     0.57713     0.24251     0.23956]), ...
                'saveable', false);
            
            
            HeaderParam(obj, 'textHeader', 'PokesPlot Preferences Pane', 1, 1);
            set(get_ghandle(textHeader), ...
                COMMON_PROPERTIES{:}, ...
                'Tag', 'textHeader', ...
                'HorizontalAlignment', 'center', ...
                'Position', [0.067047     0.90744      0.8602    0.045372]);
            
            
            SoloFunctionAddVars(obj, 'PokesPlotSection', 'rw_args', {'btnPreferencesPane', 'btnCollapse'});
            
            
            fighandle = double(get(get_ghandle(btnPreferencesPane), 'Parent'));
            while ~isequal(round(fighandle), fighandle)
                fighandle = double(get(fighandle, 'Parent'));
            end
            figure(fighandle);
            
            SoloFunctionAddVars(obj, 'PokesPlotSection', 'rw_args', {'myfig_preferences', 'editMainSort', 'editSubSort', 'editTrialSelector'});
            
            
        case 'reinit'
            clf(value(myfig_preferences));
            pos = get(get_ghandle(btnPreferencesPane), 'Position');
            par = get(get_ghandle(btnPreferencesPane), 'Parent');
            feval(mfilename, obj, 'init', 'Position', pos, 'Parent', par);
            
            
            %% CASE show_hide
        case 'show_hide'
            if value(btnPreferencesPane)
                set(value(myfig_preferences), 'Visible', 'on');
            else
                set(value(myfig_preferences), 'Visible', 'off');
            end
            
            %% CASE hide
        case 'hide'
            btnPreferencesPane.value = false;
            set(value(myfig_preferences), 'Visible', 'off');
            
            
        case 'btnSelectAllStatesCallback'
            set(value(lbxStates), 'Value', 1:length(get(value(lbxStates), 'String')));
            feval(mfilename, obj, 'lbxStatesCallback');
            
        case 'btnSelectNoneStatesCallback'
            set(value(lbxStates), 'Value', []);
            feval(mfilename, obj, 'lbxStatesCallback');
            
        case 'lbxStatesCallback'
            set(value(myfig_preferences), 'Pointer', 'watch');
            set(value(myfig), 'Pointer', 'watch');
            drawnow;
            booleanstr = {'off', 'on'};
            lbxStates_String = get(value(lbxStates), 'String');
            VISIBLE_STATES_LIST.value = lbxStates_String(get(value(lbxStates), 'Value'));
            set(value(checkboxStates), 'Value', ~isempty(value(VISIBLE_STATES_LIST)));
            for ctr = 1:length(trial_info)
                if isfield(trial_info(ctr).ghandles, 'states')
                    statenames = fieldnames(trial_info(ctr).ghandles.states);
                    statenames = setdiff(statenames, 'all_handles');
                    for ctr2 = 1:length(statenames)
                        isvisible = ismember(statenames{ctr2}, value(VISIBLE_STATES_LIST)) && ~ismember(ctr, value(INVISIBLE_TRIALS_LIST));
                        handle_list = trial_info(ctr).ghandles.states.(statenames{ctr2}); handle_list = handle_list(ishandle(handle_list));
                        set(handle_list, 'Visible', booleanstr{double(isvisible)+1});
                    end
                end
            end
            set(value(myfig_preferences), 'Pointer', 'arrow');
            set(value(myfig), 'Pointer', 'arrow');
            drawnow;
            
        case 'btnSelectAllPokesCallback'
            set(value(lbxPokes), 'Value', 1:length(get(value(lbxPokes), 'String')));
            feval(mfilename, obj, 'lbxPokesCallback');
            
        case 'btnSelectNonePokesCallback'
            set(value(lbxPokes), 'Value', []);
            feval(mfilename, obj, 'lbxPokesCallback');
            
        case 'lbxPokesCallback'
            set(value(myfig_preferences), 'Pointer', 'watch');
            set(value(myfig), 'Pointer', 'watch');
            drawnow;
            booleanstr = {'off', 'on'};
            lbxPokes_String = get(value(lbxPokes), 'String');
            VISIBLE_POKES_LIST.value = lbxPokes_String(get(value(lbxPokes), 'Value'));
            set(value(checkboxPokes), 'Value', ~isempty(value(VISIBLE_POKES_LIST)));
            for ctr = 1:length(trial_info)
                if isfield(trial_info(ctr).ghandles, 'pokes')
                    pokenames = fieldnames(trial_info(ctr).ghandles.pokes);
                    pokenames = setdiff(pokenames, 'all_handles');
                    for ctr2 = 1:length(pokenames)
                        isvisible = ismember(pokenames{ctr2}, value(VISIBLE_POKES_LIST)) && ~ismember(ctr, value(INVISIBLE_TRIALS_LIST));
                        handle_list = trial_info(ctr).ghandles.pokes.(pokenames{ctr2}); handle_list = handle_list(ishandle(handle_list));
                        set(handle_list, 'Visible', booleanstr{double(isvisible)+1});
                    end
                end
            end
            set(value(myfig_preferences), 'Pointer', 'arrow');
            set(value(myfig), 'Pointer', 'arrow');
            drawnow;
            
            
        case 'btnSelectAllWavesCallback'
            set(value(lbxWaves), 'Value', 1:length(get(value(lbxWaves), 'String')));
            feval(mfilename, obj, 'lbxWavesCallback');
            
        case 'btnSelectNoneWavesCallback'
            set(value(lbxWaves), 'Value', []);
            feval(mfilename, obj, 'lbxWavesCallback');
            
        case 'lbxWavesCallback'
            set(value(myfig_preferences), 'Pointer', 'watch');
            set(value(myfig), 'Pointer', 'watch');
            drawnow;
            booleanstr = {'off', 'on'};
            lbxWaves_String = get(value(lbxWaves), 'String');
            VISIBLE_WAVES_LIST.value = lbxWaves_String(get(value(lbxWaves), 'Value'));
            set(value(checkboxWaves), 'Value', ~isempty(value(VISIBLE_WAVES_LIST)));
            for ctr = 1:length(trial_info)
                if isfield(trial_info(ctr).ghandles, 'waves')
                    wavenames = fieldnames(trial_info(ctr).ghandles.waves);
                    wavenames = setdiff(wavenames, 'all_handles');
                    for ctr2 = 1:length(wavenames)
                        isvisible = ismember(wavenames{ctr2}, value(VISIBLE_WAVES_LIST)) && ~ismember(ctr, value(INVISIBLE_TRIALS_LIST));
                        handle_list = trial_info(ctr).ghandles.waves.(wavenames{ctr2}); handle_list = handle_list(ishandle(handle_list));
                        set(handle_list, 'Visible', booleanstr{double(isvisible)+1});
                    end
                end
            end
            set(value(myfig_preferences), 'Pointer', 'arrow');
            set(value(myfig), 'Pointer', 'arrow');
            drawnow;
            
            
            
        case 'btnRefreshPlotCallback'
            PokesPlotSection(obj, 'pokesplot_preferences_pane_callback');
            
        case 'btnExportCallback'
            msv = cell(length(trial_info), 1);
            [msv{1:end}] = deal(trial_info.mainsort_value); msv = cell2mat(msv);
            sc = zeros(size(msv));
            for ctr = 1:numel(sc)
                if isfield(trial_info(ctr).ghandles, 'spikes') && isfield(trial_info(ctr).ghandles.spikes, 'all_handles')
                    %Sundeep Tuteja, 2010-10-31: The spike count was
                    %earlier set as the length of the handles list. However,
                    %this approach did not take into account the fact that
                    %the spikes in each trial are in fact a single line
                    %object. However, there is another way. It turns out,
                    %the number of NaNs in the XData field is equal to the
                    %spike count.
                    line_handle = trial_info(ctr).ghandles.spikes.all_handles(ishandle(trial_info(ctr).ghandles.spikes.all_handles));
                    if ishandle(line_handle)
                        xdata = get(line_handle, 'XData');
                        sc(ctr) = length(find(isnan(xdata)));
                    end
                end
            end
            assignin('base', 'msv', msv);
            assignin('base', 'sc', sc);
            
            
        case 'btnPlotPSTHCallback'
            if value(SHOULD_USE_CUSTOM_PREFERENCES)
                msv = cell(length(trial_info), 1);
                [msv{1:end}] = deal(trial_info.mainsort_value);
                msv = cell2mat(msv);
                
                %Get visible trial numbers in the correct order from TRIAL_SEQUENCE
                trial_sequence = value(TRIAL_SEQUENCE);
                invisible_trials_list = value(INVISIBLE_TRIALS_LIST);
                visible_trials_list = trial_sequence;
                for ctr = 1:length(invisible_trials_list)
                    visible_trials_list = visible_trials_list(visible_trials_list ~= invisible_trials_list(ctr));
                end
                visible_trials_list = visible_trials_list(visible_trials_list <= length(trial_info));
                
                ev = [];
                ts = [];
                for ctr = 1:length(visible_trials_list)
                    if isfield(trial_info(visible_trials_list(ctr)).ghandles, 'spikes') && isfield(trial_info(visible_trials_list(ctr)).ghandles.spikes, 'all_handles')
                        spike_handles = trial_info(visible_trials_list(ctr)).ghandles.spikes.all_handles;
                        ev(end+1) = trial_info(visible_trials_list(ctr)).align_time;
                        if all(ishandle(spike_handles))
                            xdata = get(spike_handles, 'XData');
                            ts = [ts(:); columnvectortransform(xdata(1:3:end))+ev(end)];
                        end
                    end
                end
                
                
                original_dir = pwd;
                cd('..');
                remove_path = false;
                if ~inpath(fullfile(pwd, 'Analysis', 'helpers'))
                    remove_path = true;
                end
                path(fullfile(pwd, 'Analysis', 'helpers'), path);
                try
                    figure; exampleraster(ev(:), ts(:), 'pre', -t0, 'post', t1, 'binsz', 0.05, 'cnd', msv(:), 'meanflg', 0, 'errorbars', true, 'krn', value(editSmoother));
                catch ME
                    cd(original_dir);
                    if remove_path
                        rmpath(fullfile(pwd, 'Analysis', 'helpers'));
                    end
                    rethrow(ME);
                end
                if remove_path
                    rmpath(fullfile(pwd, 'Analysis', 'helpers'));
                end
                cd(original_dir);
                %psthC(ev(:), (ts(:))', -t0*1000, t1*1000, 10, (msv(:))', 0, value(editSmoother)*1000);
                %xlim([t0 t1]);
                %set(gca, 'TickDir', 'out', 'FontSize', 16);
                %xlabel(sprintf('time from %s', value(alignon)))
                %set(get(gca, 'XLabel'), 'Interpreter', 'none');
                %ylabel('spikes/sec +/- std. err.');
            end
            
        case 'close'
            if exist('myfig_preferences', 'var') && isa(myfig_preferences, 'SoloParamHandle') && ishandle(value(myfig_preferences))
                delete(value(myfig_preferences));
            end
            clear(mfilename);
            
            
            
        otherwise
            error(['Unknown action ' action]);
            
            
    end
    
catch
    showerror;
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = inpath(abspath)
%INPATH Returns true if the passed argument is present in the MATLAB path,
%false if it is not.

if strcmp(abspath(end), filesep)
    abspath = abspath(1:end-1);
end
p = path; p = [p ';'];
out = any(strfind(p, [abspath ';']));

end