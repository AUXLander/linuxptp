clear all;

N = 500;

T = 0;

LN = 1:N;

AbsT = 5 * ones(N,1);

AbsQ = 150 * ones(N, 1);

dQ = 150 * ones(N, 1);
dT = zeros(N, 1);


bX = zeros(1,N);
bP = zeros(1,N);

aX = zeros(1,N);
aP = zeros(1,N);

aP(1) = 0.1;
aX(1) = AbsQ(1);

qP = 0;
tP = 1;

C = 1.0;


sigmaV = 50;
sigmaW = 0.001;

for k = LN
    
    if k == N break; end;
    
    T1 = T + AbsT(k+1);
    T2 = T1 + AbsQ(k+1);
    T3 = T + AbsQ(k+1);
    T4 = T3 + AbsT(k+1) - AbsQ(k+1);
    
    if k == N break; end;
    
    % Çàøóìëåíèå %
    
    T1 = T1 + normrnd(0,sigmaV);
    T4 = T4 + normrnd(0,sigmaV);
    
    % Âû÷èñëåíèå ñìåùåíèÿ è âğåìåíè äîñòàâêè %
    
%   dQ(k) = ((T2 - T1) - (T4 - T3))/2;    
    dT(k+1) = ((T2 - T1) + (T4 - T3))/2;
    
    % Ôèëüòğàöèÿ çíà÷åíèé %
    
%     dQ(k+1) = T2 - T1 - filter(dT(k+1));
    Z = T2 - T1 - filter(dT(k+1));
    
    A = fA(qP, tP);
    
    % filtering
    Vk = sigmaV^2;
    Wk = sigmaW^2;
    
    bX(k+1) = A*aX(k);
    bP(k+1) = A*aP(k)*A + Vk;
    
    aX(k+1) = bX(k+1) + (1.0/((1.0/bX(k+1)) + C*(1.0/Wk)*C))*C*(1.0/Wk)*(dT(k+1) - C*bX(k+1));
    aP(k+1) = ( (1.0/bP(k+1)) + C*(1.0/Wk)*C );
    
    dQ(k+1) = T2 - T1 - aX(k+1);
    
    qP = AbsQ(k+1);
    tP = dQ(k+1);
    
    % Ïåğåâîäèì ÷àñû %
    
    if k + 1 == N break; end;
    
    AbsQ(k + 1 + 1) = AbsQ(k+1) - Z;
end

dT(N) = dT(N-1);

aX(:) = [aX(1:10) 0.3 * aX(11:end)];

hold on;
plot(LN, dQ, 'b');
% plot(LN, AbsQ, 'r');
plot(LN, aX, 'Color', [248/255 108/255 10/255],'LineWidth',3);

% plot(LN, dT);
% plot(LN, AbsT);

function f = filter(sample)
    f = sample;
end

function A = fA(q, x)
    A = 1.0 + q/x;
    
%     if q/x > 1
%        
%         A = 1;
%         
%     end
    
end