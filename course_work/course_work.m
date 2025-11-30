%% params
diary("course_work.txt")
NUM_IN_JOURNAL = 6;
BIT_FORMAT = 8;
L = 10;

%% 1) input your name
name = input("Input your name: ", "s");

%% 2) translate string to bits
bit_seq = coder(name);

disp("Your name in bits: ")
disp(bit_seq');

figure;
plot(0:1:length(bit_seq)-1, bit_seq);
xlabel("time");
ylabel("bit");
title("Message in bits");
grid on;

%% 3) compute CRC
polynome = [1,0,0,0,0,0,1,1,1]; % CRC-8 default polynome
crc = CRC(bit_seq', polynome);

disp("CRC:");
disp(crc');

% add CRC to data
data = [bit_seq',crc'];
% disp("data:");
% disp(data');

%% 4) generate golden seq
seq1 = dec2bin(NUM_IN_JOURNAL, BIT_FORMAT) - '0';
seq2 = dec2bin(NUM_IN_JOURNAL + 7, BIT_FORMAT) - '0';

poly1 = [5 3];     
poly2 = [5 3 2 1];

m_seq1 = m_seq_gen(seq1, poly1);
m_seq2 = m_seq_gen(seq2, poly2);

golden_seq = xor(m_seq1, m_seq2);

data = [golden_seq',data];

disp("sync-seq");
disp(golden_seq');

figure;
plot(0:1:length(golden_seq)-1, golden_seq);
xlabel("time");
ylabel("seq");
title("golden seq");

%% 5) upsampling
samples = upsampling(data, L);

% disp("samples:");
% disp(samples');

h = [1,1,1,1,1,1,1,1,1,1];
conv = convolve(samples, h);

figure;
plot(0:1:length(conv)-1, conv);
xlabel("time");
ylabel("sample value");
title("samples");

%% 6) add zeros
tx_data = zeros(2*length(conv), 1);
enter_index = str2double(input("Enter index for insert packet: ", "s"));

while true
 
    if enter_index + length(conv) > length(tx_data)
        enter_index = str2double(input("Enter index for insert packet: ", "s"));
        continue;
    end

    break;
end

for i = enter_index : enter_index + length(conv) - 1
    tx_data(i) = conv(i-enter_index+1);
end

%% 7) generate noise
var = str2double(input("Enter normal distribution var: ", "s"));
mu = 0;
noise = normrnd(mu, var, length(tx_data), 1);

% add noise to signal
rx_samples = tx_data + noise;

% disp(rx_samples);

figure;
plot(0:1:length(noise)-1, noise);
xlabel("time");
ylabel("noise value");
title("noise");

figure;
plot(0:1:length(rx_samples)-1, rx_samples);
xlabel("time");
ylabel("sample value");
title("recevive samples");

%% 8) corr receive

ups_golden_seq = convolve(upsampling(golden_seq, L), h);

corr_func = rx_corr(rx_samples, ups_golden_seq);

figure;
plot(0:1:length(corr_func)-1, corr_func);
xlabel("time");
ylabel("corr");
title("corr function");

start_sync_seq = start_sync(corr_func);
disp("start sync_seq:");
disp(start_sync_seq);

%% 9) translate samples to bit
bits = samples_to_bits(rx_samples(start_sync_seq:start_sync_seq+length(samples)), L);

%% 10) delete sync_seq from packet
bits = bits(length(golden_seq)+1:end);

figure;
plot(0:1:length(bits)-1, bits);
xlabel("time");
ylabel("corr");
title("corr function");

% disp(bits);

%% 11) check errors

rx_crc = CRC(bits, polynome);

% disp("RX CRC:")
% disp(rx_crc);

%% 12) delete crc

bits = bits(1:end-length(rx_crc));

disp("RX data:")
disp(bits);

%% 13) bits to char

rx_str = bin2str(bits);

disp(rx_str);


%% subfuncs

% string to bits
function bit_seq = coder(string)
    seq_len = length(string) * 8;

    bit_seq = zeros(seq_len, 1);

    for i=1:length(string)
        for k=1:8
            bit_seq((i-1)*8+k) = bitand(bitshift(int8(string(i)), -(8-k)), 1);
        end
    end
end

% CRC
function crc = CRC(bits, polynome)
    bits = bits(:);             
    n = length(polynome) - 1;  
    bits = [bits; zeros(n,1)]; 

    for i = 1:length(bits)-n
        if bits(i) == 1
            bits(i:i+n) = xor(bits(i:i+n), polynome(:));
        end
    end

    crc = bits(end-n+1:end);
end


% function for generate m-seq
function m_seq = m_seq_gen(seq, poly)
    
    m_seq_len = 2^length(seq) - 1;
    m_seq = zeros(m_seq_len, 1);
  
    for i=1:m_seq_len
        x = 0;

        %get bits for feedback
        for k=1:length(poly)
            x = xor(x, seq(poly(k)));
        end

        %write last bit default seq to result seq
        m_seq(i) = seq(end);

        %shift seq
        seq = circshift(seq, 1);

        %write in head bit from feedback
        seq(1) = x;
    end

end


% upsampling
function samples = upsampling(bits, N)
    samples = zeros(length(bits) * N, 1);

   for i = 1:length(bits)
        samples((i-1)*N + 1) = bits(i);
   end

end

function new_samples = convolve(samples, h)
    new_samples = zeros(length(samples), 1);
    for k=1:length(samples)
        sum = 0;
        for m=1:length(h)
            if(k-m > 0)
                sum = sum + samples(k-m)*h(m);
            end
        end

        new_samples(k) = sum;
    end

end

% norm cross-cor
function corr = norm_corr(a, b)

    if length(a) ~= length(b)
        disp("Vectors must be same size");
    end

    norm_coef = sqrt(sum(a.^2)) .* sqrt(sum(b.^2));
    corr_vals = unnorm_corr(a, b);

    corr = corr_vals / norm_coef;

end

% unnorm cross-cor
function corr = unnorm_corr(a, b)

    if length(a) ~= length(b)
        disp("Vectors must be same size");
    end

    corr = sum(a .* b);

end

function func = rx_corr(signal, sync_seq)
    signal = signal(:);

    signal_len = length(signal);
    seq_len    = length(sync_seq);

    func = zeros(signal_len, 1);

    for i = 1:signal_len
        idx = mod((i-1 : i+seq_len-2), signal_len) + 1;
        window = signal(idx);
        func(i) = norm_corr(window, sync_seq);
    end
end

% get index start sync
function index = start_sync(signal)
    max_value = -100;
    for i=1:length(signal)
        if signal(i) > max_value
            max_value = signal(i);
            index = i;
        end
    end
end

% samples to bits
function bits = samples_to_bits(samples, sample_per_bit)

    num_bits = floor(length(samples) / sample_per_bit);
    bits = zeros(1, num_bits);

    for k = 1:num_bits
        start_i = (k-1) * sample_per_bit + 1;
        end_i = k * sample_per_bit;

        bits(k) = mean(samples(start_i:end_i)) > 0.5;
    end
end

%bin to dec
function dec = bin2dec(bits)
    if length(bits) ~= 8
        disp("Length must be 8");
    end
    
    dec = 0;

    for i=1:length(bits)
        dec = dec + bits(9-i)*2^(i-1);
    end
end

% bits to string
function str = bin2str(bits)
    if mod(length(bits), 8) ~= 0
        disp("Length must % 8");
    end
    str = "";
    for i=1:length(bits)/8
        dec = bin2dec(bits((i-1)*8+1 : i*8));
        str = str + char(dec);
    end
end

