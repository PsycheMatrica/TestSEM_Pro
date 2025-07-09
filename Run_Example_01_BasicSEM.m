%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Illustration for TestSEM Pro package under Basic SEM models             %
%   Author: Gyeongcheol Cho                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:                                                            %
%    This code aims to illustrate how to use TestSEM_Pro package to       %
%      test the performance of various SEM estimators.                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Example 1. Cho and Choi's (2020) simulation study                      %
%   - DGP - Basic SEM model with nomological component                    %
%   - Estimators: GSCA estimators with nomological/canonical components   %
%   - Evaluation criterion: Parameter Recovery                            %
% Dependent on:                                                           %  
%   - GSCA.Basic_Prime Package 1.4.3 (Cho, 2024)                          %
%   - PLSPM.Basic_Prime Package 1.3.2 (Cho & Hwang 2024)                  %    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% References                                                              %
%     * Cho, G., & Choi, J. Y. (2020). An empirical comparison of         %
%         generalized structured component analysis and partial least     %
%         squares path modeling under variance-based structural equation  %
%         models. Behaviormetrika, 47(1), 243–272.                        %
%         https://doi.org/10.1007/s41237-019-00098-0                      %  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Check_Dependency({"GSCA.Basic_Prime", "1.4.3"; ...
                  "PLSPM.Basic_Prime","1.3.2"});

% Step 1. Initiate three inputs (DGP, Estimators, SimulationOption) 
%           for the simulation study.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
help Initiate_TestSEM

DGPType = 1;
N_estimator = 4;
[DGP, Estimators, SimulationOption] = Initiate_TestSEM(DGPType,N_estimator);

% Step 2-1. Specify the parameter values of DGP in DGP.     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DGP
DGP.Measurement
P = 7; % # of components
DGP.Measurement.list_ConstructType = ones(P,1);
DGP.Measurement.Sig_Zp = zeros(4,4,3);
DGP.Measurement.Sig_Zp(:,:,1) = [1	0.24	0.24	0.17
                                  0.24	1	0.2	0.21
                                  0.24	0.2	1	0.13
                                  0.17	0.21	0.13	1];
DGP.Measurement.Sig_Zp(:,:,2) = [1	    0.5	   0.43	  0.30;
                                  0.50	1	   0.47	  0.23;
                                  0.43	0.47   1	  0.45;
                                  0.30	0.23   0.45	  1  ];
DGP.Measurement.Sig_Zp(:,:,3) = [1	0.49	0.56	0.66
                                 0.49	1	0.74	0.48
                                 0.56	0.74	1	0.69
                                 0.66	0.48	0.69	1];
DGP.Structural
DGP.Structural.Bx = [.5  .15   .3    0    0; % path coefficients from exogenous components to endogenous components
                      0   0     0   .5    0];
[Px,Py]=size(DGP.Structural.Bx);
DGP.Structural.By = [ 0  -.5   -.5   0    0; % path coefficients between endogenous components
                      0   0    -.3   0    0;
                      0   0     0  -.5   .5;
                      0   0     0    0   .15;
                      0   0     0    0    0];  
DGP.Structural.Sig_CVx = [1 .3;
                         .3  1];
%DGP.Structural.Sig_CVx = zeros(Px,Px,4);
%for i=1:4
%    r=.1+(i-1)*.2;
%    DGP.Structural.Sig_CVx(:,:,i)=[1 r;
%                                   r 1];
%end

% Step 2-2: Enter estimation methods and their corresponding input 
%           arguments in 'Estimators'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

help GSCA_Basic
help PLSPM_Basic

Jp=size(DGP.Measurement.Sig_Zp,1); J = Jp*P;
W0 = blkdiag(ones(Jp,1),ones(Jp,1),ones(Jp,1),ones(Jp,1),ones(Jp,1),ones(Jp,1),ones(Jp,1));
C0_nomological = W0';
C0_canonical = zeros(P,J);
B0 = [zeros(7,2),[DGP.Structural.Bx;DGP.Structural.By]~=0];
ind_sign=1:4:28;
N_Boot=0;
Max_iter=1000;
Min_limit=1e-8;
Flag_C_Forced=true;
Flag_Parallel=false;
modetype1=ones(1,P); % 1 for mode A; 
modetype2=ones(1,P)*2; % 2 for mode B;
correct_type=zeros(0,P);
scheme=3; %  1 = centroid, 2 = factorial, 3 = path weighting
Estimators
Estimators.list_Function = {@GSCA_Basic,@PLSPM_Basic, @GSCA_Basic,@PLSPM_Basic};
Estimators.list_FunctionInput = {{W0,C0_nomological,B0,ind_sign,N_Boot,Max_iter,Min_limit,Flag_C_Forced,Flag_Parallel},...
                                 {W0,B0,modetype1,scheme,correct_type,ind_sign,N_Boot,Max_iter,Min_limit,Flag_Parallel},...
                                 {W0,C0_canonical,B0,ind_sign,N_Boot,Max_iter,Min_limit,Flag_C_Forced,Flag_Parallel},...
                                 {W0,B0,modetype2,scheme,correct_type,ind_sign,N_Boot,Max_iter,Min_limit,Flag_Parallel}};

% Step 2-3. Specify simulation options in SimulationOption.        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SimulationOption
SimulationOption.list_N=[100 250 500 1000];
SimulationOption.N_rep =500;
SimulationOption.DistType=0;
SimulationOption.Flag_Parallel=true;
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

save_location=[cd,'\Results_TestSEM_01_BasicSEM.xls'];
List_Names.filename=save_location;
List_Names.ExpFactor=["Sig_Zp","N"];
List_Names.levels_Factor1=["r=.1","r=.3","r=.5","r=.7"];
List_Names.PR_Eval=["Bias","SD","RMSE"];
List_Names.Estimator=["GSCA(N)","GSCA(C)","PLSPM(A)","PLSPM(B)"];
List_Names.Para=["W","C","B"];
List_Names.N=SimulationOption.list_N;
Summary_TestSEM(Results,List_Names);