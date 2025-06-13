function test_video_stream

vlc_path = bSettings('get','VIDEO','vlc_path');
stream_string = bSettings('get','VIDEO','stream_string');

cd(vlc_path);
system(['vlc -vvv ',stream_string,' &']);