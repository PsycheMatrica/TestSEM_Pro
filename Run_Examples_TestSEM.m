%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Illustration for TestSEM Pro package                                    %
%   Author: Gyeongcheol Cho                                               %
% Dependent on:                                                           %  
%   - DGP_SEM_Pro Package 1.1.                                            %
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
%   - GSCA_Prime Package 1.1                                              %
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
N_estimator = 2;
[DGP, Estimators, SimulationOption] = Initiate_TestSEM(TypeDGP,N_estimator);

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Example 2. Baek, Cho, & Hwang's (submitted) simulation study           %
%   - DGP - SEM model with 1st-order factors and 2nd-order components     %
%   - Estimators: IGSCA                                                   %
%   - Evaluation criterion: Parameter Recovery                            %
% Dependent on:                                                           %  
%   - HigherOrderIGSCA_Prime Package 1.0                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% References                                                              %
%     * Baek, I., Cho, G., & Hwang, H. (submitted). TBA                   %     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Step 1. Initiate three inputs (DGP, Estimators, SimulationOption) 
%           for the simulation study.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
help Initiate_TestSEM

DGPType = 2;
N_estimator = 1;
[DGP, Estimators, SimulationOption] = Initiate_TestSEM(DGPType,N_estimator);

% Step 2-1. Specify the parameter values of DGP in DGP.     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DGP
DGP.Measurement
DGP.Measurement.o1
P_o1 = 12; % # of factors
DGP.Measurement.o1.list_ConstructType = zeros(1,P_o1); 
DGP.Measurement.o1.Cp=[.6 .7 .8];
P_o2 = 4;
DGP.Measurement.o2
DGP.Measurement.o2.list_ConstructType = ones(1,P_o1); 
DGP.Measurement.o2.Sig_Zp=[1 .12248 .2603
                          .12248 1 .3369
                          .2603 .3369 1]; % covariance matrix for an indicator block
DGP.Structural
DGP.Structural.Bx = [.7  .5 -.3];
[Px_o2,Py_o2]=size(DGP.Structural.Bx);
DGP.Structural.By = [ 0 -.3  .5;
                      0  0  -.7;
                      0  0    0];
DGP.Structural.Sig_CVx = 1;

% Step 2-2: Enter estimation methods and their corresponding input 
%           arguments in 'Estimators'.
% Note1: Estimator functions should have a structure array
%         containing fields W1,W2, C, and B. If they do not meet this 
%         format, a wrap-up function will be required to adapt the 
%         output format for compatibility with this package.
% Note2: HigherOrderIGSCA_Prime package is required to run this code.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('C:\Users\cheol\Dropbox\Software_Development\SeCA_Pro\GSCA_Prime\HigherOrderIGSCA_Prime\')
help igsca_ho

Jp_o1=size(DGP.Measurement.o1.Cp,2); J_o1 = Jp_o1*P_o1;
W0_o1 = blkdiag(ones(Jp_o1,1),ones(Jp_o1,1),ones(Jp_o1,1),ones(Jp_o1,1),...
               ones(Jp_o1,1),ones(Jp_o1,1),ones(Jp_o1,1),ones(Jp_o1,1),...
               ones(Jp_o1,1),ones(Jp_o1,1),ones(Jp_o1,1),ones(Jp_o1,1))*99;
C0_o1 = W0_o1';
Jp_o2 = 3;
W0_o2 = blkdiag(ones(Jp_o2,1),ones(Jp_o2,1),ones(Jp_o2,1),ones(Jp_o2,1))*99;
C0_o2 = W0_o2';

C0_o2
B0_o2 = [0 1 1 1;
         0 0 1 1;
         0 0 0 1;
         0 0 0 0]*99;
P=P_o1+P_o2;
B0 = [zeros(P_o1,P);[C0_o2,B0_o2]];

dimtype1=ones(1,P_o1); 
dimtype2=zeros(1,P_o2); 

N_Boot=0;
Max_iter=500;
Min_limit=1e-4;

Estimators.list_Function = {@igsca_ho};
Estimators.list_FunctionInput = {{W0_o1,W0_o2,C0_o1,B0,dimtype1,dimtype2,N_Boot,Max_iter,Min_limit}};

% Step 2-3. Specify simulation options in SimulationOption.        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SimulationOption
SimulationOption.list_N=[50 100 250 500 1000];
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
List_Names.levels_Factor1=[NaN];
List_Names.PR_Eval=["Bias","SD","RMSE"];
List_Names.Estimator=["IGSCA"];
List_Names.Para=["W","C","B"];
List_Names.N=SimulationOption.list_N;
Summary_TestSEM(Results,List_Names);
