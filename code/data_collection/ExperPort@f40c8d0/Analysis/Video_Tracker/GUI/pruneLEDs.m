function LED = pruneLEDs(LED, live, radius)

if live(2) == 1,  % if there's a green LED
    D = pdist([LED(1,1).x LED(1,1).y; ...
               LED(2,1).x LED(2,1).y]);
    if D < radius,
        LED(2,1) = assignLED([]);
    else
        D = pdist([LED(3,1).x LED(3,1).y; ...
                   LED(2,1).x LED(2,1).y]);

