function [] = lesion_calc_sanitycheck
% does basic checks on the output of lesion_coverage_runner.m to make sure
% that the data behaves as expected

% load file
area_filter = 'ACx';
global Solo_datadir;
histodir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Histo' filesep area_filter filesep];


% get rat list
durset = rat_task_table('','action','get_duration_psych','area_filter',area_filter);
freqset= rat_task_table('','action','get_pitch_psych','area_filter',area_filter);
ratset = [durset freqset]

% test roi
valid_rois = {'AuD','A1','AuV','TeA','Ect','Prh','S1'};
pos =round(1 + ((length(valid_rois)-1) .* rand(1,1)));
testroi = valid_rois{pos};

% Check 1 - Do all rats have a given ROI as having roughly the same number of points in it?
%           Since this value depends only on the ROI template, different rats should not have different values
%           Do this using data already stored in lesion_coverage_calc.mat
if 0
    infile = [histodir 'lesion_coverage_calc.mat'];
    load(infile);

    % Pick 5 random slices for a given
    rand('twister', sum(100*clock));
    pts =round(1 + ((33-1) .* rand(1,5)));

    bufflft = [];
    buffrt = [];

    fprintf(1,'*****\nPoints:\n');
    pts
    fprintf(1,'ROI:%s\n', testroi);    
    fprintf(1,'*****\n');

    for r = 1:length(ratset)
        ratname =ratset{r};
        if strcmpi(ratname, 'Jabber'), ratname = 'Eaglet'; end;
        mystruct = eval([ratname '_lesioncvg.' testroi ';']);
        lhem = mystruct.areapts__L; rhem = mystruct.areapts__R;
        bufflft = horzcat(bufflft, lhem(pts)');
        buffrt = horzcat(buffrt, rhem(pts)');
    end;

    fprintf(1,'Left:\n'); bufflft
    fprintf(1,'\nRIght:\n'); buffrt
end;

% which rats are getting NaN for a brainarea areapts when I know the
% brainarea should NOT be empty at that slice?
if 0
    pts = [19 18 13];
    for r = 1:length(ratset)
        ratname = ratset{r};
             if strcmpi(ratname, 'Jabber'), ratname = 'Eaglet'; end;
        out = lesion_slice_coverage(ratname, 'AuV', 'slices', pts);
        alft = out.areapts__L; art = out.areapts__R;

        if sum(isnan(alft)) > 0 || sum(isnan(art)) > 0
            2;
        end;
    end;
end;

% Check 3: Examine data for particular rat/roi
if 1
    ratname = 'Bilbo'; testroi = 'A1'; slicenum = 2;
    if strcmpi(ratname, 'Jabber'), ratname = 'Eaglet'; end;
    
      infile = [histodir 'lesion_coverage_calc.mat'];
    load(infile);    
      mystruct = eval([ratname '_lesioncvg.' testroi ';']);
            fprintf(1,'%s, %s at #%i:\n',ratname, testroi, slicenum);
      % first get numpts at slice
      lft = mystruct.cvgpts__L; rt = mystruct.cvgpts__R;
      lft = lft(slicenum); rt = rt(slicenum);
      fprintf(1,'# lesion points in ROI:\tL: %i\tR: %i\n', lft, rt);
      
      % get numpts in area
      lft = mystruct.areapts__L; rt = mystruct.areapts__R;
      lft = lft(slicenum); rt = rt(slicenum);
      fprintf(1,'Size of ROI:\t\tL: %i\tR: %i\n', lft, rt);      
      
      % first get % cvg
      lft = mystruct.pctcvg__L; rt = mystruct.pctcvg__R;
      lft = lft(slicenum); rt = rt(slicenum);
      fprintf(1,'%% coverage:\t\tL: %2.1f\tR: %2.1f\n', lft, rt);
      
end;