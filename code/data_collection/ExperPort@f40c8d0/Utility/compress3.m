% COMPRESS3
% [movie_out, offet, scale] = COMPRESS3(movie_in,type)
% Compress a movie (3 dimensional array x,y,t) into
% (type='uint8','uint16', or 'uint32') representation
function [byteimage, floor, scale] = compress3(rin,type)
    min_mov = min2(min(rin,[],3));
    max_mov = max2(max(rin,[],3));
	switch(type)
	case 'uint8'
        floor = min_mov;
        scale = (2^8)/(max_mov - floor);
        byteimage = uint8((rin-floor)*scale);   
	case 'uint16'
        floor = min_mov;
        scale = (2^16)/(max_mov - floor);
        byteimage = uint16((rin-floor)*scale);   
	case 'uint32'
        floor = min_mov;
        scale = (2^32)/(max_mov - floor);
        byteimage = uint32((rin-floor)*scale);   
	otherwise
        disp('compress: unknown type!')
	end