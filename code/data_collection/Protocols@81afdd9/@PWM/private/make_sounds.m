% Emily Jane Dennis Nov 2018
% made as part of overhaul and generalization of AthenaDelayComp
% also inspired by PBups

function         [AUD1,AUD2] = make_sounds(sigma_1,sigma_2,lfreq,hfreq,T1,T2,AUD1_length,AUD2_length,AUD1_pitch,AUD2_pitch,AUD1_loudness,AUD2_loudness,fcut,Fs,comparison_type,sound_type,filter_type);
% function [soundvolume,soundfreq,soundlength,base,target,normbase,normtarget]=make_sounds(sigma_1,sigma_2,T,fcut,Fs,comparison_type,sound_type,filter_type)
% function [snd,lrate,rrate,data] = make_pbup(total_rate, gamma, srate, T, varargin)
% function [base,target,normbase,normtarget]=noisestim(sigma_1,sigma_2,T,fcut,Fs,filter_type)
% function [normbase]=singlenoise(sigma_1,T,fcut,Fs,filter_type)

% --------- INPUTS:
%  
% sigma_1           ????? always 1
% sigma_2           ????? always 1
% T1                total time (in sec) of stimulus 1 to be generated
% T2                total time (in sec) of stimulus 2 to be generated
% AUD1_length       should be the same as T1
% AUD2_length       should be the same as T2
% AUD1_pitch       	frequency of pure tone in stimulus 1
% AUD2_pitch        frequency of pure tone in stimulus 2    	
% AUD1_loudness     
% AUD1_loudness       	
% Fs,srate          sample rate
% comparison_type   type of comparison of S1/S2
% sound_type        sound type generated in S1/S2
% 
% --------- OUTPUTS:
% AUD1
% AUD2
% --------- 

        if strcmp(sound_type, 'tone');
            [AUD1,AUD2]=tonestim(T1,T2,AUD1_loudness,AUD2_loudness,AUD1_pitch,AUD2_pitch,Fs);      % elseif strcmp(sound_type, 'clicks')
            % would like to have this use pbups to compare clickfreqs
            % play in stereo
            % if duration same pitch, different
      
        elseif strcmp(sound_type,'pink');
                [normAUD1,normAUD2]=newnoisestim(1,1,T1,T2,value(fcut),Fs,value(filter_type));
                modulator1=singlenoise(1,T1,[value(lfreq) value(hfreq)],Fs,'BUTTER');
                modulator2=singlenoise(1,T2,[value(lfreq) value(hfreq)],Fs,'BUTTER');
                AUD1=normAUD1(1:(AUD1_length*Fs)).*modulator1(1:AUD1_length*Fs).*AUD1_loudness;
                AUD2=normAUD2(1:AUD2_length*Fs).*modulator2(1:AUD2_length*Fs).*AUD2_loudness;
        else
            error('make_souds does not know what sound to make something went wrong in %s',mfilename);
        end
%% from SoundDiscrimination to get variably aligned sounds within dur      
%                 if     strcmp(value(SoundLoc),'Early')        == 1; temploc = 1;
%         elseif strcmp(value(SoundLoc),'Center')       == 1; temploc = 2;   
%         elseif strcmp(value(SoundLoc),'Late')         == 1; temploc = 3; 
%         elseif strcmp(value(SoundLoc),'Early/Center') == 1; temploc = [1 2];  
%         elseif strcmp(value(SoundLoc),'Center/Late')  == 1; temploc = [2 3];   
%         elseif strcmp(value(SoundLoc),'Early/Late')   == 1; temploc = [1 3];
%         else                                                temploc = [1 2 3];
%         end
%         loc = temploc(randperm(length(temploc)));
%         loc_history.value = [loc_history(:); loc(1)]; %#ok<NODEF>
%         if     loc(1) == 1 || Sdur+0.01 > value(NICDur); silence = 0.01;
%         elseif loc(1) == 2;                       silence = (value(NICDur) - Sdur) / 2;
%         else                                      silence = value(NICDur) - (Sdur + 0.01);
%         end
%         
end

