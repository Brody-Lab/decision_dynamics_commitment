% h = vplot(vecs, symbol)
%
% Plot 2- or 3-dimensional vectors.  VECS should be a matrix of height
% 2 or 3 containing the vectors.  SYMBOL indicates the plot symbol
% (default='.' - "help plot" gives options).  Returns plot handle
% (just like "plot").

% 5/01: modified from a suggestion by Jeff Erlich (jerlich@cns.nyu.edu).
% 1/06: added code to make sure that data was longer than tall
%       added code to handle turn a complex vector into a pair of vectors.
%       changed "if [findstr.....]"   The original version was breaking in Matlab 7. 
%				Jeff Erlich (jerlich@cns.nyu.edu)

function h = vplot(vecs, sym)

if (nargin<2)
  sym = '.';
end


vecs=row(vecs);

if(~isreal(vecs))
	origvecs=vecs;
	vecs(1,:)=real(origvecs);
	vecs(2,:)=imag(origvecs);
end





if  [findstr(sym,'-') findstr(sym,':')]
  origvecs = vecs;
  vecs = zeros(size(origvecs,1), 2*size(origvecs,2));
  vecs(:,2*(1:size(origvecs,2))) = origvecs;
end


if (size(vecs,1)==2)
  h = plot(vecs(1,:), vecs(2,:), sym);
elseif (size(vecs,1)==3)
  h = plot3(vecs(1,:), vecs(2,:), vecs(3,:), sym);
else
  error('VECS must be a matrix of height 2 or 3');
end



% Should do something nice with axes to make sure origin is included
% in plot.
xlim=seeOrigin([min(vecs(1,:)) (max(vecs(1,:)))]);
ylim=seeOrigin([min(vecs(2,:)) (max(vecs(2,:)))]);
x2=get(gca,'XLim');
y2=get(gca,'YLim');
xlim=[min([xlim x2]) max([xlim x2])];
ylim=[min([ylim y2]) max([ylim y2])];
set(gca, 'XLim', xlim);
set(gca, 'YLim', ylim);
axis equal
xhairs(gca)


function y=row(x)

s=size(x);
   
if s(1)>s(2)
    y=x.';  %'
else
    y=x;
end
% YOU USE .' BECAUSE ' is the complex conjugate;'
if all(size(y)==[1 2]) && isreal(x)
   y=y.';  %'
end
   
   if (s(1)==2 && s(2)==2)
    warning('vplot does not know how to orient your input.  We will assume that the first row are the x value and the 2nd row are the y values');
  end
	

return


%% get proper limits for the graph
function y=seeOrigin(x)

if prod(x)>0
    if x(1)>0
        x(1)=0;
    else
        x(2)=0;
    end
end
y=x+[-.1 .1]*max(abs(x));
return
