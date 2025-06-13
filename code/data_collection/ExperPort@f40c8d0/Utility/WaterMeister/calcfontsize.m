function output = calcfontsize(fontsize,handles)

P = get(gcf,'Position');
R = min(P(3:4) ./ handles.size);
output = fontsize * R;