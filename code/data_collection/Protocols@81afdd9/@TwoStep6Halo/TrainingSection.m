% [x, y] = ParamsSection(obj, action, x, y)
%
% Section that takes care of YOUR HELP DESCRIPTION
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI.
%


function [x, y] = TrainingSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    %% init
    case 'init',
        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
        
        ToggleParam(obj,'Stimulation',1,x,y,'OnString','Stimulation','OffString','Stimulation');
        set_callback(Stimulation, {mfilename, 'Stimulation'});
        next_row(y);
        ToggleParam(obj,'Full_Task',0,x,y,'OnString','Full Task','OffString','Full Task');
        set_callback(Full_Task, {mfilename, 'full_task'});
        next_row(y);
        ToggleParam(obj,'One_Step',0,x,y,'OnString','One Step','OffString','One Step');
        set_callback(One_Step, {mfilename, 'one_step'});
        next_row(y);
        ToggleParam(obj,'Side_Poke',0,x,y,'OnString','Side Poke','OffString','Side Poke');
        set_callback(Side_Poke, {mfilename, 'side_poke'});
        next_row(y);
        ToggleParam(obj,'Direct_Delivery',0,x,y,'OnString','Direct Delivery','OffString','Direct Delivery');
        set_callback(Direct_Delivery, {mfilename, 'direct_delivery'});
        next_row(y);
        
       
        SubheaderParam(obj, 'title', 'Training Stage', x, y);
        next_row(y, 1.5);
        
        
    case 'Stimulation'
        Stimulation.value = 1;
        Full_Task.value = 0;
        One_Step.value = 0;
        Side_Poke.value = 0;
        Direct_Delivery.value = 0;
        TimingSection(obj,'full_task');
        ParamsSection(obj,'full_task');
    case 'full_task'
        Stimulation.value = 0;
        Full_Task.value = 1;
        One_Step.value = 0;
        Side_Poke.value = 0;
        Direct_Delivery.value = 0;
        TimingSection(obj,'full_task');
        ParamsSection(obj,'full_task');
    case 'one_step'
        Stimulation.value = 0;
        Full_Task.value = 0;
        One_Step.value = 1;
        Side_Poke.value = 0;
        Direct_Delivery.value = 0;
        TimingSection(obj,'one_step');
        ParamsSection(obj,'one_step');
    case 'side_poke'
        Stimulation.value = 0;
        Full_Task.value = 0;
        One_Step.value = 0;
        Side_Poke.value = 1;
        Direct_Delivery.value = 0;
        TimingSection(obj,'side_poke');
        ParamsSection(obj,'side_poke');
    case 'direct_delivery'
        Stimulation.value = 0;
        Full_Task.value = 0;
        One_Step.value = 0;
        Side_Poke.value = 0;
        Direct_Delivery.value = 1;
        TimingSection(obj,'direct_delivery');
        ParamsSection(obj,'direct_delivery');
        
    case 'get_training_stage'
        if value(Stimulation)
            x = 'stimulation';
        elseif value(Full_Task)
            x = 'full_task';
        elseif value(One_Step);
            x = 'one_step';
        elseif value(Side_Poke);
            x = 'side_poke';
        elseif value(Direct_Delivery)
            x = 'direct_delivery';
        else
            error('Invalid training stage');
        end
        
    case 'double_trials'
        
        if value(Stimulation)
            x = true;
        else
            x = false;
        end
        
    case 'new_training_stage' % Call this when the training stage has been changed (or might have been changed) but you don't know what it's changed to
        training_stage = TrainingSection(obj,'get_training_stage');
        TrainingSection(obj,training_stage);
        
    otherwise,
        warning('Unknown action! "%s"\n', action);
        
end



end


