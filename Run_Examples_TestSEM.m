%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Illustration for TestSEM Pro package                                    %
%   Author: Gyeongcheol Cho                                               %
%   Last Revision Date: September 24, 2024                                %  
% Dependent on:                                                           %  
%   - DGP_SEM_Pro Package 1.1.                                            %
%   - GSCA_Prime Package 1.1                                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:                                                            %
%    This code aims to illustrate how to use TestSEM_Pro package to       %
%      test the performance of various SEM estimators.                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Example 1. Cho and Choi's (2020) simulation study                      %
%   - DGP - Basic SEM model with nomological component                    %
%   - Estimators: GSCA and PLSPM estimators                               %
%   - Evaluation criterion: Parameter Recovery                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% References                                                              %
%     * Cho, G., & Choi, J. Y. (2020). An empirical comparison of         %
%         generalized structured component analysis and partial least     %
%         squares path modeling under variance-based structural equation  %
%         models. Behaviormetrika, 47(1), 243–272.                        %
%         https://doi.org/10.1007/s41237-019-00098-0                      %  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Step 1. Initiate three inputs (DGP, Estimators, SimulationOption) 
%           for the simulation study.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
help Initiate_TestSEM

TypeDGP = 1;
N_estimators = 2;
[DGP, Estimators, SimulationOption] = Initiate_TestSEM(TypeDGP,N_estimators);

% Step 2-1. Specify the parameter values of DGP in DGP.     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DGP
DGP.Measurement
P = 7; % # of components
DGP.Measurement.list_ConstructType = ones(1,P);
DGP.Measurement.Sig_Zp = [1	    0.5	   0.43	  0.30;
                          0.50	1	   0.47	  0.23;
                          0.43	0.47   1	  0.45;
                          0.30	0.23   0.45	  1  ]; 
DGP.Structural
DGP.Structural.Bx = [.5  .15   .3    0    0; % path coefficients from exogenous components to endogenous components
                      0   0     0   .5    0];
[Px,Py]=size(DGP.Structural.Bx);
DGP.Structural.By = [ 0  -.5   -.5   0    0; % path coefficients between endogenous components
                      0   0    -.3   0    0;
                      0   0     0  -.5   .5;
                      0   0     0    0   .15;
                      0   0     0    0    0];  
DGP.Structural.Sig_CVx = zeros(Px,Px,4);
for i=1:4
    r=.1+(i-1)*.2;
    DGP.Structural.Sig_CVx(:,:,i)=[1 r;
                                   r 1];
end

% Step 2-2: Enter estimation methods and their corresponding input 
%           arguments in 'Estimators'.
% Note1: Estimator functions should have a structure array
%         containing fields W, C, and B. If they do not meet this 
%         format, a wrap-up function will be required to adapt the 
%         output format for compatibility with this package.
% Note2: BasicGSCA package is required to run this code.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

help BasicGSCA

Jp=size(DGP.Measurement.Sig_Zp,1); J = Jp*P;
W0 = blkdiag(ones(Jp,1),ones(Jp,1),ones(Jp,1),ones(Jp,1),ones(Jp,1),ones(Jp,1),ones(Jp,1));
C0_nomological = W0';
C0_canonical = zeros(P,J);
B0 = [zeros(7,2),[DGP.Structural.Bx;DGP.Structural.By]~=0];

N_Boot=0;
Max_iter=1000;
Min_limit=1e-8;
Flag_C_Forced=true;
Flag_Parallel=false;

Estimators
Estimators.list_Function = {@BasicGSCA, @BasicGSCA};
Estimators.list_FunctionInput = {{W0,C0_nomological,B0,N_Boot,Max_iter,Min_limit,Flag_C_Forced,Flag_Parallel},...
                                 {W0,C0_canonical,B0,N_Boot,Max_iter,Min_limit,Flag_C_Forced,Flag_Parallel}};

% Step 2-3. Specify simulation options in SimulationOption.        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SimulationOption
SimulationOption.list_N=[100 250 500 1000];
SimulationOption.N_rep =500;
SimulationOption.DistType=1;
SimulationOption.Criterion.ParameterRecovery=true;
SimulationOption.Criterion.ConvergenceRate=true;
%SimulationOption.Criterion.SelectionRate=false;

% Step 3. Run the simulation study via TestSEM() function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
help TestSEM

Results = TestSEM(DGP,Estimators,SimulationOption);
Results.Table_PR_avg
Results.Table_PR_avg

% Step 4. Save the results.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
help Summary_TestSEM

save_location=[cd,'\Results_TestSEM.xls'];
List_Names.filename=save_location;
List_Names.ExpFactor=["Sig_CVx","N"];
List_Names.levels_Factor1=[.1, .3 .5 .7];
List_Names.PR_Eval=["Bias","SD","RMSE"];
List_Names.Estimator=["GSCA(n)","GSCA(c)"];
List_Names.Para=["W","C","B"];
List_Names.N=SimulationOption.list_N;
Summary_TestSEM(Results,List_Names);