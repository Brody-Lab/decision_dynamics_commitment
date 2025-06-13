function [x,y]=ChoiceSection(obj, action, x, y);

GetSoloFunctionArgs;
% SoloFunction('ChoiceSection', 'rw_args',{}, ...
%   'ro_args', {'n_done_trials', 'n_started_trials', 'maxtrials',
%   'RealTimeStates', 'VpdList', 'Vpd_LeftMin', 'Vpd_LeftMax', ...
%   'Vpd_RightMin', 'Vpd_RightMax'})
switch action,
    case 'init',
        fig=gcf;
        %init window for Vpd Resluts
        MenuParam(obj, 'ResultWindow', {'view', 'hidden'},2,x,y);
        next_row(y);
        set_callback(ResultWindow, {'ChoiceSection', 'res_wind_view'});

        old_x=x; old_y=y; x=5; y=5;
        SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable',0);
      
        Menuparam(obj,'MeshDiv_Y',{'1','2','3','4','5','6','7','8','9','10'}, ...
            4, x, y);next_row(y);
        Menuparam(obj,'MeshDiv_X',{'1','2','3','4','5','6','7','8','9','10'}, ...
            4, x, y);next_row(y,1.5);
        EditParam(obj, 'Y_Max', 2, x, y);next_row(y);
        EditParam(obj, 'Y_Min', 0, x, y);next_row(y);
        EditParam(obj, 'X_Max', 2, x, y);next_row(y);
        EditParam(obj, 'X_Min', 0, x, y);next_row(y);
        MenuParam(obj, 'Y_Axis',{'Del2L','Del2R','Poke', ...
            'Poke-Del2L','Poke-Del2R','Del2L_prev','Del2R_prev','Poke_prev', ...
            'Poke-Del2L_prev','Poke-Del2R_prev'}, ...
            2,x,y);next_row(y);
        MenuParam(obj, 'X_Axis',{'Del2L','Del2R','Poke', ...
            'Poke-Del2L','Poke-Del2R','Del2L_prev','Del2R_prev','Poke_prev', ...
            'Poke-Del2L_prev','Poke-Del2R_prev'}, ...
            1,x,y);next_row(y,1.5);
        MenuParam(obj, 'latest', {'ON','OFF'}, 1, x, y); next_row(y);
        SoloParamHandle(obj, 'start_trial','label', 'start', 'type', 'numedit', ...
            'value', 1, 'position', [x y 80 20]);
        SoloParamHandle(obj, 'end_trial','label', 'end', 'type', 'numedit', ...
            'value', 25, 'position', [x+90 y 80 20]); next_row(y);
        set([get_ghandle(end_trial);get_lhandle(end_trial)], 'Visible', 'off');
        next_column(x);y=5;
        
        Menuparam(obj, 'Correct_Error_Prev', {'all_prev','cor_err_prev', ...
            'correct_prev','error_prev'},1, x, y);next_row(y);
        Menuparam(obj, 'Correct_Error', {'all','cor_err','correct','error'}, ...
            1, x, y);next_row(y);        
        Menuparam(obj, 'ChoiceSide_Prev', {'all_prev','L_R_prev', ...
            'L_prev','R_prev'},1, x, y);next_row(y);
        Menuparam(obj, 'ChoiceSide', {'all','L_R','L','R'},1, x, y);next_row(y);        
        Menuparam(obj, 'WaitState_Prev', {'all_prev', 'LR_L_R_prev', ...
            'LR_L_prev','LR_R_prev','LR_prev','L_prev','R_prev'}, ...
            1, x, y);next_row(y);
        Menuparam(obj, 'WaitState', {'all','LR_L_R','LR_L','LR_R','LR','L','R'}, ...
            1, x, y);next_row(y);        
        Menuparam(obj, 'TrialType_Prev', {'all_prev','normal_tout_prev','normal_prev', ...
            'shortpoke_prev','timeout_prev'}, 1, x, y);next_row(y);
        Menuparam(obj, 'TrialType', {'all','normal_tout','normal','shortpoke','timeout'}, ...
            1, x, y);next_row(y);        
        Menuparam(obj, 'Analysis', {'number_trial','choiceL%','choiceCor%', ...
            'Impulsive%', 'shortpoke%', 'poke_duration', 'move_time'}, 2, x, y);next_row(y);
        next_row(y,0.5);
                
        set_callback(latest, {'ChoiceSection','latest' ; ...
            'ChoiceSection', 'update_window'});
        set_callback(Analysis, {'ChoiceSection','color_axis';'ChoiceSection','update_window'});
        set_callback({Correct_Error,ChoiceSide,WaitState,TrialType, ...
            Correct_Error_Prev,ChoiceSide_Prev,WaitState_Prev,TrialType_Prev, ...
            MeshDiv_Y,MeshDiv_X,Y_Max,Y_Min,X_Max,X_Min, ...
            Y_Axis,X_Axis,start_trial,end_trial}, ...
            {'ChoiceSection', 'update_window'}); 
        
        MenuParam(obj, 'ColorAxis', {'auto', 'manual'}, 1, x, y); next_row(y);
        set_callback(ColorAxis, {'ChoiceSection', 'color_axis' ; ...
            'ChoiceSection', 'update_window'});
        x2=x;y2=y;
        SoloParamHandle(obj, 'cmin', 'label', 'cmin', 'type', 'numedit', ...
            'value', 0, 'position', [x y 80 20]);
        SoloParamHandle(obj, 'cmax', 'label', 'cmax', 'type', 'numedit', ...
            'value', 1, 'position', [x+90 y 80 20]);
        SoloParamHandle(obj, 'cmin_nt', 'label', 'cmin', 'type', 'numedit', ...
            'value', 0, 'position', [x y 80 20]);
        SoloParamHandle(obj, 'cmax_nt', 'label', 'cmax', 'type', 'numedit', ...
            'value', 50, 'position', [x+90 y 80 20]);
        set_callback({cmin,cmax,cmin_nt,cmax_nt}, {'ChoiceSection', 'update_window'});

        set([get_ghandle(cmin);get_lhandle(cmin)], 'Visible', 'off');
        set([get_ghandle(cmax);get_lhandle(cmax)], 'Visible', 'off');
        set([get_ghandle(cmin_nt);get_lhandle(cmin_nt)], 'Visible', 'off');
        set([get_ghandle(cmax_nt);get_lhandle(cmax_nt)], 'Visible', 'off');
        
        %SPH for graph
        SoloParamHandle(obj, 'ax_analysis', 'saveable', 0, ...
            'value', axes('Position',[0.3 0.6 0.48 0.38]));
        colormap(hot)

        set(value(myfig), ...
            'Visible', 'off', 'MenuBar', 'none', 'Name', 'Result Window', ...
            'NumberTitle', 'off', 'CloseRequestFcn', ...
            ['ChoiceSection(' class(obj) '(''empty''), ''res_wind_hide'')']);
        set(value(myfig), 'Position', [250 100 440 430]);
        x=old_x; y=old_y; figure(fig);
        
        %init window for Block Based Analysis
        MenuParam(obj, 'BlockBasedAnalysis', {'view', 'hidden'},2,x,y);
        next_row(y, 1.5);
        set_callback(BlockBasedAnalysis, {'ChoiceSection', 'block_wind'});
        
        old_x=x; old_y=y; x=30; y=5;
        SoloParamHandle(obj, 'myfig2', 'value', figure, 'saveable',0);
        
        EditParam(obj, 'Trials_per_Block',20, x,y);next_row(y);
        MenuParam(obj, 'Denominator', {'All', 'All_Wait', 'Normal', 'WaitLR', ...
            'WaitL/R', 'WaitL', 'WaitR'},2,x,y);next_row(y);
        MenuParam(obj, 'Numerator', {'Rewarded', 'Correct', 'Incorrect', 'ShortPoke', ...
            'VADover', 'Impulsive', 'ChoiceL', 'ChoiceR'},2,x,y);
        
        set_callback({Trials_per_Block,Denominator, Numerator}, ...
            {'ChoiceSection', 'update_window2'});
        
        %SPH for graph
        SoloParamHandle(obj, 'ax_block_analysis', 'saveable', 0, ...
            'value', axes('Position',[0.1 0.35 0.8 0.6]));
        set(value(ax_block_analysis),'YLim', [-0.02 1.02], ...
            'YTick',[0:0.2:1]);
        
        SoloParamHandle(obj, 'C_bl', 'value', line([0], [0]), 'saveable', 0);
        set(value(C_bl),  'Color', 'b', 'Marker', '.','MarkerSize',6, ...
            'LineStyle', '-', 'LineWidth', 3);
        SoloParamHandle(obj, 'C_rd', 'value', line([0], [0]), 'saveable', 0);
        set(value(C_rd),  'Color', 'r', 'Marker', '.', 'LineStyle', 'none', ...
            'MarkerSize', 20);

        set(value(myfig2), ...
            'Visible', 'off', 'MenuBar', 'none', 'Name', 'Block_Based Analysis', ...
            'NumberTitle', 'off', 'CloseRequestFcn', ...
            ['ChoiceSection(' class(obj) '(''empty''), ''block_wind_hide'')']);
        set(value(myfig2), 'Position', [250 50 280 280]);
        x=old_x; y=old_y; figure(fig);       
        
    case 'update_window' %after update_result and in case for param change
        xmin=value(X_Min);xmax=value(X_Max);ymin=value(Y_Min);ymax=value(Y_Max);
        if strcmp(value(ResultWindow),'hidden'),return;end;
        if (ymax<=ymin|xmax<=xmin),return;end;
