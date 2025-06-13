% This function evaluates the events of the last trial and updates the
% variables containing performance information.
%
% Santiago Jaramillo - 2007.05.15

function EvaluateTrialEvents(obj)

persistent lasttrialeventcounter
%%%%%%%% FIX THIS WAY OF INITIALIZING %%%%%%%%%
if(length(lasttrialeventcounter)==0)
    lasttrialeventcounter = 1;
end

GetSoloFunctionArgs; % See PROTOCOLNAMEobj.m for the list of
                     % variables passed to this function.

% -- Get all events from last trial --
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HORRIBLE HACK to be able to use the simulator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global fake_rp_box;
if fake_rp_box==2,
    FSMengine = rpbox('getstatemachine');
    %FSMengine = SetStateMatrix(FSMengine, value(StateMatrix));
    eventcounter=GetEventCounter(FSMengine);
    %keyboard
    StatesAndEvents=GetEvents(FSMengine,lasttrialeventcounter,eventcounter);
    lasttrialeventcounter = eventcounter;
    disp(StatesAndEvents);
else
    StatesAndEvents = GetParam('rpbox', 'event', 'user');
    %fprintf('Event = %d\n',Event);
    disp(StatesAndEvents);
end

% -- Test if trial was a hit --
RewardStatesThisTrial = find(StatesAndEvents(:,1)== RealTimeStates.left_reward | ...
                             StatesAndEvents(:,1)== RealTimeStates.right_reward);
if(isempty(RewardStatesThisTrial))
    % -- Error or Miss trial --
    HitHistory(value(NdoneTrials)) = 0;
    %%%ErrorHistory(value(NdoneTrials)) = 1;
else
    % -- Hit trial --
    HitHistory(value(NdoneTrials)) = 1;
    %%%ErrorHistory(value(NdoneTrials)) = 0;
end

%%%%%%%%%%%% FINISH THIS %%%%%%%%%%%%%%%
