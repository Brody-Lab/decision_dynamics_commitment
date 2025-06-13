function [] = fixcorruptfile()
f=fopen('../SoloData/Data/Shraddha/Cushing/data_@duration_discobj_Shraddha_Cushing_080609a.mat');
fx=fopen('fixedmatfile.mat','w');
	bytes=fread(f,7754572+128,'uint8');
    fwrite(fx,bytes,'uint8');
	fclose(f);fclose(fx);

	load fixedmatfile.mat