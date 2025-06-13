function [x, y,  VpdList, VpdSmall, VpdLargeMin, VpdLargeMean]= ...
    VpdsSection(obj, action, x, y);

GetSoloFunctionArgs;
% SoloFunction('VpdsSection', 'rw_args',{}, ...
%   'ro_args', {'n_done_trials', 'n_started_trials', 'maxtrials'});

persistent vpd_small vpd_large_min vpd_large_mean %Thanks to these params,
% vpd change in GUI does not reflect to change in state matrix.
%instead requiring to push change_vpds button.

switch action,
    case 'init',
        %VpdsSection Parameters Window
        fig=gcf;
        MenuParam(obj, 'VpdParams', {'view', 'hidden'}, 1, x,y); next_row(y);
        set_callback(VpdParams, {'VpdsSection', 'vpd_param_view'});
        oldx=x; oldy=y; x=5; y=5;
        SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable',0);
        
        %%GUI
        %VpdsSection Parameters
        EditParam(obj, 'VpdLargeMean', 0.1, x,y); next_row(y);
        set_callback(VpdLargeMean, {'VpdsSection', 'large_mean'});
        EditParam(obj, 'VpdLargeMin', 0.1, x, y);  next_row(y);
        set_callback(VpdLargeMin, {'VpdsSection', 'large_min'});
        EditParam(obj, 'VpdSmall', 0.001, x, y);  next_row(y);
        set_callback(VpdSmall, {'VpdsSection', 'small'});
        
        vpd_small=value(VpdSmall);
        vpd_large_min=value(VpdLargeMin);
        vpd_large_mean=value(VpdLargeMean);
        
        %change buttun for
        PushButtonParam(obj, 'change_vpds', x,y);
        set_callback(change_vpds,{'VpdsSection', 'change'});

        set(value(myfig), ...
            'Visible', 'on', 'MenuBar', 'none', 'Name', 'Vpd Parameters', ...
            'NumberTitle', 'off', 'CloseRequestFcn', ...
            ['VpdsSection(' class(obj) '(''empty''), ''vpd_param_hide'')']);
        
        screen_size = get(0, 'ScreenSize');
        set(value(myfig),'Position',[670 screen_size(4)-480, 210 80]);
        
        x=oldx; y=oldy; figure(fig);
        %%%End of GUI

        %Make VpdList
        SoloParamHandle(obj, 'VpdList', 'value', zeros(2, maxtrials));
        VpdList(1,1)=vpd_small;
        VpdList(2,1)= ...
            exprnd(vpd_large_mean-vpd_large_min)+vpd_large_min;

        %End of case 'init'

    case 'change',
        vpd_small=value(VpdSmall);
        vpd_large_min=value(VpdLargeMin);
        vpd_large_mean=value(VpdLargeMean);
        
    case 'update_vpdlist', %trial_finished_action
        VpdList(1,n_done_trials+1)=vpd_small;
        VpdList(2,n_done_trials+1)= ...
            exprnd(vpd_large_mean-vpd_large_min)+vpd_large_min;

    case 'small',
        if VpdSmall<=0,
            VpdSmall.value=0.001;
            warning('Vpd should be longer than 0s');
        end;

    case 'large_min',
        if VpdLargeMin <= 0,
            VpdLargeMin.value=0.001;
            warning('Vpd should be longer than 0s');
        elseif VpdLargeMin >VpdLargeMean,
            VpdLargeMean.value=value(VpdLargeMin);
            warning('Vpd_Min should be equal to/shorter than Vpd_Mean');
        end;

    case 'large_mean',
        if VpdLargeMean<=0,
            VpdLargeMean.value=0.001;
            warning('Vpd should be longer than 0s');
        elseif VpdLargeMean<VpdLargeMin
            VpdLargeMin.value=value(VpdLargeMean);
            warning('Vpd_Mean should be equal to/longer than Vpd_Min');
        end;

    case 'vpd_param_view',
        switch value(VpdParams)
            case 'hidden',
                set(value(myfig), 'Visible', 'off');
            case 'view',
                set(value(myfig), 'Visible', 'on');
        end;

    case 'vpd_param_hide',
        VpdParams.value='hidden';
        set(value(myfig), 'Visible', 'off');

    case 'delete'
        delete(value(myfig));

    otherwise,
        error(['Don''t know how to deal with action ' action]);

end;