function [] = state_distribution(ratname, indate, state2plot)

pstruct = get_pstruct(ratname, indate);

snames = fieldnames(pstruct{1});

sdurs = 0;
stally =0;

exclude_states = {'center1_states','left1_states','right1_states','center1','left1','right1'};
snames = setdiff(snames, exclude_states);

for f = 1:length(snames)    
    eval(['sdurs.' snames{f} ' = NaN(size(pstruct));']);
    eval(['stally.' snames{f} ' = NaN(size(pstruct));']);
end;

% concat_states = {'wait_for_cpoke', 'timeout'};
% for f = 1:length(concat_states)
%     eval(['sdurs.' concat_states{f} ' = [];']);
%     eval(['stally.' concat_states{f} ' = {};']);
% end;

for k = 1:rows(pstruct)
    for s = 1:length(snames)
        curr = eval(['pstruct{k}.' snames{s} ';']);
        tmp = eval(['sdurs.' snames{s} ';']);
        ttally = eval(['stally.' snames{s} ';']);

        if rows(curr) > 0
%             if ismember(snames{s}, concat_states)
%                 for r = 1:rows(curr)
%                    tmp = horzcat(tmp, 
%                 end;
%             else
                
            if strcmpi(snames{s},'dead_time')
                if k < rows(pstruct)-1
                    nexttrial = pstruct{k+1}.dead_time;
                    tmp(k) = nexttrial(1,2) - curr(end,1);
                else
                    tmp(k) = curr(end,2) - curr(end,1);
                end;
            else
                    tmp(k) = curr(end,2) - curr(1,1);
            end;
%         end;
        ttally(k) = rows(curr);
        end;

        eval(['sdurs.' snames{s} '=tmp;']);
        eval(['stally.' snames{s} '=ttally;']);

    end;
end;

stotal = cell(length(snames),2);
totaltime = 0;
for k = 1:length(snames)
    tmp = eval(['sdurs.' snames{k} ';']);
    stotal{k,1} = nansum(tmp);
    stotal{k,2} = snames{k};
    totaltime = totaltime + stotal{k,1};
end;

stotal = sortrows(stotal);

fprintf(1,'State distribution\n');
for k = 1:rows(stotal)
%     figure; 
%     plot(tmp,'.b'); ylabel(snames{k}); xlabel('trial #');
%     set(gca,'XLim',[1 length(tmp)]);   
    fprintf(1,'\t%9s:\t%1.2f min\n', stotal{k,2}, stotal{k,1} / 60);    
end;

fprintf('Total time = %1.2f min\n\n', totaltime / 60);

if nargin > 2
    figure;
    tmp = eval(['sdurs.' state2plot ';']);
    plot(tmp,'.b');
    hold on;
    yl = get(gca,'YLim'); line([2 2], [0 yl(2)],'Color','r','LineWidth',2);
    ylabel(state2plot);
    set(gca,'XLim',[1 length(tmp)]);
    xlabel('trial #');
    set(gcf,'Position',[200 200 600 150]);
    axes__format(gca);
    title(sprintf('%s:%s', ratname, indate));
  %  hist(tmp);
end;

2;