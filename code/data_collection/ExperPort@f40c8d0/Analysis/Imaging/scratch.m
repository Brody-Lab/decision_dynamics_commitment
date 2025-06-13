
%%
fname='~/Desktop/S184_12_24001.tif';
sessid=271196;
%%
%sync_pmt_fsm(sessid,fname);  % Do this just once per scan image session

%%

[~,just_file] =  fileparts(fname);

[b,data]=bdata('select beta,data from imaging.sync_scim where filename="{S}"',just_file);  % This works after running sync_pmt_fsm    pixel*b(2)+b(1) = fsm_times; (fsm_times-b(1))/b(2) = pixels
b=b{1};

% Let's look at how good the fit is
figure(200); clf
plot(data{1}.statsL.resid,'g.'); hold on
plot(data{1}.statsR.resid,'r.')
mean(abs(data{1}.statsR.resid)>0.1)
mean(abs(data{1}.statsL.resid)>0.1)


%%
M=extract_channel(fname,1);
%%
pixperframe=numel(M(:,:,1));
v=squeeze(mean(mean(M)));
SD=get_sessdata(sessid);
peh=SD.peh{1};
pd=SD.pd{1};

shutter_times=extract_waves(peh,'shutter',1);
shutter_pix = (shutter_times-b(1))/b(2);

%%
shutter_frames = floor(shutter_pix/pixperframe);
shutter_frames(shutter_frames<50)=nan;

[y x]=cdraster(shutter_frames,1:numel(v),v,10,10,1);
plot(x,y)


%%

go_times=extract_event(peh,'wait_for_cout(1,1)');
go_pix = (go_times-b{2}(1))/b{2}(2);

go_frames = floor(go_pix/pixperframe);

[yR x]=cdraster(go_frames(pd.sides=='r' & pd.hits==1),1:numel(v),nv,20,0,1);
[yL x]=cdraster(go_frames(pd.sides=='l' & pd.hits==1),1:numel(v),nv,20,0,1);

figure(212);clf;
ax=axes;
errorplot(ax,x/11,nanmean(yR),nanstderr(yR),'Color','r'); hold on
errorplot(ax,x/11,nanmean(yL),nanstderr(yL),'Color','g');


%% 

stim_start = extract_event(peh,'nic_prestim(1,2)');
