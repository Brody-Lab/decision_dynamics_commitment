function [] = sandbox3()
%
% global Solo_datadir;
% if isempty(Solo_datadir), mystartup; end;
%
% outdir = [Solo_datadir filesep 'Data' filesep];
% outdir = [outdir 'Shraddha' filesep];
%
% fname = [outdir 'sig_struct' '.mat'];
% fprintf(1, 'Output file is:\n%s\n', fname);
%
% load(fname);
%
% ratlist = {...
%     'Boromir', 0 ; ...
%     'Gryphon', 0 ; ...
%     'Sauron',  0 ; ...
%     'Legolas', 0 ; ...
%     'Denethor', 0 ; ...
%     'Hare', 0; ...
%     'Baby', 0; ...
%     'Jabber', 0 ; ...
%     'Aragorn', 1 ; ...
%     'Gimli', 1 ; ...
%     'Lory', 1; ...
%     'Gandalf', 1 ; ...
%     'Bilbo', 1 ; ...
%     };
%
%
% %      Boromir: [-1 0 0 1 0 0 0 0 0]
% %      Gryphon: [-1 0 0 0 0 1 0 0 1]
% %       Sauron: [-1 0 0 1 0 0 0 0 0]
% %      Legolas: [-1 0 0 1 0 0 0 0 1]
% %     Denethor: [-1 0 0 1 0 0 0 0 0]
% %         Hare: [-1 0 0 1 0 0 0 0 1]
% %         Baby: [-1 0 1 1 0 0 0 0 1]
% %       Jabber: [-1 0 0 0 0 0 0 0 1]
% %      Aragorn: [-1 0 0 1 0 0 0 0 1]
% %        Gimli: [-1 0 0 0 0 0 0 0 1]
% %         Lory: [-1 0 0 1 0 0 0 0 0]
% %      Gandalf: [-1 1 0 0 0 0 0 0 1]
% %        Bilbo: [-1 0 0 1 0 0 0 0 1]
%
% figure;
% for r = 1:rows(ratlist)
%     rnum = r;%rows(hh_cell)-(k-1); %flip it
%     ratname = ratlist{r,1};
%     eval(['tmp = sig_struct.' ratname ';']);
%     for j = 2:length(tmp)
%         if tmp(j) == 0, c = [0 0 0];
%         else
%             c = [1 0 0]; %cmap(floor(tmp(idx)*length(cmap)),:);
%         end;
%
%         p=patch([j-1 j-1 j j], [r-1 r r r-1], c);
%         set(p,'EdgeColor','w');
%     end;
%     if 1
%         if tmp(end) == 0, c = [ 0 0 0];
%         else
%             c = [0 0 1];
%         end;
%         lent = length(tmp);
%         p=patch([lent-1 lent-1 lent lent], [r-1 r r r-1], c);
%     end;
% end;
% xlabel('Bin #');
% ylabel('Rats');
% set(gca,'YTick',0.5:rows(ratlist)-0.5, 'YTickLabel',fieldnames(sig_struct),'YLim',[0 rows(ratlist)],...
%     'XTick', 1.5:1:length(tmp)+0.5, 'XTickLabel', 2:1:length(tmp)+1,'XLim',[0 length(tmp)]);
% hold on;


ratlist = {'Grimesby','Blaze','Pips','Violet'};
fromdate = '080515';
todate = '999999';

for k = 1:length(ratlist)
multitrial(ratlist{k}, fromdate, todate);
end;