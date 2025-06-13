function varargout = Opt(varargin)
% Opt
% Optical imaging analysis
%
% mov = opt('ratio_movie',filaname,lo_filt,hi_filt);
% create a movie of ratio images 
%
% ZF Mainen 05/02


global exper

if nargin > 0
	action = lower(varargin{1});
else
	action = lower(get(gcbo,'tag'));
end

switch action
	
case {'init','reinit'}
	
	% opt is called after orca
	SetParam(me,'priority',6); 

	%fig = ModuleFigure(me,'visible','off');	
	fig = ModuleFigure(me);
    
	hs = 200;
	h = 5;
	vs = 20;
	n = 0;
    
  	if strcmp(action,'init') & ~isfield(exper.opt,'trial')
        exper.opt.im = [];
        exper.opt.grab = [];
        exper.opt.ratio = [];
        exper.opt.t = [];	
        exper.opt.trial = [];
    end

    uicontrol(fig,'style','pushbutton','string','Pixel Test','callback',[me ';'],'tag','pixel_test','pos',[h+hs*2/3 n*vs hs/3 vs]);  
    % bin
    uicontrol(fig,'style','text','string','bin','horiz','left','pos',[h+hs/3+5 n*vs hs/3 vs]); 
    uicontrol(fig,'style','popupmenu','string',{'1','2','4'},'value',1,'background','white',...
        'tag','bin','callback',[me ';'],'pos',[h n*vs hs/3 vs]); n=n+1;

    
    % norm
    uicontrol(fig,'style','text','string','norm','horiz','left','pos',[h+hs/3+5 n*vs hs/3 vs]); 
    uicontrol(fig,'style','popupmenu','string',{'-','sd','var'},'value',1,'background','white',...
        'tag','norm','callback',[me ';'],'pos',[h n*vs hs/3 vs]); 
  
    % test
    uicontrol(fig,'style','text','string','test','horiz','left','pos',[h+hs+5 n*vs hs/3 vs]); 
    uicontrol(fig,'style','popupmenu','string',{'kstest','ttest'},'value',1,'background','white',...
        'tag','test','callback',[me ';'],'pos',[h+hs*2/3 n*vs hs/3 vs]); n=n+1;
       
    % alpha
    uicontrol(fig,'style','text','string','alpha','horiz','left','pos',[h+hs/3+5 n*vs hs/3 vs]); 
    uicontrol(fig,'style','edit','string','0.05','horiz','right','background','white',...
        'tag','alpha','callback',[me ';'],'pos',[h n*vs hs/3 vs]); 
    
    % tail
    uicontrol(fig,'style','text','string','tail','horiz','left','pos',[h+hs+5 n*vs hs/3 vs]); 
    uicontrol(fig,'style','popupmenu','string',{'1 > 2','1 <> 2','1 < 2'},'value',1,'background','white',...
        'tag','tail','callback',[me ';'],'pos',[h+hs*2/3 n*vs hs/3 vs]); n=n+1;
  
    % group 2
    uicontrol(fig,'style','popupmenu','string',{'Press Group/update'},'value',1,'background','white',...
        'tag','group_2','user','group','callback',[me ';'],'pos',[h+hs/2 n*vs hs/2 vs]);
  
    % group 1
    uicontrol(fig,'style','text','string','groups 1,2','horiz','left','pos',[h+hs+5 n*vs hs/3 vs]); 
    uicontrol(fig,'style','popupmenu','string',{'Press Group/update'},'value',1,'background','white',...
        'tag','group_1','user','group','callback',[me ';'],'pos',[h n*vs hs/2 vs]); n=n+1;
    uicontrol(fig,'style','text','string','Pixel statistics','horiz','left','pos',[h+3 n*vs hs vs-5]); n=n+1.5;
 
 
   
    % stack
	uicontrol(fig,'style','text','string','stack','horiz','left','pos',[h+hs/3+5 n*vs hs/3 vs]); 
    uicontrol(fig,'style','popupmenu','string',{'1','2','4','5','10'},'value',4,'background','white',...
        'tag','stack','callback',[me ';'],'pos',[h n*vs hs/3 vs]); 
     % movie
    uicontrol(fig,'style','pushbutton','string','Ratio avg movie',...
        'callback',[me ';'],'tag','ratio_movie','pos',[h+hs/2 n*vs hs/2 vs]); n=n+1;
 
    uicontrol(fig,'style','text','string','Ratio movie','horiz','left','pos',[h+3 n*vs hs vs-5]); n=n+1.5;
 
    
    % Ratio averages
  
    uicontrol(fig,'style','pushbutton','string','Ratio avg',...
        'callback',[me ';'],'tag','ratio_avg','pos',[h n*vs hs/3 vs]); 
  
    uicontrol(fig,'style','pushbutton','string','Ratio avg all',...
        'callback',[me ';'],'tag','ratio_avg_all','pos',[h+hs/3 n*vs hs/3 vs]); 
  
    uicontrol(fig,'style','pushbutton','string','Ratio album',...
        'callback',[me ';'],'tag','ratio_album','pos',[h+hs*2/3 n*vs hs/3 vs]); n=n+1;
  
    
    % trials
    uicontrol(fig,'style','text','string','trials','horiz','left','pos',[h+hs+5 n*vs hs/3 vs]); 
    uicontrol(fig,'style','edit','string',{''},'horiz','right','background','white',...
        'tag','trials','user','group','callback',[me ';'],'pos',[h n*vs hs vs]); n=n+1;
    % group
    uicontrol(fig,'style','text','string','group','horiz','left','pos',[h+hs+5 n*vs hs/3 vs]); 
    uicontrol(fig,'style','popupmenu','string',{'Press Group/update'},'value',1,'background','white',...
        'tag','group','user','group','callback',[me ';'],'pos',[h n*vs hs vs]); n=n+1;
    
    uicontrol(fig,'style','text','string','Ratio averages','horiz','left','pos',[h+3 n*vs hs vs-5]); n=n+1.5;

   
    % resp
  
    InitParam(me,'resp_del','ui','edit','value',20,'pos',[h n*vs hs/3 vs]); 
    InitParam(me,'resp_dur','ui','edit','value',20,'pos',[h+hs*2/3 n*vs hs/3 vs]); n=n+1;
    
    % base
	InitParam(me,'base_del','ui','edit','value',0,'pos',[h n*vs hs/3 vs]); 
    InitParam(me,'base_dur','ui','edit','value',10,'pos',[h+hs*2/3 n*vs hs/3 vs]); n=n+1;
    
    
    uicontrol(fig,'style','text','string','Ratio windows (frames)','horiz','left','pos',[h+3 n*vs hs vs-5]); n=n+1.5;

    % high pass filter
    InitParam(me,'highpass','ui','edit','value',20,'pos',[h n*vs hs/3 vs]); 
   
    % background
	uicontrol(fig,'style','text','string','bgd subtract','horiz','left','pos',[h+hs+5 n*vs hs/3 vs]); 
    uicontrol(fig,'style','popupmenu','string',{'none','image mean','roi mean'},'value',1,'background','white',...
        'tag','bgd_subtract','callback',[me ';'],'pos',[h+hs*2/3 n*vs hs/3 vs]); n=n+1;
    
     % low pass filter
    InitParam(me,'lowpass','ui','edit','value',2,'pos',[h n*vs hs/3 vs]); 
    
    % filter type
    uicontrol(fig,'style','text','string','filter','horiz','left','pos',[h+hs+5 n*vs hs/3 vs]); 
    uicontrol(fig,'style','popupmenu','string',{'none','bandpass','lowpass','highpass'},'value',2,'background','white',...
        'tag','filter','callback',[me ';'],'pos',[h+hs*2/3 n*vs hs/3 vs]); n=n+1;
  
       
    uicontrol(fig,'style','text','string','Filter settings','horiz','left','pos',[h+3 n*vs hs vs-5]); n=n+1.5;

    
    InitParam(me,'roi','x',[],'y',[],'bw',[]);


	% message box
	uicontrol('parent',fig,'tag','message','style','edit',...
		'enable','inact','horiz','left','pos',[h n*vs hs vs]); n=n+1;
    
    % menu items
    hf = uimenu(fig,'label','File');
	uimenu(hf,'label','Set data path...','tag','data_path','callback',[me ';']);
    uimenu(hf,'label','Open .avi...','tag','open_single','callback',[me ';']);
    uimenu(hf,'label','Open .avi series...','tag','open_series','callback',[me ';']);
    uimenu(hf,'label','Avg .avi group','tag','avi_avg','callback',[me ';'],'separator','on');
	uimenu(hf,'label','Avg .avi all groups','tag','avi_avg_all','callback',[me ';']);
    
    % set the background color of the text items to the background of the figure
    set(findobj(fig,'style','text'),'background',get(fig,'color'));
    
	set(fig,'pos',[142 290-n*vs 68+hs n*vs],'visible','on');
	
   

