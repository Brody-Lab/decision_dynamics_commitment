function training_room_status_wrapper

while 1
    x = now;
    
    training_room_status;
    
    pause( 60 - ((now-x) * 24 * 3600) )
end