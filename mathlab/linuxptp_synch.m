filePath = '../wireshark-data/ptpv2_dump.json';
filestring = fileread(filePath);
data = jsondecode(filestring);

Synch = 0;
PDelayReq = 2;
PDelayResp = 3;
PDelayFollowUp = 10;

masterIpv4 = '192.168.69.69';
slaveIpv4 = '192.168.69.96';

sys_tmstmps = [-1 -1 -1 -1];

sys_delay = zeros(1000, 1);
sys_delay_index = 1;

for index = 1:numel(data)
    object = data(index);
   
    frameObject = object.x_source.layers.frame;
    frameTime = str2double(strsplit(frameObject.frame_time_epoch, '.'));
    
    frameTimeSeconds = frameTime(1);
    frameTimeNanoseconds = frameTime(2);
    
    ipv4Object = object.x_source.layers.ip;
    ipv4Src = ipv4Object.ip_src;
    
    ptpObject = object.x_source.layers.ptp;
    ptpType = str2num(ptpObject.ptp_v2_messageid);
    
    ptpTimeSeconds = 0;
    ptpTimeNanoseconds = 0;
    
    if (ptpType == Synch)
        
        sys_tmstmps = [-1 -1 -1 -1];
        
    elseif (ptpType == PDelayReq) && strcmp(ipv4Src,slaveIpv4)
        
        sys_tmstmps(1) = frameTimeNanoseconds;
        
    elseif (ptpType == PDelayResp) && strcmp(ipv4Src,masterIpv4)
        
        ptpTimeSeconds = str2num(ptpObject.ptp_v2_pdrs_requestreceipttimestamp_seconds);
        ptpTimeNanoseconds = str2num(ptpObject.ptp_v2_pdrs_requestreceipttimestamp_nanoseconds);
        
        sys_tmstmps(2) = frameTimeNanoseconds;
        sys_tmstmps(3) = ptpTimeNanoseconds;
        
    elseif (ptpType == PDelayFollowUp) && strcmp(ipv4Src,masterIpv4)
       
        ptpTimeSeconds = str2num(ptpObject.ptp_v2_pdfu_responseorigintimestamp_seconds);
        ptpTimeNanoseconds = str2num(ptpObject.ptp_v2_pdfu_responseorigintimestamp_nanoseconds);
        
        sys_tmstmps(4) = ptpTimeNanoseconds;
        
    else
        continue;
    end
    
    if (can_calc_delay(sys_tmstmps))
       [t1,t2,t3,t4] = decomp(sys_tmstmps);
       sys_tmstmps = [-1 -1 -1 -1];
       
       delay = (1/2)*((t2 - t1) + (t4 - t3));
       
       sys_delay(sys_delay_index) = delay;
       
       sys_delay_index = sys_delay_index + 1;
       
       fprintf('Delay: %d\n', uint64(delay));
    end
end

fprintf('Delay array size: %d\n', sys_delay_index);


function f = can_calc_delay(timestamps)
    [t1,t2,t3,t4] = decomp(timestamps);
    f = t1 > 0 && t2 > 0 && t3 > 0 && t4 > 0;
end

function [t1,t2,t3,t4] = decomp(timestamps)
    t1 = timestamps(1);
    t2 = timestamps(2);
    t3 = timestamps(3);
    t4 = timestamps(4);
end