function varargout = blob(varargin)
% Opt
% Optical imaging analysis
%
% ZF Mainen 07/01
%
% BLOB ANALYSIS
%
% analysis functions
% ------------------
% blob('correl',sweeps1,sweeps2)
% blob('dist_geom',sweeps1,sweeps2)
% blob('cluster',sweeps1,sweeps2,...,sweepsn)
% blob('winners',sweeps1,sweeps2...,sweepsN)	% plot blobs as filled circles with
%																	% colors assigned to the strongest
%																	% odor (sweep) for each blob
% blob('map',sweeps,hue,thresh)	 plot blobs as filled circles with
%														 color hue, only if < thresh
% blob('imap',sweeps,range)	 plot blobs as filled circles with
%												 fill color reflecting intensity
%												 range is [min max]
% blob('tuning',sweeps1,sweeps2,...,sweepsN)		lines connecting sweeps
% blob('matrix',sweeps1,sweeps2,...,sweepsN)


global exper

if nargin > 0
	action = lower(varargin{1});
else
	action = lower(get(gcbo,'tag'));
end

%fig=findobj('tag','opt_ratio_fig');

switch action
	
case {'init','reinit'}
	
	% blob is after optical
	SetParam(me,'priority',7); 

	fig = ModuleFigure(me,'visible','off');	
	
    hs = 60;
	h = 5;
	vs = 20;
    n = 0;
    
    uicontrol(fig,'style','pushbutton','string','Ratio(param)','callback',[me ';'],'tag','x_plot','pos',[h n*vs hs*2 vs]); n=n+1;
    uicontrol(fig,'style','pushbutton','string','Correl(s1,s2)','callback',[me ';'],'tag','correl','pos',[h n*vs hs*2 vs]); n=n+1;
      % group 1
    uicontrol(fig,'style','text','string','group 1','horiz','left','pos',[h+hs+5 n*vs hs vs]); 
    uicontrol(fig,'style','popupmenu','string',{'Press Group/update'},'value',1,'background','white',...
        'tag','group_1','user','group','callback',[me ';'],'pos',[h n*vs hs vs]); n=n+1;
  
    % group 2
    uicontrol(fig,'style','text','string','group 2','horiz','left','pos',[h+hs+5 n*vs hs vs]); 
    uicontrol(fig,'style','popupmenu','string',{'Press Group/update'},'value',1,'background','white',...
        'tag','group_2','user','group','callback',[me ';'],'pos',[h n*vs hs vs]); n=n+1;
  
    
    uicontrol(fig,'style','text','string','Analysis functions','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1.5;
    
    uicontrol(fig,'style','pushbutton','string','cluster','callback',[me ';'],'tag','cluster','pos',[h+hs n*vs hs vs]); 
  
    uicontrol(fig,'style','pushbutton','string','matrix','callback',[me ';'],'tag','matrix','pos',[h n*vs hs vs]); n=n+1;
    uicontrol(fig,'style','text','string','range','horiz','left','pos',[h+hs+15 n*vs hs vs]); 
    uicontrol(fig,'style','edit','string','0.003','background','white',...
        'tag','range','horiz','right','callback',[me ';'],'pos',[h n*vs hs+15 vs]); n=n+1;
    uicontrol(fig,'style','text','string','format','horiz','left','pos',[h+hs+15 n*vs hs vs]); 
    uicontrol(fig,'style','popupmenu','string',{'mean','mean,sd'},'value',1,'background','white',...
        'tag','format','callback',[me ';'],'pos',[h n*vs hs+15 vs]); n=n+1;
    uicontrol(fig,'style','text','string','normalize','horiz','left','pos',[h+hs+15 n*vs hs vs]); 
    uicontrol(fig,'style','popupmenu','string',{'none','blob','group','blob_sel'},'value',1,'background','white',...
        'tag','normalize','callback',[me ';'],'pos',[h n*vs hs+15 vs]); n=n+1;
    

    uicontrol(fig,'style','text','string','Display','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1.5;
  
    uicontrol(fig,'style','text','string','measure','horiz','left','pos',[h+hs+15 n*vs hs vs]); 
    uicontrol(fig,'style','popupmenu','string',{'ratio','ratio_time','abs_time'},'value',1,'background','white',...
        'tag','measure','callback',[me ';'],'pos',[h n*vs hs+15 vs]); n=n+1;
  
    uicontrol(fig,'style','text','string','Calculations','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1.5;
    
    uicontrol(fig,'style','pushbutton','string','Extract now','callback',[me ';'],'tag','calc_ratios','pos',[h n*vs hs vs]); n=n+1;
    
    InitParam(me,'active','ui','edit','value','','pos',[h n*vs hs vs]); n=n+1;    
   
     uicontrol(fig,'style','text','string','source','horiz','left','pos',[h+hs+15 n*vs hs vs]); 
    uicontrol(fig,'style','popupmenu','string',{'image','timecourse'},'value',1,'background','white',...
        'tag','source','callback',[me ';'],'pos',[h n*vs hs+15 vs]); n=n+1;
  
     uicontrol(fig,'style','text','string','Extract values','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1.5;
   
    
    uicontrol(fig,'style','pushbutton','string','Clear all','callback',[me ';'],'tag','clear','pos',[h n*vs hs vs]);n=n+1;
    InitParam(me,'select','ui','popupmenu','list',{' '},'value',1,'pos',[h n*vs hs vs]); n=n+1;
 
    	% message box
	uicontrol('parent',fig,'tag','message','style','edit',...
		'enable','inact','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1;

    hf = uimenu(fig,'label','File');
	uimenu(hf,'label','Open...','tag','open','callback',[me ';']);
	uimenu(hf,'label','Save...','tag','save','callback',[me ';']);
	uimenu(hf,'label','Export all...','tag','export_all','callback',[me ';'],'separator','on');
	uimenu(hf,'label','Export groups...','tag','export_groups','callback',[me ';']);
    
	set(fig,'pos',[200 290-n*vs hs*2+8 n*vs],'visible','on');
    set(findobj('parent',fig,'style','text'),'background',get(fig,'color'));
    
    if ~isfield(exper.blob,'roi')
        exper.blob.roi = [];
        exper.blob.result = [];
        h=findobj('tag','opt_ratio_fig');
        delete(findobj(h,'tag','blob','type','line'));
        delete(findobj(h,'tag','blob','type','text'));
    end
    
    for n=1:length(exper.blob.roi)
        b{n} = num2str(n);
    end
    SetParam(me,'select','list',b,'value',1);
    
     
    
case 'open'    
    path = get(get(gcbo,'parent'),'user');
    if isempty(path)
	    filterspec = '*.mat';
    else 
        filterspec = [path '\*.mat'];
    end
    prompt = 'Load blobs from mat file...';
	[filename, pathname] = uigetfile(filterspec, prompt);
    if isequal(filename,0)|isequal(pathname,0)
         message(me,'Open canceled');
         return
    end
	set(get(gcbo,'parent'),'user',pathname);
    s = load([pathname '\' filename]);
    exper = setfield(exper,'blob',s.blob);
    message(me,['Opened ' filename]);
    LoadParams(me);
    
    
case 'save'
    path = get(get(gcbo,'parent'),'user');
    filterspec = sprintf('%s_blob.mat',GetParam('control','expid'));
    if ~isempty(path)
        filterspec = [path '\' filterspec];
    end
    prompt = 'Save blobs to mat file...';
	[filename, pathname] = uiputfile(filterspec, prompt);
    if isequal(filename,0)|isequal(pathname,0)
         message(me,'Save canceled');
         return
    end
	set(get(gcbo,'parent'),'user',pathname);
    blob = exper.blob;
    save([pathname '\' filename],'blob');
    message(me,['Saved ' filename]);
    
case 'export_groups'
    [trials, names] = Group('all');
    
    [filename, pathname] = uiputfile('*.txt','Save blob data to ascii file...');
    if ~filename
        return
    end
    fid = fopen([pathname '\' filename],'w');
    if fid == -1
        message(me,'Problem opening file for writing!','error');
        return
    end
        
    [X, SX, Y, SY, ind] = get_blob_matrix;
    
    n_groups=size(X,1);
    n_blobs=size(X,2);
    n_times=size(X,3);
   
    print_blob_header(fid,ind,'groups');
    
    for n=1:n_groups
        for j=1:n_times
                fprintf(fid,'%s\t',names{n+1});   % n+1 = skip first group
            if n_times > 1
                fprintf(fid,'%d\t',(j-1)*exper.blob.stack);
            end
            for k=1:n_blobs
                fprintf(fid,'%g\t',X(n,k,j));
            end      
            
            for k=1:n_blobs
                fprintf(fid,'%g\t',SX(n,k,j));
            end
            fprintf(fid,'\n');
        end
        if n_times > 1, fprintf(fid,'\n'); end
      end
    fclose(fid);
    message(me,'');
    
    
case 'export_all'
    [filename, pathname] = uiputfile('*.txt','Save blob data to ascii file...');
    if ~filename
        return
    end
    fid = fopen([pathname '\' filename],'w');
    if fid == -1
        message(me,'Could not open file for writing','error');
        return;
    end
    
    trials = str2num(Group('all_valid'));
    [X, SX, Y, SY, ind] = get_blob_matrix(trials);
    
    print_blob_header(fid,ind,'all');
    
    for n=1:size(X,1)
        for j=1:size(X,3)
            % this wierd comparison gets rid of NaN's -- there is probably a more 
            % correct way to do this...
            if ~isnan(X(n,1,j))
                tr = trials(n);
                fprintf(fid,'%d\t',tr);
                name = Group('match',tr);
                if isempty(name), name=' '; end
                fprintf(fid,'%s\t',name);
                time = GetParamTrial('control','exptime',tr);
                fprintf(fid,'%d\t',time);
                if size(X,3) > 1, fprintf(fid,'%d\t',(j-1)*exper.blob.stack); end
                for k=1:size(X,2)
                    fprintf(fid,'%g\t',X(n,k,j));
                end
                fprintf(fid,'\n');
            end
        end
        if size(X,3) > 1, fprintf(fid,'\n'); end
    end
    fclose(fid);
    


case 'draw'
   ax = varargin{2};
   roi = exper.blob.roi;
   for n=1:length(roi)
       x = exper.blob.roi(n).x;
       y = exper.blob.roi(n).y;
       draw_circle(ax,n,x,y);
   end
    
case 'clear'
    if strcmp(questdlg('Clear all blobs?'),'Yes')
        ax = findobj('tag','opt_axes');
        delete(findobj(ax,'tag','blob'));
        exper.blob.roi = [];
        SetParam(me,'select','list',{''},'value',1);
    end    
    
    
case 'select'
    
%    fig = findobj('tag','opt_ratio_fig','user',1);
    ax = findobj('tag','opt_axes');
% fig = gcbf;   
    set(findobj(ax,'tag','blob','type','line'),'linewidth',1);
    set(findobj(ax,'tag','blob','type','text'),'fontweight','normal');
    select = str2num(GetParamList(me,'select'));
    set(findobj(ax,'tag','blob','type','line','user',select),'linewidth',2);
    set(findobj(ax,'tag','blob','type','text','user',select),'fontweight','bold');
   

    
case 'stale_ratios'
    for n=1:length(exper.blob.roi)
        exper.blob.roi(n).recalc = 1;
    end
    stale_ratios;
    

case {'sort_by_x','sort_by_x'}
    
   
    b = length(exper.blob.roi);
    
    for n=1:b
        switch action
        case 'sort_by_x'
            v(n) = mean(exper.blob.roi(n).x);
        case 'sort_by_y'
            v(n) = mean(exper.blob.roi(n).x);
        end
    end
    [val new_order] = sort(v);
    
    
    temp_roi = exper.blob.roi;
    for n=1:b
        exper.blob.roi(n) = temp_roi(new_order(n));
    end
  %  fig = findobj('tag','opt_ratio_fig');
    fig = gcbf;
    blobs = findobj(fig,'tag','blob');
    if isempty(blobs)
        ax = findobj(gcbf,'tag','opt_axes');
        ax = ax(1);
    else
        ax = get(blobs(1),'parent');
        delete(blobs);
   end
    
    for n=1:length(exper.blob.roi)
        h = draw_circle(ax,n,exper.blob.roi(n).x,exper.blob.roi(n).y);    
    end    
    
    
    
    
% -------------------------------------------------------------------
% mouse and keys
% -------------------------------------------------------------------

case 'buttonmotion'
  %  obj = get(gcbf,'currentobject');
  %  if ~strcmp(get(obj,'tag'),'blob')
    if ~strcmp(get(gco,'tag'),'blob') | ~strcmp(get(gco,'type'),'line')
        return;
    end

    ax = get(gco,'parent');
    b = get(gco,'user');
    pos = get(ax,'CurrentPoint');
    
    switch get(gcbf,'SelectionType');
    case 'normal'       % left button
        % move it
        move_circle(b,pos,radius(gco));
    case 'extend'       % middle-button or left+right-buttons or shift/left-button
        % move it
        move_circle(b,pos,radius(gco));
    case 'alt'          % right button
        % change radius
        move_circle(b,center(gco),distance(center(gco),pos));
    otherwise
    end
        
case 'buttonup'
    switch get(gcbf,'SelectionType');
    case 'normal'       % left button
    case 'extend'       % middle-button or left+right-buttons or shift/left-button
    case 'alt'          % right-button or alt/left-button
    case 'open'
    otherwise
    end
%    if strcmp(get(gco,'tag'),'blob')
%        blob_stats(gco);
%    end
    
case 'buttondown'
%    fig = findobj('tag','opt_ratio_fig','user',1);
    fig = gcbf;
    
    switch get(fig,'SelectionType');

    case 'normal'       % left button
        % select
        if strcmp(get(gco,'tag'),'blob') & strcmp(get(gco,'type'),'line')
            b = get(gco,'user');
%            SetParam(me,'select',num2str(b));
            SetParam(me,'select',b);
            set(findobj(fig,'tag','blob','type','line'),'linewidth',1,'visible','on');
            set(findobj(fig,'tag','blob','type','text'),'fontweight','normal');
            set(findobj(fig,'tag','blob','type','line','user',b),'linewidth',2);
            set(findobj(fig,'tag','blob','type','text','user',b),'fontweight','bold');

            blob_stats(gco);
%            refresh(fig);
        end
    case 'extend'       % middle-button or left+right-buttofns or shift/left-button
    case 'alt'          % right-button or alt/left-button
    case 'open'         % double click
        % don't know the radius, so make it 10
        ho = findobj(fig,'tag','blob','type','line');
        ax = get(gcf,'currentaxes');
        
        if isempty(ho)
            new_circle(ax,get(ax,'currentpoint'),10);
        else
            new_circle(ax,get(ax,'currentpoint'),radius(ho(1)));
        end
        b = length(exper.blob.roi);
        set(findobj(fig,'tag','blob','type','line'),'linewidth',1);
        set(findobj(fig,'tag','blob','type','text'),'fontweight','normal');
        set(findobj(fig,'tag','blob','type','line','user',b),'linewidth',2);
        set(findobj(fig,'tag','blob','type','text','user',b),'fontweight','bold');
        for n=1:b
            bl{n} = num2str(n);
        end
        SetParam(me,'select','list',bl,'value',b);
            

    otherwise
    end
   
case 'keypress'
    key = double(get(gcbf,'CurrentCharacter'));
    if isempty(key) 
        return;
    end
 %   fig = findobj('tag','opt_ratio_fig');
 fig = gcbf;
    
    b = str2num(GetParamList(me,'select'));    
    h = findobj(fig,'tag','blob','type','line','user',b);
    x = get(h(1),'xdata');
    y = get(h(1),'ydata');

    switch key
    case 30         % up arrow
        y = y + 1;
        set(h,'ydata',y);
        blob_stats(h(1));
    case 29         % right arrow
        x = x + 1;
        set(h,'xdata',x);
        blob_stats(h(1));
    case 28         % left arrow
        x = x - 1;
        set(h,'xdata',x);
        blob_stats(h(1));
    case 31         % bottom arrow
        y = y - 1;
        set(h,'ydata',y);
        blob_stats(h(1));
    case {45,95}  % make smaller
        [x, y] = move_circle(b,center(h(1)),max([radius(h(1))-1 1]));
        set(h,'xdata',x,'ydata',y)
        blob_stats(h(1));
    case {43,61}  % make bigger
        [x, y] = move_circle(b,center(h(1)),radius(h(1))+1);
        set(h,'xdata',x,'ydata',y)
        blob_stats(h(1));
    case 'x'        % delete
        dh = findobj(gcbf,'tag','blob');
        delete(dh);
        exper.blob.roi = [exper.blob.roi(1:b-1) exper.blob.roi(b+1:end)];
        mx = length(exper.blob.roi);
        for n=1:mx
            bl{n} = num2str(n);
        end
        SetParam(me,'select','list',bl,'value',mx);
        Blob('draw',gca);
        
        return;
    otherwise
        message(me,key);        
        return;
    end
    
    move_circle(b,center(h(1)),radius(h(1)));

    
    
case 'calc_ratios'
    calc_ratios(varargin{2:end});
    
case 'get_blob_matrix'
    varargout{:} = get_blob_matrix(varargin{2:end});
    
case 'preload'
    
%    h=findobj('tag','opt_ratio_fig');

%    delete(findobj(h,'tag','blob','type','line'));
    delete(findobj('tag','blob','type','line'));
    delete(findobj('tag','blob','type','text'));

    
case 'load'
    if ~isfield(exper,'blob')
        ModuleInit('blob');
    end
    
    if ~isfield(exper.blob,'roi')
        exper.blob.roi = [];
        exper.blob.result = [];
    end
    
    if ~ExistParam(me,'active')
        InitParam(me,'active','value','');
    end

    LoadParams(me);
    update_groups;
    
    

case 'close'
    
    
    
    
% -------------------------------------------------------------------
% analysis functions
% -------------------------------------------------------------------


    
case 'x_plot'
    % we plot the value of each blob as a function of
    % any parameter specified by the user
    
    module = GetParamList('group','module');
    param = GetParamList('group','param');
    
    trials = Group('get',get(findobj(gcbf,'tag','group_1'),'value'));

    numeric = 0;
    for n=1:length(trials)
        SetParam('control','trial',trials(n));
        CallModule(module,'trialreview');
        
        % xr = GetParamTrial(module,param,trials(n));
        
        xr = GetParam(module,param);
        
        if isnumeric(xr)
            x{n} = num2str(xr);
            numeric = 1;
        elseif isstr(xr)
            x{n} = xr;
        end
    end
    
    % order the trials
    xs = {' '};
    k = 1;
    for n=1:length(trials)
        match = strmatch(x{n},xs);
        if isempty(match)        
            xs{k} = x{n};
            trs{k} = trials(n);
            k = k+1;
        else
            trs{match} = [trs{match} trials(n)];
        end
    end
    
    rois = GetParamList(me,'select');
    if isempty(rois)
        rois = 1:length(exper.blob.roi);
    else
        rois = str2num(rois);
    end
                
    
    % calculate 
    for n=1:length(xs)
        ys{n} = exper.blob.roi(1).ratio(trs{n});
        for k=rois
            ys{n} = [ys{n} exper.blob.roi(k).ratio(trs{n})];
        end
        ysm(n) = mean(ys{n});
    end
    
    % finally plot
    figure;
    if numeric
        for n=1:length(xs)
            xsn(n) = str2num(xs{n});
        end
        plot(xsn,ysm,'ko ');
    else
        plot(ysm,'ko ');
        set(gca,'Xtick',1:length(xs),'XTickLabel',xs);
    end
    xlabel(sprintf('%s %s',module,param));
    
    exper.blob.result.x=xs;
    exper.blob.result.y=ys;
    
    
    
    
case 'correl'
 
    s1 = str2num(Group('get',get(findobj(gcbf,'tag','group_1'),'value')));
    s2 = str2num(Group('get',get(findobj(gcbf,'tag','group_2'),'value')));

    rois = 1:length(exper.blob.roi);
    
    x = [];
    y = [];
    for k=rois
        x = [x mean(exper.blob.roi(k).ratio(s1))];
        y = [y mean(exper.blob.roi(k).ratio(s2))];
    end
    figure;
    plot(x,y,'o');
    exper.blob.result.x=x;
    exper.blob.result.y=y;

    
case 'matrix'
   [X, SX, Y, SY, ind] = get_blob_matrix;
   
   range = str2num(get(findobj(gcbf,'tag','range'),'string'));
       
   
   nblob = size(X,2);
   ngroups = size(X,1);   
   
    fig = findobj('type','figure','tag','ratio_matrix');
    if isempty(fig)
        fig = figure('tag','ratio_matrix');    
    else
        figure(fig);
        clf
    end
   cmp=colormap;
   switch GetPopupmenuItem('format',gcbf)
   case 'mean'
       for n=1:ngroups
           for k=1:nblob
               [rx,ry] = circle(Y(n,k)/range*0.5);
               patch(rx+k,ry+n,[0 0 0]);
           end
       end       
       
   case 'mean,sd'
       for n=1:ngroups
           for k=1:nblob
               [rx,ry] = circle(Y(n,k)/range*0.5);
               patch(rx+k,ry+n,[0 0 0]);
               [srx,sry] = circle(SY(n,k)/range*0.5);
               h = line(srx+k,sry+n,'color','red');
           end
       end       

   otherwise

   end
   set(gca,'XLim',[0 nblob+1],'Xtick',1:nblob,'XTickLabel',ind');
   xlabel('Glomerulus');
   [trials, group_names] = Group('all');
   set(gca,'YLim',[0 ngroups+1],'Ytick',1:ngroups,'YTickLabel',group_names(2:end));
   ylabel('Odor');
   bgd_subtract = GetPopupmenuItem('bgd_subtract',findobj('type','figure','tag','opt'));
   filter = GetPopupmenuItem('filter',findobj('type','figure','tag','opt'));
   title(sprintf('filt: %s:%s Base:%d-%d Resp:%1.1f-%1.1f range=%1.4f',filter,bgd_subtract,Getparam('opt','base_del')/2,Getparam('opt','base_dur')/2,Getparam('opt','resp_del')/2,getparam('opt','resp_del')/2+getparam('opt','resp_dur')/2,range));
   switch GetPopupmenuItem('normalize');
       %   case {'clip','clip+sd'}
   case 'clip'
       range = get(findobj(gcbf,'tag','range'),'string');
       text(1,ngroups+2,sprintf('range = %s',range));
   case 'glom'
       text(1,ngroups+2,sprintf('normalized by glomerulus'));
   case 'odor'
       text(1,ngroups+2,sprintf('normalized by odor'));
   case 'sel_glom'
       text(1,ngroups+2,sprintf('normalized by glom %s',GetParamList(me,'select')));
   end
   
   exper.blob.result.x=X;
   exper.blob.result.y=Y;
   
   
   
case 'cluster'
   [X, SX, Y, SY] = get_blob_matrix;
   
   D = pdist(Y);
   Z = linkage(D,'ward'); 		% incremental sum of squares from adding groups
   dendrogram(Z);
   
   
   [trials, groupnames] = Group('all');
   order = str2num(get(gca,'XTickLabel'));
   for n=1:length(order)
       ordered_names{n} = groupnames{order(n)+1};
   end
   set(gca,'XTickLabel',ordered_names);
   xlabel('Odor');
   ylabel('Distance');
   
   exper.blob.result.D=D;
   exper.blob.result.Z=Z;
   
   
   
%
% blob('dist_geom',sweeps1,sweeps2)
%
case 'dist_geom'
   sweeps1 = varargin{2};
   sweeps2 = varargin{3};
   x = [];
   y = [];
   for k=1:length(exper.blob.roi)
      x = [x mean(exper.blob.roi(k).ratio(sweeps1))];
      y = [y mean(exper.blob.roi(k).ratio(sweeps2))];
   end
   x = x/max(abs(x));
   y = y/max(abs(y));
   dist = sqrt(sum((x - y) .^ 2));
   disp(['dist: ', num2str(dist)]);
   exper.blob.result.x=x;
   exper.blob.result.y=y;
   exper.blob.result.dist = dist;
   
   

   
%   
% blob('winners',sweeps1,sweeps2...,sweepsN)	% plot blobs as filled circles with
%										        % colors assigned to the strongest
%										        % odor (sweep) for each blob
%
case 'winners'
   for n=1:nargin-1
	   for k=1:length(exper.blob.roi)
	      X(n,k) = mean(exper.blob.roi(k).ratio(varargin{n+1}));
      end
   end
   % find the winners -- largest responses for each 
   [Y I] = min(X);   
   exper.blob.result.I=I;
   exper.blob.result.Y=Y;
   hsv = ones(length(I),3);
   hsv(:,1) = I'/max(I);
   hsv(:,2) = 1;
%   hsv(:,2) = mod(1:length(I),2)'/2+0.5;
   %   hsv(:,3) = (Y'-min(Y))/(max(Y)-min(Y));
%   hsv(:,3) = 1.25-hsv(:,2)/2;
   hsv(:,3) = 1;
   rgb = hsv2rgb(hsv);
   exper.blob.result.hsv = hsv;
   exper.blob.result.rgb = rgb;
   
   for k=1:length(exper.blob.roi)
      tag = sprintf('blob %d',k);
      h = findobj(fig,'tag',tag);
      
      x = get(h,'xdata');
      y = get(h,'ydata');
      patch(x,y,rgb(k,:));
   end
   
%   
% blob('map',sweeps,hue,thresh)	 plot blobs as filled circles with
%														 color hue, only if < thresh
%														
case 'map'
      
   for k=1:length(exper.blob.roi)
		X(k) = mean(exper.blob.roi(k).ratio(varargin{2}));
   end
   hue = varargin{3};
   thresh = varargin{4};
   
   hsv = [hue 1 0.9];
   rgb = hsv2rgb(hsv);
   
   for k=1:length(exper.blob.roi)
      if X(k) < thresh
         tag = sprintf('blob %d',k);
	      h = findobj('tag',tag);
      
   	   x = get(h,'xdata');
      	y = get(h,'ydata');
         patch(x,y,rgb);
      end
   end
   exper.blob.result.X=X;
   
%   
% blob('imap',sweeps,range)	 plot blobs as filled circles with
%												 fill color reflecting intensity
%												 range is [min max]
%														
case 'imap'
   
   optical('ratio',varargin{2});
   blob('hide');
      
   for k=1:length(exper.blob.roi)
		X(k) = mean(exper.blob.roi(k).ratio(varargin{2}));
   end
   range = varargin{3};
   
   cmp = jet;
   
   for k=1:length(exper.blob.roi)
      if X(k) < range(2)
         tag = sprintf('blob %d',k);
	      h = findobj('tag',tag);
      
   	   x = get(h,'xdata');
         y = get(h,'ydata');
         
         v = 1-((X(k)-range(1))/(range(2)-range(1)));
         if v > 1 v=1; end;
         c = round(v*(length(cmp)-1))+1;
         
         patch(x,y,cmp(c,:));
      end
   end
   exper.blob.result.X=X;


%
% blob('tuning',sweeps1,sweeps2,...,sweepsN)		lines connecting sweeps
%
case 'tuning'
   
   nblob = length(exper.blob.roi);
   for n=1:nargin-1
	   for k=1:nblob
         X(n,k) = mean(exper.blob.roi(k).ratio(varargin{n+1}));
      end
   end
   %   X = (1-(X-min(min(X)))/(max(max(X))-min(min(X))));
   r = [GetParam('opt','lowrange') GetParam('opt','highrange')];
   Y = 1-((X-r(1))/(r(2)-r(1)));
   Y(find(Y > 1)) = 1;
   Y(find(Y < 0)) = 0;

	for k=1:nblob
   	line(1:nargin-1,X(:,k));
   end
   
   exper.blob.result.X=X;
   exper.blob.result.Y=Y;
   
           
otherwise	
	message(me,'')
end


% -----------  local functions         

% begin local functions

function out = callback
	out = [lower(mfilename) ';'];

function out = me
	out = lower(mfilename); 
    
   
function stale_ratios
   % as of now, do nothing.
   
function [x,y] = new_circle(ax,pos,radius)
global exper
    
    b = length(exper.blob.roi) + 1;
    [rx,ry] = circle(radius);
    x = pos(1,1) + rx;
    y = pos(1,2) + ry;
	exper.blob.roi(b).x = x;
	exper.blob.roi(b).y = y;
	exper.blob.roi(b).ratio(1:length(exper.opt.trial)) = 0;

	h = draw_circle(ax,b,x,y);
    
    SetParam(me,'select',num2str(b));
    exper.blob.roi(b).recalc = 1;
    stale_ratios;
    
function h = draw_circle(ax,b,x,y)

    fig = get(ax,'parent');
    boff = 4;
    % figure out the color
    c = [0 1 0];
    menu_c = get(findobj(fig,'tag','set_blob_color'),'user');
    if ~isempty(menu_c)
        c = menu_c;
    end
        
	h = line('xdata',x,'ydata',y,'parent',ax,'color',c,'linewidth',1,'linestyle','-','tag','blob','user',b);

    show_labels = get(findobj(fig,'tag','blob_labels'),'checked');
    txt=text(x(1)+boff,y(1)+boff,num2str(b),'parent',ax,'tag','blob','user',b,'color',c,...
        'fontweight','normal','visible',show_labels);
    


    
function [x,y] = move_circle(b,pos,r)
global exper    
    boff = 4;
    [rx,ry] = circle(r);
    x = pos(1,1) + rx;
    y = pos(1,2) + ry;
	exper.blob.roi(b).x = x;
	exper.blob.roi(b).y = y;
	set(findobj('tag','blob','type','line','user',b),'xdata',x,'ydata',y);
    set(findobj('tag','blob','type','text','user',b),'pos',[x(1)+boff y(1)+boff]);
    exper.blob.roi(b).recalc = 1;
    stale_ratios;

    
function [x,y] = circle(radius)
	% make an roi to approximate a circle
    pts = 24;
	for n=1:pts+1
        theta = n/pts * 2 * pi;
        x(n) = sin(theta)*radius;
        y(n) = cos(theta)*radius;
	end
    
function r = radius(obj)
    x = get(obj,'xdata');
    y = get(obj,'ydata');
    r = (max(x)-min(x))/2;
    
function d = distance(pos1,pos2)
    d = sqrt((pos2(1,1)-pos1(1,1))^2 + (pos2(1,2)-pos2(1,2))^2);

function pos = center(obj)
    x = get(obj,'xdata');
    y = get(obj,'ydata');
    pos(1,1) = (max(x)-min(x))/2 + min(x);
    pos(1,2) = (max(y)-min(y))/2 + min(y);
    
function blob_stats(h)
global exper

    %tr = str2num(GetParam('opt','trials'));
    ax = get(h,'parent');
    user = get(ax,'user');
    tr = str2num(user.trials);
    
    if length(tr) == 1
        
        x = get(h,'xdata');
        y = get(h,'ydata');
        b = get(h,'user');
        [m, s] = calc_ratio(tr,x,y);
        message(me,sprintf('%2d: %.3g+/-%.3g%%',b,m*100,s*100));
    end
    
    
    
function print_blob_header(fid,ind,type)
global exper

    N = length(ind);

    fprintf(fid,'Exp ID: %s\n',GetParam('control','expid'));
    fprintf(fid,'Measure: %s\n',GetPopupmenuItem('measure'));
    switch GetPopupmenuItem('filter',findobj('type','figure','tag','opt'))
    case 'none'
        fprintf(fid,'Filter: none\n');
    case 'bandpass'
        fprintf(fid,'Filter: bandpass (%d %d)\n',exper.blob.lowpass, exper.blob.highpass);
    case 'lowpass'
        fprintf(fid,'Filter: lowpass %d\n',exper.blob.lowpass);
    case 'highpass'
        fprintf(fid,'Filter: highpass %d\n',exper.blob.highpass);
    end
    if isfield(exper.blob,'base_del')
        fprintf(fid,'Base: del %d, dur %d frames\n',exper.blob.base_del,exper.blob.base_dur);
        if strcmp(GetPopupmenuItem('measure'),'ratio')
            fprintf(fid,'Resp: del %d, dur %d frames\n',exper.blob.resp_del,exper.blob.resp_dur);
        else
            fprintf(fid,'Resp: each %d frames averaged\n',exper.blob.stack);
        end 
    end
    
    if strcmp(type,'groups')
        hstr = '\t';
    else
        hstr = '\t\t\t';
    end
    if ~strcmp(GetPopupmenuItem('measure'),'ratio') 
        hstr = [hstr '\t'];
    end
    
    fprintf(fid,[' ' hstr]);
    for k=ind
        fprintf(fid,'%d\t',ind(k));
    end
    fprintf(fid,['\nx' hstr]);
    for k=ind
        fprintf(fid,'%d\t',mean(exper.blob.roi(ind(k)).y));
    end
    fprintf(fid,['\ndx' hstr]);
    for k=ind
        fprintf(fid,'%d\t',max(exper.blob.roi(ind(k)).y)-min(exper.blob.roi(ind(k)).y));
    end
    fprintf(fid,['\ny' hstr]);
    for k=ind
        fprintf(fid,'%d\t',mean(exper.blob.roi(ind(k)).x));
    end
    fprintf(fid,['\ndy' hstr]);
    for k=ind
        fprintf(fid,'%d\t',max(exper.blob.roi(ind(k)).y)-min(exper.blob.roi(ind(k)).y));
    end
    fprintf(fid,'\n');
    
    if strcmp(type,'groups')
        fprintf(fid,'Group\t');
        if ~strcmp(GetPopupmenuItem('measure'),'ratio') 
            fprintf(fid,'Frame\t'); 
        end
        for k=ind
            fprintf(fid,'Mean %d\t',ind(k));
        end
        for k=ind
            fprintf(fid,'SD %d\t',ind(k));
        end
    else
        fprintf(fid,'Trial\tGroup\tTime\t');
        if ~strcmp(GetPopupmenuItem('measure'),'ratio') 
            fprintf(fid,'Frame\t'); 
        end
        for k=ind
            fprintf(fid,'%d\t',k);   
        end
    end
    fprintf(fid,'\n');
    
    
    
function calc_ratios(tr)
global exper

   % Start with the valid trials from Group, or all the trials if these are not specified
   % Then take out the invalid trials.    
 %  trials = str2num(getparam('group','valid'));
 %  if isempty(trials)
 %      trials = 1:length(exper.opt.trial);
 %  end
%   trials = Group('remove_invalid',trials);
   
% this will return only the trials that are valid and
% occur in some group
    trials = str2num(Group('all_valid'));  
   
   % decide which blobs we're using
   active = GetParam(me,'active');
   if ~isempty(active)
       blob_ind = str2num(active);
   else 
       blob_ind = 1:length(exper.blob.roi);
   end
   
   % First, select a target image. We use the first trial selected
   % This is just used to get the size of the image when using ROIPOLY.
   
   image = exper.opt.trial(trials(1)).rawratio.byteimage;
   
   for k=blob_ind
       
       % Here we create matrices from the regions of interest. 
       % Note, we must use flipud because the stupid convention for displaying in matlab.
       % Tthis issue recurs whenever measuring or displaying images).
       
       roi{k} = flipud(roipoly(image,exper.blob.roi(k).y,exper.blob.roi(k).x));
   end
   
   
   wh = waitbar(0,'Calculating blobs...');
   
   high = GetParam('opt','highpass');
   low = GetParam('opt','lowpass');
   
   blob_clear = [];
    % if there is a change of filters, then we must clear the whole matrix
   if ~isfield(exper.blob,'highpass') | high ~= exper.blob.highpass | low ~= exper.blob.lowpass
       if strcmp(questdlg('Filter settings have changed. Clear all blob calculations?'),'Yes')
           blob_clear = 1:length(exper.blob.roi);
       end    
   end
   % save the filter settings. They must be the same for all blobs.
   exper.blob.highpass = high;
   exper.blob.lowpass = low;
  
   
   if ~isempty(blob_clear)
       if ~strcmp(questdlg('Are you sure you want to erase old blob calculations?'),'Yes')
           return;
       end
       for k=blob_clear
           exper.blob.roi(k).raw = [];
           exper.blob.roi(k).high = [];
           exper.blob.roi(k).low = [];
           exper.blob.stack = 0;
       end
   end
   
   % the source for the signal
   calc_timecourse = strcmp(GetPopupmenuItem('source',gcbf),'timecourse');
   stack = opt('stack');
   
   [base,resp] = opt('windows');
   
   n=0;
   % loop over trials
   for j=trials
       

       
       if calc_timecourse
           % read from the appropriate .avi file (allowing user to select directory)
           filename = opt('get_avi_filename',j);
           if isempty(filename)
               return
           end
           
           nframes = max(aviread(filename))/stack;
           exper.blob.stack = stack;
       else
           % get ratio image directly from saved opt structure
           raw = opt('get_rawratio',j);          
           nframes = 1;
           exper.blob.stack = 0;
       end
       exper.blob.nframes(j) = nframes;
       
       % get background region of interest to calculate background values below
       % this only has to be done once
       if n==0
           if ~exist('raw')
               raw = aviread(filename,1,'avg');
           end
           bgd_roi = opt('get_bgd_roi',raw);
       end
       
       % loop over frames
       % if not calculating time course then nframes is just 1 and this isn't really a loop
       
       % Also note that if we are calculating the full time course then we are not
       % computing the ratio, whereas if we are calculating from the images we have the ratio
       
       for f=1:nframes
       %   try
              wh=waitbar((n*nframes+(f-1))/(length(trials)*nframes),wh);
              %   catch
           %   msgbox('User canceled. Please recalculate.')
           %   message(me,'');
           %   return
           % end
        
            if calc_timecourse
               message(me,sprintf('Trial %d frame %d',j,f));
               
                % read the right frames
                range = (f-1)*stack + (1:stack); 
                raw = aviread(filename,range,'avg');
           else
               message(me,sprintf('Trial %d',j));
           end
           drawnow
           
           % calculate background values
           exper.blob.image_mean(j,f) = mean2(raw);
           exper.blob.roi_mean(j,f) = mean2(raw(bgd_roi));
           
           high_image = gaussian2(high,raw);
           low_image = gaussian2(low,raw);
           
           % loop over blobs
           for k=blob_ind
               exper.blob.roi(k).raw(j,f) = mean(raw(find(roi{k})));
               if high > 0
                   exper.blob.roi(k).high(j,f) = mean(high_image(find(roi{k})));
               else
                   exper.blob.roi(k).high(j,f) = 0;
               end
               if low > 0
                   exper.blob.roi(k).low(j,f) = mean(low_image(find(roi{k})));
               else
                   exper.blob.roi(k).low(j,f) = 0;
               end
           end
           
       end
       
       n=n+1;
    end
    
    % This code deals with uneven frame numbers in different trials, 
    % which may not happen often but can cause unwanted surprises if not dealt with
    
    % loop over blobs
    max_nframes = max(exper.blob.nframes);
    for k=1:length(exper.blob.roi)
        
        % this may not be necessary in general:
        % trim the matrices to the length of the longest image
        exper.blob.roi(k).high = exper.blob.roi(k).high(:,1:max_nframes);
        exper.blob.roi(k).low = exper.blob.roi(k).low(:,1:max_nframes);
        exper.blob.roi(k).raw = exper.blob.roi(k).raw(:,1:max_nframes);

        % loop over trials
        % get rid of fake 0's in the matrix due to differing trial lengths
        % replace with NaNs
        for j=1:size(exper.blob.roi(k).raw,1)
            nframes = exper.blob.nframes(j);
            for i=(nframes+1):max_nframes
                exper.blob.roi(k).high(j,i) = NaN;        
                exper.blob.roi(k).low(j,i) = NaN;        
                exper.blob.roi(k).raw(j,i) = NaN;        
            end
        end
    end
    
    close(wh);
    message(me,'');
   

function [X, SX, Y, SY, blobs] = get_blob_matrix(groups,blobs,filter,bgd_subtract,measure,normalize,base,resp)
% Extract values from the blob calculation
% [X, SX, Y, SY, blobs] = get_blob_matrix(groups,blobs,filter,bgd_subtract,measure,normalize,base,resp)
%
% Input variables:
% Note. All parameters are gotten from the blob and opt gui's if not passed.
%   GROUPS is either
%       A cell array of strings corresponding to trial indices for analysis groups.
%       E.g. {'1 2 3','4 5 6','8'}
%       in this case, each groups is averaged to obtain a single value.
%       OR
%       A numeric array of trial numbers, in which case no averaging is done and no std are calculated.
%   BLOBS is an array of blob indices.
%       An empty array [] specifies all blobs.
%   FILTER is one of {'bandpass','highpass','lowpass','none'}, meaning
%       'none': unfiltered ratio
%       'bandpass': bandpass filtered, calculated from [lowpass - highpass]
%       'lowpass': gaussian filtered ratio, smaller kernel
%       'highpass': gaussian filtered ratio, larger kernel
%   BGD_SUBTRACT is one of {'none','roi mean','image mean'}
%       'none': no background subtraction
%       'image mean': subtract the average value of the ratio image computed across the whole image
%       'roi mean': ditto ... computed across the region of interest (ROI)
%   MEASURE is one of {'ratio','ratio_time','abs_time'}, meaning
%       'ratio': computed using ratio = resp / (base-resp)
%       'ratio_time': as for ratio but with entire time course returned (arrays have an additional dimention)
%       'abs_time': asolute values returned (arrays have an additional dimention)
%   NORMALIZE is one of {'none','blob','group','blob_sel'}
%       'none': no normalization
%       'blob': normalize each blob to the maximum for that blob across all groups
%       'group': normalize each group to the maximum for all blobs within that group
%       'blob_sel': normalize each group to the blob selected in the gui
%  BASE,RESP
%       each is an array of frame numbers that specifies the frames to average when calculating base and response
%
% Output variables:
%   X(groups,blobs) is mean values
%   SX(groups,blobs) is stdev values
%   Y(groups,blobs) is normalized mean values
%   SY(groups,blobs) is normalized stdev values
%   BLOB is the corresponding blob indices
%
	
	global exper
	
	% GROUPS
	if nargin < 1
        % get the groups
        groups = Group('all'); 
        groups = groups(2:end);
        
        if isempty(groups)
            message(me,'Please add groups!','error');
            return;
        else
            message(me,'')
        end
	else
        % if groups is passed as an array then convert to a cell array of
        % single values
        if ~iscell(groups)
            for n=1:length(groups)
                g{n} = num2str(groups(n)); 
            end
            groups = g;
        end
	end
	
	
	% BLOBS
	if nargin < 2
        active = GetParam(me,'active');
        if ~isempty(active)
            blobs = str2num(active);
        else 
            blobs = 1:length(exper.blob.roi);
        end
	end
	
	timecourse_available = 0;
	
	% Has the time course been calculated?
	if isfield(exper.blob,'stack')
        stack = exper.blob.stack;
        if stack > 0
            timecourse_available = 1;
        end
    else
        message(me,'Calculate first','error');
        return
    end
	
	% FILTER SETTINGS must be checked
 
    if nargin < 3
        filter = GetPopupmenuItem('filter',findobj('type','figure','tag','opt'));
    end

	if isfield(exper.blob,'highpass')
        if exper.blob.highpass ~= GetParam('opt','highpass') | ...
                exper.blob.lowpass ~=GetParam('opt','lowpass')
            %warndlg(sprintf('Current blobs are filtered at(%d %d).\nTo change, you must recalculate.',...
            %    exper.blob.lowpass,exper.blob.highpass),'Blob calculation warning','modal');
            message(me,'Warning: blob filters changed');
        end
	end
    
    % BACKGROUND SUBTRACTION
    if nargin < 4
        bgd_subtract = GetPopupmenuItem('bgd_subtract',findobj('type','figure','tag','opt'));
    end
    
    
	% MEASURE
	if nargin < 5, measure = GetPopupmenuItem('measure'); end
	if strcmp(measure,'ratio_time') | strcmp(measure,'abs_time')
        if ~timecourse_available
            message(me,sprintf('%s requires timecourse',measure),'error');
           return;
       else
           timecourse = 1;
       end
   else
       timecourse = 0;
   end
   
   if strcmp(measure,'abs_time')
       ratio = 0
   else
       ratio = 1;
   end
              
   % NORMALIZE
   if nargin < 6, normalize = GetPopupmenuItem('normalize'); end
   
   
   % BASE & RESP
   if nargin < 7
       if timecourse_available
           % if so, then we can compute the ratio for any base and resp
           % windows, so we can use the settings in opt.
           base_del = GetParam('opt','base_del');
           base_dur = GetParam('opt','base_dur');
           
           resp_del = GetParam('opt','resp_del');
           resp_dur = GetParam('opt','resp_dur');
           
           exper.blob.base_del = base_del;
           exper.blob.base_dur = base_dur;
           exper.blob.resp_del = resp_del;
           exper.blob.resp_dur = resp_dur;
           
           % make sure the durations leave at least one frame
           if base_dur < stack
               warn_str = sprintf('Base duration set to minimum of %d.',stack);
               warn_h = warndlg(warn_str,'Blob get_blob_matrix function warning');
               base_dur = stack; 
           end
           if resp_dur < stack
               warn_str = sprintf('Response duration set to minimum of %d.',stack);
               warn_h = warndlg(warn_str,'Blob get_blob_matrix function warning');
               resp_dur = stack; 
           end
           
           resp = (resp_del/stack+1):((resp_del+resp_dur)/stack);
           base = (base_del/stack+1):((base_del+base_dur)/stack);    
       end
   end
   
   
   % FILTER & MEASURE
 
 
   warn_h = [];
   omitted_trials = [];
   om_c=0;
   
   for n=1:length(groups)
       if timecourse_available
           check_trials = str2num(groups{n});
           
           % make sure all the trials are actually as long as the measurement windows
           c=0;
           trials = [];
           for ch=1:length(check_trials)
               tr = check_trials(ch);
               nframes = exper.blob.nframes(tr);
               if max(resp) <= nframes & max(base) <= nframes
                   c = c+1;
                   trials(c) = check_trials(ch);
               else
                   om_c = om_c+1;
                   omitted_trials(om_c) = check_trials(ch);
                   if ishandle(warn_h)
                       delete(warn_h);
                   end
                   warn_str = ['Omitted trials: ' sprintf('%d ',omitted_trials) 'due to base or resp windows outside valid frames!'];
                   warn_h = warndlg(warn_str,'Blob get_blob_matrix function warning');
               end
           end
       else
           trials = str2num(groups{n});
       end
       
       if isempty(trials)
           X(n,:,:) = NaN;
           SX(n,:,:) = NaN;
       else
           % calculate the background measurements, which are the same for all blobs
           switch bgd_subtract
           case 'image mean'
               bgd_data = exper.blob.image_mean;
           case 'roi mean'
               bgd_data = exper.blob.roi_mean;
           end
           switch bgd_subtract
           case {'image mean', 'roi mean'}
               if ratio
                   if timecourse
                       denom = mean(bgd_data(trials,base),2);
                       for j=1:length(trials)
                           bgd(j,:) = bgd_data(trials(j),:) / denom(j) - 1;
                       end
                   else
                       if timecourse_available
                           bgd = mean(bgd_data(trials,resp),2) ./ mean(bgd_data(trials,base),2) - 1;
                       else
                           % in this case we are already dealing with the ratio!
                           bgd = bgd_data(trials);
                       end
                   end
               else
                   % absolute measurement (timecourse only)
                   bgd = bgd_data(trials,:);
               end
           end
           
           
           ki = 1;
           for k=blobs
               
               switch filter
               case 'none'
                   data = exper.blob.roi(k).raw;
               case 'bandpass'
                   data_low = exper.blob.roi(k).low;
                   data_high = exper.blob.roi(k).high;
                   % note, this is only used for the absolute measurement, since
                   % when computing the ratio, we do the subtraction AFTER the ratio
                   data = data_low - data_high;
               case 'highpass'
                   data = exper.blob.roi(k).high;
               case 'lowpass'
                   data = exper.blob.roi(k).low;
               end
               
               if ratio
                   % take the average first over the measurement windows 
                   % then compute the ratio
                   
                   if timecourse
                       if strcmp(filter,'bandpass')
                           % note, we subtract after calculating the ratio, not before
                           denom_low = mean(data_low(trials,base),2);
                           denom_high = mean(data_high(trials,base),2);
                           for j=1:length(trials)
                               meas_low(j,:) = data_low(trials(j),:) / denom_low(j) - 1;
                               meas_high(j,:) = data_high(trials(j),:) / denom_high(j) - 1;
                           end
                           meas = meas_low - meas_high;
                       else
                           denom = mean(data(trials,base),2);
                           for j=1:length(trials)
                               meas(j,:) = data(trials(j),:) / denom(j) - 1;
                           end
                       end
                   else
                       if timecourse_available
                           if strcmp(filter,'bandpass')
                               meas_high = mean(data_high(trials,resp),2) ./ mean(data_high(trials,base),2) - 1;
                               meas_low = mean(data_low(trials,resp),2) ./ mean(data_low(trials,base),2) - 1;
                               meas = meas_low - meas_high;
                           else
                               meas = mean(data(trials,resp),2) ./ mean(data(trials,base),2) - 1;
                           end
                       else
                           % in this case we are already dealing with the ratio!
                           meas = data(trials);
                       end
                   end
               else
                   % absolute measurement (timecourse only)
                   meas = data(trials,resp,:);
               end
               
               % do the background subtraction
               switch bgd_subtract
               case {'image mean', 'roi mean'}
                   meas = meas - bgd;
               otherwise
               end
               
               % now mean and SD are computed over trials
               if length(meas) > 1
                   X(n,ki,:) = mean(meas,1);
                   SX(n,ki,:) = std(meas,1);
               else
                   X(n,ki) = meas;
                   SX(n,ki) = NaN;
               end
                   
               ki=ki+1;
           end
       end
   end
   
  
   % NORMALIZATION
   switch normalize 
   case 'none'
       Y = X;
       SY = SX; 
   case 'blob'
       for n=1:size(X,2)
           % normalize by the largest signal
           norm = max(abs(X(:,n)));
           Y(:,n) = X(:,n)/norm;
           SY(:,n) = SX(:,n)/norm;
       end
   case 'group'
       for n=1:size(X,1)
           if ~isempty(groups{n})
               % normalize by the largest signal
               norm = max(abs(X(n,:)));
               Y(n,:) = X(n,:)/norm;
               SY(n,:) = SX(n,:)/norm;
           end
       end
   case 'blob_sel'
       g = str2num(GetParamList(me,'select'));
       gi = find(g==ind);
       if ~isempty(gi)
           for n=1:size(X,1)
               if ~isempty(groups{n})
                   % normalize by a given blob
                   norm = abs(X(n,gi));
                   Y(n,:) = X(n,:)/norm;
                   SY(n,:) = SX(n,:)/norm;
               end
           end
       end
   end  
   message(me,'');
   
  
   
function [m, s] = calc_ratio(tr,x,y) % return mean and variance
global exper
% this function needs to be updated

    image = exper.opt.trial(tr(1)).rawratio.byteimage;
    roi = flipud(roipoly(image,y,x));
    k = 1;
    for j=tr
        image = exper.opt.trial(j).rawratio.byteimage;
        q = double(image(find(roi)));
        r(k) = mean(q)/exper.opt.trial(j).rawratio.scale+exper.opt.trial(j).rawratio.floor;
        k=k+1;
    end
    m = mean(r);
    s = std(r);
    

function update_x_plot
global exper

    module = GetParamList(me,'x_module');
    fields = eval(sprintf('fieldnames(exper.%s.param)',module));
    params = {' '};
    k=1;
    for n=1:length(fields)
        save = eval(sprintf('exper.%s.param.%s.save',module,fields{n}));
        if save
            params{k} = fields{n};
            k=k+1;
        end
    end
    
    SetParam(me,'x_param','list',params,'value',1);
    str = sprintf('R(%s %s)',module,GetParamList(me,'x_param'));
    set(findobj('tag','x_plot','style','pushbutton'),'string',str);
    
    
    
function update_groups
global exper

    SetParam(me,'s1','list',GetParam('group','group','list'),'value',1);
    SetParam(me,'s2','list',GetParam('group','group','list'),'value',1);
   
    

