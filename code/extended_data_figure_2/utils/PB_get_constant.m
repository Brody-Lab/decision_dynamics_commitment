function constant = PB_get_constant(constant_type, constant_field)
% PB_GET_CONSTANT Parameters for analysis
% 
%   CONSTANT = PB_GET_CONSTANT(CONSTANT_TYPE) returns the structure CONSTANT containing
%   the constants of the type specified by the character array CONSTANT_TYPE
%
% REQUIRED INPUT:
%   CONSTANT_TYPE       a lower-case character array specifying the type of constant
%
% OUTPUT:
%   CONSTANT            a structure containing the requested constants
%
% EXAMPLE:
% >> C = PB_get_constant('color');
% >> C.left
% ans =
%
%     0    0.4470    0.7410
K = struct;
%% Paths
if ispc
    switch getenv('COMPUTERNAME')
        case "BRODYLABTHOMASL"
            K.path.repositories = 'C:\Users\Thomas Zhihao Luo\Documents';
            K.path.repository_tzluo = 'V:\Documents\tzluo';
        case "BRODYNPANAL04"
            K.path.repositories = 'C:\github';
            K.path.repository_tzluo = [K.path.repositories, filesep, 'tzluo'];
        otherwise
            K.path.repositories = 'C:\github';            
            K.path.repository_tzluo = [K.path.repositories, filesep, 'tzluo'];
    end
    K.path.analysis_scripts = 'V:\Documents\tzluo\analysis_scripts';
    K.path.analysis_data = 'X:\tzluo\analysis_data';
    K.path.np_sorted_fldr =   'X:\RATTER\PhysData\NP_sorted';
    K.path.np_processed_fldr = 'X:\tzluo\Cut phys data';
else
    if ismac
        [ret, name] = system('hostname');
        if length(name) > 1 & name(1:end-1)=='PNI-24CD490C6WC0',
            % This is for Carlos' laptop. But clearly we need a way to
            % specify a user's Github root folder, and point repos there
            K.path.ks2_template = '';
            K.path.np_sorted_fldr = '/Volumes/RATTER/PhysData/NP_sorted/Thomas';
            K.path.np_processed_fldr = '/Volumes/Cut phys data';
            K.path.analysis_data = '/Volumes/brody/tzluo/analysis_data';
            K.path.repositories = '/Users/carlos/Github';
            K.path.repository_tzluo = '/Users/carlos/Github/tzluo';
        end
    end

    K.path.ks2_template = '';
    K.path.np_sorted_fldr = '/Volumes/RATTER/PhysData/NP_sorted/Thomas';
    K.path.np_processed_fldr = '/Volumes/Cut phys data';
    K.path.repositories = '/Users/Thomas/Documents';
    K.path.analysis_data = '/Volumes/brody/tzluo/analysis_data';

end
K.path.logs =               [K.path.repository_tzluo filesep 'Logs'];
K.path.ephys_log =          [K.path.logs filesep 'Ephys_log.xlsx'];
K.path.implant_log =        [K.path.logs filesep 'Implant_log.xlsx'];
K.path.multi_sess_log =     [K.path.logs filesep 'multi_sess_log.xlsx'];
K.path.opto_log =           [K.path.logs filesep 'opto_log.xlsx'];
K.path.opto_ephys_log =     [K.path.logs filesep 'Opto-ephys log.xlsx'];
K.path.pharmacology_log =   [K.path.logs filesep 'Pharmacology log.xlsx'];
K.path.photothermal_lesion_log = [K.path.logs filesep 'photothermal_lesion_log.xlsx'];
K.path.illumination_periods = [K.path.logs filesep 'illumination_periods.xlsx'];
K.path.standard_illumination_conditions = [K.path.logs filesep 'standard_illumination_conditions.xlsx'];
K.path.ks2_template =       [K.path.repositories filesep 'npx-utils' filesep 'sbox-thomas' filesep 'thomas_2019_09_12.prm'];
K.path.neural_ddm_data = [K.path.analysis_data, filesep, 'neural_ddm'];   
%% file extensions
K.file_extension.np_ap_meta = 'ap.meta';
K.file_extension.np_spike_sorted_output = 'ap_res.mat';
K.file_extension.np_sync = 'sync.mat';
%% Experimenters
K.experimenter.t = 'Thomas';
K.experimenter.k = 'Chuck';
K.experimenter.x = 'Diksha';
%% Colors
K.color = struct;
K.color.blue = [60, 80, 160]/255;
K.color.oran = [220, 120, 30]/255;
K.color.none = zeros(1,3);
K.color.isofluorane = [80 140 255]/255;
K.color.control =zeros(1,3); [80 140 255]/255;
K.color.saline = zeros(1,3);[30 30 200]/255;
K.color.muscimol = [0 100 200]/255;[220 120 30]/255;
K.color.bilateral = [0 100 200]/255;[220 120 30]/255;
K.color.right_hemi = [220 30 30]/255;
K.color.left_hemi = [30 180 30]/255;

