function newrow = format_newrow(s)

S1str = format_soundui(s{1,4}, 33);
S2str = format_soundui(s{1,5}, 33);

newrow = [sprintf('%5.3g ', s{1,1}) ' ' s{1,2} ...
    sprintf(' %3.3g ', s{1,3}) '  ' S1str S2str];

return;

%% format_soundui
function disp_str = format_soundui(x, N)

if isempty(x),
    disp_str = '--';
    return;
end;

switch x.Style,
    case {'ToneSweep', 'BupsSweep'}
        dur = x.Dur1 + x.Dur2;
    otherwise,
        dur = x.Dur1;
end;

if strcmp(x.Style, 'File'),
    filename = x.SoundFile;
    disp_str = [filename ' ' sprintf('dur:%2g',dur)];
else
    disp_str = [x.Style ' ' sprintf('dur:%2g ', dur) ...
                          sprintf('vol:%2g ', x.Vol) ...
                          sprintf('freq1:%2g ', x.Freq1) ...
                          sprintf('bal:%2g', x.Bal)];
end;

% if disp_str is more than N char, truncate
if size(disp_str,2) > N, disp_str = [disp_str(1:N-1) '\']; end;

% %% pair_value
% function v = pair_value(x, str)
% 
% [i j] = find(strcmp(x, str));
% if isempty(i),
%     v = [];
% else
%     v = x{i,2};
% end;
% 
% return;