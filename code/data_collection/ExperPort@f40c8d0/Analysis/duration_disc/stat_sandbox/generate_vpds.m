function [] = generate_vpds(vpdmin, vpdmax)



hzdrate = [0.0001 0.001 0.01 0.05];


figure;
set(gcf,'Menubar','none','Toolbar','none');
for h = 1:length(hzdrate)
    subplot(2,2,h);
    vl = vpd_hazard(vpdmin, vpdmax, hzdrate(h));
    hist(vl); title(sprintf('With hazard rate %1.2f',hzdrate(h)));
end;


function [vl] = vpd_hazard(vpdmin, vpdmax, hzdrate)

vpds       = vpdmin:0.005:vpdmax;
fprintf(1,'List size: %i', length(vpds));
prob       = hzdrate*((1-hzdrate).^(0:length(vpds)-1));
cumprob    = cumsum(prob/sum(prob));
vl         = zeros(size(vpds));


for i=1:length(vl), 
        vl(i) = vpds(min(find(rand(1)<=cumprob)));
end;
