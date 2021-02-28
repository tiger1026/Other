function out = totalPollution(W, theta, a1,a2,location_ind, params)

u = params.pollutionProfile(W, theta, a1,a2, params);
out = trapz(u(location_ind,:))*params.dt; % params.t_0_ind:end