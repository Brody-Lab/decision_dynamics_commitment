function play_pointsmovie(r,b,x,y,theta,varargin)

%
% play_pointsmovie(r,b,x,y,theta,fps,varargin)
%   plays and outputs head tracking movie extracted from VT1 files
%   r and b are (total number of drawn points)x3 matrices, 1st column is
%   what frame number that point appears, 2nd and 3rd columns are x and y 
%   positions of the point.
%   x and y are x and y positions from database tracking.
%   theta is head angle from database tracking.
%   all frame numbers and all vectors are relative to times drawn by this 
%   function.  The total number of frames drawn is assumed to be the size 
%   of x.
%   varargin: 'outfile',[],      % name of output file, empty matrix does not save 
%             'fps',60,          % frames per second
%             'fh',[],           % figure handle (default new figure)
%             'dtheta',[]        % head velocity to plot in new axes 
%             'xl',[200 700]     % sets xlim on points axis
%             'yl',[-350 150]    % sets ylim on points axis 
%                     
%   EXAMPLE
%   -------
%   if you have extracted the (nframes in session) x 400
%   matrix of bit-masked points called BMPOINTS, then to play them with 
%   this function using databased headtracking, do the following:
%   FR=STARTFRAME:ENDFRAME;
%   [R G B]=VID_BITFIELD(BMPOINTS(FR,:));
%   PLAY_POINTSMOVIE(R,B,X(FR),Y(FR),THETA(FR));
%   where X,Y, and THETA are the full tracking data from the database.
%   VID_BITFIELD can be slow depending on the number of frames asked for,
%   so this step is kept separate from this function.  Write a wrapper
%   function if you want all steps performed at once.
%

pairs = {            ...
    'outfile',[];    ...
    'fps',60;        ...
    'fh',[];         ...
    'dtheta',[];     ...
    'xl',[200 700];  ...
    'yl',[-350 150]  ...
    };
parseargs(varargin,pairs);

nfr=numel(x);

y=-y;
r=cast(r,'int32');
b=cast(b,'int32');
r(:,3)=-r(:,3);
b(:,3)=-b(:,3);

% check to see if we are going to produce a movie
if isempty(outfile), isout=false;
else
    isout=true;
    outobj=avifile(outfile,'fps',fps);
end

% check to see if we are going to plot dtheta
isvel=~isempty(dtheta);

% initialize plot elements
if isempty(fh), fh=figure; clf;
else figure(fh); clf;
end
h(1)=line(rand(10,1),rand(10,1),'color','r','linestyle','none','marker','.'); % red points
h(2)=line(rand(10,1),rand(10,1),'color','b','linestyle','none','marker','.'); % blue points
linemat=[-1 1; 0 0]*45; % <--- adjust length of head angle line here
newlinemat=[cosd(theta(1)) sind(theta(1)); -sind(theta(1)) cosd(theta(1))]...
    *linemat + [x(1)*ones(1,2); y(1)*ones(1,2)];        % rotation matrix for head angle (trick to keep head angle line constant).
h(3)=line(newlinemat(1,:),newlinemat(2,:),'color','g','linewidth',3); % line for head angle
xlim(xl)
ylim(yl)
fp=get(gcf,'position');
set(gca,'position',get(gca,'position').*[1 1 fp(4)/fp(3) 1])
set(gca,'XAxisLocation','top','YAxisLocation','right');
ah=gca;
if isvel
    ap=get(gca,'position');
    ahv=axes('position',ap.*[1 1 1 0.25]);
    line(1:nfr,dtheta,'color','k','linewidth',2);
    line([1 nfr],[0 0],'color',0.7*ones(1,3),'linestyle','--')
    hvl=line([1 1],[-300 300],'color','g');
    ylim([-300 300]);
    xlim([-4 5]);
    set(gca,'box','on')
end

% draw frame-by-frame
for n=1:nfr
    rpts=r(:,1)==n; % find transition pts that happen in this frame
    bpts=b(:,1)==n;
    set(h(1),'XData',r(rpts,2),'YData',r(rpts,3));
    set(h(2),'XData',b(bpts,2),'YData',b(bpts,3));
    newlinemat=[ cosd(theta(n)) sind(theta(n)); ...
                -sind(theta(n)) cosd(theta(n))]*linemat + ...
               [x(n)*ones(1,2); y(n)*ones(1,2)];
    set(h(3),'XData',newlinemat(1,:),'YData',newlinemat(2,:));
    if isvel
        set(hvl,'XData',[n n]);
        set(ahv,'xlim',get(ahv,'xlim')+1);
    end
    drawnow
    if isout
        currframe = getframe(ah);
        outobj = addframe(outobj,currframe);
    else
        pause(1/fps);
    end
end

if isout, outobj=close(outobj); end