function child_implement=mutation(implement,choice,depend,pop,p_mutation)
child_implement=implement;
[r,c]=size(choice);
for i=1:pop
    for j=1:r
        % �����ѡ�񱻴���
        if child_implement(i,choice(j,1))==1
            % ���ѡ����ǰû�б����������Ҳ�ǿ��Ե�==0��
            if all(child_implement(i,choice(j,2:end))==0)==1
                % ���ѡ��һ���
                pos = randi([2 c],1,1);
                child_implement(i,choice(j,pos))=1;
                 % �����������״̬
                 [rd,cd]=size(depend);
                 for c_d=1:rd
                    if child_implement(i,depend(c_d,1))==1
                        for d=depend(c_d,2:end)
                            child_implement(i,d)=1;
                        end
                    else
                        for d=depend(c_d,2:end)
                            child_implement(i,d)=0;
                        end
                    end
                 end 
            else
%                 if all(child_implement(ichoice(j,2:end))==0)==0
                % ���ǰ�Ѿ�������,ѡ��һ��û��ִ�еĻ
                if rand<=p_mutation
                     pos1 = randi([2 c],1,1);
                     while child_implement(i,choice(j,pos1))==1
                         pos1 = randi([2 c],1,1);
                     end
                     child_implement(i,choice(j,pos1))=1;
                     for p=2:c
                         if p~=pos1
                             child_implement(i,choice(j,p))=0;
                         end
                     end
%                          disp(child_implement(23,:))
                     % �����������״̬
                     [rd,cd]=size(depend);
                     for c_d=1:rd
                        if child_implement(i,depend(c_d,1))==1
                            for d=depend(c_d,2:end)
                                child_implement(i,d)=1;
                            end
                        else
                            for d=depend(c_d,2:end)
                                child_implement(i,d)=0;
                            end
                        end
                     end
                end
%                 end
            end
        else
            % ������ǰû�д�������ǰ�����������Ϊ������
            if all(child_implement(i,choice(j,2:end))==0)==0
                child_implement(i,choice(j,1))=0;
                 for p=2:c
                     child_implement(i,choice(j,p))=0;
                 end
                 % �����������״̬
                 [rd,cd]=size(depend);
                 for c_d=1:rd
                    if child_implement(i,depend(c_d,1))==1
                        for d=depend(c_d,2:end)
                            child_implement(i,d)=1;
                        end
                    else
                        for d=depend(c_d,2:end)
                            child_implement(i,d)=0;
                        end
                    end
                 end 
            end
        end
    end
end
         
            
                     
                    
                    
                
                
                