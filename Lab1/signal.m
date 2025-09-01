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
