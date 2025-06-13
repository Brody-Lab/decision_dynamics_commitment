function output = horz(input)

output = input;

if size(input,1) > size(input,2)
    output = input';
end