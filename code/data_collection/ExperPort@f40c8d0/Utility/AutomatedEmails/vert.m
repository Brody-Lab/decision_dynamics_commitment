function output = vert(input)

output = input;

if size(input,2) > size(input,1)
    output = input';
end