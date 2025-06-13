function [x, y] = InitSaving(obj, action, x, y, mychild)
%
% [x, y] = InitSaving(x, y)
%
% args:    x, y                 current UI pos, in pixels
%
% returns: x, y                 updated UI pos
%
%

GetSoloFunctionArgs;

switch action
    case 'init'
        if isempty(mychild)
            error('Invalid child object; pass the object of the child class that constructed this protocolobj instance');
        end;

        mychild = value(mychild);
        c = ['@' class(mychild)];

        EditParam(obj, 'RatName', 'ratname', x, y);
        x_old = x; next_column(x,0.5);

        gpos = gui_position(x,y);

        ToggleParam(obj, 'ASV', 1, x, y, ...
            'position',[gpos(1)+55 gpos(2) gpos(3)/5 gpos(4)], ...
            'TooltipString', 'Turns ON or OFF autosave functionality (saves every 20 trials)');
        g = get_ghandle(ASV);
        set(g,'FontSize',6, 'FontWeight','bold');
        SoloParamHandle(obj, 'asv_trials', 'value', 10);
        set_callback(ASV, {'InitSaving','change_autosave'});

        x = x_old; next_row(y);
        PushbuttonParam(obj, 'LoadSettings', x, y);   next_row(y);
        PushbuttonParam(obj, 'SaveSettings', x, y);   next_row(y);
        SoloFunction('LoadSettings', 'ro_args', {'RatName', 'mychild'});
        SoloFunction('SaveSettings', 'ro_args', {'RatName', 'mychild'});
        next_row(y, 0.5);

        PushbuttonParam(obj, 'LoadData', x, y);   next_row(y);
        if strcmp(class(mychild),'duration_discobj') || strcmp(class(mychild),'dual_discobj')
            PushbuttonParam(obj, 'LoadRealignedData', x, y);   next_row(y);
        end;
        PushbuttonParam(obj, 'SaveData', x, y);   next_row(y);
        if strcmp(class(mychild),'duration_discobj') || strcmp(class(mychild),'dual_discobj')
            SoloFunction('LoadRealignedData', 'ro_args', {'RatName', 'mychild'});
        end;
        SoloFunction('LoadData', 'ro_args', {'RatName', 'mychild'});
        SoloFunction('SaveData', 'ro_args', {'RatName', 'mychild'});
        
        InitSaving(obj, 'change_autosave');

    case 'change_autosave'
        g = get_ghandle(RatName);
        switch value(ASV)
            case 1
                set(g,'FontAngle','italic');
                set(g,'BackgroundColor',[0.6 1 0.8]);
            case 0
                set(g,'FontAngle','normal');
                set(g,'BackgroundColor','w');
            otherwise
                error('Toggle buttons should only have values of 0 or 1. What''s going on?');
        end;

    case 'autosave'
        if nargin < 3, error('Sorry, need to know n_done_trials when checking for autosave');end;              
        done_trials = value(x);  % misnomer: really mean the third argument
        if ~mod(done_trials, value(asv_trials)) && (value(ASV) > 0 )
            feval('SaveSettings', obj, 'asv', 1);
            feval('SaveData', obj, 'asv',1);
        end;
    otherwise
        error('Invalid action!');
end;


