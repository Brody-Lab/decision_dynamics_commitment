function EstimateBackground(obj,nrandframes,israndomsample)

%
% EstimateBackground(nrandframes,israndomsample)
%

if nargin<3, israndomsample=true; end

if israndomsample
  randframenos=sort(floor(rand(1,nrandframes)*obj.NumberOfFrames)+1);
else
  randframenos=1:nrandframes;
end
[garb randframes]=my_mmread(obj.MovieName,randframenos,obj.IsGPU,obj.DataType);

obj.Background=randframes{1}*0;
for k=1:nrandframes, obj.Background=obj.Background+randframes{k}; end
obj.Background=obj.Background/nrandframes;