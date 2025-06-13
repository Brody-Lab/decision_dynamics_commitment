function stop_training_room_status

TrainingRoomStatusTimer = timerfind('Tag','TrainingRoomStatusTimer');

if ~isempty(TrainingRoomStatusTimer)
    disp('Stopping TrainingRoomStatusTimer...');
    stop(TrainingRoomStatusTimer);
    disp('Deleting TrainingRoomStatusTimer...');
    delete(TrainingRoomStatusTimer);
    disp('COMPLETE');
end