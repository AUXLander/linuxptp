clear all;

N = 1000;

sigmaV = 50.5;
sigmaW = 100.5;

X = zeros(1,N);
Y = zeros(1,N);
Q = zeros(1,N);

bX = zeros(1,N);
bP = zeros(1,N);

aX = zeros(1,N);
aP = zeros(1,N);

C = 1.0;

X(1) = 1;
Q(1) = 10;
aP(1) = 0.1;
aX(1) = X(1);

Y(1) = C * X(1) + normrnd(0, sigmaW);
for k = 1:N-1
    
    A = fA(Q(k), Y(k));
    
    % processing
    X(k+1) = A*X(k)   + normrnd(0, sigmaV);
    Y(k+1) = C*X(k+1) + normrnd(0, sigmaW);
    Q(k+1) = Q(k) * 0.8;
    
    % filtering
    Vk = sigmaV;
    Wk = sigmaW;
    
    bX(k+1) = A*aX(k);
    bP(k+1) = A*aP(k)*A + Vk;
    
    aX(k+1) = bX(k+1) + (1.0/((1.0/bP(k+1)) + C*(1.0/Wk)*C))*C*(1.0/Wk)*(Y(k+1) - C*bX(k+1));
    aP(k+1) = ( (1.0/bP(k+1)) + C*(1.0/Wk)*C );
    
%     aX(k+1) = bX(k+1) + C * (Y(k+1) - C*bX(k+1)) / (Wk * (1.0/bP(k+1)) + C * C);
%     aP(k+1) = Wk / (Wk * (1.0/bP(k+1)) + C * C);
    
end

title(strcat('sigmaV: ', num2str(sigmaV), ';  sigmaW: ', num2str(sigmaW)), 'FontSize',12);

hold on
plot(1:N,  X, 'g', 'LineWidth',2);
plot(1:N,  Y, 'r', 'LineWidth',2);
plot(1:N, aX, 'b', 'LineWidth',2);


legend({'истинная траектория', 'измеряемая траектория', 'сглаженная траектория'}, 'FontSize',12);


function A = fA(q, x)
    A = 1.0 + q/x;
end
