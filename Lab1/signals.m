
%% variables
step = 0.001;
t = 0 : step : 1-step;
f = 4;

%% signal
y = my_signal(t, f);

%% create and show plot
figure;
plot(t, y);
xlabel('t,c') 
ylabel('A,B')
title('sin(12*pi*f*t + pi/11) + sin(10*pi*f*t)')
grid on

%% sampling
Fs = 48;
t = 0 : 1/Fs : 1-(1/Fs);

samples = my_signal(t, f);

%% create plot with samples
figure;
plot(t, samples);
hold on;
plot(0:step:1-step, y);
hold off;
xlabel('t,c');
ylabel('A,B');
title('DAC');
grid on;
legend("Original","Recovery signal Fs = 48")

Fs = Fs * 4;

t = 0 : 1/Fs : 1-(1/Fs);

samples = my_signal(t, f);

figure;
plot(t, samples);
hold on;
plot(0:step:1-step, y);
hold off;
xlabel('t,c');
ylabel('A,B');
title('DAC');
grid on;
legend("Original","Recovery signal Fs = 48")

%% DFT
F = my_fft(samples); 
amps = abs(F);
%% Test ADC capacity
ADC_start = 3;
ADC_end = 6;
for ADC_capacity = ADC_start:ADC_end
    
    %quantum error rate
    QER = 0;

    sum_signal_value = 0;

    max_value = 2^ADC_capacity - 1;
    
    samples = zeros(1, length(t));
    
    for k = 1:length(t)
  
        signal_value = 40 * my_signal(t(k), f);
        sum_signal_value = sum_signal_value + abs(signal_value);

        if signal_value > max_value
            samples(k) = max_value;
            QER = QER + abs(signal_value - max_value);

        else
            samples(k) = round(signal_value);
            QER = QER + abs(signal_value - round(signal_value));

        end

    end

    F = my_fft(samples);

    amps1 = abs(F);

    N = length(F);
    f_axis = (0:N/2-1)*(Fs/N);
    subplot(1, ADC_end - ADC_start + 1, ADC_capacity - ADC_start + 1);
    stem(f_axis,amps1(1:N/2));
    xlabel('f,Hz') 
    ylabel('A,B')
    label = sprintf("ADC test, capacity = %d bit, QER = %.3f", ADC_capacity, round(QER/sum_signal_value, 3));
    title(label)


end

%% my_ft vs matlab my_fft
% t_test = 0 : 0.1 : 1000;
% test_samples = my_signal(t_test, f);
% time_sum_my_ft = 0;
% time_sum_matlab_fft = 0;
% 
% for i = 1:5
%     tic;
%     my_ft_samples = my_fft(test_samples);
%     time_sum_my_ft = time_sum_my_ft + toc;
% end
% 
% for i = 1:5
%     tic;
%     my_ft_samples = fft(test_samples);
%     time_sum_matlab_fft = time_sum_matlab_fft + toc;
% end
% 
% fprintf("Matlab avg fft time:%f\n", time_sum_matlab_fft/5);
% fprintf("My ft avg time:%f\n", time_sum_my_ft/5);

%% The imperial march

frequences = [392, 392, 392, 311, 466, 392, 311, 466, 392,...
  587, 587, 587, 622, 466, 369, 311, 466, 392,...
  784, 392, 392, 784, 739, 698, 659, 622, 659,...
  415, 554, 523, 493, 466, 440, 466,...
  311, 369, 311, 466, 392];

durations = [
  350, 350, 350, 250, 100, 350, 250, 100, 700, ...
  350, 350, 350, 250, 100, 350, 250, 100, 700, ...
  350, 250, 100, 350, 250, 100, 100, 100, 450, ...
  150, 350, 250, 100, 100, 100, 450, ... 
  150, 350, 250, 100, 750
  ];

my_song = [];
fs = 44100;

 for k = 1:length(frequences)
        t = 0:1/fs:durations(k)/1000-1/fs;   
        tone = sin(2*pi*frequences(k).*t);    
        my_song = [my_song, tone];                  
 end

song_spec = fft(my_song);
amps_spec = abs(song_spec);
N = length(amps_spec);
f_axis_song = (0:floor(N/2))*(fs/N);
amps_spec = 10*log10(amps_spec(1:floor(N/2)+1));

figure;
plot(10*log10(f_axis_song),amps_spec);
title("My song amplitude spectrum");
xlabel("f, Hz");
ylabel("A, V")


audio = audioplayer(my_song,fs);

audiowrite("song.mp3", my_song, 44100);

%play
%play(audio); 

%% create spectrum plot with samples
N = length(F);
f_axis = (0:floor(N/2))*(Fs/N);
amps = amps(1:floor(N/2)+1);

figure;
stem(f_axis, amps);
xlabel("f, Hz"); 
ylabel("A,B");
title("Amplitude-frequency representation");

%% SUB FUNCTIONS

function y = my_signal(t, f)
    y = sin(12*pi*f.*t + pi/11) + sin(10*pi*f.*t);
end


%                    N
%      X(k) =       sum  x(n)*exp(-j*2*pi*(k-1)*(n-1)/N), 1 <= k <= N.
%                   n=1

function F = my_fft(samples)
    N = length(samples);
    F = zeros(N, 1);
    for k = 1 : N
        sum = 0;
        for n = 1 : N
            sum = sum + samples(n) * exp(-1i * 2 * pi * (k-1) * (n-1)/N);
        end

        F(k) = sum;
    end
end




