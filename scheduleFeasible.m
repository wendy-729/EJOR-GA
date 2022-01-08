function[feasible]=scheduleFeasible(schedule,act,nrsu,su,implement,duration)
% 判断生成的进度计划是否可行
feasible=0;
f=zeros(1,act);
len=length(find(implement(1:act)==1));
% disp(len)
for i=1:act-1
    if implement(i)==1
%         disp(i)
        for j=1:nrsu(i)
%             disp(j)
            if implement(su(i,j))==1
                % 活动i的紧后活动的开始时间大于活动i的开始时间
                if schedule(su(i,j))>=schedule(i)+duration(i)
%                 if schedule(su(i,j))-schedule(i)>=weight(i,j)
                    f(su(i,j))=1;
%                 else
%                     disp(schedule)
%                     disp(i)
%                     disp(su(i,:))
%                     disp(schedule(i))
%                     disp(su(i,j))
%                     disp(schedule(su(i,j)))
%                     disp(duration(i))
%                     disp('--------')
                end
            end
        end
    end
end
f(1) = 1;
f(act) = 1;
% disp(sum(f))
% disp(len)
if sum(f)==len
    feasible=1;
end
    