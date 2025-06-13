function filtered = filterArray(array,filter,boundary,ignorenan,domain)
    if nargin<5
        domain='spatial';
    if nargin<4
        ignorenan=false;
        if nargin<3
            boundary='';
            if nargin<2
                error('Not enough input arguments.');
            end
        end
    end
    end
    %% check sizes
    filterDim=ndims(filter);
    arrayDim=ndims(array);
    filterSize=size(filter);
    arraySize=size(array);
    hasnans=any(isnan(array(:)));            
    if arrayDim~=filterDim
        error('array must have same numer of dimensions as the filter.');
        
        
    end
    sizeDiff=arraySize-filterSize;     
    %%
    switch domain
        case 'spatial' % if boundary is not circular. this is probably faster calling conv directly, even if circular might be fast using padarray with circular boundary conditions
            switch filterDim
                case 1
                    convfun=@conv;
                case 2
                    convfun=@conv2;
                otherwise
                    convfun=@convn;
            end           
            if strcmp(boundary,'circular')
                arrayPadded = CircularPad(array,filterSize/2,filterDim,arraySize);
                filtered = convfun(arrayPadded,filter,'valid');                
            else
                filtered=convfun(array,filter,'same') ./ convfun(ones(arraySize,'like',array),filter,'same');
            end                
            %arrayPadded = padarray(padarray(array,ceil(filterSize/2)-1,'circular','pre'),floor(filterSize/2),'circular','post'); % this is rate limiting step, could speed up by optimizing padarray_small
%             if ignorenan && (hasnans || isnan(boundary))
%                 arrayZr=array;
%                 arrayZr(isnan(array))=0;
%                 if isnan(boundary)
%                     boundary=0;
%                 end
%                 filtered=imfilter(arrayZr,filter,boundary,'conv') ./ ...
%                     filterim(double(~isnan(array)),filter,boundary,'conv');
%             else
%                 filtered=imfilter(array,filter,boundary,'conv');                
%             end
        case 'frequency'   
            if any(arraySize<filterSize)
                error('Array must be larger than filter in each dimension.');
            end            
            switch filterDim
                case 1
                    fftfun=@fft;
                    ifftfun=@ifft;
                case 2
                    fftfun=@fft2;
                    ifftfun=@ifft2;                    
                otherwise
                    fftfun=@fftn;
                    ifftfun=@ifftn;                    
            end
            if isnumeric(boundary)
                % pad them both up to m+n-1 i think
                % not written yet
            elseif strcmp(boundary,'circular')
                paddedFilter = padarray_small(padarray_small(filter,ceil(sizeDiff/2),'pre',filterSize),floor(sizeDiff/2),'post',filterSize+ceil(sizeDiff/2));
                if ignorenan && hasnans 
                    arrayZr=array;
                    arrayZr(isnan(array))=0;                
                    filtered = circshift_fast( ...
                        ifftfun(fftfun(arrayZr).*fftfun(paddedFilter)), ... % do the Fourier domain multiplication
                        ceil(arraySize./2)-(isodd(arraySize)&iseven(filterSize))) ... % variable fft shift amount
                        ./ ... % normalization
                        circshift_fast( ...
                        ifftfun(fftfun(double(~isnan(array))).*fftfun(paddedFilter)),... % do the Fourier domain multiplication
                        ceil(arraySize./2)-(isodd(arraySize)&iseven(filterSize))); % variable fft shift amount
                else
                    filtered = circshift_fast(...
                        ifftfun(fftfun(array).*fftfun(paddedFilter)),... % do the Fourier domain multiplication
                        ceil(arraySize./2)-(isodd(arraySize)&iseven(filterSize))); % variable fft shift amount
                end
            end 
    end
end



function b = CircularPad(a, padSize, numDims, aSize)
    % does prepadding on an array to do circular convolution with a filter
    idx   = cell(1,numDims);
    for k = 1:numDims
      dimNums = 1:aSize(k);
      idx{k}   = dimNums(mod((1-ceil(padSize(k))):aSize(k)+floor(padSize(k))-1, aSize(k)) + 1);
    end
    b = a(idx{:});
end

function b = ZeroPad(a, padSize, numDims)
    % Form index vectors to subsasgn input array into output array.
    % Also compute the size of the output array.
    idx   = cell(1,numDims);
    sizeB = zeros(1,numDims);
    for k = 1:numDims
        M = size(a,k);
        idx{k}   = (1:M) + ceil(padSize(k))-1;
        sizeB(k) = M + 2*padSize(k)-1;
    end
    b=zeros(sizeB,'like',a);
    b(idx{:}) = a;
end