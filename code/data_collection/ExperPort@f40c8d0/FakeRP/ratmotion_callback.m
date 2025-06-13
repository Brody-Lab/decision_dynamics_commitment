function [] = ratmotion_callback(myobj, event, leftpos, centerpos, rightpos, outpos)
% set(gcf, 'WindowButtonMotionFcn', {@ratmotion_callback, get(leftbutton, 'Position'), get(centerbutton, 'Position'), get(rightbutton, 'Position'), get(outbutton, 'Position')}, 'Interruptible', 'off', 'BusyAction', 'cancel')
    persistent position
    if isempty(position), position = 'Out'; end;
    
    oldpos = position;
  
    set(myobj, 'Units', 'normalized');
    currpt = get(myobj, 'CurrentPoint');

    newpos = oldpos;
    if iswithin(currpt, leftpos),   newpos = 'Left';   end;
    if iswithin(currpt, centerpos), newpos = 'Center'; end;
    if iswithin(currpt, rightpos),  newpos = 'Right';  end;
    if iswithin(currpt, outpos),    newpos = 'Out';    end;
    position = newpos;
    
    if strcmp(newpos, oldpos), return; end;  % nothing's changed
    if ~strcmp(oldpos, 'Out') & ~strcmp(newpos, 'Out'), return; end; % if not Out, only legal act is to go Out

    % fprintf(1, 'Was in %s, now entering %s\n', oldpos, newpos);
    udata = get(myobj, 'UserData');
    for i=1:size(udata,1),
        eval([udata{i,1} ' = udata{i,2};']);
    end;

    button = eval([lower(newpos) 'button']);
    set([leftbutton;centerbutton;rightbutton;outbutton], 'BackgroundColor', 'g');
    set(button, 'BackgroundColor', 'c');
    drawnow;
    
    % Store the current rat position in the UserData cell array of the figure
    udata{find(strcmp('pos', udata(:,1))), 2} = newpos;
    set(myobj, 'UserData', udata);

    % Now the callbacks to the lunghao1 machine
    if strcmp(oldpos, 'Out'), 
        direction = 'In'; port = newpos;
    else 
        direction = 'Out'; port = oldpos;
    end;
    
    % fprintf(1, 'Calling %s\n', [port direction]);
    feval([port direction], lh1);
    
    
function [b] = iswithin(currpt, position)

    if position(1) <= currpt(1) & currpt(1) <= position(1)+position(3)  &  ...
            position(2) <= currpt(2) & currpt(2) <= position(2)+position(4),
        b = 1;
    else
        b = 0;
    end;
    
    