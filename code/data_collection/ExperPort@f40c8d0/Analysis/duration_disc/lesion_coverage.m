function [coverage] = lesion_coverage()

% for each rat, returns an S-by-1 string (S is # slices for brain area of
% interest in rat brain atlas).
% Character i of the string can be one of:
%   1 - 'L' for left-only lesion
%   2 - 'R' for right-only lesion
%   3 - 'B' for lesion in both hemisphere
%   4 - 'X' for no lesion in either hemisphere

global Solo_datadir;
fname = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep 'scoring_0806.mat'];
fprintf(1,'%s\n', fname);

load(fname);
% save(fname, 'ACx_lesionyesno__LEFT', 'ACx_lesionyesno__RIGHT', ...
%     'PFC_lesion_yesno',...
%     'ACx_task',   'PFC_task');

lefthem = ACx_lesionyesno__LEFT;
righthem = ACx_lesionyesno__RIGHT;

coverage = {};

for k= 1:(length(lefthem)/2),
    ratname = lefthem{(2*(k-1))+1};
    name_rt = lefthem{(2*(k-1))+1};
    
    if ~strcmpi(ratname,name_rt)
        error('Names of rats in lefthem and righthem do not match!');
    end;   
    
    leftval = lefthem{2*k};
    rightval = righthem{2*k};
    
    fprintf(1,'%s = L: %i\tR: %i\n', ratname, length(leftval), length(rightval));
    
    mystr = '';
    for pos = 1:length(leftval)
        lt = str2double(leftval(pos)); rt = str2double(rightval(pos));
        sumles = lt+rt;
        switch sumles
            case 0, mystr = [mystr 'X'];
            case 1, if lt == 1, mystr = [mystr 'L']; else mystr = [mystr 'R']; end;
            case 2, mystr = [mystr 'B'];
            otherwise
                error('invalid sum value for sumles - should be 0,1,2');
        end;               
        eval( ['coverage.' ratname ' = mystr;'] );
        
    end; % -- loop through lesion for one rat
end; % loop through each rat

