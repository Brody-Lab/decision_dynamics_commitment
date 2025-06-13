function [obj] = analyze_hit_history(obj, mode)

% Presents the history of the hit rate for the current protocol
% Required variables:
%

% h = findobj('Tag', 'GO_but');
% set(h, 'BackgroundColor', col);
% return;

GetSoloFunctionArgs;

FIG_WIDTH = 300;
FIG_HEIGHT = 150;
FIG_X = 500;
FIG_Y = 500;

me = lower(mfilename);
fig_name = ['fig_' me];

fig = findobj('Tag', fig_name);
lpos = 10;
upos = FIG_HEIGHT-30;

guys = [10 20 40 80];

my_owner = determine_owner;
my_funcname = determine_fullfuncname;

% create
if isempty(fig)
    fig = figure('Tag', fig_name, 'Position', [FIG_X FIG_Y FIG_WIDTH FIG_HEIGHT], ...
        'Toolbar', 'none', 'Menubar', 'none', ...
        'Name', 'Hit History');

    ctr = 1;
    % instantiate all reward counters
    for i=1:length(guys),
        pname = ['AN_Last' num2str(guys(i))];
        lbl = ['Last ' num2str(guys(i))];
        tt = ['Hit rate for last ' int2str(guys(i)) ' trials'];
        ed = EditParam(obj, pname, 0, lpos, upos, 'label', lbl, ...
            'labelpos', 'left', 'TooltipString', tt);
        set(get_ghandle(ed), 'Enable', 'inactive');
        % assign permanent name
        pairs = { pname, ed }; parse_knownargs({}, pairs);
        upos = upos - 20;
    end;

    b= PushbuttonParam(obj, 'closer', lpos, upos, 'label', 'Close me');
    set(get_ghandle(b), 'Callback', 'close');

end;

% >> BEGIN COPY OF RewardsSection.m
evs = value(LastTrialEvents);
rts = value(RealTimeStates);

if size(evs,1) == 0 
    return;
end;

% Find first left-right response after tone:
u = find(evs(:,1)==rts.wait_for_apoke  & (evs(:,2)==3 | evs(:,2)==5));
if isempty(u), % no wat-for-answer poke, must've been direct delivery
    % Find dirdel state and first left-right response after that
    u  = find(evs(:,1)==rts.left_dirdel  |  evs(:,1)==rts.right_dirdel);
    if isempty(u), error(['No wait-for-answer, no dir del state!']); end;
    u2 = find(evs(u(1):end,2)==3  |  evs(u(1):end,2)==5);
    if isempty(u2), error('No left-right answer after dir del state!'); end;
    u = u2(1) + u(1)-1;
end;
% Now, did we go right when right was correct or left when left was
% correct?
if      (evs(u(1),2)==3  &  side_list(n_done_trials)==1)  |  ...
        (evs(u(1),2)==5  &  side_list(n_done_trials)==0),
    hit_history(n_done_trials) = 1;
else
    hit_history(n_done_trials) = 0;
end;

u1 = find(evs(:,1) == rts.left_reward);
u2 = find(evs(:,1) == rts.right_reward);

% Count rewards
%if ~isempty(u1), LeftRewards.value  = LeftRewards+1;  end;
%if ~isempty(u2), RightRewards.value = RightRewards+1; end;
%if ~isempty(u1) | ~isempty(u2),
%    Rewards.value = Rewards+1;
%end;

% Update the GUI
for del=[10 20 40 80],
    mn = max([1 n_done_trials-del]);
    muhits = mean(hit_history(mn:n_done_trials));
    eval(['AN_Last' num2str(del) '.value = muhits;']);
end;

% << END COPY OF RewardsSection.m

% update - controls updated in the same order as they were created above
%for i=1:length(guys),
%     pname = ['Last' num2str(guys(i))];
%     trials = max(Trials-guys(i)+1, 1):Trials;
%     tmp = 0;
%     if trials > 0
%         tmp = mean(Hits(trials));
%     end;
%
%     eval([pname '.value = tmp;']);
% end;


