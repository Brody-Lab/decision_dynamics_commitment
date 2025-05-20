function C = colors()
% COLORS Default colors associated with task conditions or model settings
%
% C = COLORS() returns a structure whose name of each field is the name of a task condition or model
% setting, and the value of that field is a three-element array specifying the intensity of the red,
% green, and blue component of the color.
C = struct;
C.unconditioned = [0,0,0];
C.leftchoice = [0.229999504, 0.298998934, 0.754000139];
C.rightchoice = [0.706000136, 0.015991824, 0.150000072];
C.leftevidence = C.leftchoice;
C.rightevidence = C.rightchoice;
C.leftchoice_weak_leftevidence = [0.667602712               0.779706789               0.993625576];
C.leftchoice_strong_leftevidence = C.leftchoice;
C.rightchoice_weak_rightevidence = [0.968998399               0.721381489               0.612361865];
C.rightchoice_strong_rightevidence = C.rightchoice;
C.dmFC = [0                     0.447                     0.741];
C.mPFC = [0.85                     0.325                     0.098];
C.dStr = [0.929                     0.694                     0.125];
C.M1 = [0.494                     0.184                     0.556];
C.vStr = [0.466                     0.674                     0.188];
C.FOF = [0.635                     0.078                     0.184];
C.evidenceaccumulation = [0.4588    0.4392    0.7020];
C.choicemaintenance = [0.1059    0.6196    0.4667];
C.halorhodopsin = [0.9569    0.4824    0.1255];
C.opto = C.halorhodopsin;
C.ctrl = zeros(1,3);
C.intrinsic = zeros(1,3);
C.leftinput = C.leftchoice;
C.rightinput = C.rightchoice;
C.input = [0.6941    0.4314    0.2745];
C.nTc = [0.8039    0.4000    0.1961];
C.pred = [0.0510    0.5373    0.2667];
C.obsv = [0,0,0];