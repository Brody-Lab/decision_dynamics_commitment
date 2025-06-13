
clear n right_bupsdata
Right_bupsdata = sparse(length(bupsdata),length(bupsdata));
n=ones(length(bupsdata),1);
for j = 20:10:length(bupsdata)
    n(j) = j;
for i = 1:length(bupsdata)
    if ~isempty([bupsdata{i}.right bupsdata{i}.left]),less_than_sample = max([bupsdata{i}.right bupsdata{i}.left]) < sample_history(n(j))+0.05;
    else less_than_sample =0; end
    data_side = length(bupsdata{i}.left)<length(bupsdata{i}.right);    
    if less_than_sample ==1 && data_side == (xor(went_right(n(j))< 0,hit_history(n(j))==1))
        right_bupsdata(i,j) = n(j);
        n(j) = n(j)+1;
    end 
end
end
