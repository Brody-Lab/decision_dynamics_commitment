function out = gray_plus_red
% a colormap that's gray but red at saturation
	gray = (0:255)/255;
	out = repmat(gray',1,3);
	out(256,:) = [1 0 0];
