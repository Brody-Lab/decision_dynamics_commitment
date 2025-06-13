function [x, y] = InitRewards_Display(x, y, obj);    
%
% [x, y] = InitRewards_Display(x, y, obj);    
%
% args:    x, y                 current UI pos, in pixels
%          obj                  A locsamp3obj object
%
% returns: x, y                 updated UI pos
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    DispParam(obj, 'LeftRewards',                             0, x, y); next_row(y);
    DispParam(obj, 'RightRewards',                            0, x, y); next_row(y);
    DispParam(obj, 'Rewards',                                 0, x, y); next_row(y);
    DispParam(obj, 'Trials',                                  0, x, y); next_row(y);

    next_row(y);
        
    DispParam(obj, 'Last10',                                  0, x, y); next_row(y);
    DispParam(obj, 'Last20',                                  0, x, y); next_row(y);
    DispParam(obj, 'Last40',                                  0, x, y); next_row(y);
    DispParam(obj, 'Last80',                                  0, x, y); next_row(y);
    return;
    

    