case 'slice'
		
case 'trialready'
	
case 'trialend'
    trial = GetParam('control','trial');
    group = GetParamList('sequence','group');
    
    base = GetParam(me,'base_del')+1:(GetParam(me,'base_del')+GetParam(me,'base_dur'));
    resp = GetParam(me,'resp_del')+1:(GetParam(me,'resp_del')+GetParam(me,'resp_dur'));
    
    imbase = mean(exper.opt.im(:,:,base),3);
    imresp = mean(exper.opt.im(:,:,resp),3);

    calc_ratio(trial,imbase,imresp);
    
    exper.opt.trial(trial).rawratio = compress(im,'uint16');
    
    fig = get_ratio_fig('ratio');
    show_ratio(fig,num2str(trial),group);

    update_display_menu(fig);
    SaveParamsTrial(me);
    
        
case 'trialreview'
    SetParam(me,'display','value',GetParam('control','trial'));
    opt('display');    
  
case 'close'
    

case 'reset'
	exper.opt.im = [];
	exper.opt.t = [];	
	exper.opt.trial = [];	
	exper.opt.grab = [];
	setparam(me,'display','list','','value',1);
	message(me,'');
	
case 'slicerate'
    message(me,'Warning! Check ratio windows');
    
case 'load'
    if ~ExistParam(me,'roi')
        InitParam(me,'roi','x',[],'y',[],'bw',[]);
    end
  
    
case 'update_group'
  
   fig = findobj('type','figure','tag',GetParam('control','expid'));
   update_display_menu(fig);
    
  
% some external functions

case 'get_rawratio'
% return the unfiltered ratio data from a given trial
% note: pays attention to the base and resp window settings and
% can recalculate from .avi files if necessary
% Can also average over trials when trials is a vector
%   dat = opt('get_rawratio',trials)

    raw = get_rawratio(varargin{2});
    varargout{1} = raw;
    
    
case 'filter_image'
% im = opt('filter_image',raw,low,high,filter,bgd_subtract,bin)
%
%   Returns a filtered image.
%   Note. All parameters are gotten from the opt gui if not passed.
%
%   BGD_SUBTRACT is one of {'none','roi mean','image mean'}
%       'none': no background subtraction
%       'image mean': subtract the average value of the ratio image computed across the whole image
%       'roi mean': ditto ... computed across the region of interest (ROI)
%
%   FILTER is one of {'bandpass','highpass','lowpass','none'}, meaning
%       'none': unfiltered ratio
%       'bandpass': bandpass filtered, calculated from [lowpass - highpass]
%       'lowpass': gaussian filtered ratio, smaller kernel
%       'highpass': gaussian filtered ratio, larger kernel
%
%   LOW and HIGH are filter widths: low < high
%   LOW is used as a smoothing filter to get rid of noise
%   HIGH is used to compute a broadly smoothed filter that is subtracted 

    varargout{1} = filter_image(varargin{2:end});
    
    
case 'get_bgd_roi'
% bw = get_bgd_roi(im)
% return the background region of interest
    varargout{1} = get_bgd_roi(varargin{2});
    
case 'get_avi_filename'
% used to retrieve a filename including path for
% a specified file in the current experiment
%    filename = opt('get_avi_filename',trial)
    varargout{1} = get_avi_filename(varargin{2});
    
    
case 'windows'
% return baseline and response windows as arrays
%   [base, resp] = opt('windows');

    varargout{1} = GetParam(me,'base_del')+1:(GetParam(me,'base_del')+GetParam(me,'base_dur'));
    varargout{2} = GetParam(me,'resp_del')+1:(GetParam(me,'resp_del')+GetParam(me,'resp_dur'));
    
    
case 'set_windows'
    % opt('set_windows',base_del,base_dur,resp_del,resp_dur);
    SetParam(me,'base_del',varargin{2});
    SetParam(me,'base_dur',varargin{3});
    SetParam(me,'resp_del',varargin{4});
    SetParam(me,'resp_dur',varargin{5});
    
    
    
case 'stack'
    varargout{1} = str2num(GetPopupmenuItem('stack',findobj('type','figure','tag','opt')));
   

% return various useful data from the figures
case 'get'
    % dat = opt('getimage','type','trial',['group',['expid']])
    % returns the data array from specified by the parameters if it exists
    %   type = 'ratio'  -- various kinds of images generated for a given trial
    %   trial = '1', '2 3', etc -- a string 
    %   group = 'soemthing' -- optional string specifying the group
    %   expid = 'z001a'  -- optional experiment id
    
    type = varargin{2};
    if nargin >= 5
        expid = varargin{3};
        trial = varargin{4};
        gr = varargin{5};
    elseif nargin >= 4
        expid = GetParam('control','expid');
        trial = varargin{3};
        gr = varargin{4};
    else
        expid = GetParam('control','expid');
        trial = varargin{3};
        gr = group('match',trial);
    end
    
    user.group = gr;
    user.trials = trial;
    
   % fig = findobj('type','figure','tag',expid);
   
    ax_h = findobj('type','axes','user',user);
    im_h = findobj(ax_h,'tag','ratio_image');
    varargout{1} = rot90(get(im_h,'cdata'),1);


% deal with UI callbacks
    
case 'group'
    trials = Group('get',get(gcbo,'value'));
    set(findobj(gcbf,'tag','trials','user','group'),'string',trials);
     
    
case 'disp_menu'
    
    trials = get(gcbo,'label');
    group = get(gcbo,'tag');
    
    fig = get_ratio_fig('ratio');
    show_ratio(fig,trials,group);

    
case 'avg_menu'
    
    group = get(gcbo,'tag');
    trials = Group('get',group);
    
    fig = get_ratio_fig('ratio');
    show_ratio(fig,trials,group);
    
    set(findobj(gcbf,'tag','trials','user','group'),'value',trials);
    set(findobj(gcbf,'tag','group','user','group'),'value',group);
   
    
    
case 'ratio_avg'
    trials = get(findobj(gcbf,'tag','trials','user','group'),'string');
    if iscell(trials)
        trials = trials{1};
    end
    group = GetPopupmenuItem('group',gcbf);
    
    if isempty(trials)
        return;
    end
    Trials = str2num(trials);
    
    fig = get_ratio_fig('ratio');
    show_ratio(fig,sprintf('%d ',Trials(1:end)),group);
    
