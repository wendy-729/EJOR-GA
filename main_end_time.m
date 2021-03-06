% 最后的代码
clc
clear
% profile on 
global rn_seed; % 随机数种子
rn_seed = 13776;
% EDA参数设置
para=[80,0.03,0.1,100];
% 种群大小
popsize=para(1);
% 执行列表变异
p_vl_mutation=para(2);
% 活动列表变异
p_al_mutation=para(3);
% 仿真次数
rep=para(4);
% 分布类型
distribution=cell(1,1);
distribution{1,1}='U1';
% 服务水平
Pr=0.9;
% 活动数量
for actN=[10]
actNumber=num2str(actN);
all_results=[];

% 分布类型
for disT=distribution
disT=char(disT);
% 测试哪一组数据
for gd=[3]
groupdata= num2str(gd);
for dtime=[1.5,1.8] 
% 遍历每一个实例
for act=1:20
% for act=6:30:480
rng(rn_seed,'twister');% 设置随机数种子
actno=num2str(act);
%% 初始化数据
if actN==30
    fpath=['D:\研究生资料\RLP-PS汇总\实验数据集\PSPLIB\j',actNumber,'\J'];
    filename=[fpath,actNumber,'_',actno,'.RCP'];
elseif actN==5||actN ==10
    filename =['C:\Users\ASUS\Desktop\SRLP_PS数据\J',actNumber,'\项目网络数据','\J',actNumber,'_',actno,'.txt'];
