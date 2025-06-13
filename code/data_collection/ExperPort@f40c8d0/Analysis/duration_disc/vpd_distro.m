function [] = vpd_distro(ratname,date)

load_datafile(ratname,date);

hzd = cell2mat(saved_history.VpdsSection_VpdsHazardRate);
vpd = saved.VpdsSection_vpds_list;

figure;
subplot(2,1,1);
hist(vpd);

% subplot(2,1,2);
% plot(1:length(hzd), hzd, '.b');
