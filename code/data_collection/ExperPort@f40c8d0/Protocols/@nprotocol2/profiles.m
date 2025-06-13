function [ ] = profiles(action, len, lim)
% %RANDVECTOR Summary of this function goes here
% %   Detailed explanation goes here
GetSoloFunctionArgs;
% Creates a file in the Waterprofile directory and or Shock profile dir with 'len' number of random
% uniform values between 0 and 1.
% Syntax= profiles(case, length, limit)
% case wsysw = water symmetric switching
% case ssysw = shock symmetric switching
% case wsy = water symmetric but not switching
% case ssy = shock symmetric but not switching
switch action,
    
    case 'wsy',

        vec1 = lim.*rand(len,1);
        vec2=1-vec1;
        path='Protocols\@nprotocol2\WaterProfiles\'; 
        filename='H2O(L)SySw_';%11
        filename2='H2O(R)SySw_';
        numThere=dir('Protocols\@nprotocol2\WaterProfiles\');
        numbox = [];
        for i=1:length(numThere)%:=all of 1st struct = name
            this_name = numThere(i).name;
            if ~isempty(regexp(this_name,filename, 'once' )),    
                numbox = [numbox str2double(this_name(12:end-4))];
            end;
        end;
        if isempty(numbox)
            number=1;
        else
            number=max(numbox)+1;
        end
        extension='.txt';
        vecZero=zeros(len,1);
        vecOne=ones(len,1);
        save([path filename num2str(number) extension], 'vec1', '-ascii');
        save([path filename2 num2str(number) extension], 'vec2', '-ascii');
        save('Protocols\@nprotocol2\WaterProfiles\1.txt', 'vecOne', '-ascii');
        save('Protocols\@nprotocol2\ShockProfiles\0.txt', 'vecZero', '-ascii');
        save('Protocols\@nprotocol2\ShockProfiles\1.txt', 'vecOne', '-ascii');
    case 'ssy',
        vec1 = lim.*rand(len,1);
        vec2=1-vec1;
        path='Protocols\@nprotocol2\ShockProfiles\'; 
        filename='shock(L)SySw_';
        filename2='shock(R)SySw_';
        numThere=dir('Protocols\@nprotocol2\ShockProfiles\');
        numbox = [];
        for i=1:length(numThere)%:=all of 1st struct = name
            this_name = numThere(i).name;
            if ~isempty(regexp(this_name,filename, 'once' )),    
                numbox = [numbox str2double(this_name(14:end-4))];
            end;
        end;
        if isempty(numbox)
            number=1;
        else
            number=max(numbox)+1;
        end
        extension='.txt';
        save([path filename num2str(number) extension], 'vec1', '-ascii');
        save([path filename2 num2str(number) extension], 'vec2', '-ascii');
        
    case 'wsysw',
%         nVecs starts here
        vec1 = lim.*rand(len,1);
        for i=2:2:len
            vec1(i)=1-vec1(i);
        end
        vec2=1-vec1;
%         END of nVecs
%         START of Save to file
        path='Protocols\@nprotocol2\WaterProfiles\'; 
        filename='H2O(L)SySw_';%11
        filename2='H2O(R)SySw_';
        numThere=dir('Protocols\@nprotocol2\WaterProfiles\');
        numbox = [];
        for i=1:length(numThere)%:=all of 1st struct = name
            this_name = numThere(i).name;
            if ~isempty(regexp(this_name,filename, 'once' )),    
                numbox = [numbox str2double(this_name(12:end-4))];
            end;
        end;
        if isempty(numbox)
            number=1;
        else
            number=max(numbox)+1;
        end
        extension='.txt';
        vecZero=zeros(len,1);
        vecOne=ones(len,1);
        save([path filename num2str(number) extension], 'vec1', '-ascii');
        save([path filename2 num2str(number) extension], 'vec2', '-ascii');
        save('Protocols\@nprotocol2\WaterProfiles\1.txt', 'vecOne', '-ascii');
        save('Protocols\@nprotocol2\ShockProfiles\0.txt', 'vecZero', '-ascii');
        save('Protocols\@nprotocol2\ShockProfiles\1.txt', 'vecOne', '-ascii');

    case 'ssysw',
        
        vec1 = lim.*rand(len,1);
        for i=2:2:len
            vec1(i)=1-vec1(i);
        end
        vec2=1-vec1;
        path='Protocols\@nprotocol2\ShockProfiles\'; 
        filename='shock(L)SySw_';
        filename2='shock(R)SySw_';
        numThere=dir('Protocols\@nprotocol2\ShockProfiles\');
        numbox = [];
        for i=1:length(numThere)%:=all of 1st struct = name
            this_name = numThere(i).name;
            if ~isempty(regexp(this_name,filename, 'once' )),    
                numbox = [numbox str2double(this_name(14:end-4))];
            end;
        end;
        if isempty(numbox)
            number=1;
        else
            number=max(numbox)+1;
        end
        extension='.txt';
        save([path filename num2str(number) extension], 'vec1', '-ascii');
        save([path filename2 num2str(number) extension], 'vec2', '-ascii');    
       
    case 'allrnd',
        profiles('waterLeft', len);
        profiles('waterRight', len);
        profiles('shockLeft', len);
        profiles('shockRight', len);
    
    case 'waterrnd',        
        profiles('waterLeft', len);
        profiles('waterRight', len);
        
    case 'shockrnd',      
        profiles('shockLeft', len);
        profiles('shockRight', len);
        
    case 'waterleft',
        vec1=rand(len,1);
        path='Protocols\@nprotocol2\WaterProfiles\'; 
        filename='waterLeft_';
        numThere=dir('Protocols\@nprotocol2\WaterProfiles\');
        numbox = [];
        for i=1:length(numThere)%:=all of 1st struct = name
            this_name = numThere(i).name;
            if ~isempty(regexp(this_name,filename, 'once' )),    
                numbox = [numbox str2double(this_name(11:end-4))];
            end;
        end;
        if isempty(numbox)
            number=1;
        else
            number=max(numbox)+1;
        end
        extension='.txt';
        save([path filename num2str(number) extension], 'vec1', '-ascii');
        
    case 'waterright',
        vec1=rand(len,1);
        path='Protocols\@nprotocol2\WaterProfiles\'; 
        filename='waterRight_';
        numThere=dir('Protocols\@nprotocol2\WaterProfiles\');
        numbox = [];
        for i=1:length(numThere)%:=all of 1st struct = name
            this_name = numThere(i).name;
            if ~isempty(regexp(this_name,filename, 'once' )),    
                numbox = [numbox str2double(this_name(12:end-4))];
            end;
        end;
        if isempty(numbox)
            number=1;
        else
            number=max(numbox)+1;
        end
        extension='.txt';
        save([path filename num2str(number) extension], 'vec1', '-ascii');        

    case 'shockleft',
        vec1=rand(len,1);
        path='Protocols\@nprotocol2\ShockProfiles\'; 
        filename='shockLeft_';
        numThere=dir('Protocols\@nprotocol2\ShockProfiles\');
        numbox = [];
        for i=1:length(numThere)%:=all of 1st struct = name
            this_name = numThere(i).name;
            if ~isempty(regexp(this_name,filename, 'once' )),    
                numbox = [numbox str2double(this_name(11:end-4))];
            end;
        end;
        if isempty(numbox)
            number=1;
        else
            number=max(numbox)+1;
        end
        extension='.txt';
        save([path filename num2str(number) extension], 'vec1', '-ascii');
        
    case 'shockright',
        vec1=rand(len,1);
        path='Protocols\@nprotocol2\ShockProfiles\'; 
        filename='shockRight_';
        numThere=dir('Protocols\@nprotocol2\ShockProfiles\');
        numbox = [];
        for i=1:length(numThere)%:=all of 1st struct = name
            this_name = numThere(i).name;
            if ~isempty(regexp(this_name,filename, 'once' )),    
                numbox = [numbox str2double(this_name(12:end-4))];
            end;
        end;
        if isempty(numbox)
            number=1;
        else
            number=max(numbox)+1;
        end
        extension='.txt';
        save([path filename num2str(number) extension], 'vec1', '-ascii');
end;