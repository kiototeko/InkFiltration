function parameter = getParameter(class, type)

parameter = struct;

switch(class)
    %{
        case 1 %HP_Photosmart_D110
            if(type == "Blank")
               parameter.limitH1 = 5;
               parameter.limitH2 = 21;
               parameter.limitL1 = 21;
               parameter.limitL2 = 50;
               parameter.limitI = 5;
               parameter.printer_str = 'HP25';
               parameter.preminH = 180;
               parameter.prelimit = 300;
               parameter.minH = 0.7;
               parameter.szbits = 26;
               parameter.lofrec = 3500;
               parameter.hifrec = 6000;
               parameter.peakdis = 3;
               parameter.env_window = 1000;
            elseif(type == "Text")
               parameter.limitL1 = 20;
               parameter.limitL2 = 60;
               parameter.limitH1 = 5;
               parameter.limitH2 = 20;
               parameter.minH = 0.7; 
               parameter.env_window = 3000;
               parameter.printer_str = 'HP10';
               parameter.szbits = 11;
               parameter.hi_limit = 2;
               parameter.preminH = 290;
               parameter.prelimit = 1000;
               parameter.hifrec = 6000;
               parameter.lofrec = 3500;
               parameter.peakdis = 3;
            end
    %}
        case 2 %Epson_L4150

           parameter.limitL1 = 16;
           parameter.limitL2 = 27;
           parameter.limitH1 = 27;
           parameter.limitH2 = 60;
           parameter.minH = 1;
           parameter.env_window = 3000;
           parameter.szbits = 10;
           parameter.printer_str = strcat('Epson_L4150_', string(parameter.szbits-1));
           parameter.preminH = 450;
           parameter.prelimit = 500;
           parameter.hifrec = 6000;
           parameter.lofrec = 3500;
           parameter.peakdis = 5;
            
        case 3 %Canon_MG2410

           parameter.limitL1 = 15;
           parameter.limitL2 = 40;
           parameter.limitH1 = 40;
           parameter.limitH2 = 80;
           parameter.szbits = 10;
           parameter.printer_str = strcat('Canon_MG2410_', string(parameter.szbits-1));
           parameter.minH = 1.2;
           parameter.preminH = 600;
           parameter.env_window = 2500;
           parameter.prelimit = 950;
           parameter.hifrec = 4000;
           parameter.lofrec = 1400;
           parameter.peakdis = 5;
            
        case 4 %HP_Deskjet_1115
            
            if(type == "Blank")

               parameter.limitL1 = 6;
               parameter.limitL2 = 8;
               parameter.limitH1 = 10;
               parameter.limitH2 = 33;

            elseif(type == "Text")

               parameter.limitL1 = 7;
               parameter.limitL2 = 15;
               parameter.limitH1 = 15;
               parameter.limitH2 = 33;
               
            end
            
           parameter.szbits = 12;
           parameter.printer_str = strcat('HP_Deskjet_1115_', string(parameter.szbits-1));
           parameter.minH = 1;
           parameter.preminH = 400;
           parameter.env_window = 1031;
           parameter.prelimit = 550;
           parameter.hifrec = 9700;
           parameter.lofrec = 6700;
           parameter.peakdis = 2;
            
        case 5 %HP Envy
           
           parameter.limitL1 = 8;
           parameter.limitL2 = 26;
           parameter.limitH1 = 26;
           parameter.limitH2 = 51;
           parameter.szbits = 12;
           parameter.printer_str = strcat('HP_Envy_', string(parameter.szbits-1));
           parameter.minH = 1.4;
           parameter.preminH = 150;
           parameter.env_window = 1031;
           parameter.prelimit = 400;
           parameter.hifrec = 18000;
           parameter.lofrec = 8000;
           parameter.peakdis = 5;
            
%{            
        case 6 %Template
           parameter.limitL1 = 8; %lower limit of time period representing
           bit 0
           parameter.limitL2 = 26; %higher limit of time period representing
           bit 0
           parameter.limitH1 = 26; %lower limit of time period representing
           bit 1
           parameter.limitH2 = 51; %higher limit of time period representing
           bit 1
           parameter.szbits = 12; %number of bits per page plus 1
           parameter.printer_str = strcat('HP_Envy_', string(parameter.szbits-1));
           parameter.minH = 1.4; %peak threshold
           parameter.preminH = 150; %peak threshold for matched filter
           parameter.env_window = 1031; %smoothing window
           parameter.prelimit = 400; %minimum distance between peaks in matched
           filter
           parameter.hifrec = 18000; %high cutoff frequency
           parameter.lofrec = 8000; %low cutoff frequency
           parameter.peakdis = 5; %minimum distance between peaks
%}
end

end