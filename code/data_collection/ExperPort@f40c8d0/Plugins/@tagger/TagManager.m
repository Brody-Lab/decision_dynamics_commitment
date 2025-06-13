function obj=TagManager(obj,varargin)
% Deals with 3 cases
% obj=tagger() Returns a obj of class tagger
% obj=tagger(obj, 'init') contructs the SPH handles and makes obj the owner.
%       The owner can be 'base'
% obj=tagger(obj, 'init_gui',x,y) constructs the SPH handles and makes a GUI a x,y.
%                           This is optional.
%
%                           if x==-1 create a new window instead of drawing
%                           in current window

if nargin<2
    obj = class(struct, mfilename);
    return;
end


GetSoloFunctionArgs(obj);
if ~isobject(obj) || ~isa(obj,'tagger')
    warning('tagger:tagger','first argument should be an object of type tagger');
    return
end

action=varargin{1};

switch action
    case 'init'
        
        SoloParamHandle(obj,'ratname');
        SoloParamHandle(obj,'sessiondate');
        SoloParamHandle(obj,'tags');
        SoloParamHandle(obj,'sesstags');
        
        
    case 'init_with_gui'
        TagManager(obj,'init');
        x=varargin{2};
        y=varargin{3};
        if x==-1
            SoloParamHandle(obj,'tagwindow','value',double(figure))
            set(value(tagwindow),'Position',[100 100 220 180]);
            set(value(tagwindow),'MenuBar','none')
            set(value(tagwindow),'Name','Tag Manager')
            
            
            
            x=10; y=10;
        else
            SoloParamHandle(obj,'tagwindow','value',[])
        end
        
        %% setup the rat tags
        TextBoxParam(obj,'tagbox','',x,y);
        gl=get_glhandle(tagbox);
        set(gl(2),'Visible','off')
        p=get(gl(1),'Position'); set(gl(1),'Position',[p(1) p(2) 200 40]);
        next_row(y,2);
        
        EditParam(obj,'tagedit','',x,y,'label','Edit Rat Tag');
        gl=get_glhandle(tagedit);
        set(gl(2),'Visible','off')
        %p=get(gl(1),'Position'); set(gl(1),'Position',[p(1) p(2) 100 p(4)]);
        
        PushbuttonParam(obj,'addtagbutton',x,y,'label','Add');
        gl=get_glhandle(addtagbutton);
        p=get(gl,'Position'); set(gl,'Position',[p(1)+100 p(2) 50 p(4)]);
        
        PushbuttonParam(obj,'subtagbutton',x,y,'label','Sub');
        gl=get_glhandle(subtagbutton);
        p=get(gl,'Position'); set(gl,'Position',[p(1)+150 p(2) 50 p(4)]);
        
        add_callback(addtagbutton,{mfilename,'add'});
        add_callback(subtagbutton,{mfilename,'sub'});
        
        next_row(y,1);
        
        SubheaderParam(obj,'ratsubhead','Rat Tags',x,y);
        
        next_row(y,1);
        
        %% setup the sess tags
        TextBoxParam(obj,'sesstagbox','',x,y);
        gl=get_glhandle(sesstagbox);
        set(gl(2),'Visible','off')
        p=get(gl(1),'Position'); set(gl(1),'Position',[p(1) p(2) 200 40]);
        next_row(y,2);
        
        EditParam(obj,'sesstagedit','',x,y,'label','Edit Sess Tag');
        gl=get_glhandle(sesstagedit);
        set(gl(2),'Visible','off')
        %p=get(gl(1),'Position'); set(gl(1),'Position',[p(1) p(2) 100 p(4)]);
        
        PushbuttonParam(obj,'addsesstagbutton',x,y,'label','Add');
        gl=get_glhandle(addsesstagbutton);
        p=get(gl,'Position'); set(gl,'Position',[p(1)+100 p(2) 50 p(4)]);
        
        PushbuttonParam(obj,'subsesstagbutton',x,y,'label','Sub');
        gl=get_glhandle(subsesstagbutton);
        p=get(gl,'Position'); set(gl,'Position',[p(1)+150 p(2) 50 p(4)]);
        
        add_callback(addsesstagbutton,{mfilename,'sessadd'});
        add_callback(subsesstagbutton,{mfilename,'sesssub'});
        
            next_row(y,1);
        
        SubheaderParam(obj,'sesssubhead','Sess Tags',x,y);
     
        
        
        if  ~isempty(tagwindow)
            set(get(gcf,'Children'),'units','normalized')
        end
        
        
        
        TagManager(obj,'update');
        % This allows users to expand the window
        
        
        
    case 'update',
        %% update
        sessid=getSessID(obj);
        if ~isempty(sessid) 
            % Do rat tags
            [rat sd]=bdata('select ratname, sessiondate from sessions where sessid="{S}"',sessid);
            ratname.value=rat{1}; sessiondate.value=sd{1};
            [addtags,adddate]=bdata('select tag,max(tagdate) from udata.addtag where ratname="{S}" and tagdate<="{S}" group by tag order by tagdate desc',value(ratname),value(sessiondate));
            [subtags,subdate]=bdata('select tag,max(tagdate) from udata.subtag where ratname="{S}" and tagdate<="{S}" group by tag order by tagdate desc',value(ratname),value(sessiondate));
            if ~isempty(addtags) && ~isempty(addtags{1})
                tags.value=parse_tags(addtags,adddate,subtags,subdate);
                tagbox.value=display_tags(value(tags));
                
            else
                tags.value={};
                tagbox.value='';
            end
            
            %Do sess tags
            [t_tags]=bdata('select tag from udata.sesstag where sessid="{S}" and ignore_tag!=1',sessid);
            if ~isempty(t_tags)
                sesstags.value=t_tags;
                sesstagbox.value=display_tags(value(sesstags));
            else
                sesstags.value={};
                sesstagbox.value='';
            end
            
            
        end
    case 'add',
        % First check if we got a tag from the function call
        if nargin==3
            newtag=strtrim(varargin{2});
        else
            newtag=strtrim(value(tagedit));
        end
        
        % second check if it is necessary.
        conf=intersect(value(tags),newtag);
        if isempty(conf)
            sessid=getSessID(obj);
            if ~isempty(sessid)
                [rat sd]=bdata('select ratname, sessiondate from sessions where sessid="{S}"',sessid);
                ratname.value=rat{1}; sessiondate.value=sd{1};
                bdata('insert into udata.addtag values ("{S}","{S}","{S}","{S}")',value(ratname),sessid,newtag,value(sessiondate));
                TagManager(obj,'update');
                
            end
        end
        tagedit.value='';
        
    case 'sub',
        % First check if we got a tag from the function call
        if nargin==3
            newtag=strtrim(varargin{2});
        else
            newtag=strtrim(value(tagedit));
        end
        
        % 2nd check if it is necessary.
        newtag=strtrim(value(tagedit));
        conf=intersect(value(tags),newtag);
        if ~isempty(conf)
            sessid=getSessID(obj);
            if ~isempty(sessid)
                [rat sd]=bdata('select ratname, sessiondate from sessions where sessid="{S}"',sessid);
                ratname.value=rat{1}; sessiondate.value=sd{1};
                bdata('insert into udata.subtag values ("{S}","{S}","{S}","{S}")',value(ratname),sessid,newtag,value(sessiondate));
                TagManager(obj,'update');
                
            end
        end
        tagedit.value='';
        
    case 'sessadd',
        % First check if we got a tag from the function call
        if nargin==3
            newtag=strtrim(varargin{2});
        else
            newtag=strtrim(value(sesstagedit));
        end
        
        % second check if it is necessary.
        conf=intersect(value(sesstags),newtag);
        if isempty(conf)
            sessid=getSessID(obj);
            if ~isempty(sessid)
                [rat]=bdata('select ratname from sessions where sessid="{S}"',sessid);
                ratname.value=rat{1}; 
                bdata('insert into udata.sesstag values ("{S}","{S}","{S}",0)',value(ratname),sessid,newtag);
                TagManager(obj,'update');
                
            end
        end
        sesstagedit.value='';
        
    case 'sesssub',
        % First check if we got a tag from the function call
        if nargin==3
            newtag=strtrim(varargin{2});
        else
            newtag=strtrim(value(sesstagedit));
        end
        
        % 2nd check if it is necessary.
        conf=intersect(value(sesstags),newtag);
        if ~isempty(conf)
            sessid=getSessID(obj);
            if ~isempty(sessid)
                [rat]=bdata('select ratname from sessions where sessid="{S}"',sessid);
                ratname.value=rat{1}; 
                mym(bdata,'update udata.sesstag set ignore_tag=1 where sessid="{S}" and tag="{S}"',sessid,newtag);
                TagManager(obj,'update');
                
            end
        end
        sesstagedit.value='';
        
    case 'show_all_tags',
    case 'show_rats_tags',
    case 'showhide'
        sh=varargin{2};
        if ~isempty(tagwindow)
            if sh==1
                set(value(tagwindow),'Visible','on');
            else
                set(value(tagwindow),'Visible','off');
            end
        end
        
        
end


function tags=parse_tags(addtags,adddate,subtags,subdate)
[conf_tags,ia,is]=intersect(addtags, subtags);
keeps=ones(numel(addtags),1);
for kx=1:numel(conf_tags)
    if datenum(adddate{ia(kx)})<datenum(subdate{is(kx)})
        keeps(ia(kx))=0;
    end
end
tags=addtags(keeps==1);

function tagstr=display_tags(tags)
if isempty(tags)
    tagstr='';
else
    tags=sort(tags);
    tagstr=tags{1};
    for tx=2:numel(tags)
        tagstr=[tagstr ', ' tags{tx}];
    end
end


