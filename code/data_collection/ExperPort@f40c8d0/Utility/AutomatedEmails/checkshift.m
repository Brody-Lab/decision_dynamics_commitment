function output = checkshift(handles,varargin) %#ok<INUSD>

if nargin == 0; handles = []; end %#ok<NASGU>

if ~isfield(handles,'ratrig'); 
    ratrig = bSettings('get','RIGS','ratrig');
else 
    ratrig = handles.ratrig;
end
if isnan(ratrig); ratrig = 1; end

if ratrig == 1; allrignums = 1:38;
else            allrignums = 401:404;
end
dontcheckcalibration = [];

dsp = 1; 

RReg = bdata(['select ratname from ratinfo.rats where extant=1 and israt=',num2str(ratrig)]);

[WRT,WT,WST] = bdata(['select rat, tech, stoptime from ratinfo.water where date="',datestr(now,'yyyy-mm-dd'),'"']);
remrat = [];
for i=1:numel(WRT)
    if sum(strcmp(RReg,WRT{i})) == 0; 
        remrat(end+1) = i; %#ok<AGROW>
    end
end;
WRT(remrat) = [];
WT( remrat) = [];
WST(remrat) = [];


[SR,TS,RG] = bdata(['select ratname, timeslot, rig from ratinfo.schedule where date="',datestr(now,'yyyy-mm-dd'),'"']);
remrat = [];
for i=1:numel(SR)
    if sum(strcmp(RReg,SR{i})) == 0; 
        remrat(end+1) = i; %#ok<AGROW>
    end
end;
SR(remrat) = [];
TS(remrat) = [];
RG(remrat) = [];


[SRy,TSy,RGy] = bdata(['select ratname, timeslot, rig from ratinfo.schedule where date="',datestr(now-1,'yyyy-mm-dd'),'"']);
remrat = [];
for i=1:numel(SRy)
    if sum(strcmp(RReg,SRy{i})) == 0; 
        remrat(end+1) = i; %#ok<AGROW>
    end
end;
SRy(remrat) = [];
TSy(remrat) = [];
RGy(remrat) = [];


[SST,SED,SRT,SRG] = bdata(['select starttime, endtime, ratname, hostname from sessions where sessiondate="',datestr(now,'yyyy-mm-dd'),'"']);
remrat = [];
for i=1:numel(SRT)
    if sum(strcmp(RReg,SRT{i})) == 0; 
        remrat(end+1) = i; %#ok<AGROW>
    end
end;
SST(remrat) = [];
SED(remrat) = [];
SRT(remrat) = [];
SRG(remrat) = [];


[SSTy,SEDy,SRTy,SRGy] = bdata(['select starttime, endtime, ratname, hostname from sessions where sessiondate="',datestr(now-1,'yyyy-mm-dd'),'"']);
remrat = [];
for i=1:numel(SRTy)
    if sum(strcmp(RReg,SRTy{i})) == 0; 
        remrat(end+1) = i; %#ok<AGROW>
    end
end;
SSTy(remrat) = [];
SEDy(remrat) = [];
SRTy(remrat) = [];
SRGy(remrat) = [];


[SSRT,SSRG,SSST] = bdata(['select ratname, hostname, starttime from sess_started where sessiondate="',datestr(now,'yyyy-mm-dd'),'"']);
remrat = [];
for i=1:numel(SSRT)
    if sum(strcmp(RReg,SSRT{i})) == 0; 
        remrat(end+1) = i; %#ok<AGROW>
    end
end;
SSRT(remrat) = [];
SSRG(remrat) = [];
SSST(remrat) = [];


[TNR,TNG,TNS] = bdata(['select ratname, rigid, timeslot from ratinfo.technotes where datestr="',datestr(now,'yyyy-mm-dd'),'"']);
remrat = [];
for i=1:numel(TNR)
    if sum(strcmp(RReg,TNR{i})) == 0; 
        remrat(end+1) = i; %#ok<AGROW>
    end
end;
TNR(remrat) = [];
TNG(remrat) = [];
TNS(remrat) = [];


