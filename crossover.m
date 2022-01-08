function child_implement=crossover(pop,mandatory,choice,depend,implementList,actNo,choice_depend) 
% 初始化实施列表
child_implement=zeros(pop,actNo+2);
child_implement(:, actNo+1) = Inf;
child_implement(:, actNo+2) = Inf;
for i=1:pop
    for j=mandatory
        child_implement(i,j)=1;
    end
end
for i=1:2:pop
    [r,~]=size(choice); % 行，列
     b = randi([1 r],1,1);
     for e=1:b
        for j=choice(e,2:end)
            child_implement(i,j)=implementList(i,j);  %女儿
            child_implement(i+1,j)=implementList(i+1,j);   % 儿子
            % 继承依赖活动
            if any(j==choice_depend)==1
               index=find(choice_depend==j);
               for d=depend(index,2:end)     % 更新依赖活动
                    child_implement(i,d)=implementList(i,d);
                    child_implement(i+1,d)=implementList(i+1,d); 
               end 
            end
        end
     end
     if b<r
        for c=b+1:r
            e1=choice(c,1);
            % 女儿
            if child_implement(i,e1)==1  %选择e被触发
                if implementList(i+1,e1)==1  % 选择e被父亲触发
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
                    % 在父亲中选择e没有被触发，则继承母亲的
                    for j=choice(c,2:end)
                        child_implement(i,j)=implementList(i,j);
                         % 继承依赖活动
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
            % 儿子
            if child_implement(i+1,e1)==1
                if implementList(i,e1)==1  % 被母亲触发
                    for j=choice(c,2:end)
                        child_implement(i+1,j)=implementList(i,j);
                        % 继承依赖活动
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
                        % 继承依赖活动
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