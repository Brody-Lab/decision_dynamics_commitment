function do_infusion_plot(ratname, experimenter)
% do_infusion_plots(ratname, experimenter)
% uses the days from the ratinfo.infusions table to determine which days
% were infusion days.

<<<<<<< do_infusion_plot.m
inf_sess=bdata('select sessiondate from ratinfo.infusions where ignore_sess=0 and ratname regexp "{S}" and drug like "musc%"',ratname);
post_inf_sess=bdata('select date_add(sessiondate,interval 1 day) from ratinfo.infusions where ratname regexp "{S}"',ratname);
sorted_d=sort(inf_sess);
all_sess=bdata('select sessiondate from sessions where ratname regexp "{S}" and sessiondate>date_add("{S}",interval -30 day)', ratname, sorted_d{1});
=======
inf_sess=bdata('select sessiondate from ratinfo.infusions where ratname="{S}" and drug like "musc%"',ratname);
post_inf_sess=bdata('select date_add(sessiondate,interval 1 day) from ratinfo.infusions where ratname="{S}"',ratname);
all_sess=bdata('select sessiondate from sessions where ratname="{S}" and experimenter="{S}" and sessiondate>"2009-09-15"', ratname, experimenter);
>>>>>>> 1.4
sess_todo=setdiff(all_sess, [inf_sess; post_inf_sess]);
figure;

ax=axes('Position',[0.2 0.2 0.6 0.6]);
set(gca,'FontSize',7);
set(gca,'FontName','Helvetica');
psychoplot_delori(ratname, experimenter, sess_todo,'memax',ax,'nonmemax',ax,'linestyle','--','marker','s','markersize',2);
title([experimenter ', ' ratname ', control days']);
saveas(gcf,['~/' ratname '_cont.eps'],'epsc2');
psychoplot_delori(ratname, experimenter, inf_sess,'memax',ax,'nonmemax',ax,'linestyle','-','marker','o','markersize',2);
title([experimenter ', ' ratname ', muscimol days']);
title('')
saveas(gcf,['~/' ratname '_musc.eps'],'epsc2');