K.color.halorhodopsin = [255,123,0]/255;
K.color.channelrhodopsin = [0,183,255]/255;
K.color.laser = K.color.halorhodopsin;
K.color.laser_on = [0,168,255]/255;
K.color.laser_off = [0,0,0];
K.color.ctrl = [0,0,0];
K.color.default = [0        0.447        0.741; ...  % MATLAB's default color order
                 0.85        0.325        0.098; ...
                0.929        0.694        0.125; ...
                0.494        0.184        0.556; ...
                0.466        0.674        0.188; ...
                0.301        0.745        0.933; ...
                0.635        0.078        0.184]; 
K.color.default = repmat(K.color.default, 10, 1);
K.color.perturb = K.color.default(1,:);
K.color.after_perturb = K.color.halorhodopsin;
K.color.l = K.color.default(1,:);
K.color.r = K.color.default(2,:);
K.color.left = K.color.default(1,:);
K.color.right = K.color.default(2,:);
K.color.b = K.color.default(3,:);
K.color.L = K.color.default(1,:);
K.color.R = K.color.default(2,:);
K.color.B = K.color.default(3,:);
K.color.NA = zeros(1,3);
K.color.trubetskoy = 1/255 *  [230,  25,  75; ...
                               60, 180,  75; ...
                              255, 225,  25; ...
                                0, 130, 200; ...
                              245, 130,  48; ...
                              145,  30, 180; ...
                               70, 240, 240; ...
                              240,  50, 230; ...
                              210, 245,  60; ...
                              250, 190, 190; ...
                                0, 128, 128; ...
                              230, 190, 255; ...
                              170, 110,  40; ...
                              255, 250, 200; ...
                              128,   0,   0; ...
                              170, 255, 195; ...
                              128, 128,   0; ...
                              255, 215, 180; ...
                                0,   0, 128];
K.color.trubetskoy = repmat(K.color.trubetskoy, 10, 1);
K.color.opto = [0,0,0; K.color.default];
K.color.lesion = [200,30,30]/255;
K.color.prelesion = zeros(1,3);
K.color.postlesion = [200,30,30]/255;
K.color.recovery = zeros(1,3);

K.color.full_bups = K.color.halorhodopsin;
K.color.early = K.color.default(1,:);
K.color.late = K.color.default(2,:);

c = 0;
for per = {'early', 'late', 'move', 'two_s', 'fixation', }; per = per{:};
    c = c+1;
    K.color.(per) = K.color.default(c,:);
end
K.color.full = K.color.halorhodopsin;
%% figure specifiations
K.figure.size = [400, 300];
K.figure.types_saved = {'png', 'svg'};
%% line specifications
K.line.l = '--';
K.line.r = '-';
K.line.L = K.line.l;
K.line.R = K.line.r;
K.line.laser_on = '--*';
K.line.laser_off = '-';
K.line.saline = '-';
K.line.muscimol = '--';
K.line.bilateral = '--';
K.line.default{1} = '--';
K.line.default{2} = '-';

K.marker.saline = '*';
K.marker.muscimol = 'o';
K.marker.default = {'o','*','d','x','v','+','^','s','>','<'};
K.marker.default = repmat(K.marker.default, 1, 10);
%% FiberID to brain areas
K.brain_area = struct;
K.brain_area.K236.AL = 'admFC';
K.brain_area.K236.AR = 'admFC';
K.brain_area.K236.PL = 'admFC';
K.brain_area.K236.PR = 'admFC';
K.brain_area.K238.AL = 'admFC';
K.brain_area.K238.AR = 'admFC';
K.brain_area.K238.PL = 'adStr';
K.brain_area.K238.PR = 'adStr';

