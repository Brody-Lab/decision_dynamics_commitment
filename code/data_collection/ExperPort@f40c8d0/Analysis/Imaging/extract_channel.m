function M=extract_channel(fname,chnum)


h=imfinfo(fname);

ppf=h(1).Height*h(1).Width;

sind=1;
eind=ppf;
nframes=numel(h)/4;
M=nan(h(1).Height,h(1).Width,nframes);
find=1;
for f=chnum:4:numel(h)
    M(:,:,find)=imread(fname,'Info',h,'Index',f);
    find=find+1;
end
