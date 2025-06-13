

ratlist = {'Aragorn','Legolas','Riddle', 'Sherlock'};


psychdata = {};

global Solo_datadir;

for r = 1:length(ratlist)
    ratname = ratlist{r};

    indir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep ratname filesep ];

    for t = 1:2
        if t== 1,    infile = 'psych_before'; else infile = 'psych_after'; end;

        fname = [indir infile '.mat'];
        fprintf(1, 'Output file is:\n%s\n', fname);

        load(fname);
        
        % filter only for psych trials
        psych = find(psychflag > 0);
        side_list = side_list(psych);
        hit_history = hit_history(psych);
        left_tone = left_tone(psych);
        right_tone = right_tone(psych);

        mega_tones = zeros(size(hit_history));
        lefttrial = find(side_list>0);
        mega_tones(lefttrial) = left_tone(lefttrial);

        righttrial = find(side_list ==0);
        mega_tones(righttrial) = right_tone(righttrial);

        pairs = [mega_tones' hit_history'];

      
        if t == 1,
              eval(['psychdata.' ratname '= {};']);
            eval(['psychdata.' ratname '.before = pairs;']);
        else
            eval(['psychdata.' ratname '.after = pairs;']);
        end;
    end;
end;

2;

