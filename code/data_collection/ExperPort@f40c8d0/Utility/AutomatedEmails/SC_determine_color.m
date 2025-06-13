function shift_color = SC_determine_color(i)

shift_color = [1 0.8 0.8]; %default red, incomplete shift

if     i==1; shift='overnight';
elseif i==2; shift='morning';
else         shift='evening';
end

dt = now;
if     i==2 && str2num(datestr(now,'HH')) < 4;  dt = now-1; %#ok<ST2NM>
elseif i==3 && str2num(datestr(now,'HH')) < 12; dt = now-1; %#ok<ST2NM>
end

x = bdata(['select ',shift,' from ratinfo.tech_schedule where date="',datestr(dt,'yyyy-mm-dd'),'"']);
if iscell(x) && ~isempty(x); x = x{1}; end

if numel(x) > 5
    for j = 1:numel(x)-5
        t = str2num(x(j:j+5)); %#ok<ST2NM>
        if ~isempty(t)
            %we found a 6 digit number, probably means the shift went green
            shift_color = [0.8 1 0.8]; %green, complete shift
            return
        end
    end
end
    
