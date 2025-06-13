function [out] = mgb_lesion_table(ratname, action,varargin)

% Structure %%%%%%%%%%%%%
% Lesion is scored for left and right hemisphere separately.
% The structure in each hemisphere is divided into five parts:
% 1- MGv
% 2- MGd
% 3- MGm
% 4- SG & PIN
% 5- extranuclei - PIL and PP
% There are two additional areas for spread into hippocampal formation:
% 6- CA3 - portion of CA3 just lateral to MGB
% 7- DG - 'beaky' portion of DG or part of DG parallel to CA3.
%
% The data structure is a large hash, where keys are ratnames and values
% have lesion scores
% The value itself is a 7 by 2 array.
% Column 1 is for the RIGHT hemisphere; Column 2 for the LEFT.
% Rows are for MGB & hippocampal structures as numbered above
%
% The scores themselves are as follows:
% 0 - completely spared
% 1 - completely lost
% 2 - rostral lost; caudal spared
% 3 - caudal lost; rostral spared
% 4 - other type of partial loss
% ------------------------------------------------------------

ROW_HEADERS = {'MGv','MGd','MGm','SG/PIN','Extr','CA3','DG'};
COL_HEADERS = {'RIGHT','LEFT'};

out = {};
% -------------------------
% Template for lesion matrix
blank_lesion_matrix = [...
    %  RIGHT   LEFT
    0       0 ; ...    % 1- MGv
    0       0 ; ...    % 2- MGd
    0       0 ; ...    % 3- MGm
    0       0 ; ...    % 4- SG & PIN
    0       0 ; ...    % 5- extranuclei - PIL and PP
    0       0 ; ...    % 6- CA3 - portion of CA3 just lateral to MGB
    0       0 ];       % 7- DG - 'beaky' portion of DG or part of DG parallel to CA3
% -------------------------

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin: DATA portion of the file
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lesion_table = {};

lesion_table.Galadriel = [ ...
    %  RIGHT   LEFT
    2       4 ; ...    % 1- MGv
    1       4 ; ...    % 2- MGd
    1       1 ; ...    % 3- MGm
    1       1 ; ...    % 4- SG & PIN
    4       0 ; ...    % 5- extranuclei - PIL and PP
    4       4 ; ...    % 6- CA3 - portion of CA3 just lateral to MGB
    1       4 ];       % 7- DG - 'beaky' portion of DG or part of DG parallel to CA3

lesion_table.Balrog =  [...
    %  RIGHT   LEFT
    3       4 ; ...    % 1- MGv
    3       1 ; ...    % 2- MGd
    4       2 ; ...    % 3- MGm
    3       4 ; ...    % 4- SG & PIN
    0       0 ; ...    % 5- extranuclei - PIL and PP
    4       2 ; ...    % 6- CA3 - portion of CA3 just lateral to MGB
    4       3 ];       % 7- DG - 'beaky' portion of DG or part of DG parallel to CA3

lesion_table.Denethor = [...
    %  RIGHT   LEFT
    0       3 ; ...    % 1- MGv
    4       3 ; ...    % 2- MGd
    1       3 ; ...    % 3- MGm
    1       0 ; ...    % 4- SG & PIN
    4       2 ; ...    % 5- extranuclei - PIL and PP
    0       1 ; ...    % 6- CA3 - portion of CA3 just lateral to MGB
    0       3 ];       % 7- DG - 'beaky' portion of DG or part of DG parallel to CA3

lesion_table.Proudfoot = [...
    %  RIGHT   LEFT
    1       3 ; ...    % 1- MGv
    1       3 ; ...    % 2- MGd
    1       1 ; ...    % 3- MGm
    1       1 ; ...    % 4- SG & PIN
    0       4 ; ...    % 5- extranuclei - PIL and PP
    1       0 ; ...    % 6- CA3 - portion of CA3 just lateral to MGB
    0       0 ];       % 7- DG - 'beaky' portion of DG or part of DG parallel to CA3

