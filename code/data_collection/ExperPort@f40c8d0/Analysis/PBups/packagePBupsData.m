function parsedProtocolData = packagePBupsData(rat,dates,varargin)
    p=inputParser;
    p.PartialMatching=false;
    p.addRequired('rat',@(x)validateattributes(x,{'cell','char','struct'},{'nonempty'}));
    p.addRequired('dates',@(x)validateattributes(x,{'numeric','cell','char'},{'nonempty'}));
    p.addParameter('byRat',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.parse(rat,dates,varargin{:});
    params=p.Results;
    %%
    protocol_data = getProtocolData(rat,dates,'PBups.*','byRat',params.byRat,'getPeh',true);
    %% parse protocol data (extract relevant fields)
    for i=1:length(protocol_data)
        parsedProtocolData(i) = parseProtocolData(protocol_data(i),varargin{3:end},'protocol','PBups.*');   
    end
end