[TNRy,TNGy,TNSy] = bdata(['select ratname, rigid, timeslot from ratinfo.technotes where datestr="',datestr(now-1,'yyyy-mm-dd'),'"']);
remrat = [];
for i=1:numel(TNRy)
    if sum(strcmp(RReg,TNRy{i})) == 0; 
        remrat(end+1) = i; %#ok<AGROW>
    end
end;
TNRy(remrat) = [];
TNGy(remrat) = [];
TNSy(remrat) = [];


[MRT,MTC] = bdata(['select ratname, tech from ratinfo.mass where date="',datestr(now,'yyyy-mm-dd'),'"']);
remrat = [];
for i=1:numel(MRT)
    if sum(strcmp(RReg,MRT{i})) == 0; 
        remrat(end+1) = i; %#ok<AGROW>
    end
end;
MRT(remrat) = [];
MTC(remrat) = [];


[EX,IN] = bdata('select experimenter, initials from ratinfo.contacts where is_alumni=0');
[OTech,MTech,ETech] = bdata(['select overnight, morning, evening from ratinfo.tech_schedule where date="',datestr(now,'yyyy-mm-dd'),'"']);

[rigid,isbroken] = bdata('select rigid, isbroken from ratinfo.rig_maintenance order by broke_date desc');
remrig = [];
for i = 1:numel(rigid)
    if sum(allrignums == rigid(i)) == 0
        remrig(end+1) = i; %#ok<AGROW>
    end
end
rigid(   remrig) = [];
isbroken(remrig) = [];


brokerigs = rigid(isbroken == 1);
for i = 1:numel(brokerigs)
    TNR{end+1} = ''; %#ok<AGROW>
    TNS(end+1) = NaN; %#ok<AGROW>
    TNG(end+1) = brokerigs(i); %#ok<AGROW>
end

% if nargin > 2; 
%     s = get(handles.edit_window,'string');
%     s{end+1} = 'Checking Weights...';
%     set(handles.edit_window,'string',s); 
%     pause(0.1); 
% end
missingmass = checkratweights(1);

WL  = WM_rat_water_list([],[],'all',datestr(now,  'yyyy-mm-dd'),1);
WLy = WM_rat_water_list([],[],'all',datestr(now-1,'yyyy-mm-dd'),1);

% if nargin > 2; 
%     s{1} = get(handles.edit_window,'string');
%     s{end+1} = 'Checking Calibration...';
%     set(handles.edit_window,'string',s); 
%     pause(0.1); 
% end

lc = zeros(numel(allrignums),1); lc(:) = nan;
for i = allrignums
    if sum(RG == i) == 0; lc(i) = 0; continue; end
    if sum(dontcheckcalibration == i) == 1; lc(i) = 0; continue; end
    temp = check_calibration(i);
    if isnan(temp); lc(i) = Inf; continue; end 
    lc(i) = now - datenum(temp,'yyyy-mm-dd HH:MM:SS');
end

%convert sessions hostname into rig numbers
srg = [];
for i = 1:length(SRG);
    if length(SRG{i}) > 3; srg(i) = str2num(SRG{i}(4:end)); end %#ok<ST2NM,AGROW>
end
SRG = srg;
srgy = [];
for i = 1:length(SRGy);
    if length(SRGy{i}) > 3; srgy(i) = str2num(SRGy{i}(4:end)); end %#ok<ST2NM,AGROW>
end
SRGy = srgy;

%convert sess_started hostname into rig numbers
ssrg = [];
for i = 1:length(SSRG);
    if length(SSRG{i}) > 3; ssrg(i) = str2num(SSRG{i}(4:end)); end %#ok<ST2NM,AGROW>
end
SSRG = ssrg;

wst = [];
for i = 1:numel(WST)
    wst(i) = datenum(WST{i},'HH:MM:SS'); %#ok<AGROW>
end
WST = wst;

ssst = [];
for i = 1:numel(SSST)
    ssst(i) = datenum(SSST{i},'HH:MM:SS'); %#ok<AGROW>
end
SSST = ssst;

%Rig broken: 0=not broken, 1=broken no rats scheduled, 2=broken with rats scheduled
rigbroken = zeros(max(allrignums),1);
for i = allrignums
    temp = find(rigid == i,1,'first');
    if isempty(temp); continue; end
    rigbroken(i) = isbroken(temp);
    if rigbroken(i) == 1
        temp = SR(RG == i);
        if ~all(strcmp(temp,'')==1)
            rigbroken(i) = 2;
        end
    end
end

SESSDUR = cell(1,9);

SHIFTS = 'ABC';
for z = 1:3
    shift = SHIFTS(z);

    if     strcmp(shift,'A'); ws = [9,1:2]; ts = 1:3; es = 9;
    elseif strcmp(shift,'B'); ws = 3:5;     ts = 4:6; es = 3;
    else                      ws = 6:8;     ts = 7:9; es = 6;
    end

    if     strcmp(shift,'A'); MM = missingmass.overnight;
    elseif strcmp(shift,'B'); MM = missingmass.morning;
    else                      MM = missingmass.evening;
    end

%     if nargin > 2; 
%         s = get(handles.edit_window,'string');
%         s{end+1} = 'Checking Tech...';
%         set(handles.edit_window,'string',s); 
%         pause(0.1); 
%     end

    t = cell(0);
    for i = 1:numel(ts)
        sr = SR(TS == ts(i));
        sr(strcmp(sr,'')) = [];
        for j = 1:numel(sr)
            temp = strcmp(MRT,sr{j});
            if sum(temp) == 1; t(end+1) = MTC(temp); %#ok<AGROW>
            else               t{end+1} = ' '; %#ok<AGROW>
            end    
        end
    end
    for i = 1:numel(ws)
        if ws(i) == 9; wr = WLy{ws(i)};
        else           wr = WL{ws(i)};
        end
        wr = unique(wr);
        wr(strcmp(wr,'')) = [];
        for j = 1:numel(wr)
            temp = strcmp(WRT,wr{j});
            if sum(temp) == 1; t(end+1) = WT(temp); %#ok<AGROW>
            else               t{end+1} = ' '; %#ok<AGROW>
            end      
        end
    end    

    ut = unique(t);
    ut(strcmp(ut,' ')) = [];
    if ~isempty(ut)
        c = [];
        for i = 1:numel(ut)
            c(i) = sum(strcmp(t,ut{i})); %#ok<AGROW>
            if isempty(ut{i}); c(i) = 0; end %#ok<AGROW>
        end
        T = ut{find(c == max(c))};  %#ok<FNDSB>
        if ~strcmp(T,' ') && ~strcmp(T,'FW'); E = EX{strcmp(IN,T)};
        else                                  E = ' ';
        end
    else
        E = ' ';
    end

    wrongtech = 0;
    if     strcmp(shift,'A') && isempty(strfind(lower(OTech{1}),lower(E))); wrongtech = 1;
    elseif strcmp(shift,'B') && isempty(strfind(lower(MTech{1}),lower(E))); wrongtech = 1;
    elseif strcmp(shift,'C') && isempty(strfind(lower(ETech{1}),lower(E))); wrongtech = 1;
    end

%     if nargin > 2; 
%         s = get(handles.edit_window,'string');
%         s{end+1} = 'Checking Training...';
%         set(handles.edit_window,'string',s); 
%         pause(0.1); 
%     end

    SW = ones(1,9);
    MW = cell(0);
    for i = ws
        if strcmp(shift,'C') && i == 9
            R = unique(WLy{i}(:));
        else
            R = unique(WL{i}(:));
        end
        R(strcmp(R,'')) = [];
        mwc = 0;

        for j = 1:length(R)
            if sum(strcmp(WRT,R{j})) == 0
                mwc = mwc + 1;
                MW{end+1} = R{j}; %#ok<AGROW>
            end
        end
        if mwc > length(R)/2; SW(i) = 0; end
    end

    R = unique(WL{10}(:));
    R(strcmp(R,'')) = [];
    mfwc = 0;
    for j = 1:length(R)
        if sum(strcmp(WRT,R{j})) == 0
            mfwc = mfwc + 1;
        end
    end
    if mfwc > length(R)/2; FreeWaterChecked = 0; 
    else                   FreeWaterChecked = 1;
    end

    %Let's check that the first session for the tech was pulled out correctly
    RL = cell(0);
    RS = cell(0);
    RF = ones(1,9);

    rtlc = 0;
    rsc  = 0;

    if es == 9; R = SRy(TSy == es);
    else        R = SR( TS  == es);
    end
    R(strcmp(R,'')) = [];
    for j = 1:length(R)
        if es == 9; temp = strcmp(SRTy,R{j});
        else        temp = strcmp(SRT, R{j});
        end
        if sum(temp) > 0
            if es == 9
                st = SSTy(temp);
                ed = SEDy(temp);
            else
                st = SST(temp);
                ed = SED(temp);
            end

            dur = zeros(size(st));
            for k = 1:length(st)
                temp = (datenum(ed{k}) - datenum(st{k}));
                if temp < 0
                    dur(k) = 1 + temp;
                else
                    dur(k) = temp;
                end
            end
            mdur = max(dur);
            dur  = sum(dur);
            if mdur * 24 > 5
                %ran too long
                rtlc = rtlc + 1;
                RL{end+1} = R{j}; %#ok<AGROW>
            elseif dur *24 < 1
                %ran too short
                rsc = rsc + 1;
                RS{end+1} = R{j}; %#ok<AGROW>
            end
        end
    end
    if rsc  > length(R)/2; RF(es) = 0; end

    %Let's check all is good with sessions that are supposed to be trained
    MT = cell(0);
    WR = cell(0);
    ST = ones(1,9);

    for i = ts
        R = SR(TS == i);
        G = RG(TS == i);
        bad = strcmp(R,'');
        R(bad) = [];
        G(bad) = [];
        mrtc = 0;
        rsc  = 0;

        for j = 1:length(R)
            %last session the tech doesn't pull out, just check if started 
            if i == ts(end); temp = strcmp(SSRT,R{j});
            else             temp = strcmp(SRT,R{j});
            end

            if sum(temp) == 0
                mrtc = mrtc + 1;
                MT{end+1} = R{j}; %#ok<AGROW>
            else
                if i == ts(end); realrig = SSRG(temp);
                else             realrig = SRG(temp);
                end

                if all(realrig ~= G(j))
                    WR{end+1} = R{j}; %#ok<AGROW>
                end

                if i ~= ts(end)
                    st = SST(temp);
                    ed = SED(temp);
                    dur = 0;
                    for k = 1:length(st)
                        dur = dur + (datenum(ed{k}) - datenum(st{k}));
                    end
                    SESSDUR{i}(end+1) = dur;
                    if (dur > 0 && dur * 24 < 1) || (dur < 0 && 24 + (24 * dur) < 1)
                        rsc = rsc + 1;
                        RS{end+1} = R{j};  %#ok<AGROW>
                    end
                end
            end
        end

        if rsc  > length(R)/2; RF(i) = 0; end
        if mrtc > length(R)/2; ST(i) = 0; end
    end

    MM = unique(MM); %missed mass (weighing)
    MW = unique(MW); %missed watering
    MT = unique(MT); %missed training
    WR = unique(WR); %wrong rig
    RS = unique(RS); %run short
    RL = unique(RL); %run long

    %If the rat runs in the wrong rig either you need a technote or the rig
    %needs to be flagged as broken
    RatWRigTN = cell(0);
    for i = 1:length(TNG)
        temp = SR(RG == TNG(i));
        temp(strcmp(temp,'')) = [];
        RatWRigTN(end+1:end+length(temp)) =  temp;
    end
    for i = allrignums
        if rigbroken(i) > 0
            temp = SR(RG == i);
            temp(strcmp(temp,'')) = [];
            RatWRigTN(end+1:end+length(temp)) =  temp;
        end
    end
    RatWRigTNy = cell(0);
    for i = 1:length(TNGy)
        temp = SRy(RGy == TNGy(i));
        temp(strcmp(temp,'')) = [];
        RatWRigTNy(end+1:end+length(temp)) =  temp;
    end
    for i = allrignums
        if rigbroken(i) > 0
            temp = SRy(RGy == i);
            temp(strcmp(temp,'')) = [];
            RatWRigTNy(end+1:end+length(temp)) =  temp;
        end
    end
    

    RatWSesTN = cell(0);
    for i = 1:length(TNS)
        temp = SR(TS == TNS(i));
        temp(strcmp(temp,'')) = [];
        RatWSesTN(end+1:end+length(temp)) =  temp;
    end
    RatWSesTNy = cell(0);
    for i = 1:length(TNSy)
        temp = SRy(TSy == TNSy(i));
        temp(strcmp(temp,'')) = [];
        RatWSesTNy(end+1:end+length(temp)) =  temp;
    end

    P = cell(0); 
    spacecount = 0;

    addspace = 0;
    if wrongtech == 1; addspace = 1; P{end+1} = 'Wrong Tech in Schedule. MUST BE FIXED'; end %#ok<AGROW>
    if addspace == 1; P{end+1} = ' '; spacecount = spacecount + 1; end %#ok<AGROW>

    addspace = 0;
    %Free water is primary responsibility of C
    if strcmp(shift,'B') || strcmp(shift,'C')
        if FreeWaterChecked == 0; addspace = 1; P{end+1} = 'Free Water rats not checked.'; end %#ok<AGROW>
    end
    if addspace == 1; P{end+1} = ' '; spacecount = spacecount + 1; end %#ok<AGROW>

    addspace = 0;
    for i = ts
        if any(TNS == i); X = ''; else X = 'NO TECH NOTE'; end
        if ST(i) == 0; addspace = 1; P{end+1} = ['Session ',num2str(i),' was not trained. ',X]; end %#ok<AGROW>
        if RF(i) == 0; addspace = 1; P{end+1} = ['Session ',num2str(i),' ran less than 1 hour. ',X]; end %#ok<AGROW>
    end
    for i = ws
        if any(TNS == i); X = ''; else X = 'NO TECH NOTE'; end
        if SW(i) == 0; addspace = 1; P{end+1} = ['Session ',num2str(i),' was not watered. ',X]; end %#ok<AGROW>
    end
    if addspace == 1; P{end+1} = ' '; spacecount = spacecount + 1; end %#ok<AGROW>

    addspace = 0;
    for i = allrignums
        if sum(TNG == i) == 0; X = 'NO TECH NOTE'; else X = ''; end
        if lc(i) > 100; addspace = 1; P{end+1} = ['Rig ',num2str(i),' needs calibration. ',X]; end %#ok<AGROW>
    end
    if addspace == 1; P{end+1} = ' '; spacecount = spacecount + 1; end   %#ok<AGROW>

    addspace = 0;
    for i = 1:length(MM)
        if sum(strcmp(TNR,MM{i})) > 0 || sum(strcmp(RatWSesTN,MM{i})) > 0; X = ''; else X = 'NO TECH NOTE'; end
        P{end+1} = [MM{i},' was not weighed. ',X]; %#ok<AGROW>
        addspace = 1;
    end
    if addspace == 1; P{end+1} = ' '; spacecount = spacecount + 1; end %#ok<AGROW>

    addspace = 0;
    for i = 1:length(MW)
        if sum(strcmp(TNR,MW{i})) > 0 || sum(strcmp(RatWSesTN,MW{i})) > 0; X = ''; else X = 'NO TECH NOTE'; end
        P{end+1} = [MW{i},' was not watered. ',X]; %#ok<AGROW>
        addspace = 1;
    end
    if addspace == 1; P{end+1} = ' '; spacecount = spacecount + 1; end %#ok<AGROW>

    addspace = 0;
    for i = 1:length(MT)
        try
            if sum(strcmp(TNR,MT{i})) > 0 ||... 
               sum(strcmp(RatWSesTN,MT{i})) > 0 ||... 
               sum(TNG == RG(strcmp(SR,MT{i}))) > 0 ||...
               sum(strcmp(RatWRigTN,MT{i})) > 0; X = ''; else X = 'NO TECH NOTE'; 
            end
        catch; X = 'NO TECH NOTE';
        end
        P{end+1} = [MT{i},' was not trained. ',X]; %#ok<AGROW>
        addspace = 1;
    end
    if addspace == 1; P{end+1} = ' '; spacecount = spacecount + 1; end %#ok<AGROW>

    addspace = 0;
    for i = 1:length(WR)
        if ~isempty(find(strcmp(SSRT,WR{i})==1,1,'first')) && ...
           (sum(strcmp(TNR,WR{i})) > 0 ||...
           sum(strcmp(RatWRigTN,WR{i})) > 0 ||...
           sum(TNG == SSRG(find(strcmp(SSRT,WR{i})==1,1,'first'))) > 0); X = ''; else X = 'NO TECH NOTE'; end %#ok<ALIGN>
        if isempty(find(strcmp(SSRT,WR{i})==1,1,'first')) && sum(strcmp(TNR,WR{i})) > 0
            %This is an odd case where the rat ended but was not started.
            %Let's see if there's a note for just the rat.
            X = '';
        end
        P{end+1} = [WR{i},' trained in the wrong rig. ',X]; %#ok<AGROW>
        addspace = 1;
    end
    if addspace == 1; P{end+1} = ' '; spacecount = spacecount + 1; end %#ok<AGROW>

    addspace = 0;
    for i = 1:length(RS)
        temp=strcmp(SRy,RS{i});
        if sum(temp)>0
            tsy = TSy(temp);
        else
            tsy = 0;
        end
            
        if tsy == 9
            if sum(strcmp(TNRy,RS{i})) > 0  ||...
               sum(strcmp(RatWSesTN,RS{i})) > 0 ||...
               sum(anyequal(TNGy,SRGy(find(strcmp(SRTy,RS{i})==1,1,'first')))) > 0 ||...
               sum(strcmp(RatWRigTN,RS{i})) > 0; X = ''; else X = 'NO TECH NOTE'; end %#ok<ALIGN>
        else

            if sum(strcmp(TNR,RS{i})) > 0  ||...
               sum(strcmp(RatWSesTN,RS{i})) > 0 ||...
               sum(anyequal(TNG,SRG(strcmp(SRT,RS{i})))) > 0 ||...
               sum(strcmp(RatWRigTN,RS{i})) > 0; X = ''; else X = 'NO TECH NOTE'; end %#ok<ALIGN>
        end
        P{end+1} = [RS{i},' trained for less than 1 hour. ',X]; %#ok<AGROW>
        addspace = 1;
    end
    if addspace == 1; P{end+1} = ' '; spacecount = spacecount + 1; end %#ok<AGROW>

    addspace = 0;
    for i = 1:length(RL)
        if sum(strcmp(SRT,RL{i}))> 0
            ratpos_sess = find(strcmp(SRT,RL{i})==1,1,'first');
            srg = SRG(ratpos_sess);
        else
            ratpos_sess = find(strcmp(SRTy,RL{i})==1,1,'first');
            srg = SRGy(ratpos_sess);
        end
        
        if sum(strcmp(TNR,RL{i})) > 0  ||...
           sum(strcmp(RatWSesTN,RL{i})) > 0 ||...
           sum(TNG == srg) > 0 ||...
           sum(strcmp(RatWRigTN,RL{i})) > 0; X = ''; else X = 'NO TECH NOTE'; end %#ok<ALIGN>
        P{end+1} = [RL{i},' trained for more than 5 hours. ',X]; %#ok<AGROW>
        addspace = 1;
    end
    if addspace == 1; P{end+1} = ' '; spacecount = spacecount + 1; end %#ok<AGROW>

    if dsp == 1
        if isempty(P)
            disp(['No problems discovered for the ',shift,' shift.']);
        else
            disp([num2str(length(P)-spacecount),' problems discovered for the ',shift,' shift.']);
            disp(' ');
            for i = 1:length(P)
                disp(P{i}); 
            end
        end
        disp(' ');
    end
    
    
    if strcmp(shift,'A'); R = SRy(TSy == es);
    else                  R = SR( TS  == es);
    end
    R(strcmp(R,'')) = []; 
    ss = [];
    for j = 1:numel(R)
        
        if strcmp(shift,'A'); temp = strcmp(SRTy,R{j});
        else                  temp = strcmp(SRT, R{j});
        end
        if sum(temp) == 1
            if strcmp(shift,'A'); ss(j) = datenum(SEDy{temp},'HH:MM:SS'); %#ok<AGROW>
            else                  ss(j) = datenum(SED{ temp},'HH:MM:SS'); %#ok<AGROW>
            end
        end
    end
    ss = sortrows(ss');
    if     numel(ss)  > 1; SS = ss(2);
    elseif numel(ss) == 1; SS = ss(1);
    else                   SS = nan;
    end
    
    R = WL{ws(end)};
    R = R(:);
    R(strcmp(R,'')) = [];
    wst = [];
    for j = 1:numel(R)
        temp = strcmp(WRT,R{j});
        if sum(temp) > 0
            wst(j) = max(WST(temp)); %#ok<AGROW>
        end
    end
    wst = sortrows(wst');
    if     numel(wst)  > 1; SEw = wst(end-1);
    elseif numel(wst) == 1; SEw = wst(end);
    else                    SEw = nan;
    end
    
    
    R = SR(TS == ts(end));
    R(strcmp(R,'')) = [];
    tst = [];
    for j = 1:numel(R)
        temp = strcmp(SSRT,R{j});
        if sum(temp) > 0
            tst(j) = max(SSST(temp)); %#ok<AGROW>
        end
    end
    tst = sortrows(tst');
    if     numel(tst)  > 1; SEt = tst(end-1);
    elseif numel(tst) == 1; SEt = tst(end);
    else                    SEt = nan;
    end
    
    if      isnan(SEt) && ~isnan(SEw); SE = SEw;
    elseif ~isnan(SEt) &&  isnan(SEw); SE = SEt;
    elseif  isnan(SEt) &&  isnan(SEw); SE = nan;
    else                               SE = max([SEt,SEw]);
    end
    
    if isnan(SS) || isnan(SE)
        SD = nan;
    else
        if strcmp(shift,'A'); SD = 24 * (1 - (SS - SE));
        else                  SD = 24 * (SE - SS);
        end
    end
    
    stats.duration = SD;
    
    if     strcmp(shift,'A'); stats.train = mean([mean(SESSDUR{1}*24*60),mean(SESSDUR{2}*24*60)]);
    elseif strcmp(shift,'B'); stats.train = mean([mean(SESSDUR{4}*24*60),mean(SESSDUR{5}*24*60)]);
    else                      stats.train = mean([mean(SESSDUR{7}*24*60),mean(SESSDUR{8}*24*60)]);
    end
    % 
    % clear x
    % x = checkrundurations(yearmonthday,yearmonthday,0,0); %#ok<NASGU>
    % z = eval(['x.',shift]);
    % 
    % S{1} = ['Shift duration:    ',num2str(floor(z.length)), ' hours   ',num2str(round((z.length-floor(z.length))*60)),' minutes'];
    % S{2} = ['Average Training: ',num2str(floor(z.average)), ' minutes ',num2str(round((z.average-floor(z.average))*60)),' seconds'];
    % S{3} = ['Average Clawback: ',num2str(floor(z.clawback)),' minutes ',num2str(round((z.clawback-floor(z.clawback))*60)),' seconds'];
    % 
    % if dsp == 1;
    %     for i = 1:length(S);
    %         disp(S{i});
    %     end
    % end

    eval(['output.',shift,'.problems = P;']);
    eval(['output.',shift,'.stats    = stats;']);
    eval(['output.',shift,'.spacecount = spacecount;']);

end

disp('COMPLETE');

function output = anyequal(A,B)
output = zeros(size(A));
for i = 1:numel(A)
    output(i) = sum(B == A(i));
end
