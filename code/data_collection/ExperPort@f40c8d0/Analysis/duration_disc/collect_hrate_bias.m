function [] = collect_hrate_bias(ttype,action)

if nargin < 2
    if nargin < 1
        ttype='duration';
    end;
    action='load';
end;

% I/O
global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;
outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep];

% colours
clr_singleavg=[1 1 1]*0; ...
    clr_singlesession=[1 0 0] ; ...
    msize=10;

if strcmpi(ttype,'duration')
    units='s';
    fmt='%1.2f';
else
    units='kHz';
    fmt='%1.2f';
end;


switch action
    case 'save'
        load([outdir 'weberout_' ttype]);
        if strcmpi(ttype,'duration'), mp=sqrt(200*500); else mp=sqrt(8*16); end;
        ratlist=fieldnames(weberdata);

        biasdata=0;
        for r=1:length(ratlist)
            curr=eval(['weberdata.' ratlist{r} ';']);
            nnan = find(~isnan(curr.replongs(:,1)));
            [s b]= sub__bias(ttype, curr.xmid, curr.overall_xmid);
            eval(['biasdata.' ratlist{r} '.persession= s;']);
            eval(['biasdata.' ratlist{r} '.overall=b;']);
        end;

        outf=[outdir 'biasout_' ttype '.mat'];
        save(outf,'biasdata','weberdata');

    case 'load_bias'
        mymetric='Bias';
        outf=[outdir 'biasout_' ttype '.mat'];
        load(outf);

        ratlist=fieldnames(biasdata);
        datalist=cell(size(ratlist));
        ovdata = NaN(size(ratlist));
        for r=1:length(ratlist)
            datalist{r}=eval(['biasdata.' ratlist{r} '.persession;']);
            ovdata(r)=eval(['biasdata.' ratlist{r} '.overall;']);

            if strcmpi(ttype,'duration'),
                datalist{r}=datalist{r}/1000;
                ovdata(r)=ovdata(r)/1000;
            end;
        end;

    case 'load_hrate'
        mymetric='Hrate';
        outf=[outdir 'hrateout_' ttype '.mat'];
        load(outf);

        ratlist=fieldnames(hratedata);
        datalist=cell(size(ratlist));
        ovdata = NaN(size(ratlist));
        for r=1:length(ratlist)
            datalist{r}=eval(['hratedata.' ratlist{r} '.persession;']);
            ovdata(r)=eval(['hratedata.' ratlist{r} '.overall;']);
        end;

    case 'save_hrate'
        mymetric='Accuracy';

        outf=[outdir 'weberout_' ttype '.mat'];
        load(outf);

        ratlist=fieldnames(weberdata);
        hratedata=cell(size(ratlist));
        for r=1:length(ratlist)


            rp=eval(['weberdata.' ratlist{r} '.replongs;']);
            tl=eval(['weberdata.' ratlist{r} '.tallies;']);
            if strcmpi(ratlist{r},'S036') % flipped rat
                rp=tl-rp;
            end;

            [h ovh]=sub__hitrate(rp,tl);
            eval(['hratedata.' ratlist{r} '.persession=h;']);
            eval(['hratedata.' ratlist{r} '.overall=ovh;']);
        end;

        outf=[outdir 'hrateout_' ttype '.mat'];
        save(outf,'hratedata','weberdata');
    otherwise
        error('invalid action');
end;

if strcmpi(action(1:4),'save')
    return;
end;

xpos=makebargroups(datalist, clr_singleavg);
line([-1 xpos(end)+3],[0 0],'LineStyle','-','Color', 'k','LineWidth',1);
minb=1000;
maxb=-1000;
for r=1:length(ratlist)
    buf=datalist{r};
    maxb=max(maxb,max(buf));
    minb=min(minb,min(buf));
    hold on;
    plot(ones(size(buf))*xpos(r), buf,'.k','MarkerSize',msize,'Color',clr_singlesession);
end;

uicontrol('Tag', 'figname', 'Style','text', 'String', [mymetric '_prelesion_' ttype '_indiv'], 'Visible','off');
title([ mymetric ' for week pre-lesion: ' ttype]);