case 'ratio_album'
    trials = get(findobj(gcbf,'tag','trials','user','group'),'string');
    if iscell(trials)
        trials = trials{1};
    end
    group = GetPopupmenuItem('group',gcbf);
    
    if isempty(trials)
        return;
    end
    tr = str2num(trials);
    total = length(tr);
    
    fig = get_ratio_fig('ratio');
    for n=1:total
        show_ratio(fig,num2str(tr(n)),group,n,total);
    end
    
case 'album_menu'
    
    group = get(gcbo,'tag');
    trials = Group('get',group);
 
    fig = get_ratio_fig('ratio');
    
    tr = str2num(trials);
    total = length(tr);
    for n=1:total
        show_ratio(fig,num2str(tr(n)),group,n,total);
    end
        
       
case 'ratio_avg_all'
   [all_trials, all_groups] = Group('all');
       
   fig = get_ratio_fig('ratio');
   for n=2:length(all_trials)
       show_ratio(fig,all_trials{n},all_groups{n},n-1,length(all_trials)); 
   end     
    
   
case 'redraw'
    
   fig = get_ratio_fig('ratio','hold');
   ax = findobj(fig,'tag','opt_axes');
   total = length(ax);
   for n=1:total
       ind = total-n+1; % the numbers of the axes are in reverse order
       user = get(ax(ind),'user');
       show_ratio(fig,user.trials,user.group,n,total);
       delete(ax(ind));
   end
   
   
case 'ratio_movie'
    trials = get(findobj(gcbf,'tag','trials','user','group'),'string');
    if iscell(trials)
        trials = trials{1};
    end
    if isempty(trials)
        return;
    end
    Trials = str2num(trials);
    group = GetPopupmenuItem('group',gcbf);
    
    stack = str2num(GetPopupmenuItem('stack',findobj('type','figure','tag','opt')));
    base = GetParam(me,'base_del')+1:(GetParam(me,'base_del')+GetParam(me,'base_dur'));
    
    % get some info from the first file
    filename = get_avi_filename(Trials(1));
    
    frames = max(aviread(filename))/stack;
    
    imbase = aviread(filename,base,'avg');
    xs = size(imbase,1);
    ys = size(imbase,2);
 
    % allocate space for the movie
    ratio_movie = zeros(xs,ys,frames);
    
    wh = waitbar(0,'Reading and averaging...');
    
    for n=1:length(Trials)
        tr = Trials(n);
         
        filename = get_avi_filename(tr);
        imbase = aviread(filename,base,'avg');
    
        % don't use 0 pixels in the denominator
        zpix = find(imbase == 0);
        if length(zpix) > 0
            imbase(zpix) = NaN;
        end 
    
        for f=1:frames
            waitbar(((n-1)*frames+f-1)/(length(Trials)*frames),wh);
            range = (f-1)*stack + (1:stack); 
            frame = aviread(filename,range,'avg');
     
            ratio_movie(:,:,f) = ratio_movie(:,:,f) + (frame ./ imbase - 1);
        end
    end
    ratio_movie = ratio_movie ./ length(Trials);
    close(wh);
    drawnow;
    
    
    fig = get_ratio_fig('ratio');
 
    for n=1:frames
        frame = sprintf('%d',(n-1)*stack);
        ax = position_axes(axes('parent',fig,'tag','opt_axes'),n,frames);
        im = filter_image(ratio_movie(:,:,n));
        draw_ratio(ax,im,frame,group);  
        ratio_movie(:,:,n) = im;
    end
     
    varargout{1} = ratio_movie;
    
    
    
   
case 'pixel_test'
    
    alpha = str2num(get(findobj(gcbf,'tag','alpha'),'string'));
    tail_str = GetPopupmenuItem('tail');
    test = GetPopupmenuItem('test');
  
    switch tail_str
    case '1 > 2'
        tail = 1;
        comp_str = ' > ';
    case '1 <> 2'
        tail = 0;
        comp_str = ' <> ';
    case '1 < 2'
        tail = -1;
        comp_str = ' < ';
    end
    group1 = GetPopupmenuItem('group_1');
    group2 = GetPopupmenuItem('group_2');
    if strcmp(group1,group2)
        message('opt','Select 2 diff groups!','error');
        return;
    end
    trials1_str = Group('get',group1);
    trials2_str = Group('get',group2);
    if isempty(trials1_str) | isempty(trials2_str)
        message('opt','Select groups!','error');
        return;
    end
    trials1 = str2num(trials1_str);
    trials2 = str2num(trials2_str);
       
% check for binning now
if 1
    bin = str2num(GetPopupmenuItem('bin'));
else
    bin = 1;
end
    filter = GetPopupmenuItem('filter',findobj('type','figure','tag','opt'));
    bgd_subtract = GetPopupmenuItem('bgd_subtract',findobj('type','figure','tag','opt'));
   
    norm = GetPopupmenuItem('norm');
   
    
    fig = get_ratio_fig('ratio');
   % Opt('set_cols',3);
   
    [low, high] = get_filter;
       
    wh = waitbar(0,'Filtering images...');
    s = bin2(get_rawratio(trials1(1)),bin);
    

    data1 = repmat(s,[1 1 length(trials1)]);
    for n=1:length(trials1)
        wh=waitbar(n/(length(trials1)+length(trials2)),wh);
%        data1(:,:,n) = filter_image(get_rawratio(trials1(n)),low,high);
        data1(:,:,n) = filter_image(get_rawratio(trials1(n)),low,high,filter,bgd_subtract,bin);
    end
    data2 = repmat(s,[1 1 length(trials2)]);
    for n=1:length(trials2)
        wh=waitbar((n+length(trials1))/(length(trials1)+length(trials2)),wh);
%       data2(:,:,n) = filter_image(bin2(get_rawratio(trials2(n)),bin),low/bin,high/bin);
        data2(:,:,n) = filter_image(get_rawratio(trials2(n)),low,high,filter,bgd_subtract,bin);
    end
    
    % normalize images to unit standard deviation
    switch norm
    case 'var'
        bgd = get_bgd_roi(data1(:,:,1));
        if sum(size(bgd)-size(data1(:,:,1))) > 0
            bgd = logical(ceil(bin2(bgd,bin)));
        end
        var1 = std(data1,0,3) .^ 2;
        var1M = mean2(var1(bgd));
        data1 = data1 / var1M;
        
        var2 = std(data2,0,3) .^ 2;
        var2M = mean2(var2(bgd));
        data2 = data2 / var2M;
        
        message(me,sprintf('var ratio=%g',var1M/var2M));
        
    case 'sd'
        
        bgd = get_bgd_roi(data1(:,:,1));
        if sum(size(bgd)-size(data1(:,:,1))) > 0
            bgd = logical(ceil(bin2(bgd,bin)));
        end
        sd1 = std(data1,0,3);
        sd1M = mean2(sd1(bgd));
        data1 = data1 / sd1M;
        
        sd2 = std(data2,0,3);
        sd2M = mean2(sd2(bgd));
        data2 = data2 / sd2M;
 
        message(me,sprintf('sd ratio=%g',sd1M/sd2M));
        
    otherwise
    end
        
  %  ax = position_axes(axes('parent',fig,'tag','opt_axes'),1,3);
  %  draw_ratio(ax,imresize(mean(data1,3),bin,'bilinear'),trials1_str,group1);    
   
  %  ax = position_axes(axes('parent',fig,'tag','opt_axes'),2,3);
  %  draw_ratio(ax,imresize(mean(data2,3),bin,'bilinear'),trials2_str,group2);    
    
    close(wh);
    wh = waitbar(0,sprintf('Performing %s',test));
    ks_p = zeros(size(s));
    ks_h = zeros(size(s));
    for i=1:size(s,1)
        wh=waitbar(i/size(s,1),wh);
        for j=1:size(s,2)
            switch test
            case 'kstest'
                [h,p] = kstest2(data1(i,j,:),data2(i,j,:),alpha,tail);
            case 'ttest'
                [h,p] = ttest2(data1(i,j,:),data2(i,j,:),alpha,tail);
            end
            test_p(i,j) = p;
            test_h(i,j) = h;            
        end
    end
    close(wh);
    exper.opt.test.h = test_h;
    exper.opt.test.p = test_p;
    exper.opt.test.bin = bin;
    exper.opt.test.group1 = group1;
    exper.opt.test.group2 = group2;
    exper.opt.test.trials1 = trials1_str;
    exper.opt.test.trials2 = trials2_str;
    exper.opt.test.comp_str = comp_str;
    

    test_p(find(test_h == 0)) = 1;
    dat = log10(test_p);    
