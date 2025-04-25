function Specs = specify_flows
% Return a `struct` whose fields are parameters for plotting flow fields
Specs.colormap.intrinsic = 'gray';
Specs.colormap.input = 'copper';
Specs.colormap.difference = M23a.colormap_for_speed_difference;
Specs.Delta = 0.2;
Specs.Delta_scale.intrinsic = 1;
Specs.Delta_scale.leftinput = 2;
Specs.Delta_scale.rightinput = 2;
Specs.Delta_scale.input = Specs.Delta_scale.leftinput;
Specs.linewidth = 1;
Specs.xlim = [-1,1];
Specs.ylim = 0.6*[-1,1];
Specs.hypotheses = ["bistable", "DDM1", "RNN"];
Specs.quiverscale.intrinsic = 0.9;
Specs.quiverscale.leftinput = 0.5;
Specs.quiverscale.rightinput = 0.5;
Specs.quiverscale.input = Specs.quiverscale.leftinput;