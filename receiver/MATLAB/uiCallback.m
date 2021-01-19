function uiCallback(src, ~)

    num_children = length(src.Parent.Children);
    delete(src.Parent.Children(num_children-2:num_children));
    
    if(strcmp(src.Tag,'hifrec'))
        if(src.Value > src.Parent.UserData.lofrec)
            src.Parent.UserData.hifrec = src.Value;
            for i=1:length(src.Parent.Children)
                if(strcmp(src.Parent.Children(i).Tag, 'hifrec_str'))
                    src.Parent.Children(i).String = strcat('High frequency: ',string(src.Value), ' Hz');
                end
            end
        end
    elseif(strcmp(src.Tag, 'lofrec'))
        if(src.Value < src.Parent.UserData.hifrec && src.Value > 0)
            src.Parent.UserData.lofrec = src.Value;
            for i=1:length(src.Parent.Children)
                if(strcmp(src.Parent.Children(i).Tag, 'lofrec_str'))
                    src.Parent.Children(i).String = strcat('Low frequency: ',string(src.Value), ' Hz');
                end
            end
        end
    elseif(strcmp(src.Tag, 'env_window'))
        if(int32(src.Value) > 0)
            src.Parent.UserData.env_window = int32(src.Value);
            for i=1:length(src.Parent.Children)
                if(strcmp(src.Parent.Children(i).Tag, 'env_window_str'))
                    src.Parent.Children(i).String = strcat('Smoothing window size: ', string(int32(src.Value)));
                end
            end
        end
    elseif(strcmp(src.Tag, 'minH'))
        src.Parent.UserData.minH = src.Value;
        for i=1:length(src.Parent.Children)
            if(strcmp(src.Parent.Children(i).Tag, 'minH_str'))
                src.Parent.Children(i).String = strcat('Minimum peak height: ', string(src.Value));
            end
        end
    end
    
    peaks = plot_process_signal(src.Parent.UserData)
    locs_diff = diff(peaks)
    
end
