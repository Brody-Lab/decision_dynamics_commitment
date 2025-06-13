%% Test whether valves are good
%% 1/12/06

clear;

%% Change these values as needed for the particular olfactometer
olf_ip = '192.168.0.211';
%num_banks = 4;
%num_valves = 16;
num_banks = 2;
num_valves = 3;

airflow_mat = zeros(num_banks, num_valves);

olf = SimpleOlfClient(olf_ip);

for bank_ind = 1:num_banks
    
    for valve_ind = 0:(num_valves - 1);
    
        Write(olf, strcat('Bank', num2str(bank_ind), '_Valves'), valve_ind);
        
        pause(2);
        
        airflow_mat(bank_ind, (valve_ind + 1)) = Read(olf, strcat('BankFlow', num2str(bank_ind), '_Sensor'));

    end
    
    % set open valve back to 0 for this bank
    
    Write(olf, strcat('Bank', num2str(bank_ind), '_Valves'), 0);
    
end