function DrawFrames(axes1, handles)

set(handles.trackbutton, 'Enable', 'off');

record_index = str2num(get(handles.frameindex, 'String'));
record_index = round(record_index);
set(handles.frameindex, 'String', num2str(record_index));
set(handles.frameslider, 'Value', record_index);

ts = handles.TimeStamps(record_index);
set(handles.tsdisplay, 'String', sprintf('timestamp: %d', ts));

axes(axes1); cla; 
set(axes1, 'XLim', [0 640], 'YLim', [0 480]);
if record_index <= handles.extracted,
    hold on;


    rectangle('Position', handles.RigPos, 'EdgeColor', 0.8*[1 1 1]);

    num_targets = handles.valid_targets(record_index);

    for target_index = 1:num_targets,
        x_coordinate = handles.x(record_index, target_index);
        y_coordinate = handles.y(record_index, target_index);

        str_color = GetColorString(handles.color(record_index, target_index, 1:7));

        plot(x_coordinate, y_coordinate, str_color);
    end;
end;

if record_index <= length(handles.tracked) && handles.tracked(record_index) == 1,
    if record_index <= cols(handles.head) && handles.head(1, record_index) ~= 0,
        % plot estimated head position
        x_head = handles.head(1, record_index);
        y_head = handles.head(2, record_index);
        plot(x_head, y_head, 'r+');
        L = 50; % length of line, in pixels
        Dx = sqrt(L^2/(1 + handles.head(3, record_index)^2));
        Dy = handles.head(3, record_index) * Dx;
        line([x_head-Dx/2 x_head+Dx/2], [y_head-Dy/2 y_head+Dy/2], 'Color', 'r');
    end;

    here = handles.head(:, record_index);
    str = sprintf('x = %2.2f \ny = %2.2f \ntheta = %2.2f \nx_dot = %2.2f \ny_dot = %2.2f \ntheta_dot = %2.2f', ...
        here(1), here(2), here(3), here(4), here(5), here(6));
    set(handles.headinfo, 'String', str);
else
    set(handles.headinfo, 'String', '');
end;