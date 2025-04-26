%% GET_STEREO_CLICK_TIME
%
%=CALL with one input
%   
% t = get_stereo_click_time(Trials) 
%
%=CALl with two inputs
%
% t = get_stereo_click_time(PD, PEH) 
%
%   PD
%       a structure containing the protocol data
%
%   PEH
%       a structure containing the parsed event history
%
%=CALL with three inputs
%
% t = get_stereo_click_time(left_bups, right bups, clicks_on_s
%
%   left_bups
%       A cell array of the left bup times in each trial aligned to clicks_on_s
%
%   right_bups
%       A cell array of the right bup times in each trial aligned to clicks_on_s
%
%   clicks_on_s
%       A double vector indicating the time of the start of the clicks wave
%
function t = get_stereo_click_time(varargin)
    switch nargin
        case 1
            Trials = varargin{1};
            trialindex = ~Trials.violated & Trials.responded & Trials.trial_type == 'a';
            L = Trials.leftBups;
            R = Trials.rightBups;
            assert(min([cellfun(@length, L(trialindex)); ...
                        cellfun(@length, R(trialindex))])==1);
            clicks_on_s = Trials.stateTimes.clicks_on;
        case 2
            PD = varargin{1};
            PEH = varargin{2};
            L = cellfun(@(x) x.left, PD.bupsdata, 'uni', 0);
            R = cellfun(@(x) x.right, PD.bupsdata, 'uni', 0);
            clicks_on_s = get_clicks_on_time(PEH);
        case 3
            L = varargin{1};
            R = varargin{2};
            clicks_on_s = varargin{3};
        otherwise
            error('Cannot parse inputs')
    end
    L(cellfun(@isempty, L)) = {nan};
    R(cellfun(@isempty, R)) = {nan};
    L1 = cellfun(@(x) x(1), L, 'uni', 0);
    R1 = cellfun(@(x) x(1), R, 'uni', 0);
    L1=cell2mat(L1);
    R1=cell2mat(R1);
    assert(all(L1(~isnan(L1))==R1(~isnan(R1))));
    t = L1 + clicks_on_s;
end