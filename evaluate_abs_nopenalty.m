% 计算到截止日期,完全不考虑项目的完成概率
function [expected_obj,time_pro,schedule]=evaluate_abs_nopenalty(AL,rep,implement,req,resNumber,nrpr,pred,nrsu,su,deadline,resNo,actNo,stochatic_d)
% 满足截止日期的次数
p=0;
% 总的目标函数值
obj=0;
% 随机工期数据
index=1:rep;
duration_data=stochatic_d(index,:);
% 计算每个工期下的目标函数值
for i=1:rep
    d=duration_data(i,:);
%  解码生成进度计划
    [schedule,u_kt]=stochastic_SSGS_1(AL,implement,req,resNumber,d,nrpr,pred,deadline,resNo);
    u_kt1=u_kt(:,1:schedule(actNo));
    % 判断进度计划是否可行、资源可行
    if scheduleFeasible(schedule,actNo,nrsu,su,implement,d)==1 && resourceFeasible(u_kt1,resNumber)==1 
        if schedule(actNo)<=deadline
            % 统计及时完成的次数
            p=p+1;
        end
        for k=1:resNo
            for t=2:schedule(actNo)+1
                if u_kt(k,t)-u_kt(k,t-1)<0
                    temp = u_kt(k,t-1)-u_kt(k,t);
                else
                    temp = u_kt(k,t)-u_kt(k,t-1);
                end
                obj=obj+temp;
            end
            obj = obj+u_kt(k,1);
        end % 资源类型
    end
end %  情景数
expected_obj=obj/rep;
time_pro=p/rep;
                