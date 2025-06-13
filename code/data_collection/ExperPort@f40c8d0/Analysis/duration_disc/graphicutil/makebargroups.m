function [xposlist mlist slist] = makebargroups(data, colourset, varargin)
% plots multiple clusters of bars.
%
% (e.g. C1__1, C2__1, ...
%       C1__2, C2__2, ...
%       C1__3, C2__3, etc.,)
%
% data should be an C-by-N cell (C=number of clusters; N=#bars in each
% cluster)
% sampledata = { ...
%    [C1_1], [C1_2], [C1_3] ; ...
%    [C2_1], [C2_2], [C2_3] ; ] ; 
% 
% colourset is a N-by-3 set of colours;  (each row is one colour)
% so if bars (1,2,3) in each cluster are to be (orange, grey, green),
% colourset = [ ...
%    1 0.5 0 ; ...
%    0.9 0.9 0.9; ...
%    0 1 0 ] 
%
% RETURNS
% xposlist - g-by-n array of xcoords for each bar 
% mlist - g-by-n array of means.
% slist - g-by-n array of errorbar value

pairs = { ... 
    'errtype', 'sem' ; ...    % sem, std, iqr
    'what2show', 'mean' ; ... % mean, median
    }; 
parse_knownargs(varargin, pairs);


% % uncomment for debugging
% % cluster 1
% dummyset{1,1} = [1 2 3 4 5]; 
% dummyset{1,2} = [ 2 2 2 6];
% % cluster 
% dummyset{2,1} = [0 -1 6 4 2];
% dummyset{2,2} = [1 0 5 2 1];
% % cluster 3
% dummyset{3,1} = [ 3 4 4 0 1];
% dummyset{3,2} = [ 0 0 0 0 6];
% data=dummyset;
% colourset=[ 1 0.5 0; 0 1 0];


grpoffset = 2;
indieoffset = 1;

switch what2show
    case 'mean'
        mfn='nanmean';
    case 'median'
        mfn='nanmedian';
    otherwise
        error('invalid value');
end;    

figure;
startpos=0;
xpos = startpos;

xposlist = NaN(size(data));
mlist = NaN(size(data));
slist = NaN(size(data));
for g=1:rows(data)    
    for i=1:cols(data)
        dt=data{g,i};
        
        m = eval([mfn '(dt);']);
        if strcmpi(errtype, 'sem')
            s=nanstd(dt)/sqrt(length(dt(~isnan(dt))));
        elseif strcmpi(errtype,'std')
            s=nanstd(dt);
        elseif strcmpi(errtype,'iqr')
            s=dt(~isnan(dt));
            s=iqr(dt);
        else
            error('invalid error type');
        end;
               
    patch([xpos xpos xpos+1 xpos+1], ...
        [0 m m 0], colourset(i,:),'EdgeColor','none');
    line([xpos+0.5 xpos+0.5], [m-s m+s], 'Color',[1 1 1]*0.5);
    
    xposlist(g,i) = xpos+0.5;
    mlist(g,i)=m;
    slist(g,i)=s;
    
    xpos=xpos+indieoffset;
    end;
    
xpos=xpos+grpoffset;
end;

toffset= cols(data)+2;
gnum=rows(data);
set(gca,'XLim',[-1 xpos+1], 'XTick', startpos+1:toffset: toffset*(gnum-1)+1);
