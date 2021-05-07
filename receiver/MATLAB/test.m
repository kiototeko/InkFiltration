clear all;
warning('off','all');
addpath('./export_fig/');
dir = "samples2/good/"; 

distances = ["50cm", "2m", "4m", "8m"];
orientations = ["", "Upside"];
layouts = ["Simple", "Blank", "Table", "Just", "Color"];

classes = 2:5;
results_file = "results.mat";
%% Distance
berTextBlank = zeros(length(classes), length(distances), length(orientations));
ampTextBlank = zeros(length(classes), length(distances), length(orientations));

for class = classes
    for n = 1:length(distances)
        for m = 1:length(orientations)
            samplename = strcat('C', num2str(class), 'TextNovoSimple', orientations(m), distances(n));
            filename = strcat(dir, samplename, 'Pt1.wav');
            berTextBlank(class,n,m) = processSignal(filename, "Text", 25, -1, 0);
            filename = strcat(dir, samplename, 'Pt2.wav');
            bertmp = processSignal(filename, "Text", 25, -1, 0);
            fprintf("%s -> Pt1: %.2f, Pt2: %.2f ->> %.2f\n", samplename, 1-berTextBlank(class,n,m), 1-bertmp, 1-(berTextBlank(class,n,m) + bertmp)/2);
            berTextBlank(class,n,m) = 1-(berTextBlank(class,n,m) + bertmp)/2;
        end
    end
end
save(results_file, 'berTextBlank', '-append');


%% Layout

berLayouts = zeros(length(layouts), length(classes));


for m = classes
    for n = 1:length(layouts)
        samplename = strcat('C', num2str(m), 'TextNovo', layouts(n), '50cm');
        filename = strcat(dir, samplename, 'Pt1.wav');
        if(layouts(n) == "Blank")
            layout = "Blank";
        else
            layout = "Text";
        end
        berLayouts(n,m) = processSignal(filename, layout, 25, -1, 0);
        filename = strcat(dir, samplename, 'Pt2.wav');
        bertmp = processSignal(filename, layout, 25, -1, 0);
        fprintf("%s -> Pt1: %.2f, Pt2: %.2f ->> %.2f\n", samplename, 1-berLayouts(n,m), 1-bertmp, 1-(berLayouts(n,m) + bertmp)/2);
        berLayouts(n,m) = 1-(berLayouts(n,m) + bertmp)/2;
    end
end

save(results_file, 'berLayouts', '-append');

%% Noise

npower = 0:2:30;
snrs = zeros(length(classes),length(npower));

for class = classes
    for n = 1:length(npower)
        samplename = strcat('C', num2str(class), 'TextNovoSimple', '50cm');
        filename = strcat(dir, samplename, 'Pt1.wav');
        snrs(class, n) = processSignal(filename, "Text", 25, npower(n), 0);
        filename = strcat(dir, samplename, 'Pt2.wav');
        snrstmp = processSignal(filename, "Text", 25, npower(n), 0);
        fprintf("%s (SNR %i) -> Pt1: %.2f, Pt2: %.2f ->> %.2f\n", samplename, npower(n), 1-snrs(class, n), 1-snrstmp, 1-(snrs(class, n) + snrstmp)/2);
        snrs(class, n) = 1-(snrs(class, n) + snrstmp)/2;
    end
end

save(results_file, 'snrs', '-append');

%% Results
load(results_file);

printernames = ["Epson L", "Canon Pixma", "HP DeskJet", "HP ENVY"];

figure

npower = 0:2:30;


for n=classes
        plot(npower, snrs(n,:)*100);
        hold on
end

xl = xlabel('SNR_d_B');
yl = ylabel('Bit Error Ratio (%)');
set(xl, 'fontweight', 'bold')
set(yl, 'fontweight', 'bold')
lgd = legend(printernames);
set(gcf, 'Color', 'w');


%% Results

figure

layoutsnames = {'Left Aligned', 'Blank', 'Spreadsheet', 'Justified', 'Color'};

bar(berLayouts(:,2:5)*100);
set(gca, 'XTickLabel', layoutsnames);
lgd = legend(printernames);
lgd.Title.String = 'Printer';
ylim([0 max(max(berLayouts))*100+10]);

xl = xlabel('Layout');
yl = ylabel('Bit Error Ratio (%)');
set(xl, 'fontweight', 'bold')
set(yl, 'fontweight', 'bold')

set(gcf, 'Color', 'w');
