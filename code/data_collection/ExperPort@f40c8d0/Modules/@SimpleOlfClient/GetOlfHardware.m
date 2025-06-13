% function [carriers, banks] = GetOlfHardware(olf)
%     Returns which carrier/s and bank/s are hooked up to a particular machine.
%     If a new rig is hooked up, add a 'case' for it in the hostname switchyard.
%     Added by GF 12/29/06

function [carriers, banks] = GetOlfHardware(olf)

    % find the name of the machine
    [status, hostname] = system('hostname');
    hostname = lower(hostname);
    hostname = hostname(~isspace(hostname));
    
    switch hostname
      case 'cnmc3' % N1 (upper box)
          carriers = 1;
          banks = [1 2];
      case 'cnmc4' % N0 (lower box)
          carriers = 2;
          banks = [3 4];
          
      case 'corvette' % B1 (upper box)
          carriers = 3;
          banks = [1 2];
          
      case 'transam' % B2 (lower box)
          carriers = 1;
          banks = [3 4];
          
      case 'cnmc7' % C1 (upper box)
          carriers = 3;
          banks = [2 4];
          
      case 'cnmc8' % C2 (lower box)
          carriers = 4;
          banks = [1 3];
          
      case 'cnmc9' % C3 (upper box)
          carriers = 4;
          banks = [3 4];
          
      case 'cnmc10' % C4 (lower box)
          carriers = 3;
          banks = [1 2];
      otherwise % non-olf-associated, or newly hooked up boxes
          error(strcat('Olfactometer is being controlled by unknown rig. See \modules\@SimpleOlfClient\', mfilename));
    end
          
