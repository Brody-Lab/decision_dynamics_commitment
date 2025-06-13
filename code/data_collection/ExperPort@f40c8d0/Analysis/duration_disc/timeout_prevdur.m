function [] = timeout_prevdur(ratname, from, to)
% Gets the duration of "cue" state preceding all timeouts occurring in that
% state
% FOr each session, returns the 75th percentile of the duration of the
% preceeding cue.
% In effect, answers the question, "how long into the cue state does this
% animal time out most of the time?"
% change timeout_state to return the same information for another
% RealTimeState.

flist = get_files(ratname, 'fromdate', from, 'todate', to);

mdur = [];
for f=1:length(flist)
    t=timeout_state(ratname, flist{f});
    tsort=sort(t);
    pt=floor(length(tsort)*0.75);
    mdur=horzcat(mdur, tsort(pt));
end;

2;

% S032 - 081130 to 081205
%mdur =
%0.5035    0.5137    0.5352    0.5350    0.5387    0.5000
% S036
% mdur =
% 
%     0.5245    0.5302    0.5052    0.5117    0.5010
