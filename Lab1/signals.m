
%variables
step = 0.001;
t = 0 : step : 2-step;
f = 1;

%signal
y = my_signal(t, f);

%create and show plot
figure;
plot(t, y);
xlabel('t') 
ylabel('A')
title('Signal')
grid on

%sampling
Fs = 48 * 4;
t = 0 : 1/Fs : 1-(1/Fs);

samples = my_signal(t, f);

%DFT
F = fft(samples); 

amps = abs(F);

%create plot with samples
figure;
plot(t, samples);
xlabel('t') 
ylabel('A')
title('Signal')

grid on

%create spectrum plot with samples
N = length(F);
f_axis = (0:N/2-1)*(Fs/N);
figure;
plot(f_axis,amps(1:N/2));
xlabel('f') 
ylabel('A')
title('Signal')

%Test ADC capacity
for ADC_capacity = 3:6

    max_value = 2^ADC_capacity - 1;
    
    samples = zeros(1, length(t));
    
    for k = 1:length(t)

        tmp = 50 * my_signal(t(k), f);

        if tmp > max_value
            samples(k) = max_value;
        else
            samples(k) = tmp;
        end

    end

    F = fft(samples);

    amps = abs(F);

    N = length(F);
    f_axis = (0:N/2-1)*(Fs/N);
    figure;
    plot(f_axis,amps(1:N/2));
    xlabel('f') 
    ylabel('A')
    title('Signal')


end

function y = my_signal(t, f)
    %y = sin(12*pi*f.*t + pi/11) + sin(10*pi*f.*t);
    y = sin(10 * pi .* t * f);
end




