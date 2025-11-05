%% read audio file 
[y, Fs] = audioread("SIBSUTIS.mp3"); 

%% cut samples 
y_down = downsample(y, 10); 

%% create audio object 
new_audio = audioplayer(y_down,Fs/10); 

%% play 
%play(new_audio); 

%% build plots 

%amp and time 
figure(1); 
plot(y_down); 
xlabel('t,c'); 
ylabel('A,B'); 
title('Signal'); 
grid on; 

%% fft 
y_fft = fft(y); 
y_ifft = ifft(y_fft);

y_down_fft = fft(y_down); 

%% build plots
figure;
subplot(2, 1, 1);
semilogx(abs(y_fft)); 
xlabel('f,Hz'); 
ylabel('A,B'); 
title('Voice amplitude-frequency representation'); 
grid on; 

subplot(2, 1, 2);
semilogx(abs(y_down_fft)); 
xlabel('f,Hz'); 
ylabel('A,B'); 
title('Voice (down samples) amplitude-frequency representation'); 
grid on; 

%%change voice

% get first column from y (mono)
y = y(:, 1);

%timeline
t = (0:length(y)-1)' / Fs;

%shift
f_shift = 759;
y_shifted = real(y .* exp(1i * 2 * pi * f_shift * t));

% check voice
new_audio = audioplayer(y_ifft, Fs);
play(new_audio);

%% function
function shift = my_shift(vec, n) 

    if n > 0
        zero_block = zeros(n, 1);
        shift = [zero_block; vec];
    
    else
        zero_block = zeros(abs(n), 1);
    
        if abs(n) < size(vec, 1)
            shift = [vec(abs(n)+1:end, :); zero_block];
        else
            shift = zero_block; 
        end
    end

end

