function display_figures(fig)
addpath("export_fig")


filename = "samples2/C3TextNovoSimple50cmPt1.wav";
[y, Fs] = audioread(filename);
fontsize = 12;
fontaxissize = 10;

if(fig == 1)
    %For C3Blank50cmPt1.wav
    left = 0.15;
    bottom1 = 0.5;
    bottom2 = 0.01;
    width = 0.8;
    height = 0.45; 
    

    figure
    %set(1, 'units', 'centimeters', 'pos', [0 0 17.77 50])
    yss = y(15800000:15920000);
    %s = subplot(2,1,1);
    ax = axes('Position',[left bottom1 width height]);

    plot((1:length(yss))/Fs,yss)


    set(gca, 'XTickLabel', [],'XTick',[])
    ax=gca;
    ax.YAxis.FontSize = fontaxissize;
    xticklabels = ax.YTickLabel;
    xticklabels(1) = {''};

    %ax.YTickLabel = xticklabels;
    %set(gca, 'FontSize', 10);
    xlim([0 length(yss)/Fs])
    ylabel('Magnitude','FontSize', fontsize)
    ylabel('Magnitude','FontWeight', 'bold')

    Nwindow = 128;
    Noverlap = 100;
    f = 1000;
    %s = subplot(2,1,2);
    axes('Position',[left bottom2 width height])
    spectrogram(yss, Nwindow, Noverlap, f, Fs, 'yaxis');
    ax=gca;
    ax.YAxis.FontSize = fontaxissize;
    ax.XAxis.FontSize = fontaxissize;
    ylim([0 21]);
    xl = xlabel('Time (s)', 'FontSize', fontsize);
    xl.FontWeight = 'bold';
    yl = ylabel('Frequency (kHz)', 'FontSize', fontsize);
    yl.FontWeight = 'bold';
    set(yl, 'position', get(yl,'position') - [0.05 0 0]);
    c = colorbar;
    c.Location = 'southoutside';
    t = title(c,'Power/frequency (dB/Hz)');
    set(t,'position',get(t,'position')-[-180 30 0])
    set(t, 'fontsize', fontsize)
    set(t, 'fontweight', 'bold')
    set(gcf, 'Color', 'w');
    c.FontSize = fontaxissize;
    %}
    %ff = openfig('plots/magnspec.fig');
    %a=findobj(ff,'type','axe')
    %set(a.Title, 'fontsize', 12)
elseif fig == 2
    class_idx = regexp(filename, 'C[0-9]');
    class = str2double(filename{1}(class_idx+1));
    type = "Text";
    parameter = getParameter(class, type);
    
    %Filter parameters
    Wp = [parameter.lofrec parameter.hifrec]/(Fs/2);
    Rp = 0.1;
    Rs = 60;
    n = 6;

    [b, c] = ellip(n,Rp,Rs,Wp);
    yband = filtfilt(b, c, y); %Filter the signal
    [ff, ~] = envelope(yband, 1000, 'rms'); %Compute signal's envelope


    out = ff/sqrt(sum(abs(ff .^2)) / length(ff)); %Normalize

    out = downsample(out, 1000); %Downsample

    figure;
    %plot((1:length(out))*1000/Fs,out)
    plot((3273:3497)*1000/Fs,out(3273:3497));
    xlim([3273*1000/Fs 3497*1000/Fs])
    %plot(out)
    xl = xlabel('Time(s)');
    yl = ylabel('Magnitude');
    xl.FontSize = fontsize;
    xl.FontWeight = 'bold';
    yl.FontSize = fontsize;
    yl.FontWeight = 'bold';
    gca.YAxis.FontSize = fontaxissize;
    gca.XAxis.FontSize = fontaxissize;
    set(gcf, 'Color', 'w');
    
    end
    %export_fig magnspec.png -nocrop

end