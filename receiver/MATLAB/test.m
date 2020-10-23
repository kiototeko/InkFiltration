clear all;
warning('off','all');
addpath('./export_fig/');
dir = "samples2/"; 

distances = ["50cm", "2m", "4m", "6m", "8m"];
orientations = ["", "Side", "Upside"];
distances_orientations = ["50cm", "4m", "8m"];
layouts = ["ArialLeft", "Columns", "Table", "Complex", "White"];
fonts = ["ArialLeft", "Times", "Courier"];

classes = 1:3;
results_file = "results.mat";
%% FPM-DPPM
berTextBlank = zeros(length(classes), length(distances), length(orientations));
ampTextBlank = zeros(length(classes), length(distances), length(orientations));

for class = classes
    for n = 1:length(distances)
        for m = 1:length(distances_orientations)
            if (distances(n) == "2m" || distances(n) == "6m") && m > 1
                break;
            end
            samplename = strcat('C', num2str(class), 'TextBlank', orientations(m), distances(n));
            filename = strcat(dir, samplename, 'Pt1.wav');
            [berTextBlank(class,n,m),ampTextBlank(class,n,m)] = processSignal(filename, "Text");
            filename = strcat(dir, samplename, 'Pt2.wav');
            [bertmp,snrtmp] = processSignal(filename, "Text");
            berTextBlank(class,n,m) = 1-(berTextBlank(class,n,m) + bertmp)/2;
            ampTextBlank(class,n,m) = (ampTextBlank(class,n,m) + snrtmp)/2;
        end
    end
end
save(results_file, 'berTextBlank', 'ampTextBlank', '-append');

%% DPPM
berBlank = zeros(length(classes), length(distances), length(orientations));
ampBlank = zeros(length(classes), length(distances), length(orientations));


for class = classes
 
    for n = 1:length(distances)
        for m = 1:length(distances_orientations)
            if (distances(n) == "2m" || distances(n) == "6m") && m > 1
                break;
            end
            samplename = strcat('C', num2str(class), 'Blank', orientations(m), distances(n));
            filename = strcat(dir, samplename, 'Pt1.wav');
            [berBlank(class,n,m),ampBlank(class,n,m)] = processSignal(filename, "Blank");
            filename = strcat(dir, samplename, 'Pt2.wav');
            [bertmp,snrtmp] = processSignal(filename, "Blank");
            berBlank(class,n,m) = 1-(berBlank(class,n,m) + bertmp)/2;
            ampBlank(class,n,m) = (ampBlank(class,n,m) + snrtmp)/2;
        end
    end

end

save(results_file, 'berBlank', 'ampBlank', '-append');
%% Font

berFonts = zeros(length(fonts), length(classes));

for m = 1:length(classes)
    for n = 1:length(fonts)
        filename = strcat(dir, 'C', num2str(classes(m)), 'Text', fonts(n), '50cmPt1.wav');
        berFonts(n,m) = processSignal(filename, "Text");
        filename = strcat(dir, 'C', num2str(classes(m)), 'Text', fonts(n), '50cmPt2.wav');
        berFonts(n,m) = 1-(berFonts(n,m) + processSignal(filename, "Text"))/2;
    end
end

save(results_file, 'berFonts', '-append');
%% Layout

berLayouts = zeros(length(layouts), length(classes));

for m = 1:length(classes)
    for n = 1:length(layouts)
        if (layouts(n) == "White" && m == 3) || (layouts(n) == "Table" && m == 1)
            berLayouts(n,m) = 1;
            continue;
        end
        if layouts(n) == "White" && m == 2
            layout = "Blank";
        else
            layout = layouts(n);
        end
        
        filename = strcat(dir, 'C', num2str(classes(m)), 'Text', layout, '50cmPt1.wav');
        berLayouts(n,m) = processSignal(filename, "Text");
        filename = strcat(dir, 'C', num2str(classes(m)), 'Text', layout, '50cmPt2.wav');
        berLayouts(n,m) = 1-(berLayouts(n,m) + processSignal(filename, "Text"))/2;
    end
end

save(results_file, 'berLayouts', '-append');

%% Results
load(results_file);

printernames = ["HP", "Epson", "Canon"];

figure

distances_range = [0.5,2,4,6,8];
distances_limited_range = [0.5,4,8];


