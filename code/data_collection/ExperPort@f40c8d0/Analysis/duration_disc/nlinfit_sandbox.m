function [out1 out2 out3 out4] = nlinfit_sandbox(action,varargin)

persistent replong;
persistent tally;

%x = [   5.2983    5.3982    5.5013    5.6021    5.7071    5.8081    5.9081    6.0113    6.1137];
% Hare - 22 March 2007
% replong =[ 0     3     1     3     7    15    11    14    22];
% tally =[  20    12    23    16    17    21    17    15    22];

% Shadowfax 2 Oct 2007
% replong = [4     6     4     6    12    22    24    19    13];
% tally =[  61    14    19    24    23    27    24    20    13];

% Balrog 2 Oct 2007
%  replong = [    0     0     1     4     3     6     5    13    14];
%  tally = [    18     9    10    14     8    13     7    14    16];


out1=-1; out2=-1;out3=0;out4=0;
switch action
    case 'init'
%         date = varargin{1};
          x=varargin{1};
          sc=varargin{2};
%         replong = varargin{2};
%         tally = varargin{3};
        fnhandle = @logistic_setbound;
        %        opts=statset('MaxIter',100,'Display','Iter');
        [betahat resid Jacobian cov_betahat mse]= nlinfit(x,sc, fnhandle, [1, 0.01 0.1 0.1]);
%        [betahat resid Jacobian cov_betahat mse]= nlinfit(x,replong./tally, fnhandle, [1, 0.01 0.1 0.1]);
     %   [ypred delta]= nlpredci(fnhandle,x,betahat, resid,'covar',mse);
        %  nlintool(x, replong./tally, fnhandle, [0.1 0.1],'plotdata','on');
        %
        f=figure;
        if rank(Jacobian) == cols(Jacobian)
            out3=1;
            bigx=5:0.02:7;
            yhat = logistic_setbound(betahat, bigx);
            [ypred delta]= nlpredci(fnhandle,bigx,betahat, resid,'covar',mse);
            ci = nlparci(betahat, resid, 'covar', mse);
            2;
            delta=delta';
            subplot(1,2,1);
            plot(bigx,yhat,'-r');hold on;
%              plot(bigx,ypred+delta,'-b'); 
%              plot(bigx,ypred-delta,'-g');
subplot(1,2,2);
errorbar(1:length(betahat),betahat, ci(:,1), ci(:,2),'.r');
title('Error bars on parameter estimates');
set(gca,'XTick',1:4, 'XTickLabel',{'a','m','n','tau'});
            [xc xf xm web]= get_weber(bigx, yhat);
            
        end;
%        l=plot(x,replong./tally,'.b');set(l,'MarkerSize',20);
        text(6.5, 0.4, num2str(sum(resid.^2)));
        t=text(6.6, 0.6, sprintf('%1.3f',web)); set(t,'Color','r','FontWeight','bold','FontSize',20);

                 fprintf(1,'m is = %1.6f\n',betahat(1));
                 fprintf(1,'tau is = %1.6f\n', betahat(2));

        % Now compute goodness of fit
        [ypred,delta] = nlpredci(fnhandle,x,betahat,resid,'covar',cov_betahat);
        if rows(ypred) ~= rows(tally), tally=tally'; end;
        sig = nlinfit_sandbox('goodness_of_fit',replong, ypred.*tally,tally);

        if sig == 1, set(gca,'Color','y'); end;
        title(date);

        out1 = betahat;
        out4=f;
    case 'get_lims'
        pct = replong ./tally;
        out1=min(pct);out2=max(pct);

    case 'goodness_of_fit'
        obs = varargin{1};
        xpect = varargin{2};
        tally=varargin{3};

        if rows(obs) ~= rows(xpect), xpect=xpect'; end;

        pearson = sum(((obs - xpect).^2)./xpect);

        % if this model is a good fit, pearson should come from a
        % chi-squared distribution with (n-2) degrees of freedom
        % "2" is for the parameters we estimated (b0 and b1)
        % n is the length of replong (# samples)
        % what is the probability we find something this large in a chi2?
        p_thislarge = (1-chi2cdf(pearson, sum(tally)-2));

        if p_thislarge < 0.05 % less than 5% chance of seeing something this large
            out1 = 1; % reject
        else
            out1 =0; % do not reject; model is acceptable fit.
        end;
    otherwise
        error('invalid action');
end;