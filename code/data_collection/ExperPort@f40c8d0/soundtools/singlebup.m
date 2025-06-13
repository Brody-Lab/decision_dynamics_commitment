% [snd] = singlebup(srate, att, { 'width', 5}, {'ramp', 2}, {'basefreq', 2000}, ...
%                   {'ntones' 5}, {'PPfilter_fname', ''});  ...
     
% TZL, Dec 2018:    - a vector of tones can be specified
%                   - hard coded attentuation can be ignored

function [snd] = singlebup(srate, att, varargin)
   
   pairs = { ...
     'width',            5    ;  ...
     'ramp',             2    ;  ...
     'basefreq'          2000 ;  ...
     'ntones'            4    ;  ...
     'PPfilter_fname'   ''    ; ...
     'tones',            []   ; ...
   }; parseargs(varargin, pairs);
   
    if ~isempty(PPfilter_fname)
        warning('attenuation filter no longer used!')
    end
   
   width = width/1000;
   ramp = ramp/1000;
   if att == 0
       %This was calibrated on 2017-12-14 such that RigTester sound from
       %both speakers together produced a sound ~90dB when the amp was 
       %set to 50% and ntones was reduced from 5 to 4 so that all
       %frequencies are within human and rat hearing range
       att = 40;
   else
       warning('Attenuation value has been calibrated to work when att input is set to 0. Otherwise you are on your own');
   end
   
   t = 0:(1/srate):width;

   snd = zeros(size(t));
   
   tones = unique(tones);
   if ~isempty(tones) && all(tones > 0)
       for i=1:numel(value(tones))
          attenuation = att;% - ppval(PP, log10(f));
          snd = snd + (10.^(-attenuation./20)) .* sin(2*pi*tones(i)*t);
       end
   else
       for i=1:ntones
          f = basefreq*(2.^(i-1));
          attenuation = att;% - ppval(PP, log10(f));
          snd = snd + (10.^(-attenuation./20)) .* sin(2*pi*f*t);
       end
   end

   if max(abs(snd)) >= 1, snd = snd/(1.01*max(abs(snd))); end
   
   rampedge=MakeEdge(srate, ramp); ramplen = length(rampedge);
   snd(1:ramplen) = snd(1:ramplen) .* fliplr(rampedge);
   snd(end-ramplen+1:end) = snd(end-ramplen+1:end) .* rampedge;

   return;
   

% -------------------------------------------------------------
%
%
%
% -------------------------------------------------------------

    

function [envelope] = MakeEdge(srate, coslen)

    t = (0:(1/srate):coslen)*pi/(2*coslen);
    envelope = (cos(t)).^2;
    return;
       