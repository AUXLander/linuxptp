% filePath = '../test/kalman_v2.5_w1.mtx'; sigmaV = 2.5; sigmaW = 1;
% filePath = '../test/kalman_v2.5_w2.5.mtx'; sigmaV = 2.5; sigmaW = 2.5;
% filePath = '../test/kalman_v5_w1.mtx'; sigmaV = 5; sigmaW = 1;
filePath = '../test/kalman_v5_w5.mtx'; sigmaV = 5; sigmaW = 5;
% filePath = '../test/kalman_v7.5_w7.5.mtx'; sigmaV = 7.5; sigmaW = 7.5;
% filePath = '../test/kalman_v10_w5.mtx'; sigmaV = 10; sigmaW = 5;
% filePath = '../test/kalman_v10_w10.mtx'; sigmaV = 10; sigmaW = 10;
% filePath = '../test/kalman_v15_w5.mtx'; sigmaV = 15; sigmaW = 5;
% filePath = '../test/kalman_v15_w10.mtx'; sigmaV = 15; sigmaW = 10;
% filePath = '../test/kalman_v30_w25.mtx'; sigmaV = 30; sigmaW = 25;

%n = 1
% filePath = '../test/kalman_n1_v14.4338_w3.mtx'; sigmaV = 14.4338; sigmaW = 3;

%n = 3
% filePath = '../test/kalman_n3_v14.4338_w3.mtx'; sigmaV = 14.4338; sigmaW = 3;
% filePath = '../test/kalman_n3_v14.4338_w7.mtx'; sigmaV = 14.4338; sigmaW = 7;
filePath = '../test/kalman_n3_v14.4338_w13.mtx'; sigmaV = 14.4338; sigmaW = 13;

kalman_001 = readmatrix(filePath, 'FileType','text');
kalman_001 = kalman_001(15:641,:);

%n = 1
% filePath = '../test/median_n1.mtx';

%n = 3
filePath = '../test/median_n3.mtx';

median_def = readmatrix(filePath, 'FileType','text');
median_def = median_def(15:1250,:);

title(strcat('sigmaV: ', num2str(sigmaV), ';  sigmaW: ', num2str(sigmaW)), 'FontSize',12);

hold on
plot(median_def(:,1),median_def(:,2), 'Color', 'b');
plot(kalman_001(:,1),kalman_001(:,2), 'Color', 'r');
hold off

MM = strcat('Median: M = ', num2str(M(median_def(:,2)),'% 10.2f'), ' D = ', num2str(D(median_def(:,2)),'% 10.2f'));
MK = strcat('Kalman: M = ', num2str(M(kalman_001(:,2)),'% 10.2f'), ' D = ', num2str(D(kalman_001(:,2)),'% 10.2f'));

legend({MM , MK}, 'FontSize',12);

function M = M(X)
    N = size(X,1);
    M = sum(X) / N;
end

function D = D(X)
    N = size(X,1);
    Mx = M(X);
    
    sum = 0;
    
    for k = 1:N
       sum = sum + ((X(k) - Mx)^2);
    end
    
    D = sqrt(sum / (N - 1));
end

% return;


% N = 1000;
% T = 1:1:N-1;
% 
% sigmaEta = 100;
% sigmaKsi = 100;
% 
% xi = zeros(1, N);
% zi = zeros(1, N);
% Tc = zeros(1, N);
% Tm = zeros(1, N);
% 
% Tc(1) = 10;
% Tm(1) = 1;
% 
% xi(1) = (Tm(1) - Tc(1)) + normrnd(0,sigmaKsi);
% zi(1) = xi(1) + normrnd(0,sigmaEta);
% 
% Q = 1.0;
% R = 20.0;
% F = 1.0;
% H = 1.0;
% B = 0.0;
% 
% state = Tc(1);
% covariance = 0.1;
% 
% ci = zeros(1, N);
% ci(1) = Tc(1);
% for i=1:N-1
% %    rOffset = Tm(i) - Tc(i);
% %    xi_ = rOffset - xi(i);
%    
%    xi(i+1) = (Tm(i) - Tc(i)) - xi(i) + normrnd(0,sigmaKsi);;
%    zi(i+1) = xi(i+1) + normrnd(0,sigmaEta);
%    
%    Tc(i+1) = Tc(i) + 1 + xi(i);
%    Tm(i+1) = Tm(i) + 1;
%    
%    
%    sample = xi(i+1);
%    
%    X0 = F * state + B*xi(i);
%    P0 = F * covariance * F + Q;
%    K  = H * P0 / (H * P0 * H + R);
% 
%    state = X0 + (K * (sample - (H * X0)));
%    covariance = (1.0 - K*H) * P0;
%    
%    ci(i+1) = state;
%    
%    Tc(i+1) = Tc(i) + 1 + ci(i);
%    Tm(i+1) = Tm(i) + 1;
% end
% 
% hold on
% plot(1:1:N, Tc(1,:) - Tm(1,:), 'Color', 'r');
% hold off

% hold on
% plot(1:1:N, zi(1,:), 'Color', 'r');
% plot(1:1:N, ci(1,:), 'Color', 'b');
% hold off

