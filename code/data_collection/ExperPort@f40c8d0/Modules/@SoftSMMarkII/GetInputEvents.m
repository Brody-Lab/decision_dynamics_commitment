% mapping = GetInputEvents(sm)
%                Returns the input event mapping vector for this FSM.  This
%                vector was set with a call to SetInputEvents (or was 
%                default).  The format for this vector is described in
%                SetInputEvents().
function map = GetInputEvents(sm)

    map = sm.UpAndComingInputEvents;
    return;
    