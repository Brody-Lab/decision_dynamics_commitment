function [] = ratpos_callback()

    button = gcbo;
    fignum = get(button, 'Parent');
    udata = get(fignum, 'UserData');
    for i=1:size(udata,1),
        eval([udata{i,1} ' = udata{i,2};']);
    end;

    oldpos = pos;
    newpos = get(button, 'String'); 
    if strcmp(newpos, oldpos), return; end;  % nothing's changed
    if ~strcmp(oldpos, 'Out') & ~strcmp(newpos, 'Out'), return; end; % if not Out, only legal act is to go Out
    
    % Ok, legal action : proceed.
    
    % Set every position button to green; and the pressed button to cyan
    set([leftbutton;centerbutton;rightbutton;outbutton], 'BackgroundColor', 'g');
    set(button, 'BackgroundColor', 'c');
    drawnow;
    
    % Store the current rat position in the UserData cell array of the figure
    udata{find(strcmp('pos', udata(:,1))), 2} = newpos;
    set(fignum, 'UserData', udata);
    
    % Now the callbacks to the lunghao1 machine
    if strcmp(oldpos, 'Out'), 
        direction = 'In'; port = newpos;
    else 
        direction = 'Out'; port = oldpos;
    end;
    
    feval([port direction], lh1);
    
    
    