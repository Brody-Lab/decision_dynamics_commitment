function [x, y, ...
            VpdSmall_Current_N, VpdLarge_Current_N, ...
            VpdSmall_N, VpdLargeMin_N, VpdLargeMean_N, Adaptive_N, ...
            VpdSmall_Current_L, VpdLarge_Current_L, ...
            VpdSmall_L, VpdLargeMin_L, VpdLargeMean_L, Adaptive_L]= ...
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
        MenuParam(obj, 'Adaptive_N', {'On', 'Off'}, 1, x, y);
        MenuParam(obj, 'Adaptive_L', {'On', 'Off'}, 1, x, y);next_row(y);
        EditParam(obj, 'VpdLargeMean_N', 0.1, x,y);
        set_callback(VpdLargeMean_N, {'VpdsSection', 'large_mean_n'});
        EditParam(obj, 'VpdLargeMean_L', 0.1, x,y); next_row(y);
        set_callback(VpdLargeMean_L, {'VpdsSection', 'large_mean_l'});
        EditParam(obj, 'VpdLargeMin_N', 0.1, x, y);
        set_callback(VpdLargeMin_N, {'VpdsSection', 'large_min_n'});
        EditParam(obj, 'VpdLargeMin_L', 0.1, x, y);  next_row(y);
        set_callback(VpdLargeMin_L, {'VpdsSection', 'large_min_l'});
        EditParam(obj, 'VpdSmall_N', 0.0001, x, y);
        set_callback(VpdSmall_N, {'VpdsSection', 'small_n'});
        EditParam(obj, 'VpdSmall_L', 0.0001, x, y);  next_row(y);
        set_callback(VpdSmall_L, {'VpdsSection', 'small_l'});
        DispParam(obj, 'VpdLarge_Current_N', 0.1, x, y);
        DispParam(obj, 'VpdLarge_Current_L', 0.1, x, y);  next_row(y);
        DispParam(obj, 'VpdSmall_Current_N', 0.0001 ,x, y);
        DispParam(obj, 'VpdSmall_Current_L', 0.0001 ,x, y);   next_row(y);
        SubHeaderParam(obj, 'VpdsParams', 'Valid Poke Duration Parameters',x,y);   next_row(y);
        
        set([get_ghandle(Adaptive_L) get_lhandle(Adaptive_L) ...
             get_ghandle(VpdLargeMean_L) get_lhandle(VpdLargeMean_L) ...
             get_ghandle(VpdLargeMin_L) get_lhandle(VpdLargeMin_L) ...
             get_ghandle(VpdSmall_L) get_lhandle(VpdSmall_L) ...
             get_ghandle(VpdLarge_Current_L) get_lhandle(VpdLarge_Current_L) ...
             get_ghandle(VpdSmall_Current_L) get_lhandle(VpdSmall_Current_L)], ...
             'visible','off');

        VpdsSection(obj, 'prepare_next_trial');
        
    case 'prepare_next_trial',
        VPD_SMALL_N = value(VpdSmall_N);
        VPD_LARGE_MIN_N = value(VpdLargeMin_N);
        VPD_LARGE_MEAN_N = value(VpdLargeMean_N);
        VpdSmall_Current_N.value = VPD_SMALL_N;
        VpdLarge_Current_N.value= ...
            exprnd(VPD_LARGE_MEAN_N-VPD_LARGE_MIN_N) + VPD_LARGE_MIN_N;

        VPD_SMALL_L = value(VpdSmall_L);
        VPD_LARGE_MIN_L = value(VpdLargeMin_L);
        VPD_LARGE_MEAN_L = value(VpdLargeMean_L);      
        VpdSmall_Current_L.value = VPD_SMALL_L;
        VpdLarge_Current_L.value= ...
            exprnd(VPD_LARGE_MEAN_L-VPD_LARGE_MIN_L) + VPD_LARGE_MIN_L;
        
    case 'small_n',
        if value(VpdSmall_N)<=0,
            VpdSmall_N.value=0.0001;
            warning('Vpd should be longer than 0s');           
        elseif value(VpdSmall_N)>value(VpdLargeMean_N),
            VpdLargeMean_N.value = value(VpdSmall_N);
            VpdLargeMin_N.value = value(VpdSmall_N);
            warning('VpdSmall should not be longer than VpdLargeMin');
        elseif value(VpdSmall_N)>value(VpdLargeMin_N),
            VpdLargeMin_N.value = value(VpdSmall_N);
            warning('VpdSmall should not be longer than VpdLargeMin');
        end;

    case 'large_min_n',
        if value(VpdLargeMin_N) <= 0,
            VpdLargeMin_N.value=0.0001;
            warning('Vpd should be longer than 0s');
        elseif value(VpdLargeMin_N)<value(VpdSmall_N),
            VpdSmall_N.value = VpdLargeMin_N;
            warning('VpdLargeMin should not be shorter than VpdSmall');
        elseif value(VpdLargeMin_N) > value(VpdLargeMean_N),
            VpdLargeMean_N.value=value(VpdLargeMin_N);
            warning('VpdMin should not be longer than VpdLargeMean');
        end;

    case 'large_mean_n',
        if value(VpdLargeMean_N)<=0,
            VpdLargeMean_N.value=0.0001;
            warning('Vpd should be longer than 0s');
        elseif value(VpdLargeMean_N)<value(VpdSmall_N),
            VpdSmall_N.value = value(VpdLargeMean_N);
            VpdLargeMin_N.value = value(VpdLargeMean_N);
            warning('VpdMean should not be shorter than VpdLargeMin');
        elseif value(VpdLargeMean_N)<value(VpdLargeMin_N),
            VpdLargeMin_N.value=value(VpdLargeMean_N);
            warning('VpdMean should not be shorter than VpdLargeMin');
        end;
        
    case 'small_l',
        if value(VpdSmall_L)<=0,
            VpdSmall_L.value=0.0001;
            warning('Vpd should be longer than 0s');           
        elseif value(VpdSmall_L)>value(VpdLargeMean_L),
            VpdLargeMean_L.value = value(VpdSmall_L);
            VpdLargeMin_L.value = value(VpdSmall_L);
            warning('VpdSmall should not be longer than VpdLargeMin');
        elseif value(VpdSmall_L)>value(VpdLargeMin_L),
            VpdLargeMin_L.value = value(VpdSmall_L);
            warning('VpdSmall should not be longer than VpdLargeMin');
        end;

    case 'large_min_l',
        if value(VpdLargeMin_L) <= 0,
            VpdLargeMin_L.value=0.0001;
            warning('Vpd should be longer than 0s');
        elseif value(VpdLargeMin_L)<value(VpdSmall_L),
            VpdSmall_L.value = VpdLargeMin_L;
            warning('VpdLargeMin should not be shorter than VpdSmall');
        elseif value(VpdLargeMin_L) > value(VpdLargeMean_L),
            VpdLargeMean_L.value=value(VpdLargeMin_L);
            warning('VpdMin should not be longer than VpdLargeMean');
        end;

    case 'large_mean_l',
        if value(VpdLargeMean_L)<=0,
            VpdLargeMean_L.value=0.0001;
            warning('Vpd should be longer than 0s');
        elseif value(VpdLargeMean_L)<value(VpdSmall_L),
            VpdSmall_L.value = value(VpdLargeMean_L);
            VpdLargeMin_L.value = value(VpdLargeMean_L);
            warning('VpdMean should not be shorter than VpdLargeMin');
        elseif value(VpdLargeMean_L)<value(VpdLargeMin_L),
            VpdLargeMin_L.value=value(VpdLargeMean_L);
            warning('VpdMean should not be shorter than VpdLargeMin');
        end;
        
    case 'visualize_nose_poke_block_params',
        set([get_ghandle(VpdSmall_Current_N) get_lhandle(VpdSmall_Current_N) ...
             get_ghandle(VpdLarge_Current_N) get_lhandle(VpdLarge_Current_N) ...
             get_ghandle(VpdSmall_N) get_lhandle(VpdSmall_N) ...
             get_ghandle(VpdLargeMin_N) get_lhandle(VpdLargeMin_N) ...
             get_ghandle(VpdLargeMean_N) get_lhandle(VpdLargeMean_N) ... 
             get_ghandle(Adaptive_N) get_lhandle(Adaptive_N)], ...
            'visible','on');
        set([get_ghandle(VpdSmall_Current_L) get_lhandle(VpdSmall_Current_L) ...
             get_ghandle(VpdLarge_Current_L) get_lhandle(VpdLarge_Current_L) ...
             get_ghandle(VpdSmall_L) get_lhandle(VpdSmall_L) ...
             get_ghandle(VpdLargeMin_L) get_lhandle(VpdLargeMin_L) ...
             get_ghandle(VpdLargeMean_L) get_lhandle(VpdLargeMean_L) ... 
             get_ghandle(Adaptive_L) get_lhandle(Adaptive_L)], ...
            'visible','off');
        
    case 'visualize_lever_press_block_params',
        set([get_ghandle(VpdSmall_Current_N) get_lhandle(VpdSmall_Current_N) ...
             get_ghandle(VpdLarge_Current_N) get_lhandle(VpdLarge_Current_N) ...
             get_ghandle(VpdSmall_N) get_lhandle(VpdSmall_N) ...
             get_ghandle(VpdLargeMin_N) get_lhandle(VpdLargeMin_N) ...
             get_ghandle(VpdLargeMean_N) get_lhandle(VpdLargeMean_N) ... 
             get_ghandle(Adaptive_N) get_lhandle(Adaptive_N)], ...
            'visible','off');
        set([get_ghandle(VpdSmall_Current_L) get_lhandle(VpdSmall_Current_L) ...
             get_ghandle(VpdLarge_Current_L) get_lhandle(VpdLarge_Current_L) ...
             get_ghandle(VpdSmall_L) get_lhandle(VpdSmall_L) ...
             get_ghandle(VpdLargeMin_L) get_lhandle(VpdLargeMin_L) ...
             get_ghandle(VpdLargeMean_L) get_lhandle(VpdLargeMean_L) ... 
             get_ghandle(Adaptive_L) get_lhandle(Adaptive_L)], ...
            'visible','on');

    otherwise,
        error(['Don''t know how to deal with action ' action]);

end;