filePath = '../wireshark-data/oran-data.json';
filestring = fileread(filePath);

data = jsondecode(filestring);

packages_count = numel(data);

header_byte_offset = 20;

resource_element_count = 12;
resource_element_size = 2;
ud_compression_size = 1;

physical_block_size = resource_element_count * resource_element_size + ud_compression_size;

delimeters = [0 255; 0 0];

N = 0;
for i = 1:packages_count
   data(i).x_source.layers.data.data_data = strcat(data(i).x_source.layers.data.data_data, ':0');
   object = data(i).x_source.layers.data;
    
   byte_length = numel(split(object.data_data, ':'));
   
   N = N + ((byte_length - header_byte_offset)/ physical_block_size) * resource_element_count;
   
   delimeters = [delimeters; N 0; N 255; N 0];
end

T = 1:1:N;

I = zeros(1, N);
Q = zeros(1, N);

k = 1;
for i = 1:packages_count
    object = data(i).x_source.layers.data;
    
    bytes = split(object.data_data, ':');
    byte_length = numel(bytes);
    
    for l = header_byte_offset:physical_block_size:(byte_length - physical_block_size)
       
        for j = 0:1:(resource_element_count-1)

            byte_i = bytes(l + j*resource_element_size + 0);
            byte_q = bytes(l + j*resource_element_size + 1);
            
            I(k) = hex2dec(byte_i);
            Q(k) = hex2dec(byte_q);
            
            k = k + 1;
        end 
    end
end

X = zeros(1,N);
Y = zeros(1,N);

length = 15000;

for k = T
    
    X(k) = 255 * abs(cos(2*pi*2*k/length));
    Y(k) = 255 * abs(sin(2*pi*2*k/length));
    
end

hold on

t = delimeters(:,1);
x = delimeters(:,2);
    
plot(t,x, 'g--', 'LineWidth',2);

plot(T,I, 'Color', 'b');
plot(T,Q, 'Color', 'r');

plot(T,X, 'Color', 'b');
plot(T,Y, 'Color', 'r');
hold off