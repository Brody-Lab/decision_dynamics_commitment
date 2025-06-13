function  [bmythical] = play_with_bfit(x)
% fits a psychometric curve to a mythical near-perfect rat.
% Then progressively makes the function flatter, returning projected
% f(report long) for these flatter curves

l = length(x);
mp = (min(x) + max(x))/2;

lt = find(x < mp);
gt = find(x > mp);
at = gt(1); gt =gt(2:end);

% construct the perfect rat.
total = 100;
replong(lt) = 0; replong(end) = 0.1*total;
replong(at) = 0.5*total;
replong(gt) = total; replong(gt(1)) = 0.9*total;
tally = ones(size(replong)) * total;

fig = findobj('Tag', 'sig_play');
if isempty(fig), fig = figure; else, fig = clf(fig); end;
set(fig, 'Position', [20 400 400 400],'MenuBar', 'none', 'Toolbar', 'none', 'Tag', 'sig_play');
der = findobj('Tag', 'sig_deriv');
if isempty(der), der = figure; else, der = clf(der); end;
set(der, 'Position', [400 400 400 400],'MenuBar', 'none', 'Toolbar', 'none', 'Tag', 'sig_deriv');
twice = findobj('Tag', 'sig_twice');
if isempty(twice), twice = figure; else, twice = clf(twice); end;
set(twice, 'Position', [700 400 400 400],'MenuBar', 'none', 'Toolbar', 'none', 'Tag', 'sig_twice');

bmythical = glmfit(x', [replong; tally]', 'binomial');
xx = min(x):(max(x)-min(x))/100:max(x);
yy = glmval(bmythical, xx, 'logit');

set(0,'CurrentFigure', fig);
axes('Position', [0.1 0.1 0.85 0.8]);
l = plot(xx, yy, '-k'); set(l,'LineWidth', 1.5);
title(sprintf('Logit fits using different\nscales of theoretical psychometric curve'));
xlabel('Log Duration (log ms)'); ylabel('f(Reporting long)');

set(0,'CurrentFigure', der);
dy = diff(yy); dx = diff(xx); l = plot(xx(2:end), dy' ./ dx); set(l,'Color', 'k');
text(max(x), 0.4, sprintf('%2.0f%%', 1*100), 'Color', 'k', 'FontSize', 12, 'FontWeight','bold');
title(sprintf('1st order derivative of logit fits'));
xlabel('Log Duration (log ms)'); ylabel('Sharpness of discriminability');

set(0,'CurrentFigure', twice);
dy = diff(dy); dx = diff(xx); l = plot(xx(3:end), dy' ./ dx(2:end)); set(l,'Color', 'k');
text(max(x), 0.05, sprintf('%2.0f%%', 1*100), 'Color', 'k', 'FontSize', 12, 'FontWeight','bold');
title(sprintf('2nd order derivative of logit fits'));
xlabel('Log Duration (log ms)'); ylabel('Change in sharpness of discriminability');



[blah blah2 blah3 weber] = get_weber(xx, yy);
fprintf(1, '\nFit params for %2.0f%%: [%3.2f, %1.2f]\nBin pcts:', 1*100, bmythical);
fprintf(1, ' %2.1f%% ', (replong ./ tally)*100);
fprintf(1, '\nWeber: %1.2f\n', weber);
text(max(x), 0.4, sprintf('%2.0f%%', 1*100), 'Color', 'k', 'FontSize', 12, 'FontWeight','bold');


c = [ 1 0 0 ];
% ratios = [2 3 4 5 8 10 15 20]; ratios = 1 ./ ratios;
ratios = [3]; ratios = 1 ./ ratios;
hold on;
for k = 1:length(ratios)
    set(0,'CurrentFigure', fig); hold on;
    c(2) = c(2) + 0.1; c(1) = c(1)-0.1; c(3) = c(3) + 0.1;
    bfit = bmythical * ratios(k);
    yy2 = glmval(bfit, xx, 'logit');
    l = plot(xx, yy2, '-r'); set(l,'Color', c, 'LineWidth', 1);
    sample_pcts = glmval(bfit, x, 'logit');
    [blah blah2 blah3 weber] = get_weber(xx, yy2);
    fprintf(1, '\nfit params for %2.0f%%: [%3.2f, %1.2f]\nBin pcts:', ratios(k)*100, bfit);
    fprintf(1, ' %2.1f%% ', sample_pcts*100);
    fprintf(1, '\nWeber: %1.2f\n', weber);
   % text(max(x), 0.1*k, sprintf('%2.0f%%', ratios(k)*100), 'Color', c, 'FontSize', 12, 'FontWeight','bold');

    set(0,'CurrentFigure', der); hold on;
    dy = diff(yy2); l = plot(xx(2:end), dy' ./ dx); set(l,'Color', c);
    text(max(x), 0.4*(k+1), sprintf('%2.0f%%', ratios(k)*100), 'Color', c, 'FontSize', 12, 'FontWeight','bold');

    set(0,'CurrentFigure', twice); hold on;
    dy = diff(dy); l = plot(xx(3:end), dy' ./ dx(2:end)); set(l,'Color', c);
    text(max(x), 0.4*(k+1), sprintf('%2.0f%%', ratios(k)*100), 'Color', c, 'FontSize', 12, 'FontWeight','bold');

end;

