% set optical ratio to an byte ('uint8','uint16', or 'uint32') representation of image
function rout = compress(rin,type)
	switch(type)
	case 'uint8'
        rout.floor = min2(rin);
        rout.scale = (2^8)/(max2(rin) - rout.floor);
        rout.byteimage = uint8((rin-rout.floor)*rout.scale);   
	case 'uint16'
        rout.floor = min2(rin);
        rout.scale = (2^16)/(max2(rin) - rout.floor);
        rout.byteimage = uint16((rin-rout.floor)*rout.scale);   
	case 'uint32'
        rout.floor = min2(rin);
        rout.scale = (2^32)/(max2(rin) - rout.floor);
        rout.byteimage = uint32((rin-rout.floor)*rout.scale);   
	otherwise
        disp('compress: unknown type!')
	end