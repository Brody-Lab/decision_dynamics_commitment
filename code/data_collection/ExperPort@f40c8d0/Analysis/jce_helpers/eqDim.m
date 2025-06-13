function y=eqDim(m1, m2)
    
    a=size(m1);
    b=size(m2);
    y=(a(1)==b(1)) && (a(2)==b(2));