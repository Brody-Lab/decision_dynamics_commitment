function [head, LEDs, records_tracked] = TrackFrames(init_box, x, y, color, valid_targets, varargin)
% function [led] = TrackFrames(init_box, x, y, color, valid_targets, varargin)
% 
% takes in the parameters extracted by ExtractFromTargets.m (provided by Neuralynx) and
% tracks the position of the LEDs through each frames.  It is important
% that in the init_box, at least two LEDs and at most two blue LEDs are present so 
% that we start with a good estimate of the head position/orientation.
%
% Inputs:
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
%           this value represents the number of targets per record (which
%           varies from record to record).
%
% Varargin:
%       RigPos - coordinates of the rectangle that contains the rig floor;
%           points outside this rectangle will be ignored
%           the camera's resolution is 640 x 480 pixels
%       pix - threshold distance under which targets of the same channel are consolidated into
%           one, in pixels
%       channels - a 1 by 7 matrix where each element is 1 or 0,
%           designating if that color channel (see color) should be kept.
%           For example, channels = [0 0 0 1 0 1 0] means keep only the
%           pure green and pure blue channels, ignoring all others.
%       record_index - a 1D matrix specifying the 
%
%
% Outputs:
%
%
%
% BWB, April 2008

pairs = { ...
    'RigPos'         [230, 63, 320, 400]; ...
    'pix'            9 ; ...
    'record_index'   NaN; ...
}; parseargs(varargin, pairs);

if isempty(record_index),
    error('No records to track!');
    return;
elseif isempty(color),
    error('No targets!');
    return;
elseif isnan(record_index(1)) && ~isempty(color),
    record_index = 1:rows(color); % by default, process all records
end;

channels = [4 6];

% to keep track of LEDs, array of structs
%LEDs = []; % 3 rows, where each row is a LED (blue, green, blue), if it exists.
           % fields:
           % LED.exists
           % LED.x
           % LED.y

% rat head position
head = zeros(6, 1); % state vector with 6 elements:
                    % [x; y; theta; x_dot; y_dot; theta_dot]
                    % x and y must always be defined
                    % other states may be NaN if they could not be
                    % identified/computed


% ===================================================
% identify the LEDs in the first frame to kick it off
% ===================================================
[x_coord, y_coord, ch, good_targets] = ExtractLED(init_box, x, y, color, valid_targets, ...
    'record_index', record_index(1), ...
    'pix', pix, ...
    'channels', channels);
    
% blue LEDs
blues = find(ch == 6);
switch length(blues),
    case 0,
        error('TrackFrames: no blue targets in initial frame -- pick a better initial frame');
        return;
    case 1,
        LEDs(1,1) = assignLED(blues(1), x_coord, y_coord);
        LEDs(3,1) = assignLED([]);
    case 2,
        LEDs(1,1) = assignLED(blues(1), x_coord, y_coord);
        LEDs(3,1) = assignLED(blues(2), x_coord, y_coord);
    otherwise,
        error('TrackFrames: >2 blue targets initial frame -- pick a better initial frame');
        return;
end;

% green LED
greens = find(ch == 4);
switch length(greens),
    case 1,
        LEDs(2,1) = assignLED(greens(1), x_coord, y_coord);
    otherwise,
        LEDs(2,1) = assignLED([]);
end;

% compute head position
%[N live] = ntargets(LEDs, 1);
live = [LEDs(:,1).exists];
if sum(live) >= 2 && length(blues) == 2,
    ind = find(live == 1);
    head(1,1) = mean([LEDs(ind, 1).x]);
    head(2,1) = mean([LEDs(ind, 1).y]);
    head(3,1) = compute_angle(LEDs(:,1), live);
    head(4:6,1) = NaN;
else
    error('TrackFrames: less than two valid targets in initial frame -- pick a better initial frame');
    return;
end;



