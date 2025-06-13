% retrieve optical ratio as a floating (double) representation
function rout = expand(rin)
	rout = (double(rin.byteimage)/rin.scale)+rin.floor;