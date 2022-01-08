function elig=feasibleact_new(al,nrpr,pred,actNo,implement)
% 根据AL里面的活动计算合格活动
%【合格活动中包含未实施活动】
elig=[];
actSet=1:actNo;
same=ismember(actSet,al);

% 未调度的活动
unschedule=actSet(~same);
for i=1:length(unschedule)
    act=unschedule(i);
    % 活动不执行
    if implement(act)==0
        % 判断所有执行的紧前活动是否都已经调度
        flag=1;
        for j=1:nrpr(act)
            p=pred(act,j);
            % 紧前活动执行且不在AL中则不满足
            if implement(p)==1
                % 紧前活动没有在活动列表中
                if any(p==al)==0
                    flag=0;
                    break
                end
            end
        end
        % 所有的紧前活动都已经调度
        if flag==1 
            elig=[elig act];
        end
    else
        % 是执行活动
        flag_implement=1;
        % 所有紧前活动在活动列表中
        for j=1:nrpr(act)
            p=pred(act,j);
            if implement(p)==0
                continue;
            else
                if any(p==al)==0
                    flag_implement=0;
                    break
                end
            end
        end
        if flag_implement==1
            elig=[elig act];
        end
    end
end
    
        