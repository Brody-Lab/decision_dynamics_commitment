function waveplot(waves,opt)
% waveplot(waves,opt)
% waves should be an Nx4x32 matrix
% or a wave struct that you get from the spktimes table
SPCRWDTH=5;
if exist('opt','var')
    h=opt{2};
	clr=opt{1};
	alph=opt{3};
else
    figure;
    h=gca;
   	clr='b';
    alph=.7;
end
hold on
if isstruct(waves)
	waveMn=waves.mn;
	waveStd=waves.std;
else
    waveMn=squeeze(mean(waves));
    waveStd=squeeze(std(waves));
end
n_trodes=size(waveMn,1);
waveMn=reshape(waveMn',1,numel(waveMn));
    waveStd=reshape(waveStd',1,numel(waveStd));
	for ti=1:n_trodes
        ydx=(ti-1)*32+(1:32);
        xdx=ydx+SPCRWDTH*(ti-1);
        shadeplot(xdx, waveMn(ydx)-waveStd(ydx),waveMn(ydx)+waveStd(ydx),{clr,h,.6});
        plot(xdx, waveMn(ydx),clr);
    end
    ylim([min(waveMn)-max(waveStd) max(waveMn)+max(waveStd)])
set(gca,'Xtick',[]);
ylabel('\muV')
hold off
%set(gca,'YLim',[-500 2600]);
%set(gca,'Ytick',[]);
