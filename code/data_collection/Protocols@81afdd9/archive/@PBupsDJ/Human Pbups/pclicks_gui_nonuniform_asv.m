function pbups_gui(subject, resume_previous)

if nargin < 1,
	subject = 'BWB';
end;

if nargin < 2,
	resume_previous = 1;
end;

mode = 'gamma';
first_bup_stereo = 1; % prob this is a first bup stereo trial
gamma_pool = [-1.15 -0.7 -0.2 0.2 0.7 1.15];
signs = sign(gamma_pool);
target_prob = [0.9 0.7 0.6 0.7 0.8 0.9];
fixed_pool = 0;
pprob = ones(size(gamma_pool));
adapt_step = -0.04;
sample_range = [0.1 0.5];
sample_list = linspace(sample_range(1),sample_range(2),5);
sample_hits = ones(length(gamma_pool),length(sample_list));
sample_misses = ones(length(gamma_pool),length(sample_list));
antibias_beta = 4;
antibias_tau = 30;
ITI = 0.3;
R = 40;
srate = 40000;
adaptive_trials = 400;
adapt_tau = nthroot(0.001,adaptive_trials);
trials = 0;

hit_history    = [];
side_history   = [];
gamma_history  = [];
went_right     = [];
sample_history = [];
observer       = [];
stereo_history = [];
bupsdata = cell(0,0);


%% initialization of states
state = 'off';
side = 0; % -1 is left, 1 is right, 0 is both

begin = 1;

%% gui elements
ss = get(0, 'ScreenSize');
sheight = ss(4);
swidth = ss(3);
f = figure('Visible','off','Position',[1,1,ss(3),ss(4)], ...
    'Color', [1 1 1], 'MenuBar','n', ...
    'KeyPressFcn', @keypress);
set(f,'Name','Poisson Clicks Psychophysics')

state = 'inits';
nametext = 'Please enter your initials and then press enter';
hinstruct_name = uicontrol(f, 'Style', 'text', 'String',nametext , ...
	'Position', [(swidth-700)/2, (sheight)/2, 700, 100], ...
	'FontSize', 20, ...
	'BackgroundColor', [1 1 1]);

hname = uicontrol(f, 'Style', 'edit', 'String', '', ...
    'Position', [(swidth - 50)/2, (sheight-25)/2, 50, 25], ...
    'Selected','on','SelectionHighlight', 'off', 'FontSize', 10,....
    'Callback',(@name_Callback));

htrials = uicontrol(f,'Style','text','String','0',...
    'Position',[30,sheight-100,50,30],'fontsize', 10);

instructions = {['In each trial, you will hear a series of clicks coming from each ear.  '...
    'Use the arrow keys to indicate which side is clicking faster  '...
    'You may press p to pause the experiment and return to this screen or '...
    'escape to save and exit the experiment.'] ,'',...
    'Adjust the volume, then press enter' };

hinstructions = uicontrol(f, 'Style', 'text', 'String',instructions , ...
	'Position', [(swidth-700)/2, (sheight)/2-200, 700, 400], ...
    'FontSize', 20,'Visible','off', ...
    'BackgroundColor', [1 1 1]);
% movegui(f,'center')
set(f,'Visible','on');

uiwait(f)

        
        %% if the subject has saved data, load it and continue
        if resume_previous,
            if isempty(subject), subject = 'ZZZ'; end; %#ok<NODEF>
            n = 1;
            while exist([subject sprintf('%d.mat', n)], 'file'),
                n = n+1;
            end;
            fn = [subject sprintf('%d.mat', n-1)];
            if n>1
                load(fn, '-mat');
            end
        end;
        
sample_hits = ones(length(gamma_pool),length(sample_list));
sample_misses = ones(length(gamma_pool),length(sample_list));

for i = 1:length(hit_history)
    s0 = find(gamma_pool == gamma_history(i));
    samp0 = find(sample_list == sample_history(i));   
    sample_hits(s0,samp0) = sample_hits(s0,samp0)+hit_history(i);
    sample_misses(s0,samp0) = sample_misses(s0,samp0)+1-hit_history(i);    
end

%% name_Callback
    function name_Callback(source, eventdata)
        set(hinstruct_name, 'Visible','off')
        subject = get(hname, 'string')
        set(hname, 'Enable','off')
        set(hname, 'Visible','off')
        set(hinstructions,'Visible','on')
        state = 'instruct';
        uiresume(f)
    end

