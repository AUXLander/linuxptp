clear all;
filePath = '../test/raw/ndl=20_q.mtx';
x = readmatrix(filePath, 'FileType','text');

% X = -25:1:25;
% Y = normpdf(X,0,25);


hold on
histogram(x(15:end, 2), 45);