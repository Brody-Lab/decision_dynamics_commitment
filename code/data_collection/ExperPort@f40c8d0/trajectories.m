
lx0 = log(2.5);
ly0 = log(10);

L0x1 = log(3.5);
L0y1 = log(12);

L1x1 = log(1);
L1y1 = log(3.5);

nsteps = 10;

z2 = (0:nsteps-1)/(nsteps-1);

L0xx = (L0x1 - lx0)*z2 + lx0;
L0yy = (L0y1 - ly0)*z2 + ly0;

L1xx = (L1x1 - lx0)*z2 + lx0;
L1yy = (L1y1 - ly0)*z2 + ly0;

plot(exp(L0xx), exp(L0yy), 'b.-', exp(L1xx), exp(L1yy), 'g.-');

