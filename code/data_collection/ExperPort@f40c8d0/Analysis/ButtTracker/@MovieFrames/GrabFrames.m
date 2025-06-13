function GrabFrames(obj,frameinds)

%
% GrabFrames(frameinds)
%

try
  cdir=pwd;
  [vid obj.Frames]=my_mmread(obj.MovieName,frameinds,obj.IsGPU,obj.DataType);
  obj.FrameTimes=vid.times;
  obj.NFrames=numel(obj.Frames);
  obj.FrameInds=frameinds;
catch exception
  cd(cdir);
  disp(exception.message);
end