ax = position_axes(axes('parent',fig,'tag','opt_axes'),1,1);
    draw_ratio(ax,imresize(dat,bin,'bilinear'),[trials1_str trials2_str],[group1 comp_str group2]);    
   
    show_blobs(fig,ax);
    show_bgd_roi(ax);
        
    
case 'redraw_pixel_test'
    fig = get_ratio_fig('ratio');
    test_p = exper.opt.test.p;
    test_h = exper.opt.test.h;
    group1 = exper.opt.test.group1;
    group2 = exper.opt.test.group2;
    trials1_str = exper.opt.test.trials1;
    trials2_str = exper.opt.test.trials2;
    comp_str = exper.opt.test.comp_str;
    bin = exper.opt.test.bin;
    
    test_p(find(test_h == 0)) = 1;
    dat = log10(test_p);    
    ax = position_axes(axes('parent',fig,'tag','opt_axes'),1,1);
    if bin > 1
        dat = imresize(dat,bin,'bilinear');
    end
    draw_ratio(ax,dat,[trials1_str trials2_str],[group1 comp_str group2]);    
   
    show_blobs(fig,ax);
    show_bgd_roi(ax);
        
    
case 'hist'
    h = findobj('type','figure','tag','ratio_hist');
    if isempty(h)
        h = figure('tag','ratio_hist');    
    else
        figure(h);
    end
    s = size(exper.opt.rawratio);
    rflat = reshape(exper.opt.rawratio,1,s(1)*s(2));
    subplot(2,1,1);
    hist(rflat,64);
    rflat = reshape(exper.opt.ratio,1,s(1)*s(2));
    subplot(2,1,2);
    hist(rflat,64);
     
case 'clone'
    f = gcbf;
    h = copyobj(f(1),0);
    set(h,'pos',get(f(1),'pos')+[20 20 0 0]);

case 'set_range'
    default = get(gcbo,'user');
    ans= inputdlg('Set the intensity range of the image','Enter range: [low high]',1,{default});
    if isempty(ans)
        return
    end
    range = ans{1};
    % should do input checking
    set(gcbo,'user',range);
    range_str = sprintf('Range [%s]',range);
    set(get(gcbo,'parent'),'label',range_str);
    set(findobj(gcbf,'tag','autoscale'),'checked','off');
    
    clim = set_im_scaling(gcbf);
        
    make_title(gcbf);
    
case 'autoscale'
    auto = umtoggle(gcbo);
   
    clim = set_im_scaling(gcbf);
   
    ax = findobj(gcbf,'tag','opt_axes');
    if auto 
        if length(ax) > 1 
            label_str = sprintf('Range [auto]');
        else
            range_str = sprintf('%.3g %.3g',clim(1),clim(2));
            label_str = sprintf('Range [%s]',range_str);
            set(findobj(gcbf,'tag','set_range'),'user',range_str),
        end
    else      
        label_str = sprintf('Range [%s]',get(findobj(gcbf,'tag','set_range'),'user'));
    end
    set(get(gcbo,'parent'),'label',label_str);
    make_title(gcbf);
  
     
case {'lowpass','highpass'}
    
  %  ans= questdlg('Filter all images?');
  %  if strcmp(ans,'Yes')
  %  end
    
    
case 'show_blobs'
    
    umtoggle(gcbo);
   
    % this gca might be a problem
    show_blobs(gcbf,gca);
    
    
    
case 'set_blob_color'
    blobs = findobj(gcbf,'tag','blob');
    current_color = get(findobj(gcbf,'tag','set_blob_color'),'user');
    new_color = uisetcolor(current_color);
    set(blobs,'color',new_color);
    set(findobj(gcbf,'tag','set_blob_color'),'user',new_color);
  
    
case 'show_blob_labels'
    if umtoggle(gcbo)
        set(findobj(gcbf,'tag','blob','type','text'),'visible','on');
    else
        set(findobj(gcbf,'tag','blob','type','text'),'visible','off');
    end
    
    
    
case 'show_labels'
    if umtoggle(gcbo)
        set(findobj(gcbf,'tag','opt_label','type','text'),'visible','on');
    else
        set(findobj(gcbf,'tag','opt_label','type','text'),'visible','off');
    end
  
    
case 'set_label_color'
    labels = findobj(gcbf,'tag','opt_label');
    current_color = get(findobj(gcbf,'tag','set_label_color'),'user');
    new_color = uisetcolor(current_color);
    set(labels,'color',new_color);
    set(findobj(gcbf,'tag','set_label_color'),'user',new_color);
    
    
case 'show_title'
    umtoggle(gcbo);
    make_title(gcbf);
    
       
case {'colormap', 'colormap_flip'}
    
    switch action
    case 'colormap'
        menu = findobj(gcbf,'tag','colormap_menu');
        set(findobj('parent',menu),'checked','off');
        set(gcbo,'checked','on');
        mode = get(gcbo,'tag');
        set(menu,'user', mode);
    case 'colormap_flip'
        umtoggle(gcbo);
    end
    
        % do something to make colormap change right away
    set_colormap(gcbf);
    set(findobj(gcbf,'tag','opt_axes'),'visible','off');
    set(findobj(gcbf,'tag','opt_axes'),'visible','on');
   % colorbar('horiz')
 
case 'axes'
    menu = findobj(gcbf,'tag','axes_menu');
    set(findobj('parent',menu),'checked','off');
    set(gcbo,'checked','on');
    mode = get(gcbo,'tag');
    set(menu,'user', mode);
    show_axes(gcbf);
    
case 'aspect'
    fig = gcbf;
    ax = findobj(fig,'type','image');
    cdat = get(ax(1),'cdata');
    pos = get(fig,'pos');
    image_aspect_ratio = size(cdat,1)/size(cdat,2);
    
    naxes = length(findobj(fig,'tag','opt_axes','visible','on'));
    if naxes > 1 
        ncol = get(findobj(fig,'tag','set_cols'),'user');
        nrow = ceil(naxes/ncol);
        multi_axes = nrow/ncol;
    else
        multi_axes = 1;
    end
    
    pos(4) = pos(3) * image_aspect_ratio * multi_axes
    set(fig,'pos',pos);
    
    
case 'set_cols'
    if nargin == 2
        cols = varargin{2};
        rows = varargin{3};
    else
        ans= inputdlg('Set columns','Number of columns');
        if isempty(ans)
            return
        end
        c = str2num(ans{1});
            set(gcbo,'user',c);        
        cols = c;
        im = findobj(gcbf,'tag','ratio_image','visible','on');
        ax = get(im,'parent');
        len = length(im);
        rows = ceil(len/cols);
    end
    
    dx = 1/cols;
    dy = 1/rows;
    for n=1:len
        col = mod(n-1,cols);
        row = floor((n-1)/cols)+1;
        pos = [col*dx 1-row*dy dx dy];
        set(ax{len-n+1},'pos',pos);
    end
    
        
