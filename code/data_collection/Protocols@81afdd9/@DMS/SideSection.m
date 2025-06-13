% Side Section
% Initial draft by JY 2022-03
% 
% SideSection determines the direction of the current trial t based on various
% parameters: the history of left and right trials, percent correct on both,
% whether we're in the midst of a left or right block, and the antibias.
% 
% We will declare the following variables here:
% 
%   current_side = {'LEFT', 'RIGHT'}
%   LeftProb
%   MaxSame
%   
%   
%   
%   

function [x, y] = SideSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action

    %---------------------------------------------------------------%
    %          init                                                 %
    %---------------------------------------------------------------%
    case 'init'
        x = varargin{1} ; y = varargin{2};
        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);

        NumeditParam(obj, 'LeftProb', 0.5, x, y, 'position', [x y 200 20], 'labelfraction', 0.6);

        MenuParam(obj, 'MaxSame', {'1','2','3','4','5','6','7','8','Inf'}, Inf, x, y,...
            'position', [x+110 y  90 20], 'labelfraction', 0.6, 'TooltipString', ...
            sprintf(['\nMaximum number of consecutive trials where correct\nresponse', ...
                     ' is on the same side. Overrides antibias. Thus, for \nexample,', ...
                     ' if MaxSame=5 and there have been 5 Left trials, the\nnext trial',...
                     ' is guaranteed to be Right']));
        next_row(y);
        
        DispParam(obj, 'current_side', 'LEFT', x, y);
        next_row(y);
        
        SubheaderParam(obj, 'title', 'Sides Section', x, y); 
        
        % Declare global while writing protocol
        DeclareGlobals(obj, 'ro_args', {'LeftProb', 'current_side'});



    %---------------------------------------------------------------%
    %          get_left_prob                                        %
    %---------------------------------------------------------------%
    case 'get_left_prob'
        x = value(LeftProb);

    %---------------------------------------------------------------%
    %          get_right_prob                                       %
    %---------------------------------------------------------------%
    case 'get_right_prob'
        x = 1.0 - value(LeftProb);


    %---------------------------------------------------------------%
    %          get_current_side                                     %
    %---------------------------------------------------------------%
    case 'get_current_side'
        if isequal(current_side, 'LEFT')
            x = 'l';
        else
            x = 'r';
        end


    %---------------------------------------------------------------%
    %          prepare_next_trial                                   %
    %---------------------------------------------------------------%
    case 'prepare_next_trial'

        % Get posterior for L and R from antibias
        posterior = AntibiasSection(obj, 'get_posterior_probs');
        posterior = posterior ./ sum(posterior);

        % Draw to compute side for this trial
        side = rand(1) < posterior(1);
        if   side == 1; current_side.value = 'LEFT';
        else side == 0; current_side.value = 'RIGHT';
        end


    %---------------------------------------------------------------%
    %          reinit                                               %
    %---------------------------------------------------------------%
    case 'reinit',
        currfig = double(gcf);
        % Get the original GUI position and figure:
        x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
          'fullname', ['^' mfilename]);
        % Reinitialise at the original GUI position and figure:
        [x, y] = feval(mfilename, obj, 'init', x, y);
        % Restore the current figure:
        figure(currfig);

end