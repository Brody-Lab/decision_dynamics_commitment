function [] = regressprint(b,bint)

for k=1:rows(b)
    fprintf(1,'\tParam %i= %1.2f [%1.2f, %1.2f]\n', k,b(k), bint(k,1), bint(k,2));
end;