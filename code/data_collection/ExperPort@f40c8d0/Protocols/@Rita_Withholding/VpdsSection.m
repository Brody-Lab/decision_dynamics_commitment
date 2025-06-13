function [x, y, ...
            VpdSmall_Current, VpdLarge_Current, ...
            VpdSmall, VpdLargeMin, VpdLargeMean, Adaptive]= ...
    VpdsSection(obj, action, x, y)

GetSoloFunctionArgs;

% persistent vpd_small vpd_large_min vpd_large_mean %Thanks to these params,
% % vpd change in GUI does not reflect to change in state matrix.
% %instead requiring to push change_vpds button.

switch action,
    case 'init',
        %VpdsSection Parameters Window
%         fig=gcf;
%         MenuParam(obj, 'VpdParams', {'view', 'hidden'}, 1, x,y); next_row(y);
%         set_callback(VpdParams, {'VpdsSection', 'vpd_param_view'});
%         oldx=x; oldy=y; x=5; y=5;
%         SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable',0);
        
        %%GUI
        %VpdsSection Parameters
        MenuParam(obj, 'Adaptive', {'On', 'Off'}, 1, x, y);next_row(y);
        EditParam(obj, 'VpdLargeMean', 0.1, x,y); next_row(y);
        set_callback(VpdLargeMean, {'VpdsSection', 'large_mean'});
        EditParam(obj, 'VpdLargeMin', 0.1, x, y);  next_row(y);
        set_callback(VpdLargeMin, {'VpdsSection', 'large_min'});
        EditParam(obj, 'VpdSmall', 0.0001, x, y);  next_row(y);
        set_callback(VpdSmall, {'VpdsSection', 'small'});
        DispParam(obj, 'VpdLarge_Current', 0.1, x, y);  next_row(y);
        DispParam(obj, 'VpdSmall_Current', 0.0001 ,x, y);   next_row(y);
        SubHeaderParam(obj, 'VpdsParams', 'Valid Poke Duration Parameters',x,y);   next_row(y);
        
        VpdsSection(obj, 'prepare_next_trial');
        
    case 'prepare_next_trial',
        VPD_SMALL = value(VpdSmall);
        VPD_LARGE_MIN = value(VpdLargeMin);
        VPD_LARGE_MEAN = value(VpdLargeMean);
        VpdSmall_Current.value = VPD_SMALL;
        VpdLarge_Current.value= ...
            exprnd(VPD_LARGE_MEAN-VPD_LARGE_MIN) + VPD_LARGE_MIN;
        
    case 'small',
        if value(VpdSmall)<=0,
            VpdSmall.value=0.0001;
            warning('Vpd should be longer than 0s');           
        elseif value(VpdSmall)>value(VpdLargeMean),
            VpdLargeMean.value = value(VpdSmall);
            VpdLargeMin.value = value(VpdSmall);
            warning('VpdSmall should not be longer than VpdLargeMin');
        elseif value(VpdSmall)>value(VpdLargeMin),
            VpdLargeMin.value = value(VpdSmall);
            warning('VpdSmall should not be longer than VpdLargeMin');
        end;

    case 'large_min',
        if value(VpdLargeMin) <= 0,
            VpdLargeMin.value=0.0001;
            warning('Vpd should be longer than 0s');
        elseif value(VpdLargeMin)<value(VpdSmall),
            VpdSmall.value = VpdLargeMin;
            warning('VpdLargeMin should not be shorter than VpdSmall');
        elseif value(VpdLargeMin) > value(VpdLargeMean),
            VpdLargeMean.value=value(VpdLargeMin);
            warning('VpdMin should not be longer than VpdLargeMean');
        end;

    case 'large_mean',
        if value(VpdLargeMean)<=0,
            VpdLargeMean.value=0.0001;
            warning('Vpd should be longer than 0s');
        elseif value(VpdLargeMean)<value(VpdSmall),
            VpdSmall.value = value(VpdLargeMean);
            VpdLargeMin.value = value(VpdLargeMean);
            warning('VpdMean should not be shorter than VpdLargeMin');
        elseif value(VpdLargeMean)<value(VpdLargeMin),
            VpdLargeMin.value=value(VpdLargeMean);
            warning('VpdMean should not be shorter than VpdLargeMin');
        end;
        
    otherwise,
        error(['Don''t know how to deal with action ' action]);

end;