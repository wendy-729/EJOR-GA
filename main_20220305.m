% �������ۺ���
clc
clear
% profile on 
global rn_seed; % ���������
rn_seed = 13776;
% EDA��������
para=[80,0.03,0.1,100];
% ��Ⱥ��С
popsize=para(1);
% ִ���б�����
p_vl_mutation=para(2);
% ��б�����
p_al_mutation=para(3);
% �������
rep=para(4);
% �ֲ�����
distribution=cell(1,1);
distribution{1,1}='U1';

C=300;

% �����
for actN=[5,10]
actNumber=num2str(actN);
all_results=[];

% �ֲ�����
for disT=distribution
disT=char(disT);
% ������һ������
for gd=[1]
groupdata= num2str(gd);
for dtime=[1.2,1.4] 
% ����ÿһ��ʵ��
for act = 1:20
% for act=6:30:480
rng(rn_seed,'twister');% �������������
actno=num2str(act);
%% ��ʼ������
if actN==30
    fpath=['D:\��;\�о�������\RLP-PS����\ʵ�����ݼ�\PSPLIB\j',actNumber,'\J'];
    filename=[fpath,actNumber,'_',actno,'.RCP'];
elseif actN==5||actN ==10
    filename =['D:\��;\�о�������\SRLP-PS-����-20211220\����\SRLP_PS����\J',actNumber,'\��Ŀ��������','\J',actNumber,'_',actno,'.txt'];
end
% ��ȡ��Ŀ����ṹ
[projRelation,actNo,resNo,resNumber,duration,nrsu,nrpr,pred,su,req] = initData(filename);
%% �������
fp_duration = ['D:\��;\�о�������\SRLP-PS-����-20211220\����\SRLP-PS�������\J',actNumber,'\J',actNumber,'_',actno,'_duration.txt'];
stochatic_d = initfile(fp_duration);

