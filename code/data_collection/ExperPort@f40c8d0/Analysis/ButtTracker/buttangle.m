function buttangle(ratname,dstr,varargin)

%
% buttangle(ratname,dstr,varargin)
%

framerate=[];
skiptranscode=false;
updatedb=false;

pairs={...
  'framerate'     framerate
  'skiptranscode' skiptranscode
  'updatedb'      updatedb
  };
parseargs(varargin,pairs);

if ~iscell(ratname), ratname={ratname}; end
if ~iscell(dstr),    dstr={dstr}; end
if isempty(framerate), fr_string=[]; 
else fr_string=[' -r ' sprintf('%d',framerate) ' ']; 
end

% if only one rat but multiple dates specified, then the one rat gets analyzed
% multiple times
if numel(dstr)>numel(ratname), ratname(1:numel(dstr))={ratname{1}}; end
expname=get_experimenter(ratname);

for k=1:numel(dstr)
  disp(repmat('~',1,80));
  disp(['Fitting rat ' ratname{k} ' on ' dstr{k} '.']);
  try
    omoviename=fullpath([ratname{k} '/' expname{k} '_' ratname{k} '_' dstr{k} 'a.avi']);
    if ~skiptranscode
        % get the size of the transcoded movie
        imoviename=[ratname{k} '/' expname{k} '_' ratname{k} '_' dstr{k} 'a.mp4'];
        system(['ffmpeg -i ' imoviename ' -vframes 1 -an -v 0 -y tmp.jpg']);
        img=imread('tmp.jpg');
        wdth=size(img,2);
        hght=size(img,1);
        clear img
        system('rm tmp.jpg');
        divisor=ceil(wdth/100);
        wdth=round(wdth/divisor);
        hght=round(hght/divisor);
        if mod(wdth,2)~=0, wdth=wdth+1; end
        if mod(hght,2)~=0, hght=hght+1; end
        % transcode movie
        fprintf('%s ---------------- TRANSCODING',char(37))
        system(['ffmpeg -i ' imoviename ' -s ' ...
        sprintf('%d',wdth) 'x' sprintf('%d',hght) ' -an -g 2 -v 0 -y ' fr_string omoviename]);
    else
        fprintf('YOU TOLD ME NOT TO TRANSCODE, DON''T BLAME ME LATER.\n');
    end
    % create movieframes object
    obj=MovieFrames(omoviename);
    % now collect a background frame
    fprintf('%s ---------------- ESTIMATING BACKGROUND',char(37))
    obj.EstimateBackground(500,true);
    pos=obj.EstimatePosition('frameinds',1:30000);
    obj.RecalculateBackground(pos,1:30000);
    % estimate time alignment
    fprintf('%s ---------------- SYNCHING MOVIE',char(37))
    [bv,garb,bvt]=obj.BlockPixels(1:15000,'blocksize',[8 8]);
    sessid=bdata('select sessid from sessions where ratname="{S}" and sessiondate="{S}"',ratname{k},dstr{k});
    peh=get_peh(sessid);
    [protocol pd]=bdata('select protocol,protocol_data from sessions where sessid="{S}"',sprintf('%d',sessid));
    [state_name,delay,lrfieldname]=water_deliverer(protocol,ratname{k},datestr(datenum(dstr{k},'yyyymmdd'),'yyyy-mm-dd'),peh);
    obj.AlignMovie(bv,bvt,peh,pd{1},state_name,'delay',delay,'lrfieldname',lrfieldname);
    % perform fit
    fprintf('%s ---------------- FITTING MOVIE',char(37))
    obj.Fit
    % put data on sql server
    if updatedb
        fprintf('%s ---------------- UPDATING DATABASE',char(37))
        bdata('connect','sonnabend.princeton.edu','jkjun','THELm0nk')
        bdata(['insert into jkjun.butt_tracking ' ...
        '(sessid, ts      , phi      , x           , y           , length      , width       , t0    ) values' ...
        '("{Si}", "{M}"   , "{M}"    , "{M}"       , "{M}"       , "{M}"       , "{M}"       , "{Sn}")'],      ...
        sessid, obj.Time, obj.Angle, obj.Pos(1,:), obj.Pos(2,:), obj.Axs(1,:), obj.Axs(2,:), obj.T0);
    else
        fprintf('%s ---------------- NO UPDATE TO THE DATABASE',char(37))
    end
  catch exception
    disp(exception.message)
    for sk=1:(numel(exception.stack)-1)
        disp(exception.stack(sk));
    end
    disp(['Skipping ' ratname{k} ' on ' dstr{k} '.']);
  end
  disp(repmat('~',1,80));
end
