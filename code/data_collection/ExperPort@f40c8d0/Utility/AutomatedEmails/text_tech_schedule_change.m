function output = text_tech_schedule_change(DT,shift,varargin)

try
    output = cell(0);
    if nargin < 2; shift = 0; end
    [A,B,C,Y] = bdata(['select overnight, morning, evening, day from ratinfo.tech_schedule where date="',DT,'"']);
    [E,S] = bdata('select experimenter, tech_shifts from ratinfo.contacts where is_alumni=0');

    A = A{1};
    B = B{1};
    C = C{1};
    Y = Y{1};

    if     strcmp(Y,'Monday');    y = 'M';
    elseif strcmp(Y,'Tuesday');   y = 'T';
    elseif strcmp(Y,'Wednesday'); y = 'W';
    elseif strcmp(Y,'Thursday');  y = 'R';        
    elseif strcmp(Y,'Friday');    y = 'F';
    elseif strcmp(Y,'Saturday');  y = 'S';
    elseif strcmp(Y,'Sunday');    y = 'U';
    else   return;
    end

    a = '';
    b = '';
    c = '';

    for i = 1:numel(E)
        for j = 1:numel(S{i})
            if S{i}(j) == y && j < numel(S{i});
                if     S{i}(j+1) == 'a'; a = E{i};
                elseif S{i}(j+1) == 'b'; b = E{i};
                elseif S{i}(j+1) == 'c'; c = E{i};
                end
            end
        end
    end

    for i = 1:numel(E)
        eval(['M.',E{i},'={};']);
    end

    for j = 1:3

        if     j == 1; Z = A; z = a; L = 'A'; %#ok<*NASGU>
        elseif j == 2; Z = B; z = b; L = 'B';
        else           Z = C; z = c; L = 'C';
        end

        m = find(Z == '[');
        n = find(Z == ']');
        if ~isempty(m) && ~isempty(n) && m < n
            Z(m:n) = []; 
        end
        
        brks = find(Z==' ' | Z==',' | Z==';');
        brks = [0 brks numel(Z)+1];
        names = cell(0);
        for i = 1:numel(brks)-1
            temp_name = Z(brks(i)+1:brks(i+1)-1);
            if ~isempty(temp_name)
                names{end+1} = temp_name;
            end
        end
        
        found = 0;
        for i = 1:numel(names)
            if ~strcmp(names{i},z)
                %This person is not the default and needs a reminder text
                
                for k = 1:numel(E)
                    if strcmp(E{k},names{i})
                        eval(['M.',E{k},'{end+1}=L;']);
                    end
                end
            else
                %Default was found
                found = 1;
            end
        end
%                 
%         found = 0;
%         x = strfind(Z,z);
%         for i=numel(x):-1:1
%             found = 1;
%             Z(x:x+numel(z)-1) = []; 
%         end
% 
%         if ~isempty(Z)
%             for i = 1:numel(E)
%                 x = strfind(Z,E{i});
%                 if ~isempty(x)
%                     eval(['M.',E{i},'{end+1}=L;']);
%                 end
%             end
%         end

        if found == 0 && ~isempty(z)
            %There is a default person scheduled and they weren't found
            eval(['M.',z,'{end+1}=lower(L);']);
        end

        eval([L,'=Z;']);
    end
    
    if     shift == 1; ltr = 'A';
    elseif shift == 2; ltr = 'B';
    elseif shift == 3; ltr = 'C';
    end
    if shift ~= 0
        if isempty(eval(ltr)); output{1} = eval(lower(ltr));
        else 
            for i = 1:numel(E)
                temp = eval(['strcmp(M.',E{i},',ltr)']);
                if sum(temp) > 0; output{end+1} = E{i}; end
            end
        end
        return
    end

    for i = 1:numel(E)
        x = eval(['M.',E{i},';'])';

        if ~isempty(x)
            message = {};
            W = '';
            if any(strcmp(x,'A')); W(end+1:end+2) = 'A,'; end
            if any(strcmp(x,'B')); W(end+1:end+2) = 'B,'; end
            if any(strcmp(x,'C')); W(end+1:end+2) = 'C,'; end
            if ~isempty(W); 
                W(end) = ' ';
                message{end+1,1} = [E{i},', you are scheduled to work shift(s) ',W,'tomorrow.']; %#ok<*AGROW>
            end

            w = '';
            if any(strcmp(x,'a')); w(end+1:end+2) = 'A,'; end
            if any(strcmp(x,'b')); w(end+1:end+2) = 'B,'; end
            if any(strcmp(x,'c')); w(end+1:end+2) = 'C,'; end
            if ~isempty(w); 
                w(end) = ' ';
                message{end+1,1} = [E{i},', you are NOT scheduled to work shift(s) ',w,'tomorrow.'];
            end

            send_text_message(message,['Schedule for ',DT],E{i});
            send_text_message(message,['Schedule for ',DT],'Chuck');
        end
    end
catch
    senderror_report;
end
    
        
    