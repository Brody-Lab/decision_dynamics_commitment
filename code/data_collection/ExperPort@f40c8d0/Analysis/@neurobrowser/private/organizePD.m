function [tt,bm]=organizePD(pd)

if strcmp(pd,'NULL')
    tt={''};
    bm={''};
    return;
end

if isfield(pd,'helper')
	tt=pd.helper(1,:);
	bm=pd.helper(2,:);
elseif strcmp(pd,'NULL')
	tt={};
	bm={};

else

	tt={};
	bm={};
	fdn=fieldnames(pd);
	for fx=1:numel(fdn)
		fn=fdn{fx};
		try
			if iscell(pd.(fn))
				pd.(fn)=cell2mat(pd.(fnn));
			end

			if numel(unique(pd.(fn)))<10
				tt=[tt fn];
			else
				bm=[bm fn];
			end
		catch
			warning('neurobrowser:organizePD',['Failed to determine category of ' fn])
		end
	end
end