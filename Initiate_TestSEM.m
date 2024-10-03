function [DGP, Estimator, SimulationOption] = Initiate_TestSEM(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initiate_TestSEM() - MATLAB function to initiate the simulation settings%
%                       for the structural equation model.                %
% Author: Gyeongcheol Cho                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input arguments: DGPType                                                %
%   DGPType: a scalar representing the type of data generating process    %
%       1 = Basic SEM model with factors/components                       %
%       2 = SEM model with higher-order constructs                        %
%       3 = SEM model with component interactions                         %
%   N_estimator: a scalar representing the number of estimators to be     %
%                 tested.                                                 %
%   Note: If you do not specify the two input arguments,                  %
%           the function will ask you to enter the model number and the   %
%           number of estimators to be tested.                            %
% Output arguments: DGP, Estimator, SimulationOption                      %
%   DGP: a structure array including the parameters of the data           %
%        generating process (DGP) as its fields                           %
%   Estimator: a structure array including estimators and                 %
%               their input arguments as its fields                       %
%   SimulationOption: a structure array including the parameters of the   %
%                    simulation design as its fields                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note: Currently, only the basic SEM model is supported.                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if size(varargin,2)~=2
        prompt = ['Enter the model number of your interest.\n',...
                  '   1. Basic SEM model with factors/components\n',...
                  '   2. SEM model with higher-order constructs\n',...
                  '   3. SEM model with component interactions\n',...
                  '=> Model Number: '];
        DGPType=input(sprintf(prompt));
        prompt = ['Enter the number of estimators to be tested.\n',...
                  '=> Number of estimators: '];
        N_estimator=input(sprintf(prompt));
    else
        DGPType=varargin{1};
        N_estimator=varargin{2};
        if DGPType>2
            error(['Please enter the correct model number.',...
                   ' Currently, the SEM model with simple structure is supported.'])
        end
    end
    Help_TestSEM(DGPType);
    fprintf('You can call the instruction by typing "Help_TestSEM(ModelType)".\n');
    if DGPType==1                
        DGP = struct('DGPTYPE', DGPType, ...
                     'Measurement', struct('list_ConstructType', [], 'Sig_Zp', [], 'Sig_Ezp', [], 'Cp', [], 'Wp', []), ...
                     'Structural', struct('Bx', [], 'By', [], 'Sig_CVx', []));
    end
    Estimator = struct();%struct('list_Function', , 'list_FunctionInput', cell(1,N_estimator));
    Estimator.list_Function=cell(1,N_estimator);
    Estimator.list_FunctionInput=cell(1,N_estimator);
    SimulationOption = struct('list_N', [], 'N_rep', [], 'DistType', [],...
                              'Flag_SafeBackup',true,'Flag_Parallel',false,...
                              'Criterion', struct('ParameterRecovery', true, 'ConvergenceRate', false, 'SelectionRate', false));
end
   
