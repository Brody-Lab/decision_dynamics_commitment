function emails = parse_emails(input)

input(input == ' ') = '';

commas = find(input == ',');
emails = cell(length(commas) + 1,1);

for i = 1:length(commas) + 1
    if i == 1; st = 1;             
    else       st = commas(i-1)+1; 
    end
    if i == length(commas)+1; ed = length(input);
    else                      ed = commas(i) - 1;
    end
    emails{i} = input(st:ed);
end