for the_rat = {'T168', 'T181', 'T182', 'T183', 'T188', 'T190', 'T200', ...
               'T201', 'T212', 'T223', 'T219', 'T227', 'T238', 'T224', ...
               'T262', 'T240', 'T304'}; the_rat = the_rat{:};
    K.brain_area.(the_rat) = K.brain_area.K238;
end
%% windows for counting spikes and smoothing histograms
K.peth = struct;
K.peth.binS = 0.01; % bin size in second. If the bin is much smaller than the smoothing kernel, it doesn't matter much.
K.peth.type = 'LGAUSS'; % see calc_psth.m for details. 
K.peth.stdS = 0.1; % standard deviation in second 

K.peth.timeS.cpoke_in        = -1 + K.peth.binS : K.peth.binS : 3;
K.peth.timeS.cpoke_out       = -2 + K.peth.binS   : K.peth.binS : 1;
K.peth.timeS.clicks_on       =  0 + K.peth.binS   : K.peth.binS : 1.5;
% K.peth.timeS.spoke           = -0.5 + K.peth.binS : K.peth.binS : 0.5;

K.peth.refEvents = fields(K.peth.timeS)';

% round to the nearest 0.5 s
for events = K.peth.refEvents; eve = events{:};
    t_min = floor(min(K.peth.timeS.(eve))*2)/2;
    t_max = ceil(max(K.peth.timeS.(eve))*2)/2;
    K.peth.timeLimS.(eve) = [t_min, t_max];
    K.peth.timeTickS.(eve) = t_min:0.5:t_max;
end

% the time window around each trial event from which I extract spikes
%   - if the psth type is a causal Gaussian, I don't have to include spikes that are earlier or
%   later than the time steps of the PETH, but I do so anyways. I include spikes up to five STD fo
%   the smoothing kernel earlier and later than the time steps of the PETH.
K.spike_window_s = struct;
for events = K.peth.refEvents; eve = events{:};
    K.spike_window_s.(eve) = [min(K.peth.timeS.(eve)) - 5*K.peth.stdS, ...
                              max(K.peth.timeS.(eve)) + 5*K.peth.stdS];
end
%% Datetime
K.datestr_format = 'yyyy_mm_dd';
K.datetime_format = 'yyyy_MM_dd';
K.timestr_format = 'yyyy_mm_dd_HH_MM_SS';
%% text
K.text.clicks_on = 'stimulus onset';
K.text.clicks_off = 'stimulus offset';
K.text.cpoke_in = 'fixation';
K.text.cpoke_out = 'movement onset';
K.text.cpoke_req_end = 'stimulus offset';
K.text.dStr = 'adStr';
K.text.vStr = 'avStr';
K.text.M1 = 'M1';
K.text.M2_Cg1 = 'dmFC';
K.text.Cg1_M2 = 'dmFC';
K.text.PrL_MO = 'mPFC';
K.text.MO_PrL = 'mPFC';
K.text.correct_side = 'the correct side';
K.text.choice = 'the choice';
K.text.evidence = '#(R-L)';

%% Counting window
% 2018-04-30    Added
K.counting_window = struct;
K.counting_window.epoch       = string({'full'; 'early'; 'late'; 'move'});
K.counting_window.time_s_from = [0.5; 0.5; 1.0; 1.5];
K.counting_window.time_s_to   = [1.5; 1.0; 1.5; 2.0];
K.counting_window.reference_event = repmat(string('cpoke_in'), 4, 1);
K.counting_window = struct2table(K.counting_window);
%% Did an animal's implant have light_artifact?
% 2018-07-23    Added
K.light_artifact = struct;
K.light_artifact.K236 = false;
K.light_artifact.K238 = false;
K.light_artifact.T168 = false;
K.light_artifact.T181 = true;
K.light_artifact.T182 = true;
K.light_artifact.T183 = false;
K.light_artifact.T188 = false;
%% Laser stimulation periods
% 2018-07-25    Added
K.stim_period = struct;

K.stim_period.full.triggerEvent = 'cpoke_in';
K.stim_period.full.latencyMS = 500;
K.stim_period.full.durMS = 1000;

K.stim_period.early.triggerEvent = 'cpoke_in';
K.stim_period.early.latencyMS = 500;
K.stim_period.early.durMS = 500;

