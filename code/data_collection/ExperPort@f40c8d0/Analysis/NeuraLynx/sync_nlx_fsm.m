function sync_nlx_fsm(fldr,force,forcevideo)
% sync_nlx_fsm
olddir=pwd;
if ~exist('fldr','var')
    fldr=uigetdir('Please select a folder to process.');
end

if nargin<2
    force=0;
    forcevideo=0;
end
if nargin<3,
    forcevideo=force;
end;
if force
    error('sync_nlx_fsm aborted: force is temporarily disabled until clearphys bug is fixed');
end
nofldr=1;
while nofldr
    try
        if fldr==0 % then they cancelled
            return
        end

        cd(fldr)
        nofldr=0;
    catch
        fldr=uigetfolder('Please select a folder to process.');
    end
end

%% Try to guess the ratname and sessiondate
last_s=find(fldr=='\',2,'last');
last_u=find(fldr=='_',1,'last');
s_date=fldr(last_s(end)+1:last_u-1);
r_name=fldr(last_s(1)+1:last_s(2)-1);

[ratname,sessid,sessiondate]=bdata('select ratname,sessid,sessiondate from sessions where ratname="{S}" and sessiondate = "{S}"' ,r_name,s_date);
if isempty(sessid)
    %% Find the name of the data file
    bf=dir('data*mat');
    if isempty(bf) || numel(bf)>1
        [bfile, p, filterindex] = uigetfile('*.mat', 'Pick an data file');
        bf.name=[p bfile];
    end

    %% get the sessid and sessiondate
    % THIS IS GOING TO BE MESSY WITH RUNNING TWICE
    %[sessid,sessiondate]=bdata('select sessid,sessiondate from sessions where hostname like "Rig06" and data_file like "{S}"',[bf.name(1:end-4) '%']);
    %[rat,exper,date]=parse_filename(bf.name);

    [ratname,sessid,sessiondate]=bdata('select ratname,sessid,sessiondate from sessions where data_file like "{S}"',[bf.name(1:end-4) '%']);
if isempty(sessid)
    %     sdate=inputdlg('Could not find the session.  Please enter the date of the session'
    %     [sessid,sessiondate]=bdata('select sessid,sessiondate from sessions where data_file like "{S}"',[bf.name(1:end-4) '%']);
    %
    error('Did not find session that matched data file %s',bf.name(1:end-4));

end
end

if numel(sessid)>1
    [ratname,sessid,sessiondate]=bdata('select a.ratname,a.sessid,a.sessiondate from sessions a, ratinfo.phys p where a.sessid=p.sessid and a.ratname="{S}" and sessiondate = "{S}"' ,r_name,s_date);
end
ratname=ratname{1};

% We have to remove the .mat extension.


%% which EIB was being recorded from

[eibid, eib_num]=bdata('select eibid, eib_num from ratinfo.eibs where ratname="{S}"',ratname);
if isempty(eibid)
    error('You must have an eibid for this rat');
end
if numel(eibid)>1
    % let's try to guess from the dir name

    ask_user=1;

    eibids_from_ps=bdata('select eibids from ratinfo.phys where sessid="{S}"',sessid);
    if ~isempty(eibids_from_ps)
        eibid=str2num(eibids_from_ps{1});
        ask_user=0;
    else
        try
            fldr_color=cell2mat(regexpi(fldr,'black|red','match'));
            eib_clrs=cell2mat(eib_num);
            eib_clrs=eib_clrs(:,end);
            if ~isempty(fldr_color)
                eibid=eibid(regexpi(eib_clrs',fldr_color(1)));
                ask_user=0;
            end
        

        catch
        end    %auto check failed.  ask user.
    end

    if ask_user==1;
        inpstr='There are multiple EIBs for this rat. Please enter the indices of the EIBs recorded from in order seperated by spaces. (eg. 3 1 2):';
        for ex=1:numel(eibid)
            inpstr=[inpstr sprintf('\n%d) %s', ex, eib_num{ex})];
        end
        eib_list=inputdlg(inpstr);
        eib_list=sscanf(eib_list{1},'%d');
        eibid=eibid(eib_list);
    end
end
drawnow;
%% make sure the sessiondates match
% the fldr containing the spike files must be named according to the
% Neuralynx convention, where the first ten characters are
% 'YYYY-MM-DD' (the full format is 'YYYY-MM-DD_HH-MM-SS', but the time of
% day is necessary here)


if ispc, slash = '\';
else     slash = '/';
end;

n = find(fldr==slash, 1, 'last');
fldrdate = fldr(n+1:n+10);
if ~strcmp(sessiondate, fldrdate),
    error('SYNCNLX:sessiondatemismatch', 'Sessiondates from the data file and the directory do not match!\n  Cannot proceed with this inconsistency.');
end;


%% Process events

evf=dir('Events.nev');
% rec_date=fldr(end-18:end-9);
% rec_date=datenum(rec_date);
% if rec_date>datenum('2008-10-
if isempty(evf) || numel(evf)>1
    [f, p, filterindex] = uigetfile('*.?ev', 'Pick an NLX events file');
    evf=[];
    evf.name=[p f];
end
fprintf('Loading the events file.\n')
[ts, ttls]=nev2mat(evf.name);

fprintf('Processing sync pulses.\n')
[ttimes, tnums]=trialnumtimes(ts, ttls);

% make sure that the sync worked
% often the 'last' tnum is bad - not sure why check this out

if tnums(end)==0
    ttimes=ttimes(1:end-1);
    tnums=tnums(1:end-1);
end





if numel(unique(diff(tnums))) ~=1 || unique(diff(tnums))~=1
    fprintf('Some funky sync issues... trying to fix\n');
    % Check if the adjacent trial nums are unambigious
    badt=find(diff(tnums)~=1);
    badt=badt(2:2:end);
    for bx=1:numel(badt)
        % if the adjacent #s make sense just fix the one in the middle
        if (tnums(badt(bx)+1)-tnums(badt(bx)-1))==2
            tnums(badt(bx))=tnums(badt(bx)-1)+1;
        end
    end

    % duplicate trial #:
    % if there is some trial n0 that is followed by m trials n1, n2, nm and then trial n+m+1,
    % we replace n1 through nm with n+1, n+2,...n+m
    t_nums = [tnums; tnums(end)+(sum(tnums(end)==tnums))];
    dtnums = diff(t_nums);
    nm1_entries = find(dtnums>1);
    %     for i = 1:length(nm1_entries);
    %         m_val = t_nums(nm1_entries(i)+1);
    %         dm_val = dtnums(m_val-1);
    %         n_val = t_nums(m_val-dm_val);
    %         dn_window = dtnums(n_val:(m_val-2));
    %         if unique(dn_window)==0;
    %             n_window = (n_val+1):(m_val-1);
    %             tnums((n_val+1):(m_val-1)) = n_window;
    %         end;
    %     end;
    %%%%% old code... %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     dtnums = diff(tnums);                                 %
    %     bad = find(dtnums==0);                                %
    %     for i = 1:numel(bad),                                 %
    %         if dtnums(bad(i)+1) == 2,                         %
    %             tnums(bad(i)+1) = tnums(bad(i)) + 1;          %
    %         end;                                              %
    %     end;                                                  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if any(diff(tnums)~=1)
        warning('SYNCNLX:badttls','Duplicate trial #.\nThere is a serious issue with the reliability of the sync signal');
        keyboard
    else
        warning('SYNCNLX:badttls','Fixed bad sync data.  If this is unexpected, please investigate.');
        notes{1}='Fixed bad sync data.';
        % at some point stick these notes into phys_sess
    end
end


%% Process spikes and events

% First get the parsed events and calcuate the sync
peh=get_peh(sessid);
scaled_ttimes=ttimes/1e6;

% WE HATE MATLAB.
% The time that comes out of NLX is in us since 1970, which hurts matlabs
% floating point precision.  This resulted in the regression failing due to
% tolerance issues.  Scaling fixes that.

tms=extract_send_times(peh);
if numel(tnums)>numel(tms)
    fprintf(1,'Some data was lost from end of data file\n');
    tnums=tnums(1:numel(tms));
    scaled_ttimes=scaled_ttimes(1:numel(tms));
end
rtms=tms(tnums); % this takes care of the case where recording was only on for part of the behavior session
[r1,r2,r3]=regress(rtms, [scaled_ttimes ones(size(scaled_ttimes))]);

% Residuals were bowed, so discarding was silly.  Maybe look into
% non-linearity of drift of FSM clock - jce april 15, 2008
%ex_out=find(abs(r3)<2*std(r3));
%[r1,r2,r3]=regress(rtms(ex_out), [scaled_ttimes(ex_out) ones(size(ex_out))]);
r1(1)=r1(1)/1e6;
fprintf('Processing spikes\n');
[err]=process_spikes(sessid,pwd, r1,force,eibid);
fprintf('Finished processing spikes\n');


%% calculate bad ISIs and overlap
post_process_spikes(sessid,force);

%% Process video tracker coordinates
fprintf('Processing Video\n')
[verr] = process_video(sessid, pwd, r1, forcevideo);
fprintf('Finished processing Video\n')

%% Process video tracker targets
fprintf('Processing Video\n')
%[verr] = process_raw_video(sessid, pwd, r1, forcevideo);
fprintf('Finished processing Video\n')

%% Traverse up
cd(olddir)

%% convert_peh

function tms=extract_send_times(peh)

tms=zeros(numel(peh),1);

for ti=1:numel(peh)

    tms(ti)=peh(ti).states.sending_trialnum(1);
end




