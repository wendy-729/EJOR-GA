function child_implement=crossover(pop,mandatory,choice,depend,implementList,actNo,choice_depend) 
% ��ʼ��ʵʩ�б�
child_implement=zeros(pop,actNo+2);
child_implement(:, actNo+1) = Inf;
child_implement(:, actNo+2) = Inf;
for i=1:pop
    for j=mandatory
        child_implement(i,j)=1;
    end
end
for i=1:2:pop
    [r,~]=size(choice); % �У���
     b = randi([1 r],1,1);
     for e=1:b
        for j=choice(e,2:end)
            child_implement(i,j)=implementList(i,j);  %Ů��
            child_implement(i+1,j)=implementList(i+1,j);   % ����
            % �̳������
            if any(j==choice_depend)==1
               index=find(choice_depend==j);
               for d=depend(index,2:end)     % ���������
                    child_implement(i,d)=implementList(i,d);
                    child_implement(i+1,d)=implementList(i+1,d); 
               end 
            end
        end
     end
     if b<r
        for c=b+1:r
            e1=choice(c,1);
            % Ů��
            if child_implement(i,e1)==1  %ѡ��e������
                if implementList(i+1,e1)==1  % ѡ��e�����״���
                    for j=choice(c,2:end)
                        child_implement(i,j)=implementList(i+1,j);
                        if any(j==choice_depend)==1
%                             if find(choice_depend==j)~=0
                           index=find(choice_depend==j);
                           for d=depend(index,2:end)    
                                child_implement(i,d)=implementList(i+1,d);
                           end 
                        end
                    end
                else
                    % �ڸ�����ѡ��eû�б���������̳�ĸ�׵�
                    for j=choice(c,2:end)
                        child_implement(i,j)=implementList(i,j);
                         % �̳������
%                             if find(choice_depend==j)~=0
                         if any(j==choice_depend)==1
                            index=find(choice_depend==j);
                           for d=depend(index,2:end)    
                                child_implement(i,d)=implementList(i,d);
                           end 
                        end
                    end
                end
            end
            % ����
            if child_implement(i+1,e1)==1
                if implementList(i,e1)==1  % ��ĸ�״���
                    for j=choice(c,2:end)
                        child_implement(i+1,j)=implementList(i,j);
                        % �̳������
                        if any(j==choice_depend)==1
%                             if find(choice_depend==j)~=0
                            index=find(choice_depend==j);
                           for d=depend(index,2:end)    
                                child_implement(i+1,d)=implementList(i,d);
                           end 
                        end
                    end
                else
                    for j=choice(c,2:end)
                        child_implement(i+1,j)=implementList(i+1,j);
                        % �̳������
                        if any(j==choice_depend)==1
%                             if find(choice_depend==j)~=0
                            index=find(choice_depend==j);
                           for d=depend(index,2:end)    
                                child_implement(i+1,d)=implementList(i+1,d);
                           end 
                        end
                    end
                end
            end
        end
     end
end