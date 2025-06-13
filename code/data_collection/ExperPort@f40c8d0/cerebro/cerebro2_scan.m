function output = cerebro2_scan(base,display_text,varargin)

if nargin == 1; display_text = 0; end

warning('off','MATLAB:serial:fscanf:unsuccessfulRead');
output = cell(0);

x=tic;
while toc(x)<3
    if base.BytesAvailable > 0
        output{end+1} = fscanf(base); %#ok<AGROW>
        if display_text == 1
            disp(output{end});
        end
    end
end

warning('on','MATLAB:serial:fscanf:unsuccessfulRead');