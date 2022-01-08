function [lst, lft ] = backward_all_raw( projRelation, duration, lftn,implement)
act=length(duration);
lst = zeros(act,1);
lft = zeros(act,1);
lst(act)=lftn;
lft(act)=lftn;
for i=act-1:-1:1
    min_s = lftn;
    % 活动i的紧后活动
    for s=2:projRelation(i,1)+1
        b=projRelation(i,s);
        if implement(b)==1
            if lst(b)<min_s
                min_s = lst(b);
            end
        end
    end
    lst(i) = min_s-duration(i);
end
