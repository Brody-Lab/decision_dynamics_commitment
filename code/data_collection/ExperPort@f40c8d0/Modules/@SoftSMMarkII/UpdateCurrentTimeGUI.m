function sm = UpdateCurrentTimeGUI(varargin)

    if (nargin ~= 1 & nargin ~= 2),
      error('UpdateCurrentTimeGUI got wrong number of args!');
    end;

    sm = varargin{1}; 

    if (nargin == 1),
      ts = etime(clock, sm.T0);
    else
      ts = varargin{2};
    end;
    
    set(sm.TimeLabel, 'String', sprintf('%03.4f', ts));
    
    return;