case 'set_bgd_roi'
    % called from figure menu
    h = text(10,10,'Select background ROI...','fontweight','bold','fontsize',14);
   
    ax = gca;
    
    h = show_bgd_roi(ax,1);
    set(h,'color',[0 1 0]);
    
    figure(gcbf);
    [bw,x,y] = roipoly;
    delete(h);
    
    SetParam('opt','roi','x',x,'y',y,'bw',bw);  
    line(x,y,'parent',ax,'linestyle','-','linewidth',1,'tag','bgd_roi');
    
    set(findobj(gcbf,'tag','show_bgd_roi'),'checked','on');
    
    
case 'show_bgd_roi'
    show = umtoggle(gcbo);
    show_bgd_roi(gca,show);
         
    im_h = findobj(gcbf,'tag','ratio_image');
    im = get(im_h(1),'cdata');
    
    if show
        roi_x = GetParam(me,'roi','x');
        roi_y = GetParam(me,'roi','y');
        if isempty(roi_x)
            Opt('set_bgd_roi');
        end
        roi = roipoly(im,roi_x,roi_y);
    end
    
        

case 'data_path'
    [name, path] = uigetfile('*.avi','Select a file in the data directory...');
    if isequal(path,0) %user hit the cancel button
        return;
    end
    set(gcbo,'user',path);
    
    
