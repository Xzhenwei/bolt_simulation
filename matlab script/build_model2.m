function [model, M, C, K] = build_model2()
import com.comsol.model.*
import com.comsol.model.util.*

mphopen -clear;

filename_comsol = 'full_model_modal_analysis.mph';
model = mphload(filename_comsol);
alpha = 1.8977;
beta = 1.9646e-6;
%% get MCK
% MA = mphmatrix(model ,'sol3', ...
%  'Out', {'K','D','E','Null','Nullf','ud','uscale'},'initmethod','sol', 'initsol', 'sol3');


MA = mphmatrix(model ,'sol3', ...
 'Out', {'Kc','Ec','Null','Nullf'},'initmethod','sol', 'initsol', 'sol1');
% M_0 = MB.E; 
% M_0 = MA.E;  K_0 = MA.K; Null = MA.Null;
% Nullf = MA.Nullf; 
% M = Nullf'*M_0*Null;

M=MA.Ec; K = MA.Kc;

% K = Nullf'*K_0*Null;

C = alpha*M + beta*K;
end