function p = traceboundary(bw)

s = find(bw == 1);
p = zeros(length(s),2);
[i,j] = ind2sub(size(bw),s(1));
foundlast = 0;
c = 1;
p(c,:) = [i j];
bw(i,j) = 0;

while foundlast == 0
    c=c+1;
    
    temp = [bw(i-1,j-1) bw(i-1,j) bw(i-1,j+1);...
            bw(i  ,j-1) bw(i  ,j) bw(i  ,j+1);...
            bw(i+1,j-1) bw(i+1,j) bw(i+1,j+1)];

    np = find(temp == 1);
    if length(np) > 1
        a = find(np == 2 | np == 4 | np == 6 | np == 8);
        if ~isempty(a)
            np = np(a(1));
        else
            a = find(np == 1 | np == 3 | np == 7 | np == 9);
            np = np(a(1));
        end
    end
    if isempty(np); break; end
    if     np == 1; p(c,:) = [i-1,j-1]; %op = 9;
    elseif np == 2; p(c,:) = [i  ,j-1]; %op = 8;
    elseif np == 3; p(c,:) = [i+1,j-1]; %op = 7;
    elseif np == 4; p(c,:) = [i-1,j  ]; %op = 6;
    elseif np == 6; p(c,:) = [i+1,j  ]; %op = 4;
    elseif np == 7; p(c,:) = [i-1,j+1]; %op = 3;
    elseif np == 8; p(c,:) = [i  ,j+1]; %op = 2;
    elseif np == 9; p(c,:) = [i+1,j+1]; %op = 1;
    else   foundlast = 1;
    end
    
    i  = p(c,1);
    j  = p(c,2);
    
    if i == 0 || j == 0; p = p(1:end-1,:); break; end

    np = [];
    bw(i,j) = 0;
    
    if c == length(s); foundlast = 1; end
end

zpnts = find(p(:,1)==0 | p(:,2)==0);
for t = 1:length(zpnts)
    if zpnts(t) ~= 1
        p(zpnts(t),:) = p(zpnts(t)-1,:);
    else
        p(zpnts(t),:) = p(zpnts(t)+1,:);
    end
end
