% <~> function: viewrats.m
%     displays the rats in the Brody Lab rat table

function out = viewrats()
out = 0;

%     Constants
nameRatTable      = getZutConstant('nameRatTable');

bdata(['select * from ' nameRatTable]);


end
