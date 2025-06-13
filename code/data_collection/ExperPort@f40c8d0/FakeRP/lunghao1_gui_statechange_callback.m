function [] = lunghao1_gui_statechange_callback(lh1, varargin)

    fignum = get(lh1, 'UserData');
    udata = get(fignum, 'UserData');
    for i=1:size(udata,1),
        eval([udata{i,1} ' = udata{i,2};']);
    end;
    
    set(statebutton, 'String', ['State = ' sprintf('%g', GetTagVal(lh1, 'State'))]);
    set(timerbutton, 'String', ['Timer = ' sprintf('%g', GetTagVal(lh1, 'Timer'))]);

    tagbuttons = {'Dio_Hi_Dur' 'Dio_Hi_Bits' 'Bits_HighVal' 'AOBits_HighVal' 'running'  'EventCounter'};
    for i=1:length(tagbuttons)
        thisbutton = eval(tagbuttons{i});
        set(thisbutton, 'String', [tagbuttons{i} '=' sprintf('%g', GetTagVal(lh1, tagbuttons{i}))]);
    end;
    
    drawnow;