lesion_table.Elrond = [...
    %  RIGHT   LEFT
    0       1 ; ...    % 1- MGv
    1       3 ; ...    % 2- MGd
    0       1 ; ...    % 3- MGm
    0       3 ; ...    % 4- SG & PIN
    0       0 ; ...    % 5- extranuclei - PIL and PP
    0       2 ; ...    % 6- CA3 - portion of CA3 just lateral to MGB
    2       1 ];       % 7- DG - 'beaky' portion of DG or part of DG parallel to CA3

lesion_table.Gaffer = [...
    %  RIGHT   LEFT
    2      3 ; ...    % 1- MGv
    0       3 ; ...    % 2- MGd
    4       3 ; ...    % 3- MGm
    4       3 ; ...    % 4- SG & PIN
    1       2 ; ...    % 5- extranuclei - PIL and PP
    0       0 ; ...    % 6- CA3 - portion of CA3 just lateral to MGB
    2       3 ];       % 7- DG - 'beaky' portion of DG or part of DG parallel to CA3

lesion_table.Isildur = [...
    %  RIGHT   LEFT
    4       1 ; ...    % 1- MGv
    0       3 ; ...    % 2- MGd
    1       4 ; ...    % 3- MGm
    0       3 ; ...    % 4- SG & PIN
    2       4 ; ...    % 5- extranuclei - PIL and PP
    0       0 ; ...    % 6- CA3 - portion of CA3 just lateral to MGB
    0       3 ];       % 7- DG - 'beaky' portion of DG or part of DG parallel to CA3

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin: ACTIONS portion of the file
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch action
    case 'whats_spared'  % completely spared = 2, partially spared = 1, not spared = 0.
        if nargin > 2
            suppress_graph = varargin{1};
        else
            suppress_graph = 0;
        end;
        my_lesion = eval(['lesion_table.' ratname]);
        % indexing happens column-by-column (down, then across)
        spared = ones(size(my_lesion)) * 2;
        spared(find(my_lesion == 1)) = 0; % anything lost is not spared
        spared(find(my_lesion > 1)) = 1;  % partially lost is partially spared.
        out = spared;
        if suppress_graph == 0
            f=intensity_graph(spared,ROW_HEADERS, COL_HEADERS);
            title(sprintf('Regions spared for %s',ratname));
            out = f;
        end;               
        
        case 'rough_intersect'    % marks common 'partial' lesions, even if the specific lesions have different shapes
                                       % say rostral area X is lesioned in
                                       % rat 1 and caudal area X is lesioned in rat 2, X is an area of
                                       % rough intersection and would be
                                       % marked as such. 
                                       % To mark only those regions
                                       % matching precisely in lesion
                                       % extent, use 'perfect_intersection_with'
               ratlist = varargin(1:end);
        mylesion = mgb_lesion_table(varargin{1},'whats_spared',1);
       
        other_lesion = mgb_lesion_table(varargin{2},'whats_spared',1);
        
        diff = other_lesion - mylesion;
        common_idx = find(diff == 0);
        mylesion(find(diff ~=0)) = -1000;
        
        restofrats = varargin(3:end);
        for r = 1:length(restofrats)
            nextrat = restofrats{r};
            other_lesion =  mgb_lesion_table(nextrat, 'whats_spared',1);
            
            diff = other_lesion - mylesion;
            common_idx = intersect(find(diff == 0), common_idx);
            mylesion(find(diff ~=0)) = -1000;
            
        end;
                
        mark_spots(ratlist, find(diff==0),length(ROW_HEADERS), length(COL_HEADERS),'rough');
        
    case 'perfect_intersect'        
        ratlist = varargin(1:end);
        mylesion = eval(['lesion_table.' varargin{1}]);
       
        other_lesion = mgb_lesion_table(varargin{2}, 'return_raw');
        
        diff = other_lesion - mylesion;
        common_idx = find(diff == 0);
        mylesion(find(diff ~=0)) = -1000;
        
        restofrats = varargin(3:end);
        for r = 1:length(restofrats)
            nextrat = restofrats{r};
            other_lesion = mgb_lesion_table(nextrat, 'return_raw');
            
            diff = other_lesion - mylesion;
            common_idx = intersect(find(diff == 0), common_idx);
            mylesion(find(diff ~=0)) = -1000;
            
        end;
                
        mark_spots(ratlist, find(diff==0),length(ROW_HEADERS), length(COL_HEADERS),'perfect');
        
        
    case 'spared_list' % runs 'whats_spared' for provided list of rats
        ratlist = ratname;
        spared_list = {};
        for r = 1:length(ratlist)
            s=mgb_lesion_table(ratlist{r}, 'whats_spared',1);
            eval(['spared_list.' ratlist{r} ' = s;']);
        end;

        f=intensity_graph(spared_list, ROW_HEADERS,COL_HEADERS);
        set(f,'Position',[ 105         329        200*length(ratlist)         398]);
        set(gca,'FontSize',14,'FontWeight','bold');
        
        out = f;
        
    case 'graph_lesions'         
        ratlist = ratname;
        lesion_list = {};
        for r = 1:length(ratlist)            
            eval(['lesion_list.' ratlist{r} ' = lesion_table.' ratlist{r} ';']);
        end;

        f=graph_lesions(lesion_list, ROW_HEADERS,COL_HEADERS);
                set(f,'Position',[ 105         329        150*length(ratlist)         398]);
        set(gca,'FontSize',14,'FontWeight','bold');
        
        out = f;
    case 'return_raw'
        out = eval(['lesion_table.' ratname]);

    otherwise
        error('invalid action');
