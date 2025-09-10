%read audio file 
[y, Fs] = audioread("SIBSUTIS.mp3"); 

%cut samples 
y_down = downsample(y, 10); 

%create audio object 
new_audio = audioplayer(y_down,Fs/10); 

%play 
%play(new_audio); 

%build plots 

%amp and time 
figure(1); 
plot(y_down); 
xlabel('t'); 
ylabel('A'); 
title('Signal'); 
grid on; 

%fft 
y_fft = fft(y); 
y_down_fft = fft(y_down); 

%build plots
figure(2); 
semilogx(abs(y_fft)); 
xlabel('f'); 
ylabel('A'); 
title('Signal'); 
grid on; 

figure(3); 
semilogx(abs(y_down_fft)); 
xlabel('f'); 
ylabel('A'); 
title('Signal'); 
grid on; 

%freq spectrum
spec = fft(y);

%shift freq spectrum
y_shift = my_shift(spec, 3000);

%reverse fft
y_time = ifft(y_shift);

%create audio
new_audio_2 = audioplayer(y_time,Fs);

%play
play(new_audio_2); 

function shift = my_shift(vec, n) 

    if n > 0
        zero_block = zeros(n, 2, class(vec));
        shift = [zero_block; vec];
    
    else
        zero_block = zeros(abs(n), 2, class(vec));
    
        if k < size(vec, 1)
            shift = [vec(abs(n)+1:end, :); zero_block];
        else
            shift = zero_block; 
        end
    end

end

