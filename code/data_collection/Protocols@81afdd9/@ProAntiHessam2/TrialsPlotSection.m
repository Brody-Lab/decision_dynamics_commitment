% A template protocol that does almost nothing-- each trial
% just waits a second and then ends.
%

function [x y] = TrialsPlotSection(obj, action, x, y, varargin)


GetSoloFunctionArgs(obj);

switch action

%% case init
    case 'init',
        
        % plot of side choices history at top of window
        pos = get(gcf, 'Position');
        SoloParamHandle(obj, 'myaxes', 'saveable', 0, 'value', axes);
        set(value(myaxes), 'Units', 'pixels');
        set(value(myaxes), 'Position', [90 pos(4)-140 pos(3)-130 100]);
        
        xlabel('trial number');
        SoloParamHandle(obj, 'previous_plot', 'saveable', 0);
        
%% update_plot
    case 'update_plot',
        if ~isempty(value(previous_plot)), delete(previous_plot(:)); previous_plot.value = []; end; %#ok<NODEF>
        if isempty(side_history), return; end;
        
        hb = line(length

            hb = line(length(ps), sidemap(find(stim_list==ps(end))), 'Parent', value(myaxes));
            set(hb, 'Color', 'b', 'Marker', '.', 'LineStyle', 'none');
        else
            hb = [];
        end
        
        xgreen = find(correct_history==1);
        xred   = find(correct_history==0);
        xblack = find(isnan(value(hit_history)));
        ygreen = zeros(size(xgreen));
        yred   = zeros(size(xred));
        yblack = zeros(size(xblack));
        for x = 1:length(stim_list),
            i = stim_list(x);
            i_green = find(ps(xgreen) == i);
            ygreen(i_green) = sidemap(x); %#ok<FNDSB>
            i_red = find(ps(xred) == i);
            yred(i_red) = sidemap(x); %#ok<FNDSB>
            i_black = find(ps(xblack) == i);
            yblack(i_black) = sidemap(x); %#ok<FNDSB>
        end;
        
        hg = line(xgreen, ygreen, 'Parent', value(myaxes));
        set(hg, 'Color', 'g', 'Marker', '.', 'LineStyle', 'none');
        hr = line(xred, yred, 'Parent', value(myaxes));
        set(hr, 'Color', 'r', 'Marker', '.', 'LineStyle', 'none');
        hk = line(xblack, yblack, 'Parent', value(myaxes));
        set(hk, 'Color', 'k', 'Marker', '.', 'LineStyle', 'none');
        
        previous_plot.value = [hb; hr; hg; hk];
        
        minx = 0;
        maxx = n_done_trials + 2;
        set(value(myaxes), 'XLim', [minx, maxx]);
        set(value(myaxes), 'YLim', [min(sidemap)-0.5 max(sidemap)+0.5], 'YGrid', 'on');
        nrows = length(unique(sidemap));
        ticks = cell(nrows, 1);
        for x = 1:length(stim_list),
            if LeftRightOnly==0,
                ticks{find(stim_list==sidemap(x),1)} = [sides{x} ', ' sprintf([soundname ' %g'], stim_list(x))];
            else
                if sides{x}=='l', ticks{find(stim_list==sidemap(x),1)} = 'LEFT';
                else ticks{find(stim_list==sidemap(x),1)} = 'RIGHT';
                end;
            end;
        end
        set(value(myaxes), 'YTick', unique(sidemap), ...
            'YTickLabel', ticks, ...
            'YLim', [min(sidemap)-0.5 max(sidemap)+0.5]);
        set(get(value(myaxes), 'YLabel'), 'String', 'sounds');
        pause(0.1);
        
        
%% case close
    case 'close'
        currfig = double(gcf);
        
        % Get the original GUI position and figure:
        x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
        my_figure = my_window_info(3);
        
        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^' mfilename]);
        delete(my_figure);
        
        % Restore the current figure:
        if my_figure~=currfig,
            figure(currfig);
        end;
        
end




