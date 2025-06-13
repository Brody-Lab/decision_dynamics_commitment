function [aa] = VT2Mat(varargin)

% reads a .nvt Neuralynx video tracker file into a matlab format
%
% Note: uses Nlx2MatVT_v4.m, which can be downloaded at
% www.neuralynx.com/downloads; however, this code only works on windows
% machines at this time.
%
% see help on Nlx2MatVT_v4 on full explanations of the varargins

%
%
% Note: All Timestamps are in microseconds.
%
% NumFields = 6;
% Field List
%     1. Timestamps
%     2. Extracted X
%     3. Extracted Y
%     4. Extracted Angle
%     5. Targets
%     6. Points
%
% NumModes = 5;
% Extraction Modes
%     1. Extract All - This will extract every record from the file into the matlab environment;
%     2. Extract Record Index Range = This will extract every Record whos index is within a range specified by Paramter 5.
%     3. Extract Record Index List = This will extract every Record whos index in the file is the same index that is specified by Paramter 5.
%     4. Extract Timestamp Range = This will extract every Record whos timestamp is within a range specified by Paramter 5.
%     5. Extract Timestamp List = This will extract every Record with the
%     same timestamp that is specified by Paramter 5.

pairs = { ...
    'ExtractMode'         'index range'; ...
    'ModeArray'           [0 10000]; ...
    'in_this_dir'         0; ...
    'FieldSelection'     [1 1 1 1 0 0];...
    }; parseargs(varargin, pairs);

ExtractHeader  = 1;

if ~isequal(FieldSelection , [1 1 1 1 0 0]) && ~(isequal(ExtractMode,'all') || isequal(ExtractMode,1))
    error('Does not support alternate extract modes for not default FieldSelection');
end


if ~ispc,
    warning('VT2Mat:Invalid', 'At this time, VT2Mat only functions in Windows.  Sorry...');
    return;
end

if ~in_this_dir,
    [filename, pathname] = uigetfile('*.nvt', 'VT2Mat');
    evf.name = [pathname filename];
else
    evf = dir('VT*.nvt');
    if isempty(evf),
        [filename, pathname] = uigetfile('*.nvt', 'Pick a NVT video tracker file');
        evf.name = [pathname filename];
    end
end

if isnumeric(ExtractMode),
    ExtractCode = ExtractMode(1);
    if ExtractCode < 1 || ExtractCode > 5,
        warning('VT2Mat:Invalid', 'ExtractMode must be one of 1-5.');
        return;
    end
else
    switch ExtractMode,
        case 'all',
            ExtractCode = 1;
        case 'index range',
            ExtractCode = 2;
        case 'index list',
            ExtractCode = 3;
        case 'timestamp range',
            ExtractCode = 4;
        case 'timestamp list',
            ExtractCode = 5;
        otherwise
            warning('VT2Mat:Invalid', 'Does not understand what ''ExtractMode'' %s is.', ExtractMode);
            return;
    end
end

aevf=evf;

for vx=1:numel(aevf)
    evf=aevf(vx);
    fnames={'TimeStamps', 'X', 'Y', 'Theta','Targets','Points'};
    
    vt_eval='[';
    for fx=1:6
        if FieldSelection(fx)==1
            vt_eval=[vt_eval fnames{fx} ','];
        end
    end
    vt_eval=[vt_eval(1:end-1) ',NlxHeader ]='];
    
    
    
    if ExtractCode == 1,
        vt_eval=[vt_eval 'Nlx2MatVT_v4(evf.name, FieldSelection, ExtractHeader, ExtractCode);'];
        eval(vt_eval);
    else
        TimeStamps = [];
        X          = [];
        Y          = [];
        Theta      = [];
        if rows(ModeArray) == 1,
            vt_eval=[vt_eval 'Nlx2MatVT_v4(evf.name, FieldSelection, ExtractHeader, ExtractCode, ModeArray(1,:));'];
        else
            for j = 1:rows(ModeArray),
                [ts, xx, yy, th, header] = Nlx2MatVT(evf.name, FieldSelection, ExtractHeader, ExtractCode, ModeArray(j,:));
                TimeStamps = horzcat(TimeStamps, zeros(1,5), ts);
                X          = horzcat(X, zeros(1,5), xx);
                Y          = horzcat(Y, zeros(1,5), yy);
                Theta      = horzcat(Theta, zeros(1,5), th);
            end;
            NlxHeader = header;
        end
    end
    
    for fx=1:6
         if FieldSelection(fx)==1
        aa(vx).(fnames{fx})=eval(fnames{fx})
         end
    end
    aa(vx).Header = NlxHeader;
    
end