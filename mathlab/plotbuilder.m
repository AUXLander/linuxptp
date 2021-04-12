filePath = '../linux-data/calman_Q1.0_R1.8.mtx';
calman_001 = readmatrix(filePath, 'FileType','text');


filePath = '../linux-data/calman_Q1.0_R2.0.mtx';
calman_002 = readmatrix(filePath, 'FileType','text');

filePath = '../linux-data/median.mtx';
median_def = readmatrix(filePath, 'FileType','text');

hold on
% plot(median_def(:,1),median_def(:,2), 'Color', 'b');
% plot(calman_001(:,1),calman_001(:,2), 'Color', 'r');
% plot(calman_002(:,1),calman_002(:,2), 'Color', 'b');
hold off


% return;


N = 1000;
T = 1:1:N-1;

sigmaEta = 100;
sigmaKsi = 100;

xi = zeros(1, N);
zi = zeros(1, N);
Tc = zeros(1, N);
Tm = zeros(1, N);

Tc(1) = 10;
Tm(1) = 1;

xi(1) = (Tm(1) - Tc(1)) + normrnd(0,sigmaKsi);
zi(1) = xi(1) + normrnd(0,sigmaEta);

Q = 1.0;
R = 20.0;
F = 1.0;
H = 1.0;
B = 0.0;

state = Tc(1);
covariance = 0.1;

ci = zeros(1, N);
ci(1) = Tc(1);
for i=1:N-1
%    rOffset = Tm(i) - Tc(i);
%    xi_ = rOffset - xi(i);
   
   xi(i+1) = (Tm(i) - Tc(i)) - xi(i) + normrnd(0,sigmaKsi);;
   zi(i+1) = xi(i+1) + normrnd(0,sigmaEta);
   
   Tc(i+1) = Tc(i) + 1 + xi(i);
   Tm(i+1) = Tm(i) + 1;
   
   
   sample = xi(i+1);
   
   X0 = F * state + B*xi(i);
   P0 = F * covariance * F + Q;
   K  = H * P0 / (H * P0 * H + R);

   state = X0 + (K * (sample - (H * X0)));
   covariance = (1.0 - K*H) * P0;
   
   ci(i+1) = state;
   
   Tc(i+1) = Tc(i) + 1 + ci(i);
   Tm(i+1) = Tm(i) + 1;
end

hold on
plot(1:1:N, Tc(1,:) - Tm(1,:), 'Color', 'r');
hold off

% hold on
% plot(1:1:N, zi(1,:), 'Color', 'r');
% plot(1:1:N, ci(1,:), 'Color', 'b');
% hold off

