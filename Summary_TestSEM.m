function Summarized_Results=Summary_TestSEM(Results,List_Names)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Summary_TestSEM() - MATLAB function to summarize the output results of  %
%                     TestSEM() and save the results to an external       %
%                     Excel file.                                         %
% Author: Gyeongcheol Cho                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input arguments:                                                        %
%   Results: A structure array containing the results of the Monte Carlo  %
%      simulation study. The result tables vary depending on the          %
%      evaluation criteria specified in SimulationOption. They may        %
%      include, but are not limited to, the following:                    %
%      - Storage_PR_ind: A 5D array containing parameter recovery         %
%          statistics (Bias, SD, RMSE) for each estimator per condition.  %
%      - Table_PR_avg: A table summarizing the parameter recovery         %
%          statistics for each estimator across parameters of the same    %
%          type per condition.                                            %
%      - Table_CR: A table showing the convergence rate of each           %
%          estimator per condition.                                       %
%   List_Names: A structure array containing the names of the variables   %
%      to be saved in the Excel file.                                     %
%      - filename: A string representing the name of the Excel file.      %
%      - ExpFactor: A 1x2 row vector where the first entry indicates the  %
%        name of the experimental factor and the second entry indicates   %
%        the sample size.                                                 %
%      - PR_Eval: A 1x3 row vector where the first entry indicates the    %
%        evaluation type (e.g., Bias, SD, RMSE).                          %
%      - Para: A 1x3 row vector where the first entry indicates the name  %
%        of the parameter (e.g., W, C, B).                                %
%      - Level_Factor1: A 1xN_LevFac1 row vector where each entry (p)     %
%        indicates the name of the pth level of the first experimental    %
%        factor.                                                          %
%      - N: A 1xN_N row vector where each entry (p) indicates the sample  %
%        size for the pth condition.                                      %
%      - Estimator: A 1xN_estimator row vector where each entry (p)       %
%        indicates the name of the pth estimator.                         %
% Output arguments:                                                       %
%   Summarized_Results: A structure array containing tables with the      %
%      average results of the Monte Carlo simulation study, organized by  %
%      sample size and estimator.                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    N_LevFac1=size(Results.Storage_Est,1);
    N_N=size(Results.Storage_Est,2);
    N_estimator=size(Results.Storage_Est,4);
    N_para=3;
    if nargin>1
        if isfield(List_Names,'filename'); filename=List_Names.filename; else; filename=cd+'Summary_TestSEM.xls'; end
        if isfield(List_Names,'ExpFactor'); list_ExpFactor=List_Names.ExpFactor; else; list_ExpFactor=["ExpFactor1","N"]; end
        if Results.ParameterRecovery
            N_eval=3;
            if isfield(List_Names,'PR_Eval'); list_PR_Eval=List_Names.PR_Eval; else; list_ExpFactor=["Bias","SD","RMSE"]; end
            if isfield(List_Names,'Para'); list_Para=List_Names.Para; else; list_Para=["W","C","B"]; end
        end
        if isfield(List_Names,'Level_Factor1'); list_LevFac1=List_Names.levels_Factor1; else; list_LevFac1=repmat("cond",[1,N_LevFac1])+(1:N_LevFac1); end
        if isfield(List_Names,'N'); list_N=List_Names.N; else; list_N=1:N_N; end
        if isfield(List_Names,'Estimator'); list_Estimator=List_Names.Estimator; else; list_Estimator=repmat("cond",[1,N_estimator])+(1:N_estimator); end    
    end    
    if Results.ParameterRecovery
        %Cond_1,Sample_Size, Para,Estimator,EvalType
        %{
        Results_W=squeeze(mean(abs(Results.Storage_PR(:,:,Results.loc_w,:,:)),3));
        Results_C=squeeze(mean(abs(Results.Storage_PR(:,:,Results.loc_c,:,:)),3));
        Results_B=squeeze(mean(abs(Results.Storage_PR(:,:,Results.loc_b,:,:)),3));
        Final_Table_PR=zeros(N_N*N_LevFac1,N_estimator*N_eval);
        for i1=1:N_LevFac1
            table_given_i1=zeros(N_N,N_estimator*N_eval);
            for i_eval=1:3
                table_given_i1(:,(N_estimator*(i_eval-1)+1):(N_estimator*i_eval))=[squeeze(Results_W(i1,:,:,i_eval)),Results_C(i1,:,:,i_eval),Results_B(i1,:,:,i_eval)];
            end
            Final_Table_PR((N_N*(i1-1)+1):(N_N*i1),:)=table_given_i1;    
        end
        Summarized_Results.Final_Table_PR=Final_Table_PR;
        %}
        Results_W_avg=squeeze(mean(abs(Results.Storage_PR_ind(:,:,Results.loc_w,:,:)),3));
        Results_C_avg=squeeze(mean(abs(Results.Storage_PR_ind(:,:,Results.loc_c,:,:)),3));
        Results_B_avg=squeeze(mean(abs(Results.Storage_PR_ind(:,:,Results.loc_b,:,:)),3));
        if N_LevFac1>1
            Table_PR_avg_per_N=...
                [reshape(squeeze(mean(Results_W_avg,1)),[N_N,N_estimator*N_eval]),...
                 reshape(squeeze(mean(Results_C_avg,1)),[N_N,N_estimator*N_eval]),...   
                 reshape(squeeze(mean(Results_B_avg,1)),[N_N,N_estimator*N_eval])];
        else
            Table_PR_avg_per_N=...
                [Results_W_avg,Results_C_avg,Results_B_avg];
        end
        disp('Parameter Recovery per sample size and estimator')
        Table_PR_avg_per_N
        Summarized_Results.Table_PR_avg_per_N=Table_PR_avg_per_N;
        writematrix(list_ExpFactor,filename,'Sheet','PR','Range','A3','WriteMode','replacefile');
        writematrix(...
        [reshape(repmat(list_Para,[N_eval*N_estimator,1]),[N_eval*N_estimator*N_para,1])';
        repmat(reshape(repmat(list_PR_Eval,[N_estimator,1]),[N_eval*N_estimator,1])',[1,N_para]);
        repmat(list_Estimator,[1,N_eval*N_para])],filename,'Sheet','PR','Range','C1');
        writematrix(...
        [reshape(repmat(list_LevFac1,[N_N,1]),[N_N*N_LevFac1,1]),...
        reshape(repmat(list_N',[1,N_LevFac1]),[N_N*N_LevFac1,1]),...
            Results.Table_PR_avg],filename,'Range','A4','Sheet','PR');
    end
    if Results.ConvergenceRate
        writematrix([list_ExpFactor,list_Estimator],filename,'Sheet','CR','Range','A1');
        writematrix(...
        [reshape(repmat(list_LevFac1',[1,N_N]),[N_N*N_LevFac1,1]),...
        reshape(repmat(list_N',[1,N_LevFac1]),[N_N*N_LevFac1,1]),...
            Results.Table_CR],filename,'Range','A2','Sheet','CR');
        %Table_CR=zeros(N_ExpFac1*N_N,N_estimator);
        Table_CR_avg_per_N=squeeze(mean(Results.Storage_CR,1));
        disp('Convergence Rate per sample size and estimator')
        Table_CR_avg_per_N
        Summarized_Results.Table_CR_avg_per_N=Table_CR_avg_per_N;
    end
end