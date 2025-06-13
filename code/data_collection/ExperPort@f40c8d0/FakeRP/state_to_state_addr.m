function state_addr = state_to_state_addr(state)    % made by Gonzalo

% takes the normal state matrix and expands it into the full state addresss
% matrix 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%create matrix of indexes
columns = 7;
rows=size(state,1);  % number of states (rows)

% we now define the ram matrix
state_addr=zeros(1,rows*128);

% The matrix should be "stable", if no input , it should stay in the same state
state_addr(1:128:(rows*128))=(1:rows)-1;

%             Cin Cout Lin Lout Rin Rout TimeUp
channel_value=[1    2   4    8   16  32   64];

for i=1:rows
    for j=1:columns
        if j==7
            addr_index=[1    2   4    8   16  32 0]+channel_value(j)+(i-1)*128; % If TimeUp alone, or *together* with another
                                                                                % event, we will do what we would have done for TimeUp
        else
            addr_index=(i-1)*128+channel_value(j); 
        end
        state_addr(addr_index+1)=state(i,j);        
    end
end


