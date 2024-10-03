function Help_TestSEM(DGPType)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initiate_TestSEM() - MATLAB function to print out the instruction for   %
%                      the simulation settings for the structural equation%
%                      model.                                             %
% Author: Gyeongcheol Cho                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input arguments: DGPType                                                %
%   DGPType: a scalar representing the type of data generating process    %
%       1 = Basic SEM model with factors/components                       %
%       2 = SEM model with higher-order constructs                        %
%       3 = SEM model with component interactions                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note: Currently, SEM model with simple structure or higher-order        % 
%       constructs is supported.                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if DGPType == 1
    fprintf("====================================================================================\n");
    fprintf("You have selected the basic SEM model with factors and/or components.\n");
    fprintf("Please review the instructions below carefully and specify the values of\n");
    fprintf("DGP, Estimators, and SimulationOptions structure array (three output arguments).\n");
    fprintf("You may call the instruction by typing 'Help_TestSEM(DGPType), where DGPType = 1'.\n");
    fprintf("====================================================================================\n");
    fprintf("1. DGP\n");
    fprintf("    .Measurement\n");
    fprintf("      .list_ConstructType = a 1 by P row vector where the pth entry indicates how to represent the pth construct.\n");
    fprintf("                    0 for factor,\n");
    fprintf("                    1 for nomological/principal component,\n");
    fprintf("                    2 for canonical component.\n");
    fprintf("      .Sig_Zp = a Jp by Jp covariance matrix of indicators for each component.\n");
    fprintf("      .Sig_Ezp = a Jp by Jp covariance matrix of measurement disturbances for each factor.\n");
    fprintf("      .Cp = a 1 by Jp vector of loadings for each factor.\n");
    fprintf("      .Wp = a Jp by 1 vector of unstandardized weights for each canonical component.\n");
    fprintf("      * Note 1: Prescribe the values of the following parameter sets\n");
    fprintf("                only if corresponding statistical proxies are used to represent constructs\n");
    fprintf("                in the population model. Otherwise, you may leave their values empty.\n");
    fprintf("                  a. Cp, Sig_Ezp for factors,\n");
    fprintf("                  b. Sig_Zp for nomological/principal components,\n");
    fprintf("                  c. Sig_Zp, Wp for canonical components.\n");
    fprintf("      * Note 2: Each type of statistical proxy is set to have the same values\n");
    fprintf("                for their measurement model parameters.\n");
    fprintf("    .Structural\n");
    fprintf("      .Bx = a Px by Py matrix of path coefficients from exogenous factors/components to endogenous ones.\n");
    fprintf("      .By = a Py by Py matrix of path coefficients between endogenous factors/components.\n");
    fprintf("      .Sig_CVx = a Px by Px by K tensor having K correlation matrices of exogenous components.\n");
elseif DGPType == 2
    fprintf("====================================================================================\n");
    fprintf("You have selected the SEM model with higher-order constructs.\n");
    fprintf("Please review the instructions below carefully and specify the values of\n");
    fprintf("DGP, Estimators, and SimulationOptions structure array (three output arguments).\n");
    fprintf("You may call the instruction by typing 'Help_TestSEM(DGPType), where DGPType = 2'.\n");
    fprintf("====================================================================================\n");
    fprintf("1. DGP\n");
    fprintf("    .Measurement\n");
    fprintf("       .o1: a field containing measurement model parameters for 1st-order constructs.  \n");    
    fprintf("           .list_ConstructType = a 1 by P1 row vector where the pth entry indicates how to represent the pth construct.\n");
    fprintf("               0 for factor,\n");
    fprintf("               1 for nomological/principal component,\n");
    fprintf("               2 for canonical component.\n");
    fprintf("           .Sig_Zp = a Jp1 by Jp1 covariance matrix of indicators for each component.\n");
    fprintf("           .Sig_Ezp = a Jp1 by Jp1 covariance matrix of measurement disturbances for each factor.\n");
    fprintf("           .Cp = a 1 by Jp1 vector of loadings for each factor.\n");
    fprintf("           .Wp = a Jp1 by 1 vector of unstandardized weights for each canonical component.\n");
    fprintf("       .o2: a field containing measurement model parameters for 2nd-order constructs. \n");    
    fprintf("           .list_ConstructType = a 1 by P2 row vector where the pth entry indicates how to represent the pth construct.\n");
    fprintf("               0 for factor,\n");
    fprintf("               1 for nomological/principal component,\n");
    fprintf("               2 for canonical component.\n");
    fprintf("           .Sig_Zp = a Jp2 by Jp2 covariance matrix of indicators for each component.\n");
    fprintf("           .Sig_Ezp = a Jp2 by Jp2 covariance matrix of measurement disturbances for each factor.\n");
    fprintf("           .Cp = a 1 by Jp2 vector of loadings for each factor.\n");
    fprintf("           .Wp = a Jp2 by 1 vector of unstandardized weights for each canonical component.\n");
    fprintf("      * Note 1: Prescribe the values of the following parameter sets\n");
    fprintf("                only if corresponding statistical proxies are used to represent constructs\n");
    fprintf("                in the population model. Otherwise, you may leave their values empty.\n");
    fprintf("                  a. Cp, Sig_Ezp for factors,\n");
    fprintf("                  b. Sig_Zp for nomological/principal components,\n");
    fprintf("                  c. Sig_Zp, Wp for canonical components.\n");
    fprintf("      * Note 2: Each type of statistical proxy is set to have the same values\n");
    fprintf("                for their measurement model parameters.\n");
    fprintf("    .Structural\n");
    fprintf("      .Bx = a Px by Py matrix of path coefficients from exogenous 2nd-order factors/components to endogenous 2nd-order ones.\n");
    fprintf("      .By = a Py by Py matrix of path coefficients between endogenous 2nd-order factors/components.\n");
    fprintf("      .Sig_CVx = a Px by Px by K tensor having K correlation matrices of exogenous 2nd-order factors/components.\n");
else
    fprintf("Other models are not supported yet.\n");
end
fprintf("2. Estimator\n");
fprintf("    .list_Function: a cell array including function handles for estimators.\n");
fprintf("       e.g., {@estimator1, @estimator2, @estimator3};\n");
fprintf("    .list_FunctionInput: a cell array including the input arguments of each function handle as its element.\n");
fprintf("       e.g., {{arg1}, %% for estimator 1,\n");
fprintf("              {arg1, arg2, arg3}, %% for estimator 2\n");
fprintf("              {arg1, arg2} %% for estimator 3};\n");
fprintf("3. SimulationOption\n");
fprintf("    .list_N = a row vector of sample sizes considered.\n");
fprintf("    .N_rep  = number of replications.\n");
fprintf("    .TypeDist: a scalar representing the distributional type.\n");
fprintf("       0 for normal distribution,\n");
fprintf("       1 for log-normal distribution (heavily peaked and skewed),\n");
fprintf("       2 for diff-normal distribution (heavily peaked but symmetric).\n");
fprintf("    .Flag_SafeBackup: a logical value to determine whether to save the results.\n");
fprintf("    .Flag_Parallel: a logical value to determine whether to run the simulation in parallel.\n");
fprintf("    .Criterion\n");
fprintf("       .ParameterRecovery = true,\n");
fprintf("       .ConvergenceRate = true,\n");
fprintf("       .SelectionRate  = false.\n");
fprintf("====================================================================================\n");

end