for n=classes
    subplot(2,3,n)
    plot(distances_range, berBlank(n,:,1)*100, '-x',distances_limited_range, berBlank(n,[1,3,5],2)*100,'--x',distances_limited_range, berBlank(n,[1,3,5],3)*100,':x');
    title(strcat("Printer ", printernames(n), ": DPPM"));
    
    ylim([0 100]);
    xlabel('Distance (m)'),ylabel('Bit Error Ratio (%)');
end

for n=classes
    subplot(2,3,n+3),plot(distances_range, berTextBlank(n,:,1)*100, '-x',distances_limited_range, berTextBlank(n,[1,3,5],2)*100,'--x',distances_limited_range, berTextBlank(n,[1,3,5],3)*100,':x');
    title(strcat("Printer ", printernames(n), ": FPM-DPPM"));
    ylim([0 100]);
    xlabel('Distance (m)'),ylabel('Bit Error Ratio (%)');
end

lgd = legend('0°', '90°', '180°');
lgd.Title.String = 'Orientation';
lgd.Position(1) = -0.01;
lgd.Position(2) = 0.47;

set(gcf, 'Color', 'w');
%% Results
figure

for n=classes
    plot(distances_range, ampBlank(n,:,1), '-o');
    hold on
end

for n=classes
    plot(distances_range, snrTextBlank(n,:,1), '-o');
    hold on
    
end
xlabel('Distance (m)'),ylabel('Relative amplitude (dBFS)');
lgd = legend([strcat(printernames, " (DPPM)"), strcat(printernames, " (FPM-DPPM)")]);
lgd.Title.String = 'Printer';

set(gcf, 'Color', 'w');

figure

fontsnames = {'Arial', 'Times', 'Courier'};

bar(berFonts*100);
set(gca, 'XTickLabel', fontsnames);
lgd = legend(printernames);
lgd.Title.String = 'Printer';
ylim([0 100]);

xlabel('Font'),ylabel('Bit Error Ratio (%)');

set(gcf, 'Color', 'w');

figure

layoutsnames = {'Single column', 'Two columns', 'Spreadsheet', 'Complex', 'Blank'};

bar(berLayouts*100);
set(gca, 'XTickLabel', layoutsnames);
lgd = legend(printernames);
lgd.Title.String = 'Printer';
ylim([0 100]);

xlabel('Layout'),ylabel('Bit Error Ratio (%)');

set(gcf, 'Color', 'w');
%% Line length sweep
figure

for m=classes
    filename = strcat(dir, "C", num2str(classes(m)), "Sweep.wav");
    [lines,timing] = sweep_analysis(filename);
    p = plot(lines,timing);
    hold on
end
%title('Length of line vs Time')
xx = xlabel('Length of line (cm)');
set(xx, 'fontsize', 12)
yy = ylabel('Time (s)');
set(yy, 'fontsize', 12)
lgd = legend('HP', 'Epson', 'Canon');
lgd.Location = 'southeast';
set(lgd, 'fontsize', 12)
set(gcf, 'Color', 'w');

%% Noise


blank = zeros(3,2);
text = zeros(3,2);

for n=classes
    filename = strcat(dir, "C", num2str(n), "BlankNoisePt");
    filename2 = strcat(dir, "C", num2str(n), "TextNoisePt");
    blank(n,1) = 1-processSignal(strcat(filename, "1.wav"), "Blank");
    blank(n,2) = 1-processSignal(strcat(filename, "2.wav"), "Blank");
    text(n,1) = 1-processSignal(strcat(filename2,"1.wav"), "Text");
    text(n,2) = 1-processSignal(strcat(filename2,"2.wav"), "Text");
    
end

mean(blank,2)
mean(text,2)

%% Offset sweep

for n=classes
    filename = strcat(dir, "C", num2str(n), "Offset.wav");
    [offsets,peaks] = offsetAmp(filename);
    plot(offsets,peaks, '-o');
    hold on
end
yy = ylabel('Relative amplitude (dBFS)');
set(yy, 'fontsize', 12)
xx = xlabel('Offset (cm)');
set(xx, 'fontsize', 12)
lgd = legend('HP', 'Epson', 'Canon');
set(lgd, 'fontsize', 12)
set(gcf, 'Color', 'w');

%% Intercalating Modulation

inter = zeros(3,1);
for n=classes
    filename = strcat(dir, "C", num2str(n), "InterPt");
    inter(n,1) = testInter(strcat(filename, "1.wav"));
    inter(n,1) = inter(n,1) + testInter(strcat(filename, "2.wav"));
    inter(n,1) = inter(n,1)/2;
end