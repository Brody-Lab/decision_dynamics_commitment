function [x, y] = PokeMeasuresSection(obj, action, x, y)
%
% [x, y] = InitPoke_Measures(x, y, obj)
%
% args:    x, y                 current UI pos, in pixels
%          obj                  A locsamp3obj object
%
% returns: x, y                 updated UI pos
%

GetSoloFunctionArgs;
% SoloFunction('PokeMeasuresSection', 'rw_args', 'LastTrialEvents', ...
%    'ro_args', {'n_done_trials', 'n_started_trials', 'RealTimeStates'});

global Solo_Try_Catch_Flag;


switch action,
    case 'init',  % ---------- CASE INIT ----------

        % --- current trial pokes figure
        SoloFunction('CurrentTrialPokesSubsection', ...
            'ro_args', {'LastTrialEvents', 'RealTimeStates', ...
            'n_started_trials'});
        if ~Solo_Try_Catch_Flag,
            [x, y] = CurrentTrialPokesSubSection(obj, 'init', x, y);
        else
            try,
                [x, y] = CurrentTrialPokesSubSection(obj, 'init', x, y);
            catch,
                warning('Error in init portion of CurrentTrialPokesSubSection');
                lasterr,
            end;
        end;

        PokeMeasuresSection(obj, 'update_pokedur');
        PokeMeasuresSection(obj, 'show_plots');

    case 'update_counts',  % ---------- CASE UPDATE_COUNTS ---------
        Event = GetParam('rpbox', 'event', 'user');
        LastTrialEvents.value = [value(LastTrialEvents) ; Event];
        rts = value(RealTimeStates);
        if ~Solo_Try_Catch_Flag, CurrentTrialPokesSubSection(obj, 'update');
        else
            try,   CurrentTrialPokesSubSection(obj, 'update');
            catch, warning('Error in CurrentTrialPokesSubSection.update'); lasterr,
            end;
        end;


    case 'update_plot', % --------- CASE UPDATE_PLOT -------

    case 'update_pokedur' 	  , % ------------ case UPDATE_POKEDUR --
    case 'show_plots'

    case 'delete'            , % ------------ case DELETE ----------
        if ~Solo_Try_Catch_Flag, CurrentTrialPokesSubSection(obj, 'delete');
        else
            try,   CurrentTrialPokesSubSection(obj, 'delete');
            catch, warning('Error in CurrentTrialPokesSubSection.delete'); lasterr
            end;
        end;

    otherwise,
        error(['Don''t know how to deal with action ' action]);
end;




