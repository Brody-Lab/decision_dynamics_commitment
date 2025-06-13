function [x, y, Num_Bins Num2Make Blocks_Switch]=BlocksSection(obj,action,x,y);

GetSoloFunctionArgs;

switch action,
    case 'init', % ----------  INIT  -------------------------
        % main protocol window
        parentfig = gcf; figure(parentfig);
        parent_x = x; parent_y = y;

        % new popup window
        x = 5; y = 5;
        SoloParamHandle(obj, 'blocksfig', 'value', figure, 'saveable', 0);
      
         ToggleParam(obj,'Blocks_Switch', 0,x,y);next_row(y);
         set_callback({Blocks_Switch},{'SidesSection', 'make_blocks'; 'ChordSection','make_blocks'});
         
        EditParam(obj, 'BlockSize', 32,   x, y); next_row(y);
        set_callback({BlockSize},{'BlocksSection','compute_num2make'});
        EditParam(obj,'Num_Bins', 8, x,y); next_row(y);
        set(get_ghandle(Num_Bins),'Enable','off');
        num_bins = value(Num_Bins);
        SoloParamHandle(obj, 'NumSamples', 'value', value(BlockSize) / num_bins);
        SoloParamHandle(obj, 'Num2Make', 'value', zeros(num_bins,1)); next_row(y);

        default_weight = 1 / num_bins;
        col1_x = x;
        for idx = num_bins:-1:1
            EditParam(obj,sprintf('Wt_%i',idx), default_weight,x,y,...
                'position', [x y 120 20],'labelfraction',0.65);
            
            ToggleParam(obj,sprintf('Force_%i',idx), 0,x,y,'position',[x+100 y 120 20]);
            set_callback({eval(sprintf('Force_%i', idx))}, ...
                {'BlocksSection','set_weights';...
                'SidesSection','make_blocks'; ...
                'ChordSection','make_blocks'; ... 
                });
            next_row(y);
            x=col1_x;
        end;

        SubheaderParam(obj, 'blocks_sbh', 'Blocks Section', x, y);next_row(y);

        x = parent_x; y = parent_y; figure(parentfig); % make master protocol figure gcf
        MenuParam(obj, 'BlocksView', {'hidden', 'view'}, 1, x, y); next_row(y);
        set_callback({BlocksView}, {'BlocksSection', 'blocks_param_view'});

        BlocksSection(obj,'set_weights');

        % wrap up child figure stuff and return control to parent
        set(value(blocksfig), ...
            'Visible', 'off', 'MenuBar', 'none', 'Name', 'Blocks Section', ...
            'NumberTitle', 'off', 'CloseRequestFcn', ...
            'BlocksSection(obj,''blocks_param_hide'')');
        set(value(blocksfig), 'Position', [1082  91    265  281]);


    case 'set_weights'
        %      get forced weights
        wt_so_far = 0;
        n2m = value(Num2Make);
        pos=0;
        for idx = 1:value(Num_Bins)
            curr= sprintf('Force_%i',idx);
            currwt = sprintf('Wt_%i',idx);
            if value(eval(curr)) > 0,
                wt_so_far = wt_so_far + value(eval(currwt));
                pos = pos+1;
                n2m(idx) = round(value(eval(currwt)) * value(BlockSize));
            end;
        end;
        left_over = (1-wt_so_far)/(value(Num_Bins)-pos);

        for idx = 1:value(Num_Bins)
            curr= sprintf('Force_%i',idx);
            currwt = sprintf('Wt_%i',idx);
            if value(eval(curr)) ==0 % somebody to be set to default weight
                eval([currwt '.value = left_over;']);
                n2m(idx) = round( left_over * value(BlockSize) );
            end;
        end;
        % left_over = (1-wt_so_far)/(length(weights)-length(pos));
        % weights(setdiff(1:length(weights), pos)) = left_over;
        while sum(n2m) < value(BlockSize)
            n2m(end) = n2m(end)+1;
        end;
        while sum(n2m) > value(BlockSize)
            n2m(end) = n2m(end)-1;
        end;

        Num2Make.value = n2m;

        value(Num2Make)                

    case 'compute_num2make'
        n2m = value(Num2Make);
        for idx = 1:value(Num_Bins)
            currwt = sprintf('Wt_%i',idx);
            n2m(idx) = round(value(eval(currwt)) * value(BlockSize));
        end;
        
         while sum(n2m) < value(BlockSize)
            n2m(end) = n2m(end)+1;
        end;
        while sum(n2m) > value(BlockSize)
            n2m(end) = n2m(end)-1;
        end;
        
        Num2Make.value = n2m;
        
        value(Num2Make)
        
        SidesSection(obj,'make_blocks');
        ChordSection(obj,'make_blocks');
        
        
    case 'blocks_param_view',	% --- blocks_param_VIEW ---
        switch value(BlocksView)
            case 'hidden',
                set(value(blocksfig), 'Visible', 'off');
            case 'view',
                set(value(blocksfig), 'Visible', 'on');
        end;

    case 'blocks_param_hide',
        BlocksView.value = 'hidden';
        set(value(blocksfig), 'Visible', 'off');


    otherwise
        error('invalid action');
end;
