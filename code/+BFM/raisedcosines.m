function Phi = raisedcosines(centers, Delta_centers, y)
    Phi = (cos(max(-pi, min(pi, (y'-centers)*pi/Delta_centers/2))) + 1)/2;
end