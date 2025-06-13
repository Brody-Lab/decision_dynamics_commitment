function v=reduce_frames(v)

%
% v=reduce_frames(v)
%   Takes mmread video output v and replaces all v.frames(:).cdata with only
%   single channel information.  That is, v.frames(n).cdata goes from a
%   HEIGHTxWIDTHx3 matrix to a HEIGHTxWIDTH matrix.
% 
% keyboard
nframes=numel(v.frames);
for n=1:nframes
  v.frames(n).cdata=v.frames(n).cdata(:,:,1);
end
v.frames={v.frames(:).cdata};