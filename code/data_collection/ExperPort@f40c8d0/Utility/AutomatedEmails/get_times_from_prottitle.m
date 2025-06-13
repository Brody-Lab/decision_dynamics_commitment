function [Ts,Te] = get_times_from_prottitle(T)

Ts = []; Te = [];

for i = 1:length(T)-5
    if strcmp(T(i),' ')          &&...
       ~isempty(str2num(T(i+1))) &&...
       ~isempty(str2num(T(i+2))) &&...
       strcmp(T(i+3),':')        &&...     
       ~isempty(str2num(T(i+4))) &&...
       ~isempty(str2num(T(i+5)))
   
        if  isempty(Ts); Ts = T(i+1:i+5);
        else             Te = T(i+1:i+5); 
        end
    end
end
   
    