A = [1.1269 -0.4940 0.1129;
     1.0000  0.0000 0.0000;
     0.0000  1.0000 0.0000];
 
B = [-0.3832; 0.5919; 0.5191];
C = [1 0 0];

Plant = ss(A,[B B],C,0,-1,'inputname',{'u' 'v'},'outputname','y');

Q = 1;
R = 1;
[kalmf,L,P,K] = kalman(Plant,Q,R);

a = A;
b = [B B 0*B];
c = [C;C];
d = [0 0 0;
     0 0 1];
 
P = ss(a,b,c,d,-1,'inputname',{'u' 'v' 'w'},'outputname',{'y' 'yw'});

sys = parallel(P,kalmf,1,1,[],[]);

SimModel = feedback(sys,1,4,2,1);   % Замыкаем 4й вход (yw) со 2м выходом (yw) системы SYS
SimModel = SimModel([1 3],[1 2 3]); % Удаляем yw из I/O списка

t = [0:100]';
u = sin(t/5);
n = length(t);
rng default
v = sqrt(Q)*randn(n,1);
w = sqrt(R)*randn(n,1);


[out,x] = lsim(SimModel,[v,w,u]);

y = out(:,1);   % истинный сигнал 
ye = out(:,2);  % отфильтрованный сигнал 
yw = y + w;     % измеренный сигнал 

subplot(211), plot(t,y,'--',t,ye,'-'),
xlabel('No. of samples'), ylabel('Output')
title('Kalman filter response')
subplot(212), plot(t,y - yw,'-.',t,y - ye,'-'),
xlabel('No. of samples'), ylabel('Error')