end;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin: SUBROUTINES portion of the file
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = text_output(mylesion)


% higher numbers are hotter
function [f] = intensity_graph(mylesion,ROW_HEADERS, COL_HEADERS,varargin)
f=figure;
cmap = {'k',[0.5 0.5 0.5],'w'};
graphic_display(mylesion, ROW_HEADERS, COL_HEADERS, cmap);

function [f] = graph_lesions(mylesion, ROW_HEADERS, COL_HEADERS)
f=figure;

cmap = {'w', % spared
        'k', % lost
        'y', % rostral lost
        [0 0.5 0], % caudal lost
        [0.5 0.5 0.5] % other partial lost ...
        };
graphic_display(mylesion, ROW_HEADERS, COL_HEADERS, cmap);


function [] = graphic_display(mylesion,ROW_HEADERS, COL_HEADERS, cmap)
if ~isstruct(mylesion)
    tmp={};
    tmp.ratname = mylesion;
    mylesion = tmp;
end;

%set(gca,'XLim',[0 (2*length(fieldnames(mylesion)))-1], 'YLim', [0 rows(mylesion)]);
ratlist = fieldnames(mylesion);

megalesion = mylesion;
for idx = 1:length(ratlist)
    mylesion = eval(['megalesion.' ratlist{idx}]);
    tr = rows(mylesion); tc=cols(mylesion);
    for r = 1:rows(mylesion)
        for c = 1:cols(mylesion)
            metac = (2*(idx-1))+(c-1);
            patch([metac-1 metac-1 metac metac],[tr-(r-1) tr-r tr-r tr-(r-1)], cmap{mylesion(r,c)+1});
        end;
    end;
end;

for idx = 1:length(ratlist)
    line([(2*idx)-1 (2*idx)-1],[0 rows(mylesion)],'Color','r','LineWidth',4);
end;

set(gca,'YTick',0.5:1:6.5, 'YTickLabel',ROW_HEADERS(end:-1:1),'XTick',0:2:((2*length(ratlist))),'XTickLabel', ratlist,'XLim',[-1 (2*length(ratlist))-1]);
set(gca,'Position',[0.1 0.1 0.8 0.8])

% plots two lesions side by side and then marks index # "idx" with a red
% asterisk.
function [] = mark_spots(ratlist, idx,NUM_ROWS, NUM_COLS,type,varargin)
if strcmpi(type,'perfect')
    f=mgb_lesion_table(ratlist, 'graph_lesions');
else
f=mgb_lesion_table(ratlist, 'spared_list');
end;

    
for i = 1:length(idx)
    pos = idx(i);
    r = NUM_ROWS - (mod(pos, NUM_ROWS)-1);
    c = ceil(pos / NUM_ROWS);
    fprintf(1,'%i becomes (%i, %i)\n', pos, r,c);
    text(c-1.5, r-0.5, '*','FontSize',36, 'Color','r');
end;