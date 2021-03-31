filePath = '../wireshark-data/ptpv2_dump_4.json';
filestring = fileread(filePath);
data = jsondecode(filestring);

Synch = 0;
PDelayReq = 2;
PDelayResp = 3;
PDelayFollowUp = 10;

masterIpv4 = '192.168.69.69';
slaveIpv4 = '192.168.69.73';

sys_tmstmps = [-1 -1 -1 -1];

sys_delay = zeros(1000, 1);
sys_delay_index = 1;



for index = 1:numel(data)
    object = data(index);
   
    frameObject = object.x_source.layers.frame;
    
    split = strsplit(frameObject.frame_time_epoch, '.');
    
    frameTimeSeconds = uint64(str2num(char(split(1))));
    frameTimeNanoseconds = uint64(str2num(char(split(2))));
    
    ipv4Object = object.x_source.layers.ip;
    ipv4Src = ipv4Object.ip_src;
    
    ptpObject = object.x_source.layers.ptp;
    ptpType = str2num(ptpObject.ptp_v2_messageid);
    
    ptpTimeSeconds = 0;
    ptpTimeNanoseconds = 0;
    
    if (ptpType == Synch)
        
        sys_tmstmps = [0 0; 0 0; 0 0; 0 0];
        
    elseif (ptpType == PDelayReq) && strcmp(ipv4Src,slaveIpv4)
        
        sys_tmstmps(1,1) = uint64(frameTimeSeconds);
        sys_tmstmps(1,2) = uint64(frameTimeNanoseconds);
        
    elseif (ptpType == PDelayResp) && strcmp(ipv4Src,masterIpv4)
        
        ptpTimeSeconds = uint64(str2num(ptpObject.ptp_v2_pdrs_requestreceipttimestamp_seconds));
        ptpTimeNanoseconds = uint64(str2num(ptpObject.ptp_v2_pdrs_requestreceipttimestamp_nanoseconds));
        
        sys_tmstmps(2,1) = uint64(frameTimeSeconds);
        sys_tmstmps(2,2) = uint64(frameTimeNanoseconds);
        
        sys_tmstmps(3,1) = uint64(ptpTimeSeconds);
        sys_tmstmps(3,2) = uint64(ptpTimeNanoseconds);
        
    elseif (ptpType == PDelayFollowUp) && strcmp(ipv4Src,masterIpv4)
       
        ptpTimeSeconds = uint64(str2num(ptpObject.ptp_v2_pdfu_responseorigintimestamp_seconds));
        ptpTimeNanoseconds = uint64(str2num(ptpObject.ptp_v2_pdfu_responseorigintimestamp_nanoseconds));
        
        sys_tmstmps(4,1) = uint64(ptpTimeSeconds);
        sys_tmstmps(4,2) = uint64(ptpTimeNanoseconds);
        
    else
        continue;
    end
    
    format longEng
    
    if (can_calc_delay(sys_tmstmps))
       [tt1,tt2,tt3,tt4] = decomp(sys_tmstmps);
       sys_tmstmps = [0 0; 0 0; 0 0; 0 0];
       
       %4.531561548
       
       t1 = vpa(10^9) * vpa(tt4(1)) + vpa(tt4(2));
       
       t2 = vpa(10^9) * vpa(tt2(1)) + vpa(tt2(2));% - vpa('1617118596037812856');
       t3 = vpa(10^9) * vpa(tt1(1)) + vpa(tt1(2));% - vpa('1617118596037812856');
       
%        fprintf('t23: %d\n', t23);
       
       t4 = vpa(10^9) * vpa(tt3(1)) + vpa(tt3(2));
       
       rr = 1.0;
       
       delay = (t2 - t3) * rr + (t4 - t1);
       
       ratio1 = (t2 - t1) / (t4 - t3);
       
       t21 = (t2 - t1);% * ratio1;
       t43 = (t4 - t3);
       
       t23 = t2 - t3;
       t41 = t4 - t1;
       
       freq = (1.0 - ratio1) * 1e9;
       
       offset = t2 - t1 - delay;
       
       sys_delay(sys_delay_index) = delay;
       
       sys_delay_index = sys_delay_index + 1;
       
       fprintf('master offset: %d, freq: %d, delay: %d, t1: %d, t2: %d, t3: %d, t4: %d\n', offset, freq, delay, t1, t2, t3, t4);
    end
end

fprintf('Delay array size: %d\n', sys_delay_index);


function f = can_calc_delay(timestamps)
    [t1,t2,t3,t4] = decomp(timestamps);
    f = t1(1) > 0 && t2(1) > 0 && t3(1) > 0 && t4(1) > 0 && t1(2) > 0 && t2(2) > 0 && t3(2) > 0 && t4(2) > 0;
end

function [t1,t2,t3,t4] = decomp(timestamps)
    t1 = timestamps(1,:);
    t2 = timestamps(2,:);
    t3 = timestamps(3,:);
    t4 = timestamps(4,:);
end