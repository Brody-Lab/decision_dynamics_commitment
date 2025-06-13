function [lowerpoint upperpoint midpoint weber] = get_weber_lin(xx,yy,pitches)

lowerpoint=interp1(yy,xx,0.25,'linear','extrap');
upperpoint=interp1(yy,xx,0.75,'linear','extrap');
midpoint=interp1(yy,xx,0.5,'linear','extrap');


xfin = upperpoint;
xcomm = lowerpoint;
xmid = midpoint;;

if pitches >0, mybase=2; else mybase= exp(1);end;
weber = ((mybase^xfin)-(mybase^xcomm))/(mybase^xmid);
