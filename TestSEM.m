function Results = TestSEM(DGP,Estimator,SimulationOption)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestSEM() - MATLAB function to run Monte Carlo simulations to evaluate  %
%              the performance of SEM estimators and relevant statistics  %
% Author: Gyeongcheol Cho                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input arguments: DGP, Estimators, SimulationOption                      %
%   DGP: a structure array including the parameters of the data           %
%        generating process (DGP) as its fields                           %
%   Estimators: a structure array including estimators and  their input   %
%        arguments as its fields                                          %
%   SimulationOption: a structure array including the parameters of the   %
%        simulation design as its fields                                  %
%   Note: You can find detailed information on the fields of each input   % 
%         argument by running the command "Help_TestSEM(DGPType)"         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output arguments: Results                                               %
%   Results: a structure array including the results of the Monte Carlo   %
%      simulation study as its fields. Result tables can vary depending   %
%      on the evaluation criteria specified in SimulationOption. It may   %
%      include the following but is not limited to:                       %
%      - Storage_PR_ind: a 5D array containing the parameter recovery     %
%          statistics (Bias, SD, RMSE) for each estimator per condition   %
%      - Table_PR_avg: a table containing the parameter recovery          %
%          statistics for each estimator across parameters within the     %
%          same parameter type per condition                              %
%      - Table_CR: a table containing the convergence rate of each        %
%          estimator per condition                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if DGP.DGPType==1
        list_ConstructType = DGP.Measurement.list_ConstructType;
        Sig_Zp = DGP.Measurement.Sig_Zp;     
        Wp_unstd = DGP.Measurement.Wp;     
        Cp = DGP.Measurement.Cp;         
        Sig_Ezp = DGP.Measurement.Sig_Ezp;   
        P= length(list_ConstructType);   
        Jp = size(Sig_Zp,1); if Jp==0; Jp=size(Cp,2); end 
        J=Jp*P;
        Info_construct(P,1)=struct('Type',[],'Jp',[],'Sig_Zp',[],'Sig_Ezp',[],'Cp',[],'Wp',[]);
        for p=1:P
            Info_construct(p).Type=list_ConstructType(p);
            Info_construct(p).Jp=Jp; 
            if list_ConstructType(p)==0
                Info_construct(p).Sig_Ezp = Sig_Ezp;
                Info_construct(p).Cp      = Cp;
            elseif list_ConstructType(p)==1
                Info_construct(p).Sig_Zp = Sig_Zp;
            elseif list_ConstructType(p)==2
                Info_construct(p).Sig_Zp = Sig_Zp;
                Info_construct(p).Wp = Wp_unstd;
            end
        end
        if isfield(DGP,'Structural');
            Info_model=struct('Bx',DGP.Structural.Bx,'By',DGP.Structural.By,'J',J,'list_Jp',ones(1,P)*Jp,'P',P);
            Array_Sig_CVx=DGP.Structural.Sig_CVx;      
            N_ExpFac1 = size(Array_Sig_CVx,3);
        else
            Info_model=struct('Bx',zeros(P,P),'By',zeros(0,0),'J',J,'list_Jp',ones(1,P)*Jp,'P',P);
            Array_Sig_CVx=eye(P,P);
            N_ExpFac1 = 1;
        end

        SimulationOption.N=sum(SimulationOption.list_N);
        SimulationOption.GenType=1;
        list_N=SimulationOption.list_N;
        N_N=size(list_N,2);
        N_rep=SimulationOption.N_rep;

        list_Function = Estimator.list_Function;
        list_FunctionInput = Estimator.list_FunctionInput;    
        N_estimator=size(list_Function,2);
        
        loc_N = cumsum(list_N);
        loc_N = [[1,loc_N(1:end-1)+1];loc_N];
            
        Flag_SafeBackup=SimulationOption.Flag_SafeBackup;
        Flag_Parallel=SimulationOption.Flag_Parallel;
        Flag_PR=SimulationOption.Criterion.ParameterRecovery;
        Flag_CR=SimulationOption.Criterion.ConvergenceRate;
        Flag_SR=SimulationOption.Criterion.SelectionRate;
        Flag_SaveEst=Flag_PR || Flag_SR;
        if Flag_SaveEst
            estimatorArgs=list_FunctionInput{1,1};
            W0=estimatorArgs{1}==1;
            C0=estimatorArgs{2}==1;
            B0=estimatorArgs{3}==1;        
            Nw=sum(sum(double(W0),1),2);
            Nc=sum(sum(double(C0),1),2);
            Nb=sum(sum(double(B0),1),2);
            Nwcb=Nw+Nc+Nb;
            N_para=3;
            loc_w=1:Nw;
            loc_c=(Nw+1):(Nw+Nc);
            loc_b=(Nw+Nc+1):(Nw+Nc+Nb); 
            Storage_Est=zeros(N_ExpFac1,N_N,Nwcb,N_estimator,N_rep);
            if Flag_PR
                Storage_PR_ind = zeros(N_ExpFac1,N_N,Nwcb,N_estimator,3); 
                Table_PR_avg = zeros(N_ExpFac1*N_N,N_para*N_estimator*3); 
            end
        end
        if Flag_CR
            Storage_CR = zeros(N_ExpFac1,N_N,N_estimator); 
            Table_CR=zeros(N_ExpFac1*N_N,N_estimator);
        end
        %% Run Simulation
        for i4=1:N_ExpFac1 
            Info_model.Sig_CVx = Array_Sig_CVx(:,:,i4);
            [Para,Dataset] =  DGP_BlockwiseSEM(Info_construct,Info_model,SimulationOption);
            vec_W_true = Para.W(W0);
            vec_C_true = Para.C(C0);
            vec_B_true = Para.B(B0);
            Mat_Para_true = repmat([vec_W_true;vec_C_true;vec_B_true],[1,N_estimator]);
            for i3=1:N_N
                loc_n_st=loc_N(1,i3);
                loc_n_ed=loc_N(2,i3);
                loc_n = loc_n_st:loc_n_ed;
                fprintf('\n r = %f, N = %d',i4,list_N(i3)); 
                fprintf('\n=============================='); 
                if Flag_SaveEst; storage_est=zeros(Nwcb,N_estimator,N_rep); end
                if Flag_CR; storage_cr=zeros(N_estimator,N_rep); end
                if Flag_Parallel
                    parfor i2=1:N_rep
                        Z = Dataset(loc_n,:,i2);    
                        FuncEst = list_Function;            
                        FuncEstArgs = list_FunctionInput;  
                        for i1=1:N_estimator
                            estimatorFunc = FuncEst{i1};
                            estimatorArgs = FuncEstArgs{i1};
                            INI = estimatorFunc(Z, estimatorArgs{:});        
                            if Flag_SaveEst; storage_est(:,i1,i2)=[INI.W(W0);INI.C(C0);INI.B(B0)]; end
                            if Flag_CR; storage_cr(i1,i2)=INI.Converge; end
                        end
                    end
                else
                    for i2=1:N_rep                
                        fprintf('\n r = %4.3f, N = %d, iter = %d',i4,list_N(i3),i2); 
                        Z = Dataset(loc_n,:,i2);                
                        for i1=1:N_estimator
                            estimatorFunc = list_Function{1,i1};
                            estimatorArgs = list_FunctionInput{1,i1};
                            INI = estimatorFunc(Z, estimatorArgs{:});        
                            if Flag_SaveEst; storage_est(:,i1,i2)=[INI.W(W0);INI.C(C0);INI.B(B0)]; end
                            if Flag_CR; storage_cr(i1,i2)=INI.Converge; end
                        end
                    end                
                end
                loc_row_in_table=(i4-1)*N_ExpFac1+i3;
                if Flag_PR      
                    bias=Mat_Para_true-mean(storage_est,3);
                    sd=std(storage_est,1,3); 
                    rmse=(bias.^2+sd.^2).^(1/2);
                    Storage_PR_ind(i4,i3,:,:,1) = bias;
                    Storage_PR_ind(i4,i3,:,:,2) = sd;
                    Storage_PR_ind(i4,i3,:,:,3) = rmse;                
                    Storage_Est(i4,i3,:,:,:) = storage_est;    
                    Table_PR_avg(loc_row_in_table,:) = ...
                        [mean(abs([bias(loc_w,:),sd(loc_w,:),rmse(loc_w,:)]),1),...
                        mean(abs([bias(loc_c,:),sd(loc_c,:),rmse(loc_c,:)]),1),...
                        mean(abs([bias(loc_b,:),sd(loc_b,:),rmse(loc_b,:)]),1)];
                    Table_PR_avg(1:loc_row_in_table,:)
                end        
                if Flag_CR           
                    cr=mean(storage_cr,2);     
                    Storage_CR(i4,i3,:)=cr;
                    Table_CR(loc_row_in_table,:)=cr; 
                    Table_CR(loc_row_in_table,:)
                end
                if Flag_SafeBackup; save('Backup_TestSEM.mat'); end
            end
        end
    elseif DGP.DGPType==2
