function output = num2bytes(input)

if     input > 1e12; tb = round(input / 1e11) / 10; nm = ' TB';
elseif input > 1e9;  tb = round(input / 1e8)  / 10; nm = ' GB';
elseif input > 1e6;  tb = round(input / 1e5)  / 10; nm = ' MB';
elseif input > 1e3;  tb = round(input / 1e2)  / 10; nm = ' KB';
else                 tb = input;                    nm = ' B';
end

output = [num2str(tb),nm];