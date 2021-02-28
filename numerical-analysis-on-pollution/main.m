clear variables; close all; clc;

% params.pollutionProfile = @pollutionProfile_forward;
params.pollutionProfile = @pollutionProfile_backward;

%%
params.nx = 81;
params.ny = 81;
params.dt = 0.005;
params.tf = 0.25;
params.dx = 1/(params.nx-1);
params.dy = 1/(params.ny-1);
params.D = 0.05;
params.kindergarten = [0.5, 0.5]; % x,y
params.LU = 0;
params.spdiag = 0;

x = 0:params.dx:1;
y = 0:params.dy:1;
t = 0:params.dt:params.tf;
nt = length(t);
params.nt = nt;
params.t_0 = 0;

W = 1;
theta = pi/2;
a1 = 2;
a2 = 1;

%% part (e,f,g)
tic
u = params.pollutionProfile(W, theta, a1, a2, params);
toc
%%

uplot = reshape(u, [params.ny, params.nx, nt]);

num_contours = 50;

figure;
contour(x, y, uplot(:,:,1), num_contours);
colorbar;
title(sprintf('Pollution at t=%f', 0));
xlabel('x');
ylabel('y');

ind = round((nt-1)/2);
figure;
contour(x, y, uplot(:,:,ind), num_contours);
colorbar;
title(sprintf('Pollution at t=%f', t(ind)));
xlabel('x');
ylabel('y');

figure;
contour(x, y, uplot(:,:,nt), num_contours);
colorbar;
title(sprintf('Pollution at t=%f', params.tf));
xlabel('x');
ylabel('y');


%% part (i)
figure;
kindergarten_loc_ind = sub2ind([params.ny params.nx], find(y==params.kindergarten(2)), find(x==params.kindergarten(1)));
plot(t, u(kindergarten_loc_ind,:));
drawnow;
xlabel('time');
ylabel('pollution');

% compute total pollution
total_pol = totalPollution(W,theta,a1,a2,kindergarten_loc_ind, params);
fprintf('Total pollution at kindergarten is %f\n', total_pol);

%% part (j)
N_sims = 100;
all_sims = zeros(N_sims,1);
fprintf('Sample: %4d\n', 0);
for n_sim = 1:N_sims
    fprintf('\b\b\b\b\b%4d\n', n_sim);
    W_n = wblrnd(2,2);
    theta_n = 2*pi*rand;
    a1_n = exprnd(2);
    a2_n = exprnd(1);

    all_sims(n_sim) = totalPollution(W_n,theta_n,a1_n,a2_n,kindergarten_loc_ind, params);
end
K_mc =  mean(all_sims);
fprintf('Total average pollution: %f\n', K_mc);

%% part (m): find most dangerous wind parameters
a1 = 2; a2 = 1;

[xmin,fval] = fmincon(@(x)-totalPollution(x(1),x(2),a1, a2, kindergarten_loc_ind, params), ...
    [1 pi/2], [],[],[],[],[0 0], [5 2*pi], []);

W_star     = xmin(1);
theta_star = xmin(2);
fprintf('With a1=%.1f and a2=%.1f, the most dangerous params are:\n   W=%.2f, theta=%.2f\nwith a total pollution of\n   %f\n', a1, a2, W_star, theta_star, -fval);


a1 = 1; a2 = 2;

[xmin,fval] = fmincon(@(x)-totalPollution(x(1),x(2),...
    a1, a2, kindergarten_loc_ind, params), ...
    [1 3*pi/2], [],[],[],[],[0 0], [5 2*pi], []);

W_star     = xmin(1);
theta_star = xmin(2);
fprintf('With a1=%.1f and a2=%.1f, the most dangerous params are:\n   W=%.2f, theta=%.2f\nwith a total pollution of\n   %f\n', a1, a2, W_star, theta_star, -fval);
