function TN_search(varargin)

defaults = {'days'       1;...
            'ratname',  '';...
            'keyword',  '';...
            'tech',     ''};
        
parseargs(varargin, defaults)        


[RN,NT,DT,TI] = bdata(['select ratname, note, datestr, techinitials from ratinfo.technotes where datestr>"',...
    datestr(now-days,'yyyy-mm-dd'),'"']);
[EX IN] = bdata('select experimenter, initials from ratinfo.contacts');

for i = 1:length(NT)
    note = char(NT{i}');
    nametemp = strcmpi(IN,TI{i});
    if sum(nametemp) == 1; name = EX{nametemp};
    else                   name = '';
    end
    x = strfind(lower(note),lower(keyword));
    
    test = true;
    
    if ~isempty(keyword); if ~isempty(x); test = test && true; else test = test && false;  end; end
    if ~isempty(tech);                    test = test && sum(strcmpi(name,tech))     == 1; end
    if ~isempty(ratname);                 test = test && sum(strcmpi(ratname,RN{i})) == 1; end
    
    if test    
        name(end+1:10) = ' ';
        disp([DT{i},'  ',name,' ',RN{i},'   ',note]);
    end
end