filePath = '../wireshark-data/terminal_5.edited.json';
filestring = fileread(filePath);

global data;
global sys_time;
global kalm_time;
global sys_time_index;
global sys_delay;
global sys_delay_index;
global sys_offset;
global sys_offset_index;

data = jsondecode(filestring);

N = numel(data);

removeDate = vpa('1617185946026000000');

sys_time = zeros(N, 1);
kalm_time = zeros(N, 1);

sys_time_index = 1;


sys_delay = zeros(N, 1);
sys_delay_index = 1;

sys_offset = zeros(N, 1);
sys_offset_index = 1;

rr = 1.0;

sys_time(1) = vpa('1617185946026397802')/2 + vpa('1617185946026556488')/2 - removeDate;




read_pair(1);

M = 0; % матожидание
D = 0; % дисперсия

for t = 2:1:N-1
    [time, offset] = read_pair(t);
    
    timestamp = mod(time - removeDate, 1e9);
    
    M = offset / N;
    
    sys_time(t) = timestamp - offset;   % устанавливаем время без сглаживания
end

sigmaPsi=6481430 / 3;
sigmaEta=6481430;

xOpt(1)=sys_time(1);
eOpt(1)=sigmaEta;

% Keep Kalman
for t = 1:1:N-1
    D = D +((sys_offset(t) - M)^2) / (N - 1);
    
    eOpt(t+1)=sqrt((sigmaEta^2)*(eOpt(t)^2+sigmaPsi^2)/(sigmaEta^2+eOpt(t)^2+sigmaPsi^2));
    K(t+1)=(eOpt(t+1))^2/sigmaEta^2;
    xOpt(t+1)=(xOpt(t)+a*t)*(1-K(t+1))+K(t+1)*sys_time(t + 1);
end

kalm_time = xOpt;

fprintf('M: %d & D: %d\n', M, D);

hold on
plot(1:N, sys_time);
plot(1:N, kalm_time);
hold off

function [time, offset] = read_pair(index)
    global data;
    global sys_delay;
    global sys_delay_index;

    global sys_offset;
    global sys_offset_index;
    
    object = data(index);

    t1 = vpa(object.t1);
    t2 = vpa(object.t2);
    t3 = vpa(object.t3);
    t4 = vpa(object.t4);

    delay  = 0.5*((t2-t1)+(t4-t3));
    offset = 0.5*((t2-t1)-(t4-t3));

    ratio = (t2 - t1) / (t4 - t3);
    freq = (1.0 - ratio) * 1e9;

    sys_delay(sys_delay_index) = delay;
    sys_delay_index = sys_delay_index + 1;

    sys_offset(sys_offset_index) = offset;
    sys_offset_index = sys_offset_index + 1;
    
    time = t3;
    
%     fprintf('master offset: %d, freq: %d, delay: %d\n', offset, freq, delay);
end