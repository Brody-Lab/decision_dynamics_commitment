function [ptemp,exclude] = extract_percent_water_registry(ratname)

ptemp = 20;
exclude = 0;
comments = bdata(['select comments from ratinfo.rats where ratname="',ratname,'"']);
comments = comments{1};
if ~isempty(comments);
    x = strfind(comments,'Water Pub ');
    if ~isempty(x) && numel(comments) >= x+10
        %User may have entered an amount
        if numel(comments) >= x+12 && comments(x+11)=='.' && ~isempty(str2num(comments(x+12))) %#ok<ST2NM>
            %decimal value < 10 like 5.3
            ptemp = str2num(comments(x+10:x+12)); %#ok<ST2NM>
        elseif numel(comments) >= x+13 && comments(x+12)=='.' && ~isempty(str2num(comments(x+13))) %#ok<ST2NM>
            %decimal value > 10 like 11.3
            ptemp = str2num(comments(x+10:x+13)); %#ok<ST2NM>
        elseif numel(comments) >= x+11 && ~isempty(str2num(comments(x+11))) %#ok<ST2NM>
            %integer value > 10
            ptemp = str2num(comments(x+10:x+11)); %#ok<ST2NM>
        elseif numel(comments) >= x+10 && ~isempty(str2num(comments(x+10))) %#ok<ST2NM>
            %integer value < 10
            ptemp = str2num(comments(x+10)); %#ok<ST2NM>
        elseif numel(comments) >= x+16 && strcmpi(comments(x+10:x+16),'exclude')
            %Exclude from pub
            ptemp = 99;
            exclude = 1;
        else
            %Cannot interpret instructions, set to default
            ptemp = 20;
        end
    end
end

israt = bdata(['select israt from ratinfo.rats where ratname="',ratname,'"']);

if israt == 1 && ptemp < 3 
    ptemp = 3;
elseif israt == 0 && ptemp < 4
    ptemp = 4;
elseif isnan(ptemp) || isempty(ptemp)
    ptemp = 20;
end