%         if n_done_trials<1, return;end;

        from  = max(1,value(start_trial));
        switch value(latest),
            case 'ON',
                to = n_done_trials;
            case 'OFF',
                to = min(value(n_done_trials),value(end_trial));
                if from>to,
                    to=from;
                    end_trial.value=to;
                end;
            otherwise error('whuh?');
        end;
    
        rts=RealTimeStates;
        vpdlist=value(VpdList);vpdlist=vpdlist(:,from:to);
        
        %get SPH value for local
        ttype=CpokeData.trial_type;ttype=ttype(:,from:to);
        wstate=CpokeData.wait_state;wstate=wstate(:,from:to);
        cside=CpokeData.choice_side;cside=cside(:,from:to);
        ccorrect=CpokeData.choice_correct;ccorrect=ccorrect(:,from:to);
        pdur=CpokeData.poke_duration;pdur=pdur(:,from:to);

        mesh_y=value(MeshDiv_Y);mesh_x=value(MeshDiv_X);
        ybin=(ymax-ymin)/mesh_y; xbin=(xmax-xmin)/mesh_x;

        %first get index for trial interested
        switch value(TrialType),
            case 'shortpoke', idx=find(ttype==1);
            case 'timeout', idx=find(ttype==2);
            case 'normal', idx=find(ttype==3);
            case 'normal_tout', idx=find(ttype==2|ttype==3);
            case 'all',idx=[1:size(ttype,2)];
        end;
 
        switch value(WaitState),
            case 'all', idx_ws=[1:size(idx,2)];
            case 'LR_L_R', idx_ws=find(wstate==rts.wait_lrpokeO| ...
                    wstate==rts.wait_lpokeO|wstate==rts.wait_rpokeO);
            case 'LR_L', idx_ws=find(wstate==rts.wait_lrpokeO|wstate==rts.wait_lpokeO);
            case 'LR_R',idx_ws=find(wstate==rts.wait_lrpokeO|wstate==rts.wait_rpokeO);
            case 'LR', idx_ws=find(wstate==rts.wait_lrpokeO);
            case 'L', idx_ws=find(wstate==rts.wait_lpokeO);
            case 'R',idx_ws=find(wstate==rts.wait_rpokeO);
        end;
        idx=intersect(idx,idx_ws);

        switch value(ChoiceSide),
            case 'all', idx_cs=[1:size(idx,2)];
            case 'L_R', idx_cs=find(cside==-1|cside(idx)==1);
            case 'L', idx_cs=find(cside(idx)==1);
            case 'R', idx_cs=find(cside(idx)==-1);
        end;
        idx=intersect(idx,idx_cs);
            
        switch value(Correct_Error),
            case 'all', idx_ce=[1:size(idx,2)];
            case 'cor_err', idx_ce=find(ccorrect==-1|ccorrect(idx)==1);
            case 'correct', idx_ce=find(ccorrect==1);
            case 'error', idx_ce=find(ccorrect==-1);
        end;
        idx=intersect(idx,idx_ce);
            
        switch value(TrialType_Prev),
            case 'shortpoke_prev', idx_p=find(ttype==1);
            case 'timeout_prev', idx_p=find(ttype==2);
            case 'normal_prev', idx_p=find(ttype==3);
            case 'normal_tout_prev', idx_p=find(ttype==2|ttype==3);
            case 'all_prev', idx_p=[1:size(ttype,2)];
        end;
        
        switch value(WaitState_Prev),
            case 'all_prev', idx_wsp=[1:size(wstate,2)];
            case 'LR_L_R_prev',idx_wsp=find(wstate==rts.wait_lrpokeO| ...
                    wstate==rts.wait_lpokeO|wstate==rts.wait_rpokeO);
            case 'LR_L_prev', idx_wsp=find(wstate==rts.wait_lrpokeO| ...
                        wstate==rts.wait_lpokeO);
            case 'LR_R_prev',idx_wsp=find(wstate==rts.wait_lrpokeO| ...
                    wstate==rts.wait_rpokeO);
            case 'LR_prev', idx_wsp=find(wstate==rts.wait_lrpokeO);
            case 'L_prev', idx_wsp=find(wstate==rts.wait_lpokeO);
            case 'R_prev', idx_wsp=find(wstate==rts.wait_rpokeO);
        end;
        idx_p=intersect(idx_p,idx_wsp);
        
        switch value(ChoiceSide_Prev),
            case 'all_prev', idx_csp=[1:size(cside,2)];
            case 'L_R_prev', idx_csp=find(cside==1|cside==-1);              
            case 'L_prev', idx_csp=find(cside==1);
            case 'R_prev', idx_csp=find(cside==-1);
        end;
        idx_p=intersect(idx_p,idx_csp);
        
        switch value(Correct_Error_Prev),
            case 'all_prev', idx_cep=[1:size(ccorrect,2)];
            case 'cor_err_prev', idx_cep=find(ccorrect==1|ccorrect==-1);
            case 'correct_prev', idx_cep=find(ccorrect==1);
            case 'error_prev', idx_cep=find(ccorrect==-1);
        end;
        idx_p=intersect(idx_p,idx_cep);
        
        idx_p=idx_p+1;
        idx=intersect(idx,idx_p);
        
