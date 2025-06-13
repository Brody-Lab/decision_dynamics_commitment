function [out1 out2 out3 out4 out5] = logistic_fitter(action,varargin)

persistent curr_max;
persistent curr_min;
persistent binrange_mp;

MIN__VALUES__NEEDED=8; % if number of x,y pairs < 8, don't bother fitting model

out1=-1; out2=-1;out3=0;out4=0;
switch action
    case 'init'
        tones = varargin{1};
        side_choice = varargin{2};
        binrange_mp = varargin{3};
        ispitch = varargin{4};
        graphic_getweber = 0;

        if nargin > 5 % somebody set the graphic weber switch
            if strcmpi(varargin{5}, 'graphic_getweber'),
                graphic_getweber = varargin{6};
            else
                error('Invalid number of arguments');
            end;
        end;

        empt = union(isnan(tones), isnan(side_choice));
        if length(find(empt==1)) > 0, error('Sorry, there cannot be any NaN entries in input.'); end;

        % establish endpoints of the x-range
        if ispitch == 1 
            x = log2(tones);
            if (x(1) == 0), x(1) = 0.00001; end;            
            minx = min(x)-0.5; maxx=max(x)+0.5;
            binrange_mp = log2(binrange_mp);
        elseif ispitch == 0
            x = log(tones);
            % mp = log(binrange_mp);
            minx = min(x)-0.3; maxx=max(x)+0.3;
            binrange_mp = log(binrange_mp);
        else
            fprintf(1,'Not transforming x before fit\n');
            x = tones;
            minx = min(x); maxx=max(x);
            binrange_mp = mean(x);
        end;
        %  xx = min(x):0.02:max(x);
        xx= min(x): 0.0002 : max(x);

        fnhandle = @sub__sig4;
        fnhandle2 = @sub__lin;
        opt = statset;

        % Case 1 -- not enough data to fit curve: all values set to NaN
        if length(x) < MIN__VALUES__NEEDED
            fit_failed = 1;
            out.xcomm =NaN;
            out.xmid=NaN;
            out.xfin=NaN;
            out.weber=NaN;
            out.interp_x = NaN;
            out.interp_y = NaN;
            out.logtones = NaN;
            out.mp = NaN;
            out.betahat = NaN;
            out.chitest_sig = NaN; % new var not in weber_caller; 1 means not from chi distribution
            out.fit_failed = 1;
            out.ci = NaN;
            out.linearfit=NaN;
            out.sigmoidfit=NaN;
        else
            warning off stats:nlinfit:IllConditionedJacobian;
            warning off MATLAB:rankDeficientMatrix;
            warning off stats:nlinfit:IterationLimitExceeded;
            warning off MATLAB:nearlySingularMatrix;

            dbstop if warning;
            %sp_init = [1 0.01 0.1 0.1];
            
            % Sigmoid fit
            sig4_init = [0.1 .8 nanmean(x) 0.1];            
            myvars = {'betahat','resid','Jacobian','cov_betahat','mse'};
            [betahat resid Jacobian cov_betahat mse]= nlinfit(x',side_choice', fnhandle, sig4_init,opt);
            sigmoidfit = [];            
            for k=1:length(myvars), eval(['sigmoidfit.' myvars{k} '=' myvars{k} ';']); end;
            sigmoidfit.yy=sigmoid4param(betahat, xx);
            
            % linear fit
            [betahatlin residlin Jacobianlin cov_betahatlin mselin]= nlinfit(x',side_choice', fnhandle2, [1 0], opt);                   
            linearfit=[];
            for k=1:length(myvars), eval(['linearfit.' myvars{k} '=' myvars{k} 'lin;']);end;
            linearfit.yy=linear(betahatlin, xx);
                        %             
            xc=0;xf=0;xm=0; wb=-1; ci=0;
            yy = NaN(size(xx));
            
            % Case 2: There was enough data and fit was good            
            if (rank(Jacobian) == cols(Jacobian)) && betahat(3) > 0 % reasonable fit -- I don't recall now why I thought
                                                                    % that the 'n' parameter has to be > 0 for it to be a good fit
                out3=1;
                ci = nlparci(betahat, resid, 'covar', cov_betahat);
                yy = sub__sig4(betahat, xx);
                
                [xc xf xm wb]= get_weber(xx, yy,'graphic',graphic_getweber,'pitches', ispitch);
                if wb == -1
                   [betahat resid Jacobian cov_betahat mse] = nlinfit(x',side_choice', fnhandle2, [1 0], opt);                   
                   yy=sub__lin(betahat, xx);                  
                   [xc xf xm wb] = get_weber_lin(xx,yy,ispitch);
                   
                end;
                fit_failed=0;
                % Case 3: Was enough data but fit failed
            else                
                % use linear fit values
                betahat=betahatlin;
                resid=residlin;
                Jacobian=Jacobianlin;
                cov_betahat=cov_betahatlin;
                mse=mselin;
                
                yy = sub__lin(betahat, xx);
                [xc xf xm wb] = get_weber_lin(xx,yy,ispitch);
                fit_failed=0;
