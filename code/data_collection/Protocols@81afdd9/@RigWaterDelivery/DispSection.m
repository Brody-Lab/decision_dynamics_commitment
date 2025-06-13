

function [x, y] = DispSection(obj, action, x, y)

GetSoloFunctionArgs;
switch action
    %% init
    case 'init'
        
        pos = get(gcf, 'Position');
        tb = annotation('Textbox',[0.05 0.75 0.9 0.235]);
        SoloParamHandle(obj,'tb_sph','value',tb);
        set(value(tb_sph),'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',20);
        set(value(tb_sph),'BackgroundColor',[1,0,0],'String','Still Delivering Water');
       
        
    case 'still_watering',

        set(value(tb_sph),'BackgroundColor',[1,0,0],'String','Still Delivering Water');
        
    case 'done_watering'
        set(value(tb_sph),'BackgroundColor',[0,1,0],'String','Delivery Complete');
   
        
    otherwise,
        warning('Unknown action! "%s"\n', action);
end


end