%Now get index for trials to be analyzed

        switch value(X_Axis),
            case 'Del2L', x_axis=vpdlist(1,:);
            case 'Del2R', x_axis=vpdlist(2,:);
            case 'Poke', x_axis=pdur;
            case 'Poke-Del2L', x_axis=pdur-vpdlist(1,:);
            case 'Poke-Del2R', x_axis=pdur-vpdlist(2,:);
            case 'Del2L_prev', x_axis=[-Inf vpdlist(1,1:end-1)];
            case 'Del2R_prev', x_axis=[-Inf vpdlist(2,1:end-1)];
            case 'Poke_prev', x_axis=[-Inf pdur(1,1:end-1)];
            case 'Poke-Del2L_prev', x_axis=[-Inf pdur(1,1:end-1)-vpdlist(1,1:end-1)];
            case 'Poke-Del2R_prev', x_axis=[-Inf pdur(1,1:end-1)-vpdlist(2,1:end-1)];
        end;
        switch value(Y_Axis),
            case 'Del2L', y_axis=vpdlist(1,:);
            case 'Del2R', y_axis=vpdlist(2,:);
            case 'Poke', y_axis=pdur;
            case 'Poke-Del2L', y_axis=pdur-vpdlist(1,:);
            case 'Poke-Del2R', y_axis=pdur-vpdlist(2,:);
            case 'Del2L_prev', y_axis=[-Inf vpdlist(1,1:end-1)];
            case 'Del2R_prev', y_axis=[-Inf vpdlist(2,1:end-1)];
            case 'Poke_prev', y_axis=[-Inf pdur(1,1:end-1)];
            case 'Poke-Del2L_prev', y_axis=[-Inf pdur(1,1:end-1)-vpdlist(1,1:end-1)];
            case 'Poke-Del2R_prev', y_axis=[-Inf pdur(1,1:end-1)-vpdlist(2,1:end-1)];
        end;
        
        %draw
        if ~isempty(idx),
            num_trial=hist3([y_axis(1,idx)' x_axis(1,idx)'],'Edges', ...
                {[ymin-ybin:ybin:ymax],[xmin-xbin:xbin:xmax]}); %(mesh+2)-by-(mesh+2) array
            if strcmp(value(Analysis),'number_trial'),
                    pcolor([xmin:xbin:xmax], [ymin:ybin:ymax], ...
                        num_trial(2:end,2:end),'parent',value(ax_analysis)) %last column and last array are ignored
