clear all
close all


run ../../install.m
run comsol_server_ini.m

%% generate model
[model, M, C, K, Null, ud, U, disp_idx, tip_idx] = build_model3();
U = abs(U);
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

ic = V(1:n,1);
%% Parameters
% time simulation parameters
dt = 0.0001;
Tend = 0.2;
model.param.set('dt', dt,    'time step');                   
model.param.set('Tend', Tend,    'transient end time');
%%
created = 0;
if created == 0
    model.study.create('std3');
    model.study('std3').create('stat', 'Stationary');
end
model.study('std3').feature('stat').activate('solid', true);

model.study("std3").run(); % time transient with 1 time step (used only to define sol)
%%
% factor = ic(tip_idx);
UU = U;
factor = 1;
u0 = Null*ic*factor + ud;
UU(disp_idx) = U(disp_idx) + u0*0.25;
%%
model.sol('sol3').setU(UU);
model.sol('sol3').setPVals(0);
model.sol('sol3').createSolution;
%% check if solutions are consistent
UUU = mphgetu(model,'soltag','sol3','solnum',1);
diff = UUU-UU;
find(diff~=0)
%%
% created = 1;
if created == 0
    model.study.create('std4');
    model.study('std4').create('time', 'Transient');
end

model.study('std4').feature('time').set('probefreq', 'tout');
model.study('std4').feature('time').set('useinitsol', true);   % use initial solution
model.study('std4').feature('time').set('initmethod', 'sol');  % by selecting a previous solution
model.study('std4').feature('time').set('initstudy', 'std3');  % which is std1 (study 1)
model.study('std4').feature('time').set('initsol', 'sol3');
% model.study('std4').feature('time').set('solnum', 'first');    % selecting the first solution

% SOLUTION 4
if created == 0
model.sol.create('sol4');
model.sol('sol4').study('std4');
model.sol('sol4').attach('std4');
model.sol('sol4').create('st1', 'StudyStep');
model.sol('sol4').create('v1', 'Variables');
model.sol('sol4').create('t1', 'Time');
model.sol('sol4').feature('t1').create('fc1', 'FullyCoupled');
model.sol('sol4').feature('t1').create('d1', 'Direct');
model.sol('sol4').feature('t1').create('i1', 'Iterative');
model.sol('sol4').feature('t1').feature('i1').create('mg1', 'Multigrid');
model.sol('sol4').feature('t1').feature('i1').feature('mg1').feature('pr').create('so1', 'SOR');
model.sol('sol4').feature('t1').feature('i1').feature('mg1').feature('po').create('so1', 'SOR');
model.sol('sol4').feature('t1').feature('i1').feature('mg1').feature('cs').create('d1', 'Direct');
model.sol('sol4').feature('t1').feature.remove('fcDef');
end

model.sol('sol4').feature('v1').feature('comp1_solid_pblt1_sblt1_d_pre').set('scalemethod', 'manual');
model.sol('sol4').feature('v1').feature('comp1_u').set('scalemethod', 'manual');
model.sol('sol4').feature('v1').feature('comp1_solid_pblt1_sblt1_d_pre').set('scaleval', '1e-4');
model.sol('sol4').feature('v1').feature('comp1_u').set('scaleval', '1e-2*0.2827945006251376');
model.sol('sol4').feature('v1').set('control', 'time');

model.sol('sol4').feature('t1').set('tlist', 'range(0,0.0001,0.1)');
model.sol('sol4').feature('t1').set('plot', 'on');
model.sol('sol4').feature('t1').set('plotgroup', 'pg1');
model.sol('sol4').feature('t1').set('plotfreq', 'tout');
model.sol('sol4').feature('t1').set('probesel', 'all');
model.sol('sol4').feature('t1').set('probes', {'point1'});
model.sol('sol4').feature('t1').set('probefreq', 'tsteps');
model.sol('sol4').feature('t1').set('atolglobalvaluemethod', 'factor');
model.sol('sol4').feature('t1').set('reacf', true);
model.sol('sol4').feature('t1').set('storeudot', true);
model.sol('sol4').feature('t1').set('endtimeinterpolation', true);
model.sol('sol4').feature('t1').set('timemethod', 'genalpha');
model.sol('sol4').feature('t1').set('predictor', 'constant');
model.sol('sol4').feature('t1').set('control', 'time');


model.sol('sol4').attach('std4');
model.sol('sol4').feature('st1').label('Compile Equations: Time Dependent');
model.sol('sol4').feature('v1').label('Dependent Variables 1.1');
model.sol('sol4').feature('t1').set('probefreq', 'tout');

model.study("std4").feature("time").set("usertol", true);
%%

%%
rtol = 1e-3;
model.study("std4").feature("time").set("rtol", rtol); 
model.study('std4').feature('time').set('tlist', 'range(0,dt,Tend)');
%%
tic
model.study("std4").run();
toc
%%


% sol4info = mphsolinfo(model,'soltag','sol4','NU','on');
% NU = sol4info.sizesolvals;
% [u, udot] = mphgetu(model,'soltag','sol4','solnum',1:1:NU);
% u_out = u(out_full,:);
% udot_out = udot(out_full,:);
