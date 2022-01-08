function child_implement=mutation(implement,choice,depend,pop,p_mutation)
child_implement=implement;
[r,c]=size(choice);
for i=1:pop
    for j=1:r
        % 如果该选择被触发
        if child_implement(i,choice(j,1))==1
            % 如果选择以前没有被触发【求和也是可以的==0】
            if all(child_implement(i,choice(j,2:end))==0)==1
                % 随机选择一个活动
                pos = randi([2 c],1,1);
                child_implement(i,choice(j,pos))=1;
                 % 更新依赖活动的状态
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
                % 活动以前已经被触发,选择一个没有执行的活动
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
                     % 更新依赖活动的状态
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
            % 如果活动当前没有触发，以前触发，则将其变为不触发
            if all(child_implement(i,choice(j,2:end))==0)==0
                child_implement(i,choice(j,1))=0;
                 for p=2:c
                     child_implement(i,choice(j,p))=0;
                 end
                 % 更新依赖活动的状态
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
         
            
                     
                    
                    
                
                
                