%                     colorbar('peer',value(ax_analysis))
            else,
                [xn,xnth]=histc(x_axis(1,idx)',[xmin-xbin:xbin:xmax+xbin]);
                [yn,ynth]=histc(y_axis(1,idx)',[ymin-ybin:ybin:ymax+ybin]);
                subs=[ynth xnth];subs_idx=find(subs(:,1)~=0&subs(:,2)~=0);

%                 if isempty(subs_idx), %Gray patch for empty data patch
%                     x1=linspace(0,mesh_x,mesh_y*mesh_x+1); x2=floor(x1(1,1:end-1));
%                     x3=x2*xbin+xmin;x4=x3+xbin; patch_x=[x3;x4;x4;x3];
%                     y1=[ymin:ybin:ymax-ybin+eps];y2=y1+ybin;y3=[y1;y1;y2;y2];
%                     patch_y=repmat(y3,1,mesh_x);
%                     patch(patch_x,patch_y,[0.7 0.7 0.7],'parent',value(ax_analysis));
%                     return;
%                 end;
                switch value(Analysis),
                    case 'choiceL%',
                        C=cside(:,idx)';
                        A=accumarray(subs(subs_idx,:),C(subs_idx,:), ...
                            [mesh_y+2,mesh_x+2],@(x) length(find(x==1)));
                    case 'choiceCor%',
                        C=ccorrect(:,idx)';
                        A=accumarray(subs(subs_idx,:),C(subs_idx,:), ...
                            [mesh_y+2,mesh_x+2],@(x) length(find(x==1)));
                    case 'Impulsive%',
                        W=wstate(:,idx)';
                        A=accumarray(subs(subs_idx,:),W(subs_idx,:), ...
                            [mesh_y+2,mesh_x+2],@(x) length(find(x==rts.wait_lpokeO| ...
                            x==rts.wait_rpokeO)));
                    case 'shortpoke%',
                        T=ttype(:,idx)';
                        A=accumarray(subs(subs_idx,:),T(subs_idx,:), ...
                            [mesh_y+2,mesh_x+2],@(x) length(find(x==1)));
                    case 'poke_duration',
                    case 'move_time',
                end;

               warning off all
               fraction=A./num_trial;
               warning on all
               pcolor([xmin:xbin:xmax],[ymin:ybin:ymax],fraction(2:end,2:end), ...
                   'parent',value(ax_analysis))
               %Gray patch for num_trial==0
               idx_nz=find(num_trial(2:end-1,2:end-1)~=0);
               x1=linspace(0,mesh_x,mesh_y*mesh_x+1); x2=floor(x1(1,1:end-1));
               x3=x2*xbin+xmin;x4=x3+xbin; patch_x=[x3;x4;x4;x3]; patch_x(:,idx_nz)=0;
               y1=[ymin:ybin:ymax-ybin];y2=y1+ybin;y3=[y1;y1;y2;y2];
               patch_y=repmat(y3,1,mesh_x);patch_y(:,idx_nz)=0;
               patch(patch_x,patch_y,[0.7 0.7 0.7],'parent',value(ax_analysis));  
            end;
        else,
            x1=linspace(0,mesh_x,mesh_y*mesh_x+1); x2=floor(x1(1,1:end-1));
            x3=x2*xbin+xmin;x4=x3+xbin; patch_x=[x3;x4;x4;x3];
            y1=[ymin:ybin:ymax-ybin+eps];y2=y1+ybin;y3=[y1;y1;y2;y2];
            patch_y=repmat(y3,1,mesh_x);
            patch(patch_x,patch_y,[0.7 0.7 0.7],'parent',value(ax_analysis));
        end;
        
        switch value(ColorAxis),
            case 'auto',
                caxis(value(ax_analysis),'auto');
            case 'manual',
                if strcmp(value(Analysis), 'number_trial'),
                    caxis(value(ax_analysis), [value(cmin_nt) value(cmax_nt)]);
                else,
                    caxis(value(ax_analysis), [value(cmin) value(cmax)]);
                end;
        end;
        colorbar('peer',value(ax_analysis))
        
    case 'update_window2'
        if n_done_trials<1, return; end;
        rts=value(RealTimeStates);
        ttype=CpokeData.trial_type; wstate=CpokeData.wait_state;
        cside=CpokeData.choice_side; ccorrect=CpokeData.choice_correct;
        pdur=CpokeData.poke_duration;

        trials_per_block=value(Trials_per_Block);
        block_num=floor(n_done_trials/trials_per_block);
        trial_rem=n_done_trials-(block_num*trials_per_block);
        if trial_rem==0,red_data=trials_per_block;
        else, red_data=trial_rem;
        end;
        
        switch value(Denominator),
            case 'All',
                denomi01=ones(trials_per_block,block_num);
                denomi_rd01=ones(1,red_data);
            case 'All_Wait',
                denomi=reshape(ttype(1:trials_per_block*block_num), ...
                    trials_per_block, block_num);
                denomi01=(denomi==2|denomi==3);
                denomi_rd=ttype(n_done_trials-red_data+1:n_done_trials);
                denomi_rd01=(denomi_rd==2|denomi_rd==3);
            case 'Normal',
                denomi=reshape(ttype(1:trials_per_block*block_num), ...
                    trials_per_block, block_num);
                denomi01=(denomi==3);
                denomi_rd=ttype(n_done_trials-red_data+1:n_done_trials);
                denomi_rd01=(denomi_rd==3);
            case 'WaitLR',
                denomi=reshape(wstate(1:trials_per_block*block_num), ...
                    trials_per_block, block_num);
                denomi01=(denomi==rts.wait_lrpokeO);
                denomi_rd=wstate(n_done_trials-red_data+1:n_done_trials);
                denomi_rd01=(denomi_rd==rts.wait_lrpokeO);
            case 'WaitL/R',
                denomi=reshape(wstate(1:trials_per_block*block_num), ...
                    trials_per_block, block_num);
                denomi01=(denomi==rts.wait_lpokeO|denomi==rts.wait_rpokeO);
                denomi_rd=wstate(n_done_trials-red_data+1:n_done_trials);
                denomi_rd01=(denomi_rd==rts.wait_lpokeO|denomi_rd==rts.wait_rpokeO);
            case 'WaitL',
                denomi=reshape(wstate(1:trials_per_block*block_num), ...
                    trials_per_block, block_num);
                denomi01=(denomi==rts.wait_lpokeO);
                denomi_rd=wstate(n_done_trials-red_data+1:n_done_trials);
                denomi_rd01=(denomi_rd==rts.wait_lpokeO);
            case 'WaitR'
                denomi=reshape(wstate(1:trials_per_block*block_num), ...
                    trials_per_block, block_num);
                denomi01=(denomi==rts.wait_rpokeO);
                denomi_rd=wstate(n_done_trials-red_data+1:n_done_trials);
                denomi_rd01=(denomi_rd==rts.wait_rpokeO);
        end;
        switch value(Numerator),
            case 'Rewarded',
                numera=reshape(ccorrect(1:trials_per_block*block_num), ...
                    trials_per_block, block_num);
                numera01=(numera==1&denomi01);
                numera_rd=ccorrect(n_done_trials-red_data+1:n_done_trials);
                numera_rd01=(numera_rd==1&denomi_rd01);
            case 'Correct',
                numera=reshape(ccorrect(1:trials_per_block*block_num), ...
                    trials_per_block, block_num);
                numera01=(numera==1&denomi01);
                numera_rd=ccorrect(n_done_trials-red_data+1:n_done_trials);
                numera_rd01=(numera_rd==1&denomi_rd01);
            case 'Incorrect',
                numera=reshape(ccorrect(1:trials_per_block*block_num), ...
                    trials_per_block, block_num);
                numera01=(numera==-1&denomi01);
                numera_rd=ccorrect(n_done_trials-red_data+1:n_done_trials);
                numera_rd01=(numera_rd==-1&denomi_rd01);
            case 'ShortPoke',
                numera=reshape(ttype(1:trials_per_block*block_num), ...
                    trials_per_block, block_num);
                numera01=(numera==1&denomi01);
                numera_rd=ttype(n_done_trials-red_data+1:n_done_trials);
                numera_rd01=(numera_rd==1&denomi_rd01);
            case 'VADover',
                numera=reshape(ttype(1:trials_per_block*block_num), ...
                    trials_per_block, block_num);
                numera01=(numera==2&denomi01);
                numera_rd=ttype(n_done_trials-red_data+1:n_done_trials);
                numera_rd01=(numera_rd==2&denomi_rd01);
            case 'Impulsive',
                numera=reshape(wstate(1:trials_per_block*block_num), ...
                    trials_per_block, block_num);
                numera01=((numera==rts.wait_lpokeO|numera==rts.wait_rpokeO) ...
                    &denomi01);
                numera_rd=wstate(n_done_trials-red_data+1:n_done_trials);
                numera_rd01=((numera_rd==rts.wait_lpokeO|numera_rd==rts.wait_rpokeO) ...
                    &denomi_rd01);
            case 'ChoiceL'
                numera=reshape(cside(1:trials_per_block*block_num), ...
                    trials_per_block, block_num);
                numera01=(numera==1&denomi01);
                numera_rd=cside(n_done_trials-red_data+1:n_done_trials);
                numera_rd01=(numera_rd==1&denomi_rd01);
            case 'ChoiceR'
                numera=reshape(cside(1:trials_per_block*block_num), ...
                    trials_per_block, block_num);
                numera01=(numera==-1&denomi01);
                numera_rd=cside(n_done_trials-red_data+1:n_done_trials);
                numera_rd01=(numera_rd==-1&denomi_rd01);
        end;
        
        warning off all
        %update blue dot
        if block_num~=0,
        cbl_y=sum(numera01)./sum(denomi01);
        cbl_y(find(sum(denomi01)==0))=NaN;
        set(value(C_bl),'XData',[1:block_num], ...
            'YData',cbl_y);
        else,
            set(value(C_bl),'XData',[],'YData',[]);
        end;
        
        %update red dot
        if trial_rem==0, crd_x=block_num;
        else, crd_x=block_num+1;
        end;
        crd_y=sum(numera_rd01)/sum(denomi_rd01);
        set(value(C_rd),'XData',[crd_x],'YData',[crd_y]);
        
        warning on all
        
        set(value(ax_block_analysis), 'XLim', [0.9 block_num+1.1]);%, 'YLim', [-0.02 1.02]
        
    case 'res_wind_view',
        switch value(ResultWindow)
            case 'hidden', set(value(myfig), 'Visible', 'off');
            case 'view', set(value(myfig), 'Visible', 'on');
        end;

    case 'res_wind_hide',
        ResultWindow.value='hidden';
        set(value(myfig), 'Visible', 'off');

    case 'delete', delete(value(myfig));
        
    case 'block_wind'
        switch value(BlockBasedAnalysis)
            case 'hidden', set(value(myfig2), 'Visible', 'off');
            case 'view', set(value(myfig2), 'Visible', 'on');
        end;
        
    case 'block_wind_hide',
        BlockBasedAnalysis.value='hidden';
        set(value(myfig2), 'Visible', 'off');
        
    case 'delete2', delete(value(myfig2));
        
    case 'latest'
        if strcmp(value(latest),'ON'),
            set([get_ghandle(end_trial); get_lhandle(end_trial)], 'Visible', 'off');
        else, %'OFF'
            set([get_ghandle(end_trial); get_lhandle(end_trial)], 'Visible', 'on');
        end;
    
    case 'color_axis',
        switch value(ColorAxis),
            case 'auto',
                set([get_ghandle(cmin); get_lhandle(cmin)], 'Visible', 'off');
                set([get_ghandle(cmax); get_lhandle(cmax)], 'Visible', 'off');
                set([get_ghandle(cmin_nt);get_lhandle(cmin_nt)], 'Visible', 'off');
                set([get_ghandle(cmax_nt);get_lhandle(cmax_nt)], 'Visible', 'off');
            case 'manual',
                if strcmp(value(Analysis), 'number_trial'),
                    set([get_ghandle(cmin_nt);get_lhandle(cmin_nt)], 'Visible', 'on');
                    set([get_ghandle(cmax_nt);get_lhandle(cmax_nt)], 'Visible', 'on');
                    set([get_ghandle(cmin); get_lhandle(cmin)], 'Visible', 'off');
                    set([get_ghandle(cmax); get_lhandle(cmax)], 'Visible', 'off');
                else,
                    set([get_ghandle(cmin); get_lhandle(cmin)], 'Visible', 'on');
                    set([get_ghandle(cmax); get_lhandle(cmax)], 'Visible', 'on');
                    set([get_ghandle(cmin_nt);get_lhandle(cmin_nt)], 'Visible', 'off');
                    set([get_ghandle(cmax_nt);get_lhandle(cmax_nt)], 'Visible', 'off');
                end;
        end;                
        
    otherwise,
        error(['Don''t know how to deal with action ' action]);
end;