%                fit_failed=1; xc=NaN; xf=NaN; xm=NaN; wb=NaN;                
            end;
            % Now compute goodness of fit
           % [ypred,delta] = nlpredci(fnhandle,x,betahat,resid,'covar',cov_betahat); % yes/no values from the fitted curve
           % sig = logistic_fitter('goodness_of_fit',side_choice, ypred);
           sig=1;

            out.xcomm =xc;
            out.xmid=xm;
            out.xfin=xf;
            out.weber=wb;
            out.interp_x = xx;
            out.interp_y = yy;
            out.logtones = x;
            out.mp = binrange_mp;
            out.betahat = betahat;
            out.chitest_sig = sig; % new var not in weber_caller; 1 means not from chi distribution
            out.fit_failed = fit_failed;
            out.ci = ci;            %        out.fig=f;
            out.sigmoidfit=sigmoidfit;
            out.linearfit=linearfit;
        end;

        % reset values
        curr_min = -1000;
        curr_max = +1000;
        binrange_mp=0;

        out1=out;

    case 'get_lims'
        out1=curr_min;
        out2=curr_max;
    case 'get_bin_midpoint'
        out1=binrange_mp;

    case 'goodness_of_fit'
        obs = varargin{1};
        xpect = varargin{2};
        sigma=varargin{3};
        fittype = varargin{4};
        
 
        
        if strcmpi(fittype,'sigmoid')
            paramnum=4;
%              obs
%              sigma
        elseif strcmpi(fittype,'linear')
            paramnum=2;
        else
            error('fittype should be ''sigmoid'' or ''linear''');
        end;
        if rows(obs) ~= rows(xpect), xpect=xpect'; end; 
        
%         sigma(find(sigma==0)) = 0.000001;

        chi2 = sum((((obs - xpect) ./sigma).^2));

                
     %   fprintf(1,'chi2test: chi2 for %s=%2.3f\n', fittype,chi2);       

        % if this model is a good fit, pearson should come from a
        % chi-squared distribution with (n-2) degrees of freedom
        % "paramnum" is for the parameters we estimated (b0 and b1)
        % n is the length of replong (# samples)
        % what is the probability we find something this large in a chi2?
    
        
        % formula taken from Carlos' Romo script "linefit.m"
        % and equation 15.2.12 from Numerical Recipes (1992 edition).
        n=(length(obs)-paramnum);
        nannie = sum(isnan(obs));
        if n <=0 || (nannie > 0 && strcmpi(fittype,'sigmoid'))
            q=-1;
        else
            q = 1-gammainc(chi2/2, n/2);
        end;
       
%         if strcmpi(fittype,'sigmoid')
%              numer = obs - xpect
%            fprintf(1,'chi2=%2.3f\n\tq for sigmoid=%2.4f\n\n', chi2, q);
%         end;
        
        out1=q;
        
    case 'get_interpolated'
        %      fprintf(1,'*** Warning: Calling ''get_interpolated''; behaviour not fully tested');
        bins=varargin{1};
        ispitch=varargin{2};
        betahat=varargin{3};
        pct= varargin{4};
        binrange_mp = varargin{5};

        % curr_min=min(pct); curr_max = max(pct);

        % Perform logistic regression and calculate Weber ratio
        if ispitch > 0
            x = log2(bins);
            if (x(1) == 0), x(1) = 0.00001; end;
            minx = min(x)-0.5; maxx=max(x)+0.5;
            binrange_mp = log2(binrange_mp);
        else
            x = log(bins);
            mp = log(binrange_mp);
            minx = min(x)-0.3; maxx=max(x)+0.3;
            binrange_mp = log(binrange_mp);
        end;
        if nargin > 6
            xx = varargin{6};
        else
            xx = x(1):0.02:x(end);
        end;
        yy = sub__sig4(betahat, xx);

        %        if ispitch >0,xx = 2.^(xx);else xx = exp(xx);end;

        out1=xx;
        out2=yy;

        curr_min=-1000;
        curr_max=+1000;
        binrange_mp=0;

    case 'get_midpoint' % return stimulus point for which y-axis is at 50%
        xx= varargin{1};
        yy= varargin{2};
        mid = find(abs(yy - 0.5) == min(abs(yy-0.5)));

        out1 = xx(mid);

    otherwise
        error('invalid action');
end;

function y=sub__sig4(beta,x)
%
% y0=beta(1)    sets the lower bound
% a=beta(2)     a+y0 is the upper bound
% x0=beta(3)    is the bias
% b=beta(4)     is the slope


y0=beta(1);
a=beta(2);
x0=beta(3);
b=beta(4);

y=y0+a./(1+ exp(-(x-x0)./b));

function y=sub__lin(beta,x)
m=beta(1);
c=beta(2);

y= (m*x)+c;


