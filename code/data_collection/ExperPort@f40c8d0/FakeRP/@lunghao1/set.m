function [] = set(lh1, varargin)

    lh1 = get_mylh1(lh1);
    
    for i=1:2:length(varargin),
        switch varargin{i},
            case {'UserData', 'statechange_callback', 'doutchange_callback', 'aoutchange_callback'}
                lh1.(varargin{i}) = varargin{i+1};
                
            case 'DIO_Bypass1Active',
                lh1.DIO_Bypass1.active = varargin{i+1};
                lh1.DOut = bitor(lh1.DIO_Out(lh1.StateNow+1), ...
                    bitor(lh1.DIO_Bypass1.active*lh1.Dio_Hi_Bits, lh1.DIO_Bypass2*lh1.Bits_HighVal));
                save_mylh1(lh1);
                check_doutchange_callback(lh1);
                return;

            otherwise,
                error(['Don''t know how to set ' varargin{i}]);
        end;    
    end;    
    save_mylh1(lh1);
    
    