% ���㵽����ֹ����гͷ�
function [expected_obj,time_pro,schedule]=evaluate_abs(AL,rep,implement,req,resNumber,nrpr,pred,nrsu,su,deadline,resNo,actNo,stochatic_d)
% �����ֹ���ڵĴ���
p=0;
% �ܵ�Ŀ�꺯��ֵ
obj=0;

% ���ѡȡrep����������
index=1:rep;
duration_data=stochatic_d(index,:);
% ����ÿ�������µ�Ŀ�꺯��ֵ
for i=1:rep
    d=duration_data(i,:);
%  ���� ���ɽ��ȼƻ�
    [schedule,u_kt]=stochastic_SSGS_1(AL,implement,req,resNumber,d,nrpr,pred,deadline,resNo);
    % ����Ƿ񳬹�deadline
    flag = 0;
    u_kt1=u_kt(:,1:schedule(actNo));
    % �жϽ��ȼƻ��Ƿ���С���Դ���С���ʱ�����Ŀ
    if scheduleFeasible(schedule,actNo,nrsu,su,implement,d)==1 && resourceFeasible(u_kt1,resNumber)==1 
        if schedule(actNo)<=deadline
            % ͳ�Ƽ�ʱ��ɵĴ���
            p=p+1;
        else
            flag = 1;
        end
        % �龰�µ�Ŀ�꺯��
        scen_obj = 0;
        % ����Ŀ�꺯��ֵ
        if flag ==0
            for k=1:resNo
                for t=2:schedule(actNo)+1
                    if u_kt(k,t)-u_kt(k,t-1)<0
                        temp = u_kt(k,t-1)-u_kt(k,t);
                    else
                        temp = u_kt(k,t)-u_kt(k,t-1);
                    end
                    scen_obj=scen_obj+temp;
                end
                scen_obj = scen_obj+u_kt(k,1);
            end  
        else
            % ����deadline�����ǳͷ�         
            for k=1:resNo
                max_abs = 0;
                for t=2:schedule(actNo)
                    if u_kt(k,t)-u_kt(k,t-1)<0
                        temp = u_kt(k,t-1)-u_kt(k,t);
                        if temp>max_abs
                            max_abs = temp;
                        end
                    else
                        temp = u_kt(k,t)-u_kt(k,t-1);
                        if temp>max_abs
                            max_abs = temp;
                        end
                    end
                    scen_obj=scen_obj+temp;
                end
%                 % �ӳͷ�
                penalty_k = max_abs*((schedule(actNo)-deadline));
                scen_obj = scen_obj+u_kt(k,1)+penalty_k;
            end % ��Դ����
        end
        obj = obj+scen_obj;
    end
end %  �龰��
expected_obj=obj/rep;
time_pro=p/rep;
                