%%  Run 1 trial
    function begin_trial()
        if mod(length(hit_history),200)==0
            stop_save;
            state = 'ITI';
        end
        display(sprintf('trial %d', numel(hit_history)));
        set(hinstructions, 'String', sprintf(['Wait until the sound has stopped playing ' ...
            '\nThen press the left or right arrow button to respond']));
        s = next_trial(hit_history, side_history, pprob, antibias_beta, antibias_tau)         %#ok<NOPRT>
        stereo = rand(1)<first_bup_stereo;
        
        if ~fixed_pool  && ~isempty(hit_history) && numel(hit_history)<adaptive_trials && ~begin,                        
            s0 = find(gamma_pool == gamma_history(end));
            gamma_0 = adaptive_step_ratch(abs(gamma_pool(s0)), hit_history(end),...
                'hit_step', adapt_step, 'stableperf', target_prob(s0), ...
                'mx', 2.5, 'mn', 0, 'do_callback', 0) * signs(s0);
            gamma_pool(s0) = gamma_0;
            gamma_pool(numel(gamma_pool)+1-s0) = -gamma_0;
            disp(gamma_pool);
            adapt_step = adapt_step * adapt_tau;
            sample = mean(sample_range);           
        else
            samp_probs = sample_hits(s,:).*sample_misses(s,:)./((sample_hits(s,:)+sample_misses(s,:)).^3); 
            sample_num = find(cumsum(samp_probs)/sum(samp_probs) > rand(1), 1, 'first');
            sample = sample_list(sample_num);            
        end;
        begin = 0;

        [snd lrate rrate data] = make_pbup(R, gamma_pool(s), srate, sample, 'first_bup_stereo', stereo);
        io = pbups_observer(data.left, data.right, sample); % ideal observer: counts bups
        if strcmp(mode, 'gamma'),
            side = gamma_pool(s) > 0;
            if side == 0, side = -1; end;
        elseif strcmp(mode, 'counting')
            side = io; % correct side response: -1, 0, or +1
        end;
        
        trials = length(sample_history);
        sample_history = [sample_history; sample];
        gamma_history  = [gamma_history; gamma_pool(s)];
        observer       = [observer; io];
        side_history   = [side_history; side];
        stereo_history = [stereo_history; stereo];
        bupsdata{trials+1,1} = data;
        
        
        pause(0.75-sample);
        soundsc(snd', srate);
        state = 'Stim';
    end
        



%% stopsave function
    function stop_save()
        state = 'off';
        filename = get(hname, 'String');
        n = 1;
        while exist([filename sprintf('%d.mat', n)], 'file'),
            n = n+1;
        end;
        
        trials = min([length(hit_history) length(bupsdata)]);
        sample_history = sample_history(1:trials);
        gamma_history  = gamma_history(1:trials);
        observer       = observer(1:trials);
        side_history   = side_history(1:trials);
        stereo_history = stereo_history(1:trials);
        bupsdata = bupsdata(1:trials);
        went_right = went_right(1:trials);
        hit_history = hit_history(1:trials);
        
        save([filename sprintf('%d.mat', n)], 'hit_history', 'gamma_history', 'went_right', ...
			'side_history', 'sample_history', 'observer', 'bupsdata', 'mode', 'R', 'gamma_pool', ...
			'fixed_pool', 'stereo_history','adaptive_trials','adapt_step','sample_hits', ...
            'sample_misses','sample_list');
% 		psychoplot4(gamma_history, went_right);
	end

%% keypress
    function keypress(source, evnt)
        switch state,
            case 'ITI',
                if strcmp(evnt.Key, 'p')
                    uiresume()
                    set(hinstructions,'String',instructions,'fontsize',20)
                    state = 'instruct';
                elseif strcmp(evnt.Key,'escape'), stop_save(), close(f),bupsdata = bupsdata(1:length(hit_history)-1);    
                end
			case 'Stim',
				if strcmp(evnt.Key, 'leftarrow'),      response = -1;
				elseif strcmp(evnt.Key, 'rightarrow'), response = 1;
                elseif strcmp(evnt.Key,'escape'), stop_save(), close(f),bupsdata = bupsdata(1:length(hit_history)-1);
                elseif strcmp(evnt.Key, 'p')
                    response = 0;                   
                    set(hinstructions,'String',instructions,'fontsize',20)
                    state = 'instruct';
				else								   response = 0;
				end;
                
				set(htrials,'String',num2str(numel(hit_history)))
                
				if abs(response) > 0,
					went_right  = [went_right; (response==1)];
					s0 = find(gamma_pool == gamma_history(end));
                    samp0 = find(sample_list == sample_history(end));
					if side == 0,
						state = 'Reward';
						hit_history = [hit_history; 1];
                        sample_hits(s0,samp0) = sample_hits(s0,samp0)+1;
						reward_state;
					elseif side == response,
						state = 'Reward';
						hit_history = [hit_history; 1];
                        sample_hits(s0,samp0) = sample_hits(s0,samp0)+1;
						reward_state;
					else
						state = 'Punishment';
						hit_history = [hit_history; 0];
                        sample_misses(s0,samp0) = sample_misses(s0,samp0)+1;
						punish_state;
					end;
				end;
                
                
            case 'instruct'
                if strcmp(evnt.Key, 'return')
                    set(hinstructions, 'String','')
                    state = 'ITI';
                    begin_trial()
                elseif strcmp(evnt.Key,'escape')
                    stop_save()
                    close(f)
                    bupsdata = bupsdata(1:length(hit_history)-1);
                end
                    
        end;
	end

%% reward_state
    function reward_state
        set(hinstructions, 'String', 'Correct. Good Job!', 'ForegroundColor', [0 1 0], 'FontSize', 30);
        pause(ITI);
        state = 'ITI';
        set(hinstructions, 'String', '','ForegroundColor', [0 0 0]);
        begin_trial()
    end
	
	
%% punish_state    
    function punish_state
        set(hinstructions, 'String', 'Incorrect', 'ForegroundColor', [1 0 0], 'FontSize', 30);
        pause(ITI);
        state = 'ITI';
        set(hinstructions, 'String', '','ForegroundColor', [0 0 0]);
        begin_trial()
	end
        
end 


%% next_trial
function s = next_trial(hit_history, side_history, pprob, beta, tau)
	% fill in antibias code here
	s = find(cumsum(pprob)/sum(pprob) > rand(1), 1, 'first');

end