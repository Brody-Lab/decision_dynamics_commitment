function stop_room_turnover_indicator

timerexists = timerfind('Tag','RoomTurnoverIndicatorTimer');

if ~isempty(timerexists)
    disp('Stopping RoomTurnoverIndicatorTimer...');
    stop(timerexists);
    disp('Deleting RoomTurnoverIndicatorTimer...');
    delete(timerexists);
    disp('COMPLETE');
end