K.stim_period.late.triggerEvent = 'cpoke_in';
K.stim_period.late.latencyMS = 1000;
K.stim_period.late.durMS = 500;

K.stim_period.move.triggerEvent = 'cpoke_in';
K.stim_period.move.latencyMS = 1500;
K.stim_period.move.durMS = 500;

K.stim_period.two_s.triggerEvent = 'cpoke_in';
K.stim_period.two_s.latencyMS = 0;
K.stim_period.two_s.durMS = 2000;

K.stim_period.fixation.triggerEvent = 'cpoke_in';
K.stim_period.fixation.latencyMS = 0;
K.stim_period.fixation.durMS = 500;

stim_periods = fields(K.stim_period);
stim_periods = stim_periods(:)';
%% Pharmacology
% *********************** %
% Minimum injector length
% *********************** %
K.pharma.min_injector_mm = struct;
K.pharma.min_injector_mm.K214 = 1.5;
K.pharma.min_injector_mm.K215 = 1.5;
K.pharma.min_injector_mm.K216 = 2;
% ***************** %
% Excluded sessions
% ***************** %
K.pharma.excluded_sessions = struct;
K.pharma.excluded_sessions.K213 = {'2017-01-16'; ... % right cannula was clogged
                          '2017-01-17'; ...
                          '2017-01-18'; ...
                          '2017-01-21'; ...
                          '2017-01-25'};
K.pharma.excluded_sessions.K214 = {'2017-01-16'};
K.pharma.excluded_sessions.K215 = {'2017-01-16'};
K.pharma.excluded_sessions.K216 = {'2017-01-16'};
K.pharma.excluded_sessions = structfun(@datetime, K.pharma.excluded_sessions, 'uni', 0);
%% PopDV
% time bin used for computing the regularization coefficient that maximizes
% cross-validated performance, for each reference event.
K.popdv.t_reg_coeff.clicks_on = 0.4;
K.popdv.t_reg_coeff.clicks_off = 0;
K.popdv.t_reg_coeff.cpoke_out = 0;
K.popdv.t_reg_coeff.cpoke_in = 1.5;
K.popdv.t_reg_coeff.feedback = 0.5;
% the trial event used for making given a reference event, e.g. "cpoke_out"
% is the event used for masking if the reference event is "clicks_on"
K.popdv.mask_event.clicks_on = 'cpoke_out';
K.popdv.mask_event.clicks_off = 'cpoke_out';
K.popdv.mask_event.cpoke_out = 'spoke';
K.popdv.mask_event.cpoke_in = 'spoke';
K.popdv.mask_event.feedback = '';
% the time interval 
K.popdv.mask_interval_s.cpoke_out = [0, inf];
K.popdv.mask_interval_s.spoke = [0, inf];
K.popdv.mask_interval_s.feedback = [0,0];
% steps_s
K.popdv.steps_s.clicks_on = 0:0.1:1;
K.popdv.steps_s.clicks_off = -1:0.02:0.5;
K.popdv.steps_s.cpoke_out = -1:0.02:0.5;
K.popdv.steps_s.cpoke_in = -0.5:0.02:2.5;
K.popdv.steps_s.feedback = -0.5:0.02:2.5;
% noise distribution
K.popdv.distr.choice = 'binomial';
K.popdv.distr.correct_side = 'binomial';
K.popdv.distr.evidence = 'normal';
% link function distribution
K.popdv.link.choice = 'logit';
K.popdv.link.correct_side = 'logit';
K.popdv.link.evidence = 'identity';
%% single_unit_criteria
K.single_unit_criteria.max_frac_submillisecond_isi = 0.001;
%% plotting
K.plotting.click_diff_bins = -40:10:40;
K.plotting.click_diff_bins(1)=-inf;
K.plotting.click_diff_bins(end)=inf;
%% parameters to ignore when sorting
K.ignore_parameters = {'on_ramp_dur_s'};
%% Return the constant
if nargin < 2
    constant_field = [];
end
constant_type = lower(constant_type);
constant_field = char(constant_field);
if isfield(K, constant_type)
    if ~isempty(constant_field)
        constant = K.(constant_type).(constant_field);
    else
        constant = K.(constant_type);
    end
else
    warning('Cannot find the constants of the type %s', constant_type)
    constant = [];
end