function output = calcpsychends_SD(obj,midpoint,ratio)

output(1) = sqrt((midpoint^2) / ratio);
output(2) = output(1) * ratio;