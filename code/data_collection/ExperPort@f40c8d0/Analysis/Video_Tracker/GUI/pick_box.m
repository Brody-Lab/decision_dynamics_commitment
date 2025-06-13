function box = pick_box(box_0, head, L)
% returns a square box of side L around the head location of given in the
% argument,

x         = head(1);
y         = head(2);
theta     = head(3);
x_dot     = head(4);
y_dot     = head(5);
theta_dot = head(6);

if ~isnan(x),
    box = [x-L/2 y-L/2 L L];
else
    box = box_0;
end;