% ������Խṹ����
if actN==30
    fp_choice=['D:\��;\�о�������\SRLP-PS����\���ݺʹ���_final\SRLP-PSʵ������\J',actNumber,'\'];
elseif actN==5||actN ==10
    fp_choice = ['D:\��;\�о�������\SRLP-PS-����-20211220\����\SRLP_PS����\J',actNumber,'\',];
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

% д���ļ�·��
fpathRoot=['D:\��;\�о�������\SRLP-PS-����-20211220\new_model_results\GA\J',actNumber,'\'];
setName = ['srlp_',num2str(actNo)];
dt=num2str(dtime);
%% ���л��ִ�е���Ŀ��ֹ����[cpm] ƽ������
[all_est, all_eft]= forward(projRelation, duration);
lftn=all_eft(actNo);
deadline=floor(dtime*all_eft(actNo));
% ��õĽ�
best_AL=zeros(1,actNo);
best_implement=zeros(1,actNo+1);
best_implement(1,actNo+1)=Inf;
% ��ʼ��
parent_implementList=zeros(2*popsize,actNo+1);
best_nrpr=nrpr;
best_nrsu=nrsu;
best_pred=pred;
best_su=su;
% �ͷ��ɱ�����Ϊ1��
cost=ones(1,resNo);
%% �������ִ���б�
tic;
% tstart = tic;
% ����ʵʩ���Ϊ1
implementList=zeros(popsize,actNo+1);
implementList(:,actNo+1)=Inf;
% ����ʵʩ���Ϊ1
for i=1:popsize
    for j=mandatory
        implementList(i,j)=1;
    end
end
% ���ȷ����ѡ�
[r,c]=size(choice);
% ����������Ŀ�ѡ�
choice_depend=depend(:,1);
for i=1:popsize
    for j=1:r
        if implementList(i,choice(j,1))==1
            index = randi([2 c],1,1);  % �ڿ�ѡ���������ѡ��һ���
            a = choice(j,index);
            implementList(i,a)=1;
            % ���������
            if any(a==choice_depend)==1
                index=find(choice_depend==a);
               for d=depend(index,2:end)     
                    implementList(i,d)=1;
               end 
            end
        end
    end
end
% ��ʼ����б�
AL_set=zeros(popsize,actNo);
AL_set(:,1)=1;
AL_set(:,actNo)=actNo;
% ������
parent_AL=zeros(popsize*2,actNo);
% ����ִ���б���������㣬����ϸ����ϣ�����ִ�еĽ�ǰ����Ѿ�ִ�У�������ִ�л��δִ�л���л��������ʼʱ�䣬���ʸߵĻ��ͷŽ���б�
for i=1:popsize
    implement=implementList(i,:);
    [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);
    %% ���ƻ�Ŀ�ʼʱ��
%     ����ֹ����Ͻ硾���л�Ĺ�����ӡ�
    makespan=sum(duration);
%   ����ִ�л�ġ����Ե�������ʼʱ�䣬������δִ�л��������ʼʱ�䡿
    [ls, lf]= backward_all(projRelation_i, duration, makespan,implement); 
    min_ls=min(ls);
    ls=ls-min_ls+1;  
    AL=AL_set(i,:);
    % �Ѿ����ڻ�б��еĻ
    inList=[1 actNo];
%     ��ÿһ����Ŀ�ṹ�л�����翪ʼʱ�䶼�ǲ�һ���ġ�
    for j=2:actNo-1
        % �����λ����û�з��û
        if AL(j)==0
            % �ϸ�
            eligSet=feasibleact(inList,nrpr_i,pred_i,actNo,implement);
            % �ܸ��ʡ���ĸ��
            sum_pro=0;
            for e1=eligSet
                sum_pro=sum_pro+(1/ls(e1));
            end
            % ѡ����ʸߵĻ
            if ~isempty(eligSet)
                pro=(1/ls(eligSet(1)));
                % �ϸ����еĵ�һ���
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
%% ������ʼ��Ⱥ
for i=1:popsize 
    % ����һ������Ҫ��Ҫȥ����ʱ�����Ϊ1�ģ���Ȼ��Ӱ�������Ŀ�ṹ��
    implement=implementList(i,1:actNo); % ��ǰ����
    % ���Ŀ�ṹ����
    if projectFeasible(implement,choice,depend)==1
        al=AL_set(i,:);
        [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);  
        % ����
        expected_obj=evaluate_abs_consider_penalty_new_objective(al,rep,implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,stochatic_d,C);      
        implementList(i,actNo+1)=expected_obj;

        % ��¼��õĸ���
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
% tused = toc(tstart);
%% ����������õ�Ⱦɫ��
%��ֹ����
end_time = 15;
end_schedules=5000;
nr_schedules=popsize;
count = 0;
% ����������
% while tused<end_time
while nr_schedules<end_schedules
    parent_AL(1:popsize,:)=AL_set;
    parent_implementList(1:popsize,:)=implementList;
    %% �����е�ִ���б����н���ͱ���
    child_implementList=crossover(popsize,mandatory,choice,depend,implementList,actNo,choice_depend);
    child_implementList = child_implementList(:,1:actNo+1);
    child_implementList=mutation(child_implementList,choice,depend,popsize,p_vl_mutation);
    % �Ӵ�ִ���б�
    parent_implementList(popsize+1:end,:)=child_implementList;
    %% ��б�����ͱ���
    % ���㽻��
    child_AL=zeros(popsize,actNo);
    for i=1:2:popsize
       % �������һ������λ��
       pos1= randi([2,actNo-1],1);
       pos2=pos1;
       child_AL(i,1:pos1)=AL_set(i,1:pos1);
       child_AL(i+1,1:pos1)=AL_set(i+1,1:pos1);
       % ��������
       for j=AL_set(i+1,:)
           % ��������Ů���У���Ž�ȥ
           if any(child_AL(i,:)==j)==0
               pos1=pos1+1;
               child_AL(i,pos1)=j;
           end
       end
       % ����ĸ��
       for j=AL_set(i,:)
           % �������ڶ����У���Ž�ȥ
           if any(child_AL(i+1,:)==j)==0
               pos2=pos2+1;
               child_AL(i+1,pos2)=j;
           end
       end
    end
    % AL����
    % �޸�����õ��Ĳ����и��塾���ȹ�ϵ�����С�
    for i=1:popsize
        AL=child_AL(i,:);
%       �޸�ǰ�ĸ���
        AL(1)=[];
        % �޸���ĸ���
        newAL=[];
        newAL(1)=1;
        implement=child_implementList(i,1:actNo);
        [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);
        while ~isempty(AL)
            for ii=AL
                % ���ִ������Ҫ�޸�
                if implement(ii)==0
                    newAL=[newAL ii];
                    index=find(AL==ii);
                    AL(index)=[];
                else
                    % �ִ�У��ж�����ִ�еĽ�ǰ�Ƿ���newAL��
                    flag=1;
                    for j=1:nrpr_i(ii)
                        jinqian=pred_i(ii,j);
                        if child_implementList(i,jinqian)==1
                            if any(newAL==jinqian)==0
                                flag=0;
                            end
                        end
                        if flag==0
%                             disp('������')
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
    % ��б����졾����û�����ȹ�ϵ��ִ�л����˳��
    for i=1:popsize
        AL=child_AL(i,:);
        [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,child_implementList(i,:),actNo);
        new_AL=AL_mutation(AL,child_implementList(i,:),nrsu_i,su_i,actNo,p_al_mutation);
        child_AL(i,:)=new_AL;
    end
    parent_AL(popsize+1:end,:)=child_AL;
   %% �����Ӵ�
    for i=popsize+1:2*popsize 
        % ����һ������Ҫ��Ҫȥ����ʱ�����Ϊ1�ģ���Ӱ�������Ŀ�ṹ��
        implement=parent_implementList(i,1:actNo); % ��ǰȾɫ��
        % ���Ŀ�ṹ����
        if projectFeasible(implement,choice,depend)==1
            al=parent_AL(i,:);
            [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);

              % ����
             expected_obj=evaluate_abs_consider_penalty_new_objective(al,rep,implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,stochatic_d,C);      
             
             parent_implementList(i,actNo+1)=expected_obj;
             
             % ��¼��õĸ���
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
     % �ж��Ƿ�ﵽ��10000
%     if nr_schedules==2000 && count==0
%          count = count+1;
%          cputime1=toc;
%         outResults1=[act,best_implement(actNo+1),best_implement(actNo+2),cputime1,best_AL,best_implement,nr_schedules];
%         outFile1=[fpathRoot,num2str(nr_schedules),'sch_ga_',setName,'_s_',num2str(disT),'_',dt,'.txt'];
%      end
    p=parent_implementList;
%  ѡ����õ�pop������Ϊ������������С��
    [~,fitIndex]=sort(parent_implementList(:,actNo+1));
    fitIndex=fitIndex(1:popsize);
    implementList=p(fitIndex,:);
    AL_set=parent_AL(fitIndex,:);
%     tused = toc(tstart);
    nr_schedules = nr_schedules+popsize;
end % ��ֹ����
% cputime = tused;
cputime = toc;
%% ����1000��
REP= 1000;
rep_best_implement = best_implement;
fp_duration1 = ['D:\��;\�о�������\SRLP-PS-����-20211220\����\1000�η���\J',actNumber,'\J',actNumber,'_',actno,'_duration.txt'];
stochatic_d1 = initfile(fp_duration1);
expected_obj=evaluate_abs_consider_penalty_new_objective(best_AL,REP,best_implement,req,resNumber,best_nrpr,best_pred,best_nrsu,best_su,deadline,resNo,actNo,stochatic_d1,C);
rep_best_implement(actNo+1) = expected_obj;
% profile  viewer
%% д���ļ���Ŀ�꺯����ֵ����ʱ�깤�ĸ���,AL...��
outResults=[act,best_implement(actNo+1),rep_best_implement(actNo+1),cputime,best_AL,best_implement,end_schedules];
%ʱ��
outFile=[fpathRoot,num2str(end_schedules),'s_sch_ga_',setName,'_',dt,'_',num2str(rep),'.txt'];
dlmwrite(outFile,outResults,'-append', 'newline', 'pc',  'delimiter', '\t');
% dlmwrite(outFile1,outResults1,'-append', 'newline', 'pc',  'delimiter', '\t');
outResults=[];
% outResults1=[];
disp(['Instance ',num2str(act),' has been solved.']);
end % ʵ��
end % ��ֹ����
end % ����
end % �ֲ�����
end % �����
       