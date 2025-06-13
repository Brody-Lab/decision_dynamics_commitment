function vnum = matlab_version_number

n = version;

try
    n = n(1:find(n=='.',1,'first')-1);
catch
    n = n(1:2);
end

vnum = str2num(n);

