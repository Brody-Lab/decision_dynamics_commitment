function [aaout1, aout2] = lunghao1_gui_aoutchange_callback(lh1, varargin)

    fignum = get(lh1, 'UserData');
    udata = get(fignum, 'UserData');
    for i=1:size(udata,1),
        eval([udata{i,1} ' = udata{i,2};']);
    end;
    
    aout1 = GetTagVal(lh1, 'AOut1');
    aout2 = GetTagVal(lh1, 'AOut2');
    
    set(aoutbutton, 'String', sprintf('Aout= %.1f  %.1f', aout1, aout2));
    drawnow;

    if nargout>0, aaout1 = aout1; end;
 
        