% axis formatting
set(gca,'XTick',xpos, 'XTickLabel',1:length(xpos));
if strcmpi(mymetric,'Bias')
    
    ytk=-4:1:2;
    yl=[-4 2];
    ytklbl=ytk;
    if strcmpi(ttype,'duration')
        yl=[-120 100]/1000
        ytk=[-100:50:100]/1000;
        ytklbl=ytk;
    end;
else
    yl=[0.5 1];
    ytk=0.5:0.1:1;
    ytklbl=50:10:100;
    units = '%';
end;

set(gca,'YLim',yl,'YTick',ytk,'YTickLabel',ytklbl);

axes__format(gca);
ylabel([mymetric ' ' units]);
xlabel('Individual animal');
set(gcf,'Position',[360   596   708   262]);


% now group average
if strcmpi(ttype,'pitch'), ttype='frequency'; end;
clr=group_colour(ttype);
[x m s]=makebargroups({ovdata}, clr);hold on;
plot(ones(size(ovdata))*0.5, ovdata, 'or', 'MarkerSize',7,'LineWidth',1.3,'Color',clr_singleavg);
% for k=1:length(ratlist)
%     text(1.1, ovdata(k),ratlist{k});
% end;
line([-1.5 2.5],[0 0],'LineStyle','-','Color','k','LineWidth',1);
set(gca,'XLim',[-0.2 1.5]);


ylabel([mymetric ' ' units]);
set(gca,'YLim',[min(ovdata) max(ovdata)],'XTick',[]);

if strcmpi(mymetric,'bias')
    if strcmpi(ttype,'duration'), 
        ytk=[-0.1:0.05:0.1];
        set(gca,'YLim',[-0.12 ytk(end)],'YTick',ytk);
    else
        set(gca,'YLim',[-4 2],'YTick',-4:1:2);
    end;
else
    m=m*100;
    s=s*100;
    fmt='%2.1f';
    units='%';
    set(gca,'YLim',[0.5 1],'YTick',0.5:.1:1,'YTickLabel',50:10:100);
end;
xlabel(ttype);
fprintf(1,'%s\n',repmat('-',1,50));
fprintf(1,['Group average (n=%i) = ' fmt '(' fmt ') %s\n'], length(ratlist), m, s, units);
fprintf(1,'%s\n',repmat('-',1,50));

uicontrol('Tag', 'figname', 'Style','text', 'String', [mymetric '_prelesion_' ttype '_group'], 'Visible','off');
axes__format(gca);
set(gcf,'Position',[1020         602         189         327]);


function [sess_b b] = sub__bias(ttype, rm, ovmid)

sess_b=NaN(size(rm));
for k=1:length(rm)
    %     sess_b(k)=normalizedbias(bins,mp,replongs(k,:), tallies(k,:));
    sess_b(k)=sub__computebias(ttype,rm(k));
end;

% b=normalizedbias(bins,mp,sum(replongs,1), sum(tallies,1));
b = sub__computebias(ttype, ovmid);


function [b] = sub__computebias(ttype, rm)
if strcmpi(ttype(1),'d')

    b = exp(rm) - sqrt(200*500);

else
    b = 2.^(rm) - sqrt(8*16);
end;

function [sess_h h] = sub__hitrate(rp, tl)

nnan=find(~isnan(rp(:,1)));

if length(nnan) < rows(rp)
    2;
end;

sess_h = NaN(length(nnan),1);
h=NaN;

rp=rp(nnan,:);
tl=tl(nnan,:);

for k=1:rows(rp)
    try
        sht= sum(tl(k,1:4)) - sum(rp(k,1:4));
    catch
        2;
    end;


    lt=sum(rp(k,5:8));

    sess_h(k) = (sht+lt) / sum(tl(k,:));
end;

rp=sum(rp,1);
tl=sum(tl,1);

sht=sum(tl(1:4))-sum(rp(1:4));
lt=sum(rp(5:8));
h = (sht+lt) / sum(tl);