% ==========================================================
% go through the rest of the records
% until there is too little information to go on, then stop
% ==========================================================
no_led = 0;
box = init_box;
for k = 2:length(record_index),
    good_targets = 0;
    it = 1;
    L  = [35 40 45 55 60 70];
    while good_targets < 2 && it <= 6,
        box = pick_box(box, head(:,k-1), L(it));
        [x_coord, y_coord, ch, good_targets] = ExtractLED(box, x, y, color, valid_targets, ...
            'record_index', record_index(k), ...
            'pix', pix, ...
            'channels', channels);
        it = it + 1;
    end;

    % blue LEDs
    blues = find(ch == 6);
    switch length(blues),
        case 0,
            LEDs(1,k) = assignLED([]);
            LEDs(3,k) = assignLED([]);
        case 1,
            xx = x_coord(blues);
            yy = y_coord(blues);
            lastx = [LEDs([1 3], k-1).x]';
            lasty = [LEDs([1 3], k-1).y]';
            
            D = pdist([xx yy; lastx lasty]);
            [dist nearest] = min(D(1:2));
            nearest = round(nearest*1.4); % converts [1, 2] to [1, 3]
            
            LEDs(nearest, k) = assignLED(blues(1), x_coord, y_coord);
            LEDs(setdiff([1 3], nearest), k) = assignLED([]);
        otherwise,            
            xx = x_coord(blues);
            yy = y_coord(blues);
            lastx = [LEDs([1 3], k-1).x]';
            lasty = [LEDs([1 3], k-1).y]';
            
            [peet D]= find_nearest([lastx lasty], [xx yy]);
            if length(unique(peet)) == length(peet),
                LEDs(1, k) = assignLED(blues(peet(1)), x_coord, y_coord);
                LEDs(3, k) = assignLED(blues(peet(2)), x_coord, y_coord);
            else  % if the same point is closest to both previous LED positions
                [tempval index] = min(D);
                if index == 1,
                    LEDs(1, k) = assignLED(blues(peet(1)), x_coord, y_coord);
                    LEDs(3, k) = assignLED([]);
                else
                    LEDs(1, k) = assignLED([]);
                    LEDs(3, k) = assignLED(blues(peet(1)), x_coord, y_coord);
                end;
            end;
                    
    end;
    
    % green LEDs
    greens = find(ch == 4);
    switch length(greens),
        case 0,
            LEDs(2, k) = assignLED([]);
        case 1,
            LEDs(2, k) = assignLED(greens(1), x_coord, y_coord);
        otherwise,
            xx = x_coord(greens);
            yy = y_coord(greens);
            lastx = [LEDs(2, k-1).x]';
            lasty = [LEDs(2, k-1).y]';
            
            [peet D] = find_nearest([lastx lasty], [xx yy]);
            LEDs(2, k) = assignLED(greens(peet(1)), x_coord, y_coord);
    end;
    
    % estimate head position from identified LEDs
    live = [LEDs(:,k).exists];
    if sum(live) >= 2,
        ind = find(live == 1);
        %LEDs(:,k) = pruneLEDs(LEDs(:,k), live, 10);
        [xhead yhead] = compute_position(LEDs(:,k), live);
        head(1,k) = xhead;
        head(2,k) = yhead;
        head(3,k) = compute_angle(LEDs(:, k), live);
        head(4,k) = diff(head(1, k-1:k));  % the difference between this point and the last
        head(5,k) = diff(head(2, k-1:k));
        if isnan(head(3,k-1)) || isnan(head(3,k))
            head(6,k) = NaN;
        else
            head(6,k) = diff(head(3, k-1:k)); % this is a very crude calculation and should be improved upon
        end;
    elseif sum(live) == 1, % if only one out of 3 LEDs may be identified...
        ind = find(live == 1);
        lastx = LEDs(ind, k-1).x;
        lasty = LEDs(ind, k-1).y;
        if ~isnan(lastx),
            head(3,k) = LEDs(ind,k).x - lastx;
            head(4,k) = LEDs(ind,k).y - lasty;
            head(1,k) = head(1,k-1) + head(3,k);
            head(2,k) = head(2,k-1) + head(4,k);
            head(3,k) = NaN;
            head(6,k) = NaN;
        else % if the current 
            warning(sprintf('Lost track of points!  TrackFrame aborted after record_index %d.', record_index(k-1)));
            records_tracked = k-1;
            return;
        end;
    else % if no LEDs can be found assume rat has not moved
        if no_led < 3,
            head(1,k) = head(1, k-1);
            head(2,k) = head(2, k-1);
            head(3,k) = NaN;
            head(4,k) = 0;
            head(5,k) = 0;
            head(6,k) = NaN;
            no_led = no_led + 1;
        else
            warning(sprintf('Lost track of points!  TrackFrame aborted after record_index %d.', record_index(k-4)));
            records_tracked = k-4;
            head = head(:,1:k-4);
            return;
        end;
    end;
    
    
    
end;

records_tracked = cols(head);        