case 'open_single'
   if nargin < 2
      in_path = get(findobj(gcbf,'tag','data_path'),'user');    
        
     [name, path] = uigetfile('.avi','Open .avi file...');
        if isequal(name,0) | isequal(path,0) %user hit the cancel button
            message(me,'Cancelled .avi open');
            return;
      end    
      filename = [path '\' name];
  else
      filename = varargin{2};
  end
 
  
  im = aviread(filename,'all','read');
  varargout{1} = im;
  
  
 % set_avi_info(filename);
 % calc_ratio(trial);
        
   


case 'open_series'
    
    if nargin < 2
        if isempty(GetParam(me,'filebase'))
            Opt('set_path');
        end
        range = inputdlg('Enter trial range','Import .AVI files',1,{num2str(uirange)});
        if isempty(range)
            return;
            message(me,'Canceled open series');
        else
            trials = str2num(range{1});
        end
        
        answer =questdlg('Calculate time course?');
        do_timecourse = strcmp(answer,'Yes');
        
    else
        trials = varargin{2};
    end
    SetParam('control','trial','range',[1 999]);
    
    for n=trials
        
        filename = sprintf('%s%03d.avi',GetParam(me,'filebase'),n);
        message(me,['Loading ' filename '...']);
        
        exper.opt.im = [];
        [exper.opt.im, rate] = aviread(filename,'all','read');
        if exper.opt.im == -1
            message(me,'File not found!','error');
            return;
        end
        
        set_avi_info(filename);
        
        calc_ratio(n);
        
        if do_timecourse
            blob('timecourse');
        end
        
    end 
    message(me,'');
    
    
    
    
case 'avi_avg'
 
    out_path = get(gcbo,'user');
    in_path = get(findobj(gcbf,'tag','data_path'),'user');    
    trials = str2num(get(findobj(gcbf,'tag','trials','user','group'),'string'));
    group = GetPopupmenuItem('group',gcbf);
    expid = GetParam('control','expid');
    
    bin = 1;
    stack = 4;
    
    [avg, in_path, out_path] = avi_average(expid,trials,group,bin,stack,in_path,out_path);
    set(gcbo,'user',out_path);
    set(findobj(gcbf,'tag','data_path'),'user',in_path);
    
    exper.opt.im = avg;
    
case 'avi_avg_all'
    out_path = get(gcbo,'user');
    s_list = GetParam('group','group','list');
    for n=1:length(s_list)
        SetParam('group','group','value',n);
        Group('group');
        out_path = avi_average(path);
        set(gcbo,'user',out_path);
    end    
          
    
case 'movie'
    
    for n=1:size(exper.opt.im,3)
        M(n) = im2frame(double(exper.opt.im(:,:,n)));
    end
    movie(M);
    
    

% -------------------------------------------------------------------------------------
% Handle gui events in the display window
% -------------------------------------------------------------------------------------
    
case 'keypress' 
    mode = get(findobj(gcbf,'tag','show_blobs'),'checked');
    if strcmp(mode,'on')
            Blob('keypress');
    end


case 'buttonup'
    user.buttondown = 0;
    set(gcbf,'user',user);
    if strcmp(get(gco,'type'),'image')
        
    else
        mode = get(findobj(gcbf,'tag','show_blobs'),'checked');
        if strcmp(mode,'on')
            Blob('buttonup');
        end
    end
    
case 'buttondown'
    
    user.buttondown = 1;
    set(gcbf,'user',user);
    type = get(gco,'type');
    if strcmp(get(gco,'tag'),'blob')
        Blob('buttondown');
        return;
    end
    
    switch type
    case 'image'
        ax = get(gco,'parent');
        user = get(ax,'user');
        
        switch get(gcf,'SelectionType');
        case 'open'
            Blob('buttondown');
        case 'normal'       % left button
            % select the image
  %          SetParam(me,'trials',user.trials);
  %          SetParam(me,'name',user.name);
        case 'extend'       % middle-button or left+right-buttons or shift/left-button
        case 'alt'          % right-button or alt/left-button
            % add to the invalid list if it's a single image
            if length(str2num(user.trials)) == 1
                % if the image is not already invalid
                if isempty(find(str2num(user.trials) == str2num(GetParam('group','invalid'))))
                    % add the trial to the invalid list
                    Group('add_invalid', user.trials); 
                    x = get(ax,'xlim');
                    y = get(ax,'ylim');
                    line([x(1) x(2)],[y(2) y(1)],'parent',ax,'color','red','tag','invalid');
                    line([x(1) x(2)],[y(1) y(2)],'parent',ax,'color','red','tag','invalid');
                else
                    % if the image is already invalid then remove it from the invalid list
                    new_invalid = Group('delete_invalid',user.trials);
                    delete(findobj(ax,'tag','invalid','type','line'));
                end
            end                
        case ''         % double click
        otherwise
        end
     case 'text'
        if strcmp(get(gcf,'SelectionType'),'open') % double click
            click_str = get(gco,'string');
            if str2num(click_str) > 0
                % clicked on a single trial
                trial = click_str;
                Opt('display',trial);
            end
        end
         
    otherwise
    end
    
    
case 'buttonmotion'
   user = get(gcbf,'user');
   if user.buttondown
       Blob('buttonmotion');
   end
  
    
	
% -------------------------------------------------------------------------------------
% implement external functions
% -------------------------------------------------------------------------------------

case 'roi'
   % bw = Opt('bgd_roi')
   % Returns the current background roi. If 'use roi' is not checked, the roi
   % is the entire image.
   % bw is a matrix of 1's and 0's (see ROIPOLY Matlab function). 

    
   varargout{1} = get_bgd_roi
  
   
otherwise	
	message(me,'')
end



% begin local functions

function out = callback
	out = [lower(mfilename) ';'];

function out = me
	out = lower(mfilename); 
    
    
    
function update_display_menu(fig)

    % clear the current menu
    m1 = findobj(fig,'label','Display');
    if isempty(m1)
        return;
    end
    % only work with the most recent figure
    m1 = m1(1);
    delete(findobj('parent',m1));
    
    [trials,groups] = Group('all');
    
    for n=2:length(groups)
        m2 = uimenu(m1,'label',groups{n},'tag','disp_group');
        avg_menu = uimenu(m2,'label','average','tag',groups{n},'callback','opt(''avg_menu'')');
        alb_menu = uimenu(m2,'label','album','tag',groups{n},'callback','opt(''album_menu'')');
        tr = str2num(trials{n});
        for m=1:length(tr)
            trial_menu = uimenu(m2,'label',num2str(tr(m)),'tag',groups{n},'callback','opt(''disp_menu'')');
            if m==1
                set(trial_menu,'separator','on');
            end
        end
    end
    
        

function fig = get_ratio_fig(name,opt)
% if called with opt = 'hold', then don't erase it

    expid = GetParam('control','expid');
    title = sprintf('%s %s',expid,name);

    % first, check if there is a window with the same name
    % if so, then assume that we want to update this one
    h = findobj('tag',expid,'name',title);
	if ~isempty(h)
        fig = h(1);
        % if called with opt = 'hold', then don't erase it
        if nargin >= 2 & strcmp(opt,'hold')
            return;
        end
        ax = findobj(fig,'tag','opt_axes');
        % set(findobj(ax),'visible','off');  
        % kill all the axes!
        delete(ax);
        make_title(fig);
        return;
    else
        % otherwise just look for any ratio figure
        % so that we can copy it's settings
        h = findobj('tag',expid);
        if ~isempty(h)
            fig = copyobj(h(1),0);
            delete(findobj(fig,'type','axes'));
            set(fig,'name',title,'pos',get(h(1),'pos')+[20 20 0 0]);
            make_title(fig);
            return;
        end
    end    
    % otherwise, if this is the first figure then we need to actually create it
    
    user.buttondown = 0;
    
    fig = figure('name',title,'tag',expid,'number','off','doublebuffer','on',...
        'backingstore','on','sharecolors','off',...
        'renderermode','manual','renderer','zbuffer',...
        'keypressfcn','opt(''keypress'');',...
        'WindowButtonDownFcn','opt(''buttondown'');',...
        'WindowButtonUpFcn','opt(''buttonup'');',...
        'WindowButtonMotionFcn','opt(''buttonmotion'');',...
        'user',user);
        
    m1 = uimenu(fig,'label','Opt','tag','menu');
    uimenu(m1,'label','Clone','tag','clone','callback',[me '(''clone'');'],'accelerator','L');
    
    m2 = uimenu(m1,'label','Range [-0.003 0.003]','tag','range_menu');
    uimenu(m2,'label','Set...','tag','set_range','callback','opt(''set_range'');','user','-0.003 0.003');
    uimenu(m2,'label','Autoscale','tag','autoscale','callback','opt(''autoscale'');');


    m2 = uimenu(m1,'label','Background ROI','tag','roi_menu');
    uimenu(m2,'label','Show','tag','show_bgd_roi','callback','opt(''show_bgd_roi'');');
    uimenu(m2,'label','Set...','tag','set_bgd_roi','callback','opt(''set_bgd_roi'');');
    
    m2 = uimenu(m1,'label','Axes','tag','axes_menu','user','off');
    uimenu(m2,'label','Off','tag','off','check','on','callback','opt(''axes'');');
    uimenu(m2,'label','Grid','tag','grid','check','off','callback','opt(''axes'');');
    uimenu(m2,'label','Grid+labels','tag','grid_labels','check','off','callback','opt(''axes'');');
    uimenu(m2,'label','Set cols','tag','set_cols','callback','opt(''set_cols'');','user',1,'separator','on');
    uimenu(m2,'label','Set aspect','tag','aspect','callback','opt(''aspect'');');
    
    m2 = uimenu(m1,'label','Blobs','tag','blobs_menu');
    uimenu(m2,'label','Edit','tag','show_blobs','checked','off','callback','opt(''show_blobs'');');
    uimenu(m2,'label','Labels','tag','blob_labels','checked','on','separator','on','callback','opt(''show_blob_labels'');');
    uimenu(m2,'label','Set color...','tag','set_blob_color','user','white','separator','on',...
        'callback','opt(''set_blob_color'');');
    m3 = uimenu(m2,'label','Sort','tag','blob_sort_menu');
    uimenu(m3,'label','Sort by x','tag','blob_sort_by_x','callback','blob(''sort_by_x'');');
    uimenu(m3,'label','Sort by y','tag','blob_sort_by_y','callback','blob(''sort_by_y'');');
    
    m2 = uimenu(m1,'label','Labels','tag','label_menu');
    uimenu(m2,'label','Show title','tag','show_title','check','on','callback','opt(''show_title'');');
    uimenu(m2,'label','Show labels','tag','show_labels','check','on','callback','opt(''show_labels'');');
    uimenu(m2,'label','Set color...','tag','set_label_color','separator','on','user','white',...
        'callback','opt(''set_label_color'');');

    m2 = uimenu(m1,'label','Colormap','tag','colormap_menu','user','gray');
    uimenu(m2,'label','Gray','tag','gray','check','on','callback','opt(''colormap'');');
    uimenu(m2,'label','Hot','tag','hot','check','off','callback','opt(''colormap'');');
    uimenu(m2,'label','Jet','tag','jet','check','off','callback','opt(''colormap'');');
    uimenu(m2,'label','Flip','tag','flip_colormap','check','off','separator','on','callback','opt(''colormap_flip'');');
    
    m1 = uimenu(fig,'label','Display','tag','display');
     
    set_colormap(fig); 
    update_display_menu(fig);
    make_title(fig);

    
    
function ax = position_axes(ax,index,total)
% index is the current image number
% total is the total number of images in this figure

    fig = get(ax,'parent');
    show_axes(fig,ax);
	   
    if total == 1
        set(ax,'pos',[0 0 1 1]);
    else
        
        cols = ceil(sqrt(total));
        
        % see if user has specified the number of columns
        h = findobj(fig,'tag','set_cols');
        c = get(h,'user');
        if c > 1        % assume that if c == 1 then we should ignore this request
            cols = c;       
        else
            set(h,'user',cols);
        end
        
        rows = ceil(total/cols);
        col = mod((index-1),cols);
        row = floor((index-1)/cols)+1;
        
        dx = 1/cols;
        dy = 1/rows;
        pos = [col*dx 1-row*dy dx dy];
        set(ax,'pos',pos);    
    end
    
     

function show_ratio(fig,trials,group,index,total)

    if nargin == 3
        index = 1;
        total = 1;
    end
    
    ax = axes('parent',fig,'tag','opt_axes');
    position_axes(ax,index,total);
    
    raw = get_rawratio(trials);
    dat = filter_image(raw);
    draw_ratio(ax,dat,trials,group);
    
    show_blobs(fig,ax);
    show_bgd_roi(ax);
    
        
    

function draw_ratio(ax,dat,trials,group)

    fig = get(ax,'parent');
     
    user.group = group;
    user.trials = trials;
    set(ax,'climmode','manual','DataAspectRatioMode','manual','tag','opt_axes','user',user);
    
    im_h = findobj(ax,'tag','ratio_image');
    if isempty(im_h)
        im_h = image('parent',ax,'tag','ratio_image','cdatamapping','scaled');
    end
    set(im_h,'cdata',rot90(dat,-1));
	if ~isempty(dat)
        set(ax,'xlim',[1 size(dat,1)-1],'ylim',[1 size(dat,2)-1]);
    end
 
    % set scaling
    set_im_scaling(fig);   
    
    % add label
    if isempty(group) | size(str2num(trials)) == 1
        string = trials;
    else
        string = group;
    end
    
    color = get(findobj(fig,'tag','set_label_color'),'user');
    visible = get(findobj(fig,'tag','show_labels'),'checked');    
    x = get(ax,'xlim');
    y = get(ax,'ylim');
    text(x(1)+(x(2)-x(1))/20,y(2)-(y(2)-y(1))/20,string,'tag','opt_label','visible',visible,...
             'fontname','arial','fontweight','bold','vertical','top','interpreter','none',...
             'parent',ax,'color',color);
    
    
    
function ans = changed_windows(trial)
% function to determine whether the baseline and response windows
% are changed
global exper
     
    if GetParam(me,'base_del') ~= GetParamTrial(me,'base_del',trial) | ...
       GetParam(me,'base_dur') ~= GetParamTrial(me,'base_dur',trial) | ...
       GetParam(me,'resp_del') ~= GetParamTrial(me,'resp_del',trial) | ...
       GetParam(me,'resp_dur') ~= GetParamTrial(me,'resp_dur',trial)
  
        ans = 1;
    else
        ans = 0;
    end
    
    
function restore_windows(trial)
% function to set the current baseline and response windows back to the stored values
global exper

	if ~isempty(GetParamTrial(me,'base_del',trial))
        SetParam(me,'base_del',GetParamTrial(me,'base_del',trial));
        SetParam(me,'base_dur',GetParamTrial(me,'base_dur',trial));
        SetParam(me,'resp_del',GetParamTrial(me,'resp_del',trial));
        SetParam(me,'resp_dur',GetParamTrial(me,'resp_dur',trial));
	end

function save_windows(trial)
% function to save the current baseline and response windows for the trial   
  
    SaveParamTrial(me,'base_del',trial);
    SaveParamTrial(me,'base_dur',trial);
    SaveParamTrial(me,'resp_del',trial);
    SaveParamTrial(me,'resp_dur',trial);
   
function dat = get_rawratio(trials)
global exper

    if ischar(trials)
        trials = str2num(trials);
    end
    dat = [];
    skipped = [];
    % in this function, one could allow for the average to be saved
    % as a group 
    
    % one could also abandom the current method of storing ratios in 
    % the exper structure, and for example, read them from a file
            
    for n=1:length(trials)
        tr = trials(n);
        
        if changed_windows(tr) 
            % here one must read the data from file    
            
            im = calc_ratio_from_avi(tr);
            if im == -1 % -1 is the 'code' for frames out of range
                im = [];
                return;
            end
            
            if isempty(im)
                message(me,'Couldn''t open .avi','error');
                im = expand(exper.opt.trial(tr).rawratio);
                return;
            else
                exper.opt.trial(tr).rawratio = compress(im,'uint16');
                save_windows(tr);
            end
        else
            im = expand(exper.opt.trial(tr).rawratio);
        end
   
        if n==1
            dat = im;
        else
            if sum(size(dat)-size(im)) == 0
                dat = dat + im;
            else
                skipped = [skipped n];
            end
                
             
        end
    end    
    n = length(trials)-length(skipped);
    dat = dat/n;
    
    if ~isempty(skipped)
        skp_str = sprintf('%d ',skipped);
        message(me,['size mismatch ' skp_str]); 
    else
        message(me,'');
    end

    
function filename = get_avi_filename(trial)
global exper


    fig = findobj('tag','opt','type','figure');
    path = get(findobj(fig,'tag','data_path'),'user');    
	
    name = sprintf('%s%03d.avi',GetParam('control','expid'),trial);
    filename = [path '\' name];
    
    fid = fopen(filename); 
    if fid == -1
        ans = questdlg(sprintf('Can you locate the file %s?',name));
        read_avi_ok = strcmp(ans,'Yes');
        if ~read_avi_ok
            % put the current windows back to what is stored in exper 
            restore_windows(trial);
            filename = '';
            message(me,'No image loaded','error');
            return;
        end
            
        path = uigetfolder('Select the .avi folder...');
        if isempty(path) %user hit the cancel button
            message(me,'Cancelled');
            % put the current windows back to what is stored in exper 
            restore_windows(trial);
            filename = '';
            return;
        end    
        set(findobj(fig,'tag','data_path'),'user',path);    
        filename = [path '\' name];
        
        fid = fopen(filename); 
        if fid == -1
            % put the current windows back to what is stored in exper 
            restore_windows(trial);
            filename = '';
            return;
        end
    else
        set(findobj(fig,'tag','data_path'),'user',path);    
    end
    fclose(fid);
    
    
    
function im = calc_ratio_from_avi(trial)

    filename = get_avi_filename(trial);
    
    if isempty(filename)  % if use 'cancel'ed then true
        im = [];
        return;
    end
    
    avirange = aviread(filename);
    
    base = GetParam(me,'base_del')+1:(GetParam(me,'base_del')+GetParam(me,'base_dur'));
    resp = GetParam(me,'resp_del')+1:(GetParam(me,'resp_del')+GetParam(me,'resp_dur'));

    if base(end) > avirange(end) | resp(end) > avirange(end)
        message(me,sprintf('File has only %d frames, windows invalid',avirange(end)),'error');
        im = -1;
        return;
    end
    
    
    message(me,'Reading from .avi file');
    
    imbase = aviread(filename,base,'avg');
    imresp = aviread(filename,resp,'avg');
    
    im = calc_ratio(trial,imbase,imresp);
     
    message(me,'');
    
    

function im = calc_ratio(trial,imbase,imresp)
global exper
 
    % don't use 0 pixels in the denominator
    zpix = find(imbase == 0);
    if length(zpix) > 0
        imbase(zpix) = NaN;
    end 
        
    im = imresp ./ imbase - 1;
   
    
function im = filter_image(raw,low,high,filter,bgd_subtract,bin)
%
% im = filter_image(raw,low,high,filter,bgd_subtract)
%   Note. All parameters are gotten from the blob and opt gui's if not passed.
%   LOW and HIGH are filter widths: low < high
%   LOW is used as a smoothing filter to get rid of noise
%   HIGH is used to compute a broadly smoothed filter that is subtracted 
%   FILTER is one of {'bandpass','highpass','lowpass','none'}, meaning
%       'none': unfiltered ratio
%       'bandpass': bandpass filtered, calculated from [lowpass - highpass]
%       'lowpass': gaussian filtered ratio, smaller kernel
%       'highpass': gaussian filtered ratio, larger kernel
%   BGD_SUBTRACT is one of {'none','roi mean','image mean'}
%       'none': no background subtraction
%       'image mean': subtract the average value of the ratio image computed across the whole image
%       'roi mean': ditto ... computed across the region of interest (ROI)
%   BIN: optional parameter specifying binning in the x,y dimension
%        does not use bin parameter from the menu -- must be passed explicitly
%
global exper    


    if nargin < 3
        [low, high] = get_filter;    
    end
	if nargin < 4
        bgd_subtract = GetPopupmenuItem('bgd_subtract',findobj('type','figure','tag','opt'));
    end
    if nargin < 5
        filter = GetPopupmenuItem('filter',findobj('type','figure','tag','opt'));
    end
    if nargin < 6
        %      bin = str2num(GetPopupmenuItem('bin'));
        bin = 1;        % do not use bin parameter from the menu -- must be passed explicitly
        
    end
    
    if bin > 1
        raw = bin2(raw,bin);
    end
        
    switch filter
    case 'bandpass'
        im = gaussian2(low/bin,raw) - gaussian2(high/bin,raw);
    case 'highpass'
        im = gaussian2(high/bin,raw);
    case 'lowpass'
        im = gaussian2(low/bin,raw);
    case 'none'
        im = raw;
    end
        
    switch bgd_subtract
    case 'image mean'
        im = im - mean2(raw);
	case 'roi mean'
        bw = get_bgd_roi(raw); 
        im = im - mean2(raw(bw));
	case 'none'
	end
	
	

function [low,high] = get_filter
global exper

    low = GetParam(me,'lowpass');
    high = GetParam(me,'highpass');


   
function bw = get_bgd_roi(im)
    
    roi_x = GetParam(me,'roi','x');
    roi_y = GetParam(me,'roi','y');
    
    if ~isempty(roi_x) & ~isempty(roi_y)
        % THIS ROTATION HAS TO BE CHECKEDD!!!!!!        
        bw = rot90(roipoly(rot90(im),roi_x,roi_y),-1);
        %        bw = roipoly(im,roi_x,roi_y);
        %      disp('')
    else
        bw = ones(size(im,1),size(im,2));
    end

function clim = set_im_scaling(fig,range)
   
    if nargin < 2
	    autoscale = strcmp(get(findobj(fig,'tag','autoscale'),'checked'),'on');
	    range = str2num(get(findobj(fig,'tag','set_range'),'user'));
    else
        autoscale = 0;
    end
	
    ax = findobj(fig,'tag','opt_axes');
    for n=1:length(ax)
        im_h = findobj(ax(n),'tag','ratio_image'); % there should only be 1 im_h
        if autoscale
            if isempty(get(im_h,'user'))
                dat = get(im_h,'cdata');
                clim = [min2(dat) max2(dat)];
                set(im_h,'user',clim);
            else
                clim = get(im_h,'user');
            end
	    else
            clim = range;
	    end
        set(ax,'clim',clim);
    end   
    

function h=show_bgd_roi(ax,show)
global exper


    fig = get(ax,'parent');
  
    if nargin < 2
        show = strcmp(get(findobj(fig,'tag','show_bgd_roi'),'checked'),'on');
    end
    h = findobj(fig,'tag','bgd_roi','type','line');
    if show
        if isempty(h)
            x = GetParam(me,'roi','x');
            y = GetParam(me,'roi','y');
            h = line(x,y,'parent',ax,'linestyle','-','linewidth',1,'tag','bgd_roi');
        else
            set(h,'parent',ax,'visible','on');
        end
    else
        set(h,'visible','off');    
    end
    

function show_blobs(fig,ax)
        
    blob = findobj(fig,'tag','blob');
    
    if strcmp(get(findobj(fig,'tag','show_blobs'),'checked'),'on')
        if isempty(blob)
            Blob('draw',ax);
        else
            set(blob,'visible','on','parent',ax);
        end
    else
        set(blob,'visible','off');
    end

 
function make_title(fig)
    
   delete(findobj(fig,'tag','ratio_title'));
   if strcmp(get(findobj(fig,'tag','show_title'),'checked'),'on')
       ax = axes('parent',fig,'pos',[0 0 1 1],'tag','ratio_title','visible','off');
       range = lower(get(findobj(fig,'tag','range_menu'),'label'));
       filter = lower(get(findobj(fig,'tag','filter_menu'),'label'));
       name = get(fig,'name');
       title_str = sprintf('%s:  %s  %s',name,filter,range);
       
       h = text(0.5,1,title_str,'horiz','center','vertical','top','parent',ax,'tag','ratio_title','interpreter','none');
   end
    
function show_axes(fig,ax)
    
    if nargin < 2
        ax = findobj(fig,'tag','opt_axes');
    end 
    
    mode = get(findobj(fig,'tag','axes_menu'),'user');
    switch mode
    case 'off'
        set(ax,'visible','off');
    case 'grid'
        set(ax,'xgrid','on','ygrid','on','visible','on','layer','top','box','on','gridlinestyle','-');
        set(ax,'xticklabel','','yticklabel','');
    case 'grid_labels'
        set(ax,'xgrid','on','ygrid','on','visible','on','layer','top','box','on','gridlinestyle','-');
        set(ax,'xticklabelmode','auto','yticklabelmode','auto');
    end
    
  
    
function set_colormap(fig)
global exper

    switch get(findobj(fig,'tag','colormap_menu'),'user')
    case 'gray'
        cmap = gray;
    case 'hot'
        cmap = flipud(hot);
    case 'jet'
        cmap = flipud(jet);
        cmap(end,:) = [0 0 0];
    end

    % flip colormap?
    if strcmp(get(findobj(fig,'tag','flip_colormap'),'checked'),'on')
       cmap = flipud(cmap);
    end
    set(fig,'colormap',cmap);
    

    
function id = get_odor_id
global exper
    trials = str2num(GetParam(me,'trials'));
    ids = GetParam('whiff','id','trial');
    id = ids{trials(1)};
    for n=1:length(trials)
        if ~strcmp(ids{trials(n)},id)
            id = '';
            return
        end
    end



    
function set_avi_info(filename)
    info = aviread(filename,'all','info');
        
        SetParam('control','trial',info.param(1));
        SetParam(me,'trials',num2str(info.param(1)));
        
        SetParam('control','exptime',info.param(2));
        SaveParamTrial('control','exptime');
        
        SetParam('whiff','delay',info.param(11));
        SaveParamTrial('whiff','delay');
        
        SetParam('whiff','duration',info.param(12));
        SaveParamTrial('whiff','duration');
        
        odor_id = info.param(3:10);
        odor_flow = info.param(22:29);
        default_flow = GetParam('whiff','default_flow');
        for n=1:length(odor_id)
            odid{n} = num2str(odor_id(n));
            if odor_flow(n) > 0
                flow{n} = num2str(odor_flow(n));
            else
                flow{n} = default_flow;
            end
        end
        SetParam('whiff','id','list',odid);
        SetParam('whiff','flow','list',flow);
        
        %       for now we only deal with single odors (not multiple channels at once)!
        chan = info.param(13);
        SetParam('whiff','sequence','value',chan);
        SaveParamTrial('whiff','sequence');
        
        if length(odid) >= chan
            % this means we have all the ids represented 
            % as in newer .avi files
            SetParam('whiff','id','value',chan(1));
            SetParam('whiff','flow','value',chan(1));
        else
            % otherwise we only have one id, so we use it
            SetParam('whiff','id','value',1);
            SetParam('whiff','flow','value',1);
        end
        SaveParamTrial('whiff','id');
        SaveParamTrial('whiff','flow');
        
        
function [im, in_path, out_path] = avi_average(expid,trials,group,bin,stack,in_path,out_path)
global exper
% This function averages together .avi movies from a set to make a new .avi movie file

    if nargin < 7 | isempty(out_path)
       out_path = uigetfolder('Select output directory...');
    end
        
    if nargin < 6 | isempty(in_path)
        [filename, in_path] = uigetfile('Select a file in the input directory...');
    end
    
    if nargin < 5
        stack = 1;
    end
    
    if nargin < 4
        bin = 1;
    end    
    
    if ischar(trials)
        trials = str2num(trials);
    end
    
    k = 0;

    for n=trials
        filename = sprintf('%s\\%s%03d.avi',in_path,expid,n);
        message(me,sprintf('Reading %s%03d.avi',expid,n));
      
        if k==0
            info = aviread(filename,'all','info');
            im = [];
            im = aviread(filename,'all','read');
        else
            im = imadd(im,aviread(filename,'all','read'));
    	end
	
	    k = k+1;
	end
	
	if k >= 1
        im = imdivide(im,k);
     %   if bin > 1 | stack > 1 
     %       im = bin3(im,[bin bin stack]);
     %   end
       
        info.avg = 1;
        info.rate = 30/stack;
        
        filename = sprintf('%s\\%s_%s.avi',out_path,expid,group);
        AVIwrite(im,filename,info);
        message(me,sprintf('Wrote %s%s',expid,group));
	end

    
    