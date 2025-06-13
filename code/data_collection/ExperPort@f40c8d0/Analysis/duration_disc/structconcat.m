function [s] = structconcat(s1,s2)
% concatenates two structs
% precondition - s1 and s2 don't have common fieldnames. this check is not
% done.

f1=fieldnames(s1);
f2=fieldnames(s2);

s=[];

if length(f1) > length(f2)
  s=s1;
  catf=f2;
  cats='s2';
else
  s=s2;
  catf=f1;
  cats='s1';
end;

for k=1:length(catf)
    eval(['s.' catf{k} '=' cats '.' catf{k} ';']);
end;