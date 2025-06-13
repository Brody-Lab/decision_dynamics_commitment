function [] = lunghao1_gui_doutchange_callback(lh1, varargin)

    fignum = get(lh1, 'UserData');
    udata = get(fignum, 'UserData');
    for i=1:size(udata,1),
        eval([udata{i,1} ' = udata{i,2};']);
    end;
    
    dout = GetTagVal(lh1, 'DOut');
    pdout = bitget(dout, 8:-1:1);
    doutstr = ' '*ones(1,8); for i=1:8, doutstr(i) = sprintf('%g', pdout(i)); end;
    
    if pdout(8), set(leftwater,  'Visible', 'on'); else set(leftwater,  'Visible', 'off'); end;
    if pdout(7), set(rightwater, 'Visible', 'on'); else set(rightwater, 'Visible', 'off'); end;
    
    set(doutbutton, 'String', ['Dout = ' doutstr]);
    drawnow;
