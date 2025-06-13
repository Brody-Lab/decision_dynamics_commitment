% set optical ratio to an byte ('uint8','uint16', or 'uint32') representation of image
function [byteimage, floor, scale] = compress(rin,type)
	switch(type)
	case 'uint8'
        floor = min2(rin);
        scale = (2^8)/(max2(rin) - rout.floor);
        byteimage = uint8((rin-rout.floor)*rout.scale);   
	case 'uint16'
        floor = min2(rin);
        scale = (2^16)/(max2(rin) - rout.floor);
        byteimage = uint16((rin-rout.floor)*rout.scale);   
	case 'uint32'
        floor = min2(rin);
        scale = (2^32)/(max2(rin) - rout.floor);
        byteimage = uint32((rin-rout.floor)*rout.scale);   
	otherwise
        disp('compress: unknown type!')
	end