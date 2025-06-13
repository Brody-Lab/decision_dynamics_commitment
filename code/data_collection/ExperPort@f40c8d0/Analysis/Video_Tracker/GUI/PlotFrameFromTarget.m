%PlotFrameFromTarget Plot 1 frame or 1 video tracker record of target information.
%
%   nlx_targets is composed of M number nlx records by N max targets per record.
%   The function is passed 5 parameters:
%       x - an M by N matrix where M = the number of records and N = number of x coordinates per record.
%           this value represents the x coordinate of a given target.
%       y - an M by N matrix where M = the number of records and N = number of y coordinates per record.
%           this value represents the y coordinate of a given target.
%       color - an M by N by 7 matrix where M = the number of records and N = number of colors per record.
%           The 7 represents the 7 types of color information that is stored.
%           this value represents the color of a given target, or zero if that color is not present, or one if present.
%           color(:,:,1) = Raw Red
%           color(:,:,2) = Pure Red
%           color(:,:,3) = Raw Green
%           color(:,:,4) = Pure Green
%           color(:,:,5) = Raw Blue
%           color(:,:,6) = Pure Blue
%           color(:,:,7) = Luminance
%       valid_targets - a matrix containing the number of values for each N in the above variables.
%           this value represents the number of targets per record (which varies from record to record).
%       record_index - an integer representing an index into the above 4 matrices.  This represents which frame # to plot.
%
%   NOTE:  if a target is equal to zero i.e. the bitfield, then the target is empty for there wasn't any data written to it.
%
%   Author: Kevin Iamiceli
%   Date:   1/31/02
%   Co.     Neuralynx Inc.
%
%   Example:
%       Use NLX_VTRead which is a mex-file, or matlab_read.exe to read a neuralynx video tracker file into matlab.
%       >> [TS, Lights, Pixels] = NLX_VTRead('C:\Cheetah_Data\01_31_2002_8_31_04\VT1.nvt');
%
%       A who command will list the variable names in matlab
%       >> who;
%
%       Usually a good idea is to make smaller buffers from the ones read in from a file.
%       It is not recommended to do more than 1000 video tracker records at a time.
%       Using slicing to create new buffers is a great way to accomplish this.
%       >> Targets = Lights(:,1:1000);
%       The first : represents all data in that dimension, which happens to be 50 targets per record, and the 1:1000 represents 1000 records.
%       This Targets variable can now also be passed to the following function just as Lights.
%
%       Then call ExtractFromTargets, passing it the targets extracted, in this example the variable name is Lights.
%       Return parameters should include 4 fields as described above.
%       >> [x, y, color, valid_targets] = ExtractFromTargets(Lights);
%
%       Then call this function to display the targets with their appropriate color.
%       Color information is not exact, it is displayed as well as possible using matlab.
%       The Function is mainly for demostration purposes, please read all documentation within that m-file.
%       >> PlotFrameFromTarget(x, y, color,valid_targets,100);
%       or
%       >> PlotFrameFromTarget(x, y, color,valid_targets,1:100);
%
%----------------------------------------------------------------------------------------------------------------------
%   This function plots 1 frame of targets from a video tracker record.  The user must specify the index for the record
%   in the array passed to the function.  
%----------------------------------------------------------------------------------------------------------------------
function PlotFrameFromTarget( x,y,color,valid_targets,record_index,head, offset)
    if numel(record_index) == 1,
        num_targets = valid_targets(record_index);  % get the number of targets for the given record that are valid

        figure(record_index);   % index the given figure window with the same index for the specified frame
        hold on;   % make sure all targets are plotted in the same window

        % loop through number of targets for the given rec
        for target_index = 1:num_targets;
            if iscell(x),
                x_coordinate = x{record_index}(target_index);    % x coordinate for plotting target
                y_coordinate = y{record_index}(target_index);    % y coordinate for plotting target

                %y_coordinate = 480 - y_coordinate;  % scale the y value due to a upper left origin for the video tracker.

                str_color = GetColorString(color{record_index}(target_index,1:7));   % gets the string of the color to plot the target
            else
                x_coordinate = x(record_index, target_index);
                y_coordinate = y(record_index, target_index);
                str_color = GetColorString(color(record_index, target_index, 1:7));
            end;
            plot( x_coordinate, y_coordinate, str_color);   % plot target

        end
        
        if nargin > 5,
            % plot estimated head position
            x_head = head(1, record_index-offset);
            y_head = head(2, record_index-offset);
            plot(x_head, y_head, 'r+');
            L = 50; % length of line, in pixels
            Dx = sqrt(L^2/(1 + head(3, record_index-offset)^2));
            Dy = head(3, record_index-offset) * Dx;
            line([x_head-Dx/2 x_head+Dx/2], [y_head-Dy/2 y_head+Dy/2], 'Color', 'r');
        end;
        
        axis([0 640 0 480]);    % set axis for graph
        hold off;   % release the plot
    elseif numel(record_index) > 1,
        h = figure(record_index(1));
        set(h, 'Name', sprintf('Records %d - %d', record_index(1), record_index(end)));
        for k = 1:length(record_index),
            num_targets = valid_targets(record_index(k));  % get the number of targets for the given record that are valid

            figure(record_index(1));   
            clf; hold on;   % make sure all targets are plotted in the same window

            % loop through number of targets for the given rec
            for target_index = 1:num_targets;

                if iscell(x),
                    x_coordinate = x{record_index(k)}(target_index);    % x coordinate for plotting target
                    y_coordinate = y{record_index(k)}(target_index);    % y coordinate for plotting target

                    %y_coordinate = 480 - y_coordinate;  % scale the y value due to a upper left origin for the video tracker.

                    str_color = GetColorString(color{record_index(k)}(target_index,1:7));   % gets the string of the color to plot the target
                else
                    x_coordinate = x(record_index(k), target_index);
                    y_coordinate = y(record_index(k), target_index);
                    str_color = GetColorString(color(record_index(k), target_index, 1:7));
                end;

                plot( x_coordinate, y_coordinate, str_color);   % plot target

            end
            
            if nargin > 5,
                % plot estimated head position
                x_head = head(1, record_index(k)-offset);
                y_head = head(2, record_index(k)-offset);
                plot(x_head, y_head, 'r+');
                L = 50; % length of line, in pixels
                Dx = sqrt(L^2/(1 + head(3, record_index(k)-offset)^2));
                Dy = head(3, record_index(k)-offset) * Dx;
                line([x_head-Dx/2 x_head+Dx/2], [y_head-Dy/2 y_head+Dy/2], 'Color', 'r');
            end;

            rectangle('Position', [230, 63, 320, 400]);
            axis([0 640 0 480]);    % set axis for graph
            hold off;   % release the plot
            pause(0.01);
        end;
    else,
        %huh?
    end;
    
%----------------------------------------------------------------------------------------------------------------------
%  This function returns a string containg color information for plotting the frame.  Color is chosen in a specific
%   order based on preference.  The color yellow is used to represent raw green due to the absence of a light green color string.
%----------------------------------------------------------------------------------------------------------------------
function [color_string] = GetColorString( color_array )

    if ( color_array(2) ~= 0 )      % pure red
        color_string = 'ro';
    elseif ( color_array(4) ~= 0 )  % pure green
        color_string = 'go';        
    elseif ( color_array(6) ~= 0 )  % pure blue
        color_string = 'bo';
    elseif ( color_array(5) ~= 0 )  % raw blue
        color_string = 'co';
    elseif ( color_array(1) ~= 0 )  % raw red
        color_string = 'mo';
    elseif ( color_array(3) ~= 0 )  % raw green
        color_string = 'yo';
    else                            % black for luminance or default
        color_string = 'ko';
    end
        
    