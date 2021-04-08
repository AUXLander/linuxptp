filePath = '../linux-data/calman_Q1.0_R100.0.mtx';
calman_001 = readmatrix(filePath, 'FileType','text');


filePath = '../linux-data/calman_Q2.0_R1000.0.mtx';
calman_002 = readmatrix(filePath, 'FileType','text');

filePath = '../linux-data/median.mtx';
median_def = readmatrix(filePath, 'FileType','text');


hold on
% plot(calman_001(:,1),calman_001(:,2), 'Color', 'r');
plot(calman_002(:,1),calman_002(:,2), 'Color', 'r');
plot(median_def(:,1),median_def(:,2), 'Color', 'b');
hold off