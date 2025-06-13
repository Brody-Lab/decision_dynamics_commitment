% [area]=rocraw(P1,P2)  Compute ROC area from two distributions
%
%
% P1 and P2 are two probability density functions, defined on a
% space x. All three of these must be vectors of the same length,
% such that "plot(x, P1, x, P2)" would plot the two probability
% density functions. It is also assumed that sum(P1) = 1 = sum(P2).
%
% RETURNS:
% --------
%
% The ROC area, for the probability that an ideal observer would
% report that an event drawn from P2 was greater than an event
% drawn from P1.
%


function [area] = rocraw(d1, d2)
   
drawflag=0;

d1=col(d1);
d2=col(d2);
x1=min([d1;d2]);
x2=max([d1;d2]);
x=linspace(x1, x2, 50);
P1=histc(d1, x);
P2=histc(d2, x);
P1=P1/sum(P1);
P2=P2/sum(P2);
if drawflag
    bar([P1 P2])
end


   
   M = colvec(P2)*rowvec(P1);
   
   area = sum(sum(triu(M,1)));
   
   area = area + 0.5*sum(diag(M));

   if area<0.5
       area=1-area;
   end
   
