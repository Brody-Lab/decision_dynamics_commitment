% function sm = UpdateInputUI(sm)
%                Call this whenever the set of input events changes
%                as a result of calling SetInputEvents().  This
%                will update the UI buttons to reflect the changed
%                set of possible input events.
function sm = UpdateInputUI(sm)

sm = get(sm.Fig, 'UserData');

[m, n] = size(sm.InputEvents);
if (m > 1),
    error(['INTERNAL ERROR sm.InputEvents is not a vector!']);
end;

[mb, nb] = size(sm.InputButtons);
if (mb > 1),
    error(['INTERNAL ERROR sm.InputButtons is not a vector!']);
end;

%if (m == 0), return; end;

min_id = min(sm.InputEvents);
max_id = max(sm.InputEvents);
if (min_id < 0), min_id = -min_id; end;
if (max_id < 0), max_id = -max_id; end;
max_id = max([min_id max_id]);

if (size(sm.InputState, 2) ~= max_id),
    % delete (any) previously created graphics objects
    for i=1:nb,
        delete(sm.InputButtons(1, i));
    end;

    sm.InputState = zeros(1, max_id);

    sm.InputButtons = zeros(1, max_id);

    % we have max_id input channels..

    for i=1:max_id,
        butWidth = 1.0/max_id;
        butHeight = sm.InputButtonHeight;
        butX = butWidth * (i-1);
        butY = sm.InputButtonPos;

        theButton = ...
            uicontrol(sm.Fig, 'Style', 'ToggleButton', 'Units', ...
            'normalized', 'Position', ...
            [butX butY butWidth butHeight]);
        set([theButton], 'FontSize', 8);

        % setup the callback
        set(theButton, 'Callback', {@InputClickedCallback, sm, i}, ...
            'Interruptible', 'off', 'BusyAction', 'queue');
        sm.InputButtons(1, i) = theButton;

        RedrawInputButton(sm, i); % correctly set its state based on the
        % InputState array

    end;

end;

set(sm.Fig, 'UserData', sm);

return;
