clear all
close all


run ../../install.m
run comsol_server_ini.m

%% generate model
[model, M, C, K] = build_model2();
%%
% Construction of M,C,K leads to excessive data stored in Assembly class
% which in turn increases memory requirements during computation when fint
% is called -> construct fint independently


n = length(M);
disp(['Number of degrees of freedom = ' num2str(n)])
disp(['Phase space dimensionality = ' num2str(2*n)])

%% Dynamical system setup

DS = DynamicalSystem();
set(DS,'M',M,'C',C,'K',K);

set(DS.Options,'Emax',5,'Nmax',10,'notation','multiindex')

%% Linear Modal analysis

[V,D,W] = DS.linear_spectral_analysis();

