function [output_txt] = plot_cbk(src, eData)
  
  
  tgt = get(eData, 'Position')
output_txt = sprintf('Yoohoo, Popeye!\nI''m at %i,%i', tgt(1), tgt(2)); 
fprintf(1, output_txt);
%  h = src;
%  get(h, 'XData')
%  fprintf(1, 'Heyayou');