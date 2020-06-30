classdef UIFile < handle
    properties (Hidden = true)
        Figure
        ExteriorButton
        InteriorButton
        LeftImageButton
        RightImageButton
        CloseButton
        PixelText
        PixelEdit
        CreateText
    end
    properties
        DYE
        IYE
        Left
        Right
        Pixel
    end
    methods
        function file_call(UI, obj, ~)
            [file,path] = uigetfile({'*.xlsx';'*.xls'},'File Selector');
            if isequal(file,0)
               disp('Yükleme Baþarýsýz');
            else
                out = xlsread([path,file]);
                UI.(obj.Tag) = out;
                disp([file,', baþarý ile yüklendi']);
            end
        end
        function image_call(UI, obj, ~)
            [file,path] = uigetfile({'*.TIF';'*.tif';'*.jpg';'*.jpeg';'*.png'},...
                'File Selector');
            if isequal(file,0)
               disp('Yükleme Baþarýsýz');
            else
                image = imread([path,file]);
                UI.(obj.Tag).Image = image;
                UI.(obj.Tag).Name = file ;
                disp([file,', baþarý ile yüklendi']);
            end
        end
        function edit_call(UI, obj, ~)
            pix = str2double(obj.String) ;
            UI.Pixel = pix ;
        end
        function close_call(~, ~, ~)
                 delete(gcf)
        end
    end
    methods 
        function UI = UIFile
            UI.Figure = figure;
            UI.Figure.Visible = 'off';
            UI.Figure.ToolBar = 'none' ;
            UI.Figure.MenuBar = 'none' ;
            UI.Figure.Units = 'Normalized';
            UI.Figure.Position = [0.1508  0.2311  0.1558  0.5148];
            UI.Figure.Name = 'Get File';
            UI.Figure.CloseRequestFcn = @UI.close_call ;
            
            UI.ExteriorButton = uicontrol();
            UI.ExteriorButton.Style = 'PushButton';
            UI.ExteriorButton .Units = 'Normalized';
            UI.ExteriorButton.Tag = 'DYE' ;
            UI.ExteriorButton .BackgroundColor = [1 1 1];
            UI.ExteriorButton .FontWeight = 'bold';
            UI.ExteriorButton .Position = [ 0.1700  0.8500  0.6700  0.0635];
            UI.ExteriorButton .String = 'Exterior';
            UI.ExteriorButton.Callback = @UI.file_call ;
            
            UI.InteriorButton = uicontrol();
            UI.InteriorButton.Style = 'PushButton';
            UI.InteriorButton .Units = 'Normalized';
            UI.InteriorButton.Tag = 'IYE' ;
            UI.InteriorButton .BackgroundColor = [1 1 1];
            UI.InteriorButton .FontWeight = 'bold';
            UI.InteriorButton .Position = [ 0.1700  0.7500  0.6700  0.0635];
            UI.InteriorButton .String = 'Interior';
            UI.InteriorButton.Callback = @UI.file_call ;
            
            UI.LeftImageButton = uicontrol();
            UI.LeftImageButton.Style = 'PushButton';
            UI.LeftImageButton .Units = 'Normalized';
            UI.LeftImageButton.Tag = 'Left' ;
            UI.LeftImageButton .BackgroundColor = [1 1 1];
            UI.LeftImageButton .FontWeight = 'bold';
            UI.LeftImageButton .Position = [ 0.1700  0.5500  0.6700  0.0635];
            UI.LeftImageButton .String = 'Left Image';
            UI.LeftImageButton.Callback = @UI.image_call ;
            
            UI.RightImageButton = uicontrol();
            UI.RightImageButton.Style = 'PushButton';
            UI.RightImageButton .Units = 'Normalized';
            UI.RightImageButton.Tag = 'Right' ;
            UI.RightImageButton .BackgroundColor = [1 1 1];
            UI.RightImageButton .FontWeight = 'bold';
            UI.RightImageButton .Position = [ 0.1700  0.4500  0.6700  0.0635];
            UI.RightImageButton .String = 'Right Image';
            UI.RightImageButton.Callback = @UI.image_call ;

            UI.PixelText = uicontrol();
            UI.PixelText.Style = 'text';
            UI.PixelText.Units = 'Normalized';
            UI.PixelText.FontSize = 10;
            UI.PixelText.FontWeight = 'bold';
            UI.PixelText.Position =  [ 0.1700  0.2900  0.6700  0.0635];
            UI.PixelText.String = 'Pixel :';
            
            UI.PixelEdit = uicontrol();
            UI.PixelEdit.Style = 'edit';
            UI.PixelEdit.Units = 'Normalized';
            UI.PixelEdit.FontSize = 10;
            UI.PixelEdit.FontWeight = 'bold';
            UI.PixelEdit.Position = [ 0.1700  0.2500  0.6700  0.0635];
            UI.PixelEdit.Callback = @UI.edit_call ;
            
            UI.CloseButton = uicontrol();
            UI.CloseButton.Style = 'PushButton';
            UI.CloseButton .Units = 'Normalized';
            UI.CloseButton.Tag = 'Right' ;
            UI.CloseButton .BackgroundColor = [1 1 1];
            UI.CloseButton .FontWeight = 'bold';
            UI.CloseButton .Position = [ 0.1700  0.1000  0.6700  0.0535];
            UI.CloseButton .String = 'Close';
            UI.CloseButton.Callback = @UI.close_call ;
            
            UI.Figure.Visible = 'On';
        end
    end
end