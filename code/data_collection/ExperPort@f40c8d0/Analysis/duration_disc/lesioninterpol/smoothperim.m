function bw = smoothperim(bw)

done = 0;
cnt = 0;

while done == 0
    
    s = find(bw == 1);
    removedpoint = [];
    
    for p = 1:length(s)

        [i,j] = ind2sub(size(bw),s(p));
        temp = [bw(i-1,j-1),bw(i,j-1),bw(i+1,j-1),bw(i-1,j),bw(i,j),bw(i+1,j),bw(i-1,j+1),bw(i,j+1),bw(i+1,j+1)];  

        if     (temp(1)==1 && temp(4)==1) && sum(temp([3 6 9]))==0; bw(i,j) = 0; removedpoint = [i j];  
        elseif (temp(4)==1 && temp(7)==1) && sum(temp([3 6 9]))==0; bw(i,j) = 0; removedpoint = [i j]; 
        elseif (temp(7)==1 && temp(8)==1) && sum(temp([1 2 3]))==0; bw(i,j) = 0; removedpoint = [i j]; 
        elseif (temp(8)==1 && temp(9)==1) && sum(temp([1 2 3]))==0; bw(i,j) = 0; removedpoint = [i j]; 
        elseif (temp(9)==1 && temp(6)==1) && sum(temp([1 4 7]))==0; bw(i,j) = 0; removedpoint = [i j]; 
        elseif (temp(6)==1 && temp(3)==1) && sum(temp([1 4 7]))==0; bw(i,j) = 0; removedpoint = [i j]; 
        elseif (temp(3)==1 && temp(2)==1) && sum(temp([7 8 9]))==0; bw(i,j) = 0; removedpoint = [i j]; 
        elseif (temp(2)==1 && temp(1)==1) && sum(temp([7 8 9]))==0; bw(i,j) = 0; removedpoint = [i j]; 
        end

        if sum(temp([1:4 6:9])) == 1; bw(i,j) = 0; removedpoint = [i j]; end

    end
    cnt = cnt + 1;
   % disp(removedpoint);
    if isempty(removedpoint); done = 1; end
    if cnt >= 10;             done = 1; end
end