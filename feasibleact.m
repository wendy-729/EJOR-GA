function elig=feasibleact(al,nrpr,pred,actNo,implement)
% ����AL����Ļ����ϸ�
%���ϸ��а���δʵʩ���
elig=[];
actSet=1:actNo;
same=ismember(actSet,al);

% δ���ȵĻ
unschedule=actSet(~same);
for i=1:length(unschedule)
    act=unschedule(i);
    % ���ִ��
    if implement(act)==0
        % �жϽ�ǰ�Ƿ��Ѿ�����
        flag=1;
        for j=1:nrpr(act)
            p=pred(act,j);
            % ��ǰ�û���ڻ�б���
            if any(p==al)==0
                flag=0;
                break
            end
        end
        % ���еĽ�ǰ����Ѿ�����
        if flag==1 
            elig=[elig act];
        end
    else
        % ��ִ�л
        flag=1;
        % ���н�ǰ��ڻ�б���
        for j=1:nrpr(act)
            p=pred(act,j);
            if implement(p)==0
                continue;
            else
                if any(p==al)==0
                    flag=0;
                    break
                end
            end
        end
        if flag==1
            elig=[elig act];
        end
    end
end
    
        