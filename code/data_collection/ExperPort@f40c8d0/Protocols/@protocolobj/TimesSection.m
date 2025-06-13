function [x, y, BadBoySound, BadBoySPL, WN_SPL, ITISound, ITILength, ITIReinitPenalty, ...
    TimeOutSound, TimeOutLength, TimeOutReinitPenalty, ...
    ExtraITIonError, DrinkTime]=TimesSection(obj, action, x, y);
%
%[x, y, iti_sound_len, tout_sound_len, ExtraITIonError, ...
%            DrinkTime]=InitTimes(x, y, obj);
%
% args:    x, y                 current UI pos, in pixels
%          obj                  A locsamp3obj object
%
% returns: x, y                 updated UI pos
%          iti_sound_len        handle to length, in secs, of ITI sound
%          timeout_sound_len    handle to length, in secs, of timeout sound
%          ExtraITIOnError      handle to # of ITI sounds to emit on error
%          DrinkTime            handle to length of pause after correct
%
% Simply initialises (or re-initialises) all UI elements parameterising
% penalty/ITI states (states with white noise)
%

GetSoloFunctionArgs;

child_class = ['@' class(value(mychild))];
child_vars = {'ExtraITIonError', 'ITISound',  'ITILength', 'ITIReinitPenalty', 'TimeOutSound', ...
    'TimeOutLength', 'TimeOutReinitPenalty','BadBoySound', 'DrinkTime'};

if ~strcmp(action, 'init')
    for c_var = 1:length(child_vars)
        func_name = [ mfilename '_' child_vars{c_var} ];
        sph = get_sphandle('owner', child_class, 'name', child_vars{c_var}, ...
            'fullname', func_name); sph = sph{1};
        eval([child_vars{c_var} '  = sph;']);
    end;
end;

switch action,
    case 'init',

        % Var defines penalty length values for ITI (length/reinit), TimeOut (length/reinit), and Error ITI
        cell_units = {}; for i=0:2:16,
            cell_units = [cell_units {num2str(i)}];
        end;

        extraiti_tooltip  = 'Extra seconds of white noise upon error response';
        itilen_tooltip    = 'Seconds of white noise after the end of the trial';
        itireinit_tooltip = 'Extra seconds of white noise if poke during ITI';
        % UI params controlling inter-trial-interval (ITI):


        MenuParam(obj, 'ITISound',  {'silence', 'white noise'}, 2, x, y, ...
            'TooltipString', 'Always white noise for now', 'param_owner', child_class);
        set(get_ghandle(ITISound), 'Enable', 'off', 'Visible', 'off');

        MenuParam(obj, 'ExtraITIonError',  cell_units, 1, x, y, ...
            'TooltipString', extraiti_tooltip, 'param_owner', child_class); next_row(y);
        MenuParam(obj, 'ITILength', cell_units, 2, x, y, ...
            'TooltipString', itilen_tooltip, 'param_owner', child_class); next_row(y);
        MenuParam(obj, 'ITIReinitPenalty', cell_units, 2, x, y, ...
            'TooltipString', itireinit_tooltip, 'param_owner', child_class); next_row(y);
        next_row(y, 0.5);

        % --- Now TimeOut sound: for comments, see ITISound immediately above

        MenuParam(obj, 'TimeOutSound',{'silence', 'white noise'}, 2, x, y, ...
            'TooltipString', 'Always white noise for now', ...
            'param_owner', child_class);
        set(get_ghandle(TimeOutSound), 'Enable', 'off', 'Visible', 'off');

        MenuParam(obj, 'TimeOutLength',        cell_units, 2, x, y, ...
            'param_owner', child_class);   next_row(y);
        MenuParam(obj, 'TimeOutReinitPenalty', cell_units, 2, x, y, ...
            'param_owner', child_class);   next_row(y);
        next_row(y, 0.5);

        MenuParam(obj, 'BadBoySound', {'on', 'off'}, 1, x, y, 'param_owner', child_class); next_row(y);
        MenuParam(obj, 'BadBoySPL', {'normal', 'Louder', 'LOUDEST'}, 1, x, y, 'label', 'BadBoy SPL', 'TooltipString', 'Sound intensity/volume for BadBoy sound', 'param_owner', child_class);next_row(y);
        set_callback(BadBoySPL, {'make_and_upload_state_matrix', 'update_bb_sound'});

        next_row(y,0.5);

        EditParam(obj, 'WN_SPL', 1, x, y, 'label', 'WN SPL (% Orig)', 'TooltipString', '% regular volume of white noise (p<1 --> softer, p>1 --> louder)', 'param_owner', child_class);     next_row(y);
        set_callback(WN_SPL, {'make_and_upload_state_matrix', 'update_wn_sound'});
        next_row(y,0.5);

        % --- Finally, set up the UI for DrinkTime
        EditParam(obj, 'DrinkTime', 1, x, y, 'param_owner', child_class);   next_row(y);
        next_row(y,0.5);
        SubheaderParam(obj, 'times_sbh', 'Penalty and ITI', x, y, 'param_owner', child_class); next_row(y);

        SoloParamHandle(obj, 'bbspl_loud_tracker', 'value', 0, 'param_owner', child_class);
        SoloParamHandle(obj, 'trials_since_last_chng', 'value', 0, 'param_owner', child_class);

    case 'reinit',
        delete_sphandle('handlelist', ...
            get_sphandle('owner', class(obj), 'fullname', mfilename));
        TimesSection(obj, 'init', 186, 100);

    otherwise,
        error(['Don''t know how to deal with action ' action]);

end;