%        [Para,Dataset,~] = DGP_HigherOrderSEM(list_ConstructType_o1,Sig_Zp_o1,Sig_Ezp_o1,Cp_o1,Wp_o1,...
%            list_ConstructType_o2,Sig_Zp_o2,Sig_Ezp_o2,Cp_o2,Wp_o2,...
%            Sig_CVx,Bx,By,...
%            N,N_rep,DistType);

        list_ConstructType_o1 = DGP.Measurement.o1.list_ConstructType;
        Sig_Zp_o1 = DGP.Measurement.o1.Sig_Zp;     
        Wp_o1 = DGP.Measurement.o1.Wp;     
        Cp_o1 = DGP.Measurement.o1.Cp;         
        Sig_Ezp_o1 = DGP.Measurement.o1.Sig_Ezp;   

        P_o1= length(list_ConstructType_o1);   
        Jp_o1 = size(Sig_Zp_o1,1); if Jp_o1==0; Jp_o1=size(Cp_o1,2); end 
        J_o1=Jp_o1*P_o1; 
 
        list_ConstructType_o2 = DGP.Measurement.o2.list_ConstructType;
        Sig_Zp_o2 = DGP.Measurement.o2.Sig_Zp;     
        Wp_o2 = DGP.Measurement.o2.Wp;     
        Cp_o2 = DGP.Measurement.o2.Cp;         
        Sig_Ezp_o2 = DGP.Measurement.o2.Sig_Ezp;   

        P_o2= length(list_ConstructType_o2);   
        Jp_o2 = size(Sig_Zp_o2,1); if Jp_o2==0; Jp_o2=size(Cp_o2,2); end 
        J_o2=Jp_o2*P_o2;

        P=P_o1+P_o2;        

        if isfield(DGP,'Structural');
            Info_model=struct('Bx',DGP.Structural.Bx,'By',DGP.Structural.By,'J',J,'list_Jp',ones(1,P_o2)*Jp_o2,'P',P_o2);
            Array_Sig_CVx=DGP.Structural.Sig_CVx;      
            N_ExpFac1 = size(Array_Sig_CVx,3);
        else
            Info_model=struct('Bx',zeros(P_o2,P_o2),'By',zeros(0,0),'J',J_o2,'list_Jp',ones(1,P_o2)*Jp_o2,'P',P_o2);
            Array_Sig_CVx=eye(P_o2,P_o2);
            N_ExpFac1 = 1;
        end

        SimulationOption.N=sum(SimulationOption.list_N);
        SimulationOption.GenType=1;
        list_N=SimulationOption.list_N;
        N_N=size(list_N,2);
        N_rep=SimulationOption.N_rep;

        list_Function = Estimator.list_Function;
        list_FunctionInput = Estimator.list_FunctionInput;    
        N_estimator=size(list_Function,2);
        
        loc_N = cumsum(list_N);
        loc_N = [[1,loc_N(1:end-1)+1];loc_N];
            
        Flag_SafeBackup=SimulationOption.Flag_SafeBackup;
        Flag_Parallel=SimulationOption.Flag_Parallel;
        Flag_PR=SimulationOption.Criterion.ParameterRecovery;
        Flag_CR=SimulationOption.Criterion.ConvergenceRate;
        Flag_SR=SimulationOption.Criterion.SelectionRate;
        Flag_SaveEst=Flag_PR || Flag_SR;
        if Flag_SaveEst
            estimatorArgs=list_FunctionInput{1,1};
            W01=estimatorArgs{1}~=0;
            W02=estimatorArgs{2}~=0;
            C01=estimatorArgs{3}~=0;
            B0_Full=estimatorArgs{4}~=0;
            C02=B0_Full((P_o1+1):P,1:P_o1);
            B0 =B0_Full((P_o1+1):P,(P_o1+1):P);            

            C02_Spec=B0_Full;
            C02_Spec((P_o1+1):P,(P_o1+1):P)=false;
             B0_Spec=B0_Full;
             B0_Spec((P_o1+1):P,1:P_o1)=false;            
            
            Nw1=sum(sum(double(W01),1),2);
            Nw2=sum(sum(double(W02),1),2);
            Nw=Nw1+Nw2;
            Nc1=sum(sum(double(C01),1),2);
            Nc2=sum(sum(double(C02),1),2);
            Nc=Nc1+Nc2;
            Nb=sum(sum(double(B0),1),2);
            Nwcb=Nw+Nc+Nb;
            N_para=3;
            loc_w=1:Nw;
            loc_c=(Nw+1):(Nw+Nc);
            loc_b=(Nw+Nc+1):(Nw+Nc+Nb); 
            Storage_Est=zeros(N_ExpFac1,N_N,Nwcb,N_estimator,N_rep);
            if Flag_PR
                Storage_PR_ind = zeros(N_ExpFac1,N_N,Nwcb,N_estimator,3); 
                Table_PR_avg = zeros(N_ExpFac1*N_N,N_para*N_estimator*3); 
            end
        end
        if Flag_CR
            Storage_CR = zeros(N_ExpFac1,N_N,N_estimator); 
            Table_CR=zeros(N_ExpFac1*N_N,N_estimator);
        end
        %% Run Simulation
        for i4=1:N_ExpFac1 
            Info_model.Sig_CVx = Array_Sig_CVx(:,:,i4);
            [Para,Dataset,~] = DGP_HigherOrderSEM(list_ConstructType_o1,Sig_Zp_o1,Sig_Ezp_o1,Cp_o1,Wp_o1,...
                                                  list_ConstructType_o2,Sig_Zp_o2,Sig_Ezp_o2,Cp_o2,Wp_o2,...
                                                  Sig_CVx,Bx,By,...
                                                  N,N_rep,DistType);

            vec_W1_true = Para.o1.W(W01);
            vec_W2_true = Para.o2.W(W02);
            vec_W_true=[vec_W1_true;vec_W2_true];            
            vec_C1_true = Para.o1.C(C01); 
            vec_C2_true = Para.o2.C(C02); 
            vec_C_true=[vec_C1_true;vec_C2_true];      
            vec_B_true = Para.o2.B(B0);

            Mat_Para_true = repmat([vec_W_true;vec_C_true;vec_B_true],[1,N_estimator]);
            for i3=1:N_N
                loc_n_st=loc_N(1,i3);
                loc_n_ed=loc_N(2,i3);
                loc_n = loc_n_st:loc_n_ed;
                fprintf('\n r = %f, N = %d',i4,list_N(i3)); 
                fprintf('\n=============================='); 
                if Flag_SaveEst; storage_est=zeros(Nwcb,N_estimator,N_rep); end
                if Flag_CR; storage_cr=zeros(N_estimator,N_rep); end
                if Flag_Parallel
                    parfor i2=1:N_rep
                        Z = Dataset(loc_n,:,i2);    
                        FuncEst = list_Function;            
                        FuncEstArgs = list_FunctionInput;  
                        for i1=1:N_estimator
                            estimatorFunc = FuncEst{i1};
                            estimatorArgs = FuncEstArgs{i1};
                            INI = estimatorFunc(Z, estimatorArgs{:});        
                            if Flag_SaveEst; storage_est(:,i1,i2)=[INI.W1(W01);INI.W2(W02);INI.C(C01);INI.B(C02_Spec);INI.B(B0_Spec)]; end
                            if Flag_CR; storage_cr(i1,i2)=INI.Converge; end
                        end
                    end
                else
                    for i2=1:N_rep                
                        fprintf('\n r = %4.3f, N = %d, iter = %d',i4,list_N(i3),i2); 
                        Z = Dataset(loc_n,:,i2);                
                        for i1=1:N_estimator
                            estimatorFunc = list_Function{1,i1};
                            estimatorArgs = list_FunctionInput{1,i1};
                            INI = estimatorFunc(Z, estimatorArgs{:});        
                            if Flag_SaveEst; storage_est(:,i1,i2)=[INI.W1(W01);INI.W2(W02);INI.C(C01);INI.B(C02_Spec);INI.B(B0_Spec)]; end
                            if Flag_CR; storage_cr(i1,i2)=INI.Converge; end
                        end
                    end                
                end
                loc_row_in_table=(i4-1)*N_ExpFac1+i3;
                if Flag_PR      
                    bias=Mat_Para_true-mean(storage_est,3);
                    sd=std(storage_est,1,3); 
                    rmse=(bias.^2+sd.^2).^(1/2);
                    Storage_PR_ind(i4,i3,:,:,1) = bias;
                    Storage_PR_ind(i4,i3,:,:,2) = sd;
                    Storage_PR_ind(i4,i3,:,:,3) = rmse;                
                    Storage_Est(i4,i3,:,:,:) = storage_est;    
                    Table_PR_avg(loc_row_in_table,:) = ...
                        [mean(abs([bias(loc_w,:),sd(loc_w,:),rmse(loc_w,:)]),1),...
                        mean(abs([bias(loc_c,:),sd(loc_c,:),rmse(loc_c,:)]),1),...
                        mean(abs([bias(loc_b,:),sd(loc_b,:),rmse(loc_b,:)]),1)];
                    Table_PR_avg(1:loc_row_in_table,:)
                end        
                if Flag_CR           
                    cr=mean(storage_cr,2);     
                    Storage_CR(i4,i3,:)=cr;
                    Table_CR(loc_row_in_table,:)=cr; 
                    Table_CR(loc_row_in_table,:)
                end
                if Flag_SafeBackup; save('Backup_TestSEM.mat'); end
            end
        end
    else 
        error("Currently, the SEM model with simple structure or higher-order constructs is supported."); 
    end
    if Flag_SaveEst; Results.Storage_Est = Storage_Est; end

    Results.ParameterRecovery=Flag_PR;
    Results.ConvergenceRate=Flag_CR;
    if Flag_PR      
        Results.Storage_PR_ind = Storage_PR_ind;
        Results.Table_PR_avg=Table_PR_avg;
        Results.loc_w=loc_w;
        Results.loc_c=loc_c;
        Results.loc_b=loc_b;
    end
    if Flag_CR
        Results.Storage_CR = Storage_CR;
        Results.Table_CR = Table_CR;
    end
end