end
% 获取项目网络结构
[projRelation,actNo,resNo,resNumber,duration,nrsu,nrpr,pred,su,req] = initData(filename);
%% 随机工期
% if actN==5||actN ==10
%     fp_duration = ['C:\Users\ASUS\Desktop\SRLP-PS随机工期\J',actNumber,'\J',actNumber,'_',actno,'_duration.txt'];
% elseif actN == 30
%     fp_duration=['D:\研究生资料\SRLP-PS汇总\数据和代码_final\随机工期\',num2str(disT),'\J',actNumber,'\',actno,'.txt'];
% end
fp_duration = ['C:\Users\ASUS\Desktop\SRLP-PS随机工期\J',actNumber,'\J',actNumber,'_',actno,'_duration.txt'];
stochatic_d = initfile(fp_duration);

% 获得柔性结构数据
if actN==30
    fp_choice=['D:\研究生资料\SRLP-PS汇总\数据和代码_final\SRLP-PS实验数据\J',actNumber,'\'];
elseif actN==5||actN ==10
    fp_choice = ['C:\Users\ASUS\Desktop\SRLP_PS数据\J',actNumber,'\',];
end

choicename=[fp_choice,groupdata,'\choice\J',actNumber,'_',actno,'.txt'];
dependname=[fp_choice,groupdata,'\dependent\J',actNumber,'_',actno,'.txt'];
choice = initfile(choicename);
depend = initfile(dependname);
mandatoryname=[fp_choice,groupdata,'\mandatory\J',actNumber,'_',actno,'.txt'];
mandatory = initfile(mandatoryname);
choiceListname=[fp_choice,groupdata,'\choiceList\J',actNumber,'_',actno,'.txt'];
choiceList = initfile(choiceListname);
choiceList=unique(choiceList);
choiceList=sort(choiceList);

% 写入文件路径
fpathRoot=['C:\Users\ASUS\Desktop\测试实验20211102\GA\J',actNumber,'\'];
setName = ['srlp_',num2str(actNo)];
dt=num2str(dtime);
%% 所有活动都执行的项目截止日期[cpm] 平均工期
[all_est, all_eft]= forward(projRelation, duration);
lftn=all_eft(actNo);
deadline=floor(dtime*all_eft(actNo));
% 最好的解
best_AL=zeros(1,actNo);
best_implement=zeros(1,actNo+2);
best_implement(1,actNo+1)=Inf;
best_implement(1,actNo+2)=Inf;
% 初始化
parent_implementList=zeros(2*popsize,actNo+2);
best_nrpr=nrpr;
best_nrsu=nrsu;
best_pred=pred;
best_su=su;
% 惩罚成本【都为1】
cost=ones(1,resNo);
%% 随机生成执行列表
tstart = tic;
% 所有实施活动置为1
implementList=zeros(popsize,actNo+2);
implementList(:,actNo+1)=Inf;
implementList(:,actNo+2)=Inf;
% 所有实施活动置为1
for i=1:popsize
    for j=mandatory
        implementList(i,j)=1;
    end
end
% 随机确定可选活动
[r,c]=size(choice);
% 触发依赖活动的可选活动
choice_depend=depend(:,1);
for i=1:popsize
    for j=1:r
        if implementList(i,choice(j,1))==1
            index = randi([2 c],1,1);  % 在可选集合中随机选择一个活动
            a = choice(j,index);
            implementList(i,a)=1;
            % 更新依赖活动
            if any(a==choice_depend)==1
                index=find(choice_depend==a);
               for d=depend(index,2:end)     
                    implementList(i,d)=1;
               end 
            end
        end
    end
end
% 初始化活动列表
AL_set=zeros(popsize,actNo);
AL_set(:,1)=1;
AL_set(:,actNo)=actNo;
% 父个体
parent_AL=zeros(popsize*2,actNo);
% 根据执行列表和逆向计算，计算合格活动集合（所有执行的紧前活动都已经执行，包括了执行活动和未执行活动）中活动的最晚开始时间，概率高的话就放进活动列表
for i=1:popsize
    implement=implementList(i,:);
    [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);
    %% 估计活动的开始时间
%     虚终止活动的上界【所有活动的工期相加】
    makespan=sum(duration);
%   所有执行活动的【粗略的最晚开始时间，计算了未执行活动的最晚开始时间】
    [ls, lf]= backward_all(projRelation_i, duration, makespan,implement); 
    min_ls=min(ls);
    ls=ls-min_ls+1;  
    AL=AL_set(i,:);
    % 已经放在活动列表中的活动
    inList=[1 actNo];
%     【每一个项目结构中活动的最早开始时间都是不一样的】
    for j=2:actNo-1
        % 如果该位置上没有放置活动
        if AL(j)==0
            % 合格活动
            eligSet=feasibleact(inList,nrpr_i,pred_i,actNo,implement);
            % 总概率【分母】
            sum_pro=0;
            for e1=eligSet
                sum_pro=sum_pro+(1/ls(e1));
            end
            % 选择概率高的活动
            if ~isempty(eligSet)
                pro=(1/ls(eligSet(1)));
                % 合格活动集中的第一个活动
                index=eligSet(1);
                for e1=eligSet
                    pro_e=1/ls(e1);
                    if pro_e>pro
                        index=e1;
                    end
                end
                AL(j)=index;
                inList=[inList index];
            end
        end
    end
    AL_set(i,:)=AL;
end
%% 评估初始种群
for i=1:popsize 
    % 【这一步很重要，要去掉及时完成率为1的，不然会影响更新项目结构】
    implement=implementList(i,1:actNo); % 当前个体
    % 活动项目结构可行
    if projectFeasible(implement,choice,depend)==1
        al=AL_set(i,:);
        [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);  
        % 对活动列表进行仿真rep次
        [expected_obj,time_pro]=evaluate_abs(al,rep,implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,stochatic_d);
        implementList(i,actNo+1)=expected_obj;
        implementList(i,actNo+2)=time_pro;

        % 记录最好的个体
        if implementList(i,actNo+1)<best_implement(actNo+1)
            best_implement=implementList(i,:);
            best_AL=al;
            best_nrpr=nrpr_i;
            best_nrsu=nrsu_i;
            best_pred=pred_i;
            best_su=su_i;
        end
    else
        implementList(i,actNo+1)=Inf;
    end
end
%% 迭代，求最好的染色体
end_time = 10;
%终止条件
% end_schedules=2000;
% nr_schedules=popsize;
count = 0;
tused = toc(tstart);
% 评估父个体
while tused<end_time
    parent_AL(1:popsize,:)=AL_set;
    parent_implementList(1:popsize,:)=implementList;
    %% 对所有的执行列表进行交叉和变异
    child_implementList=crossover(popsize,mandatory,choice,depend,implementList,actNo,choice_depend);
    child_implementList=mutation(child_implementList,choice,depend,popsize,p_vl_mutation);
    % 子代执行列表
    parent_implementList(popsize+1:end,:)=child_implementList;
    %% 活动列表交叉和变异
    % 单点交叉
    child_AL=zeros(popsize,actNo);
    for i=1:2:popsize
       % 随机生成一个交换位置
       pos1= randi([2,actNo-1],1);
       pos2=pos1;
       child_AL(i,1:pos1)=AL_set(i,1:pos1);
       child_AL(i+1,1:pos1)=AL_set(i+1,1:pos1);
       % 遍历父亲
       for j=AL_set(i+1,:)
           % 如果活动不在女儿中，则放进去
           if any(child_AL(i,:)==j)==0
               pos1=pos1+1;
               child_AL(i,pos1)=j;
           end
       end
       % 遍历母亲
       for j=AL_set(i,:)
           % 如果活动不在儿子中，则放进去
           if any(child_AL(i+1,:)==j)==0
               pos2=pos2+1;
               child_AL(i+1,pos2)=j;
           end
       end
    end
    % AL变异
    % 修复交叉得到的不可行个体【优先关系不可行】
    for i=1:popsize
        AL=child_AL(i,:);
%       修复前的个体
        AL(1)=[];
        % 修复后的个体
        newAL=[];
        newAL(1)=1;
        implement=child_implementList(i,1:actNo);
        [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);
        while ~isempty(AL)
            for ii=AL
                % 活动不执行则不需要修复
                if implement(ii)==0
                    newAL=[newAL ii];
                    index=find(AL==ii);
                    AL(index)=[];
                else
                    % 活动执行，判断所有执行的紧前是否都在newAL中
                    flag=1;
                    for j=1:nrpr_i(ii)
                        jinqian=pred_i(ii,j);
                        if child_implementList(i,jinqian)==1
                            if any(newAL==jinqian)==0
                                flag=0;
                            end
                        end
                        if flag==0
%                             disp('不满足')
                            break;
                        end
                    end
                    if flag==1
                        newAL=[newAL ii];
                        index=find(AL==ii);
                        AL(index)=[];
                        break;
                    else
                        continue;   
                    end
                end
            end
        end  
        child_AL(i,:)=newAL;
    end
    % 活动列表变异【两个没有优先关系的执行活动交换顺序】
    for i=1:popsize
        AL=child_AL(i,:);
        [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,child_implementList(i,:),actNo);
        new_AL=AL_mutation(AL,child_implementList(i,:),nrsu_i,su_i,actNo,p_al_mutation);
        child_AL(i,:)=new_AL;
    end
    parent_AL(popsize+1:end,:)=child_AL;
%% 评估子代
    for i=popsize+1:2*popsize 
        % 【这一步很重要，要去掉及时完成率为1的，会影响更新项目结构】
        implement=parent_implementList(i,1:actNo); % 当前染色体
        % 活动项目结构可行
        if projectFeasible(implement,choice,depend)==1
            al=parent_AL(i,:);
            [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);
                        
            % 对活动列表进行仿真rep次
             [expected_obj,time_pro]=evaluate_abs(al,rep,implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,stochatic_d);
             parent_implementList(i,actNo+1)=expected_obj;
             parent_implementList(i,actNo+2)=time_pro;
             
             % 记录最好的个体
             if parent_implementList(i,actNo+1)<best_implement(actNo+1) 
                 best_implement=parent_implementList(i,:);
                 best_AL=al;
                 best_nrpr=nrpr_i;
                 best_nrsu=nrsu_i;
                 best_pred=pred_i;
                 best_su=su_i;
             end
            
        else
            parent_implementList(i,actNo+1)=Inf;
        end
    end
    p=parent_implementList;
%  选择最好的pop个体作为父代，升序（最小）
    [~,fitIndex]=sort(parent_implementList(:,actNo+1));
    fitIndex=fitIndex(1:popsize);
    implementList=p(fitIndex,:);
    AL_set=parent_AL(fitIndex,:);
%     nr_schedules = nr_schedules+popsize;
    tused = toc(tstart);
end % 迭代结束
cputime = tused;
%% 计算真正的目标函数
if best_implement(actNo+1)~=Inf
    [expected_obj,time_pro]=evaluate_abs_nopenalty(best_AL,rep,best_implement,req,resNumber,best_nrpr,best_pred,best_nrsu,best_su,deadline,resNo,actNo,stochatic_d);
    best_implement(actNo+1) = expected_obj;
    best_implement(actNo+2) = time_pro;
end
% % disp(cputime)
% disp(best_implement(actNo+1))
% disp(best_implement(actNo+2))
% disp('---------------')
% profile  viewer
%% 写入文件（目标函数均值，及时完工的概率,AL...）
outResults=[act,best_implement(actNo+1),best_implement(actNo+2),cputime,best_AL,best_implement];
outFile=[fpathRoot,num2str(end_time),'sch_ga_',setName,'_',dt,'_',num2str(rep),'.txt'];
dlmwrite(outFile,outResults,'-append', 'newline', 'pc',  'delimiter', '\t');
outResults=[];
disp(['Instance ',num2str(act),' has been solved.']);
end % 实例
end % 截止日期
end % 组数
end % 分布类型
end % 活动数量
       