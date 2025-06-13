function [x_out, y_out, theta_out, err] = smooth_trajectory(x, y, theta)
%
% smoothes the trajectory/head angles tracked by Neuralynx by averaging
% neighboring time points to interpolate the gaps


% theta == 0 indicates that only 1 led was visible, so the x-y coords is
% usually off by a few pixels
lost  = find(theta == nan);
% when x or y == 0, no led was found
blank = find(x == 0);

% if there's a bunch of zeros in theta, then we only had one led visible
% during a majority of the session and there's not much we can do in terms
% of interpolation
if numel(lost) > 0.8*numel(theta),
    err = 1;
    x_out = x;
    y_out = y;
    theta_out = theta;
    return;
else
    err = 0;
end

%% first fix those lost points where one led was still visible
f  = setdiff(lost, blank);
% find the begins and ends of these bouts of lostness
if isempty(f),
    fs1=[]; fs2=[];
else,
    fs1 = [f(1) f(find(diff(f) > 1) + 1)];
    fs2 = [f(diff(f) > 1) f(end)]; 
end;

not_fixed = [];
for i = 1:numel(fs1),
    if fs1(i)-1 > 0 && fs2(i)+1 < numel(x),
        if x(fs1(i)-1) == 0 || x(fs2(i)+1) == 0,
            not_fixed = [not_fixed fs1(i):fs2(i)]; %#ok<AGROW>
        else
            t = fs2(i) - fs1(i) + 2;
            dx = (x(fs2(i)+1) - x(fs1(i)-1))/t;
            dy = (y(fs2(i)+1) - y(fs1(i)-1))/t;
            
            % interpolate linearly
            if dx > 0, newx = x(fs1(i)-1):dx:x(fs2(i)+1);
            else       newx = x(fs2(i)+1) * ones(1,t+1); end
            if dy > 0, newy = y(fs1(i)-1):dy:y(fs2(i)+1);
            else       newy = y(fs2(i)+1) * ones(1,t+1); end

            x(fs1(i)-1:fs2(i)+1) = newx;
            y(fs1(i)-1:fs2(i)+1) = newy;
        end
    end
end

%% now handle those places where the leds are lost altogether
f = union(blank, not_fixed);
% find the begins and ends of these bouts of lostness
if isempty(f),
    fs1 = []; fs2 = [];
else
    fs1 = [f(1) f(find(diff(f) > 1) + 1)];
    fs2 = [f(diff(f) > 1) f(end)]; 
end;

R = 10; % range of samples at either end over which to interpolate
for i = 1:numel(fs1),
    if fs1(i)-R > 0 && fs2(i)+R < numel(x),
        t_int   = fs1(i)-R:fs2(i)+R;
        x_local = x(t_int);
        y_local = y(t_int);
        
        t_local   = t_int(x_local > 0);
        x_local   = x_local(x_local > 0);
        y_local   = y_local(y_local > 0);
        
        % interpolate based on the non-zeros points
        x_int = interp1q(t_local', x_local', t_int');
        y_int = interp1q(t_local', y_local', t_int');
        
        x(fs1(i):fs2(i)) = x_int(R+1:end-R);
        y(fs1(i):fs2(i)) = y_int(R+1:end-R);
    end
end

%% we are going to be wrong sometimes...
% find the points where the jump was too severe
x_outliers = find(abs(diff(x)) > 15);
y_outliers = find(abs(diff(y)) > 15);
f = union(x_outliers, y_outliers);

if isempty(f),
    fs1=[]; fs2=[];
else,
    fs1 = [f(1) f(find(diff(f) > 1) + 1)];
    fs2 = [f(diff(f) > 1) f(end)]; 
end;

not_fixed = [];
for i = 1:numel(fs1),
    if fs1(i)-1 > 0 && fs2(i)+1 < numel(x),
        if x(fs1(i)-1) == 0 || x(fs2(i)+1) == 0,
            not_fixed = [not_fixed fs1(i):fs2(i)]; %#ok<AGROW>
        else
            t = fs2(i) - fs1(i) + 2;
            dx = (x(fs2(i)+1) - x(fs1(i)-1))/t;
            dy = (y(fs2(i)+1) - y(fs1(i)-1))/t;
            
            % interpolate linearly
            if dx > 0, newx = x(fs1(i)-1):dx:x(fs2(i)+1);
            else       newx = x(fs2(i)+1) * ones(1,t+1); end
            if dy > 0, newy = y(fs1(i)-1):dy:y(fs2(i)+1);
            else       newy = y(fs2(i)+1) * ones(1,t+1); end

            x(fs1(i)-1:fs2(i)+1) = newx;
            y(fs1(i)-1:fs2(i)+1) = newy;
        end
    end
end

        


x_out = x;
y_out = y;
theta_out = theta;