classdef LIDAR < handle
    % version R2017b
    properties
        Data
        Area
        BoundSHP
        Build
    end
    properties (Constant, Hidden = true)
        shape = struct('Geometry', ...
            {'Polygon'}, ...
            'X',{1}, 'Y',{1}, ...
            'Area',{1},'BinaNo',{1});
    end
    properties (Hidden = true)
        poly
        BB
        clustSize
        build
        bound
        A
        MinPts
        epsilon
        Legends
        Limite
    end
    methods
        function self = LIDAR(file)
            try
                if ischar(file)
                    expression = '\.' ;
                    splitStr = regexp(file, expression, 'split') ;
                    if strcmpi(splitStr{2}, 'las')
                        LAS = lasdata(file) ; % las data convert
                        self.Data = [LAS.x, LAS.y, LAS.z] ;
                    elseif strcmpi(splitStr{2}, 'txt')
                        fileID = fopen(file, 'r');
                        Data = textscan(fileID,'%f %f %f');  % txt read
                        fclose(fileID);
                        self.Data = [Data{1}, Data{2}, Data{3}] ;
                    else
                        error('Lütfen .las, .txt uzantýlý veri giriniz...')
                    end
                else
                    self.Data = file ; % Direct file
                end
            catch
                if nargin
                fprintf('%s is not defined. Because file has a error. So, this line is working. \n', file)
                end
                [file, path] = uigetfile({'*.las';'*.txt'},'Dosya seçiniz');
                self = LIDAR([path, file]) ;
            end
        end
        % Point select
        function selectionArea(self)
            fig = figure('WindowButtonDownFcn', @wbdcb, ...
                'Position', [150 80 1480 820]) ;
            ah = axes(); % 'SortMethod', 'childorder' 
            plot(ah, self.Data(:, 1), self.Data(:, 2), 'r.') ;
            movegui('center')
            xdat = [];
            ydat = [];
            xinit = [];
            yinit = [];
            count = 1 ;
            function wbdcb(src, ~)
                seltype = src.SelectionType ;
                if strcmp(seltype, 'normal')
                    src.Pointer = 'crosshair';
                    cp = ah.CurrentPoint;
                    xinit(end + 1) = fix(cp(1,1));
                    yinit(end + 1) = fix(cp(1,2));
                    self.poly(count, :) = [xinit(count) yinit(count)] ;
                    hl = line('XData', xinit, 'YData', yinit,...
                        'Marker', '+', 'color', 'k', 'LineWidth', 5);
                    src.WindowButtonMotionFcn = @wbmcb;
                    src.WindowButtonUpFcn = @wbucb;
                    count = count + 1;
                elseif strcmp(seltype,'open')
                    src.Pointer = 'circle';
                    src.WindowButtonUpFcn = @wbucb;
                end
                function wbmcb(~, ~)
                   cp = fix(ah.CurrentPoint);
                   xdat = [xinit,cp(1,1)];
                   ydat = [yinit,cp(1,2)];
                   hl.XData = xdat;
                   hl.YData = ydat;
                   drawnow
                end
                function wbucb(src, ~)
                   last_seltype = src.SelectionType;
                   if strcmp(last_seltype,'alt')
                      src.Pointer = 'circle';
                      src.WindowButtonMotionFcn = '';
                      src.WindowButtonUpFcn = '';
                      fig.WindowButtonDownFcn = '' ;
                      hl.XData(end + 1) = xdat(1);
                      hl.YData(end + 1) = ydat(1);
                   else
                      return
                   end
                end
            end
            waitfor(gcf)
        end
        % seçili bölge koordinatlarý
        function areaCoordinate(self)
            [in, ~] = inpolygon(self.Data(:,1), self.Data(:,2), self.poly(:, 1), self.poly(:, 2));
            M1 = self.Data(:, 1);
            M2 = self.Data(:, 2);
            M3 = self.Data(:, 3);
            B = [M1(in), M2(in), M3(in)];
            self.BB = B;
            self.checkElevation() ;
            C = [M1(~in), M2(~in), M3(~in)];
            fig = figure('Position', [150 80 1480 820]);
            axes(fig, 'Position',[0.25, 0.11, 0.58, 0.82]);
            rotate3d on ;
            bg = uibuttongroup(fig, 'Visible','off',...
                              'Position',[0 0 .1 1],...
                              'SelectionChangedFcn',@bselection);
                          
                  uicontrol(bg,'Style', 'radiobutton', ...
                      'Units', 'Normalized', ...
                      'String','in',...
                      'FontSize', 12, ...
                      'Position',[.2 .8 .5 .2],...
                      'HandleVisibility','off');

                  uicontrol(bg,'Style','radiobutton',...
                      'Units', 'Normalized', ...
                      'String','on',...
                      'FontSize', 12, ...
                      'Position',[.2 .6 .5 .2],...
                      'HandleVisibility','off');
                  
                  uicontrol(bg,'Style', 'radiobutton', ...
                      'Units', 'Normalized', ...
                      'String','all',...
                      'FontSize', 12, ...
                      'Position',[.2 .4 .5 .2],...
                      'HandleVisibility','off');
                  
                  uicontrol(bg,'Style', 'radiobutton', ...
                      'Units', 'Normalized', ...
                      'String','3D',...
                      'FontSize', 12, ...
                      'Position',[.2 .2 .6 .2],...
                      'HandleVisibility','off');
                  
                  plot(M1(in),M2(in),'r+') 
                  bg.Visible = 'on';
            function bselection(~, event)
                cla
                hold on
                if strcmp(event.NewValue.String, 'in')
                    plot(M1(in),M2(in),'r+') 
                elseif strcmp(event.NewValue.String, 'on')
                    plot(M1(~in),M2(~in),'bo')
                elseif strcmp(event.NewValue.String, 'all')
                    plot(M1(in),M2(in),'r+') 
                    plot(M1(~in),M2(~in),'bo')
                else
                    plot3(B(:,1), B(:,2) ,B(:,3), 'g.', C(:,1), C(:,2), C(:,3), 'r.');
                end
                hold off
            end
            waitfor(gcf)
        end
        function clusterAlgorithm(self)
            f.fig = figure('Position', [150 80 1480 820]);
            ax = axes(f.fig, 'Position',[0.35, 0.11, 0.58, 0.82]);
            plot3(ax, self.Area(:,1), self.Area(:,2), self.Area(:,3),'.r') ;
            rotate3d on ;
            bg = uibuttongroup('Visible','on',...
                              'Position',[0 0 .25 1],...
                              'SelectionChangedFcn',@bselection);

            uicontrol(bg,'Style', 'radiobutton', ...
                              'Units', 'Normalized', ...
                              'String','K-Means',...
                              'Position',[.1 .8 .5 .2],...
                              'HandleVisibility','off');

            uicontrol(bg,'Style','radiobutton',...
                              'Units', 'Normalized', ...
                              'String','DBSCAN',...
                              'Position',[.6 .8 .5 .2],...
                              'HandleVisibility','off');
                          
            uicontrol(f.fig, 'Style','push',...
                              'Units', 'Normalized', ...
                              'String','Print Screen',...
                              'Position',[.25 .94 .1 .06],...
                              'HandleVisibility','off', ...
                              'callback', @printcall);     

            tg = uitabgroup(bg, 'Units', 'Normalized', ...
                'Position',[.1 .6 .8 .25]);
            tabkmeans = uitab(tg, 'Title', 'K-Means');

            kmeantx = uicontrol(tabkmeans, 'Style', 'text', 'String', 'Cluster : ', ...
                'Units', 'Normalized', 'Position', [.05 .55 .4 .3], ...
                'FontSize', 12);

            kmeaned = uicontrol(tabkmeans, 'Style','edit',...
                         'Units', 'normalized',...
                         'Position', [.45 .6 .5 .3],... 
                         'CallBack', @callb);
                     
            hdbtx1 = uicontrol(tabkmeans, 'Style', 'text', 'String', 'MinPts : ', ...
                'Units', 'Normalized', 'Position', [.05 .53 .4 .3], ...
                'Visible', 'off', ...
                'FontSize', 12);
            
            hdbtx2 = uicontrol(tabkmeans, 'Style', 'text', 'String', 'Epsilon : ', ...
                'Units', 'Normalized', 'Position', [.05 .28 .4 .3], ...
                'Visible', 'off', ...
                'FontSize', 12);
            
            hdbed1 = uicontrol(tabkmeans, 'Style','edit',...
                         'Units', 'normalized',...
                         'Position', [.45 .6 .5 .25],... 
                         'Visible', 'off', ...
                         'CallBack', @callb2);
                     
            hdbed2 = uicontrol(tabkmeans, 'Style','edit',...
                         'Units', 'normalized',...
                         'Visible', 'off', ...
                         'Position', [.45 .35 .5 .25],... 
                         'CallBack', @callb3);

            uicontrol(tabkmeans, 'Style','push',...
                         'String', 'Apply', ...
                         'Units', 'normalized',...
                         'Position', [.45 .02 .5 .3], ...
                         'callback', @buttoncallb);

            tg(2) = uitabgroup(bg, 'Units', 'Normalized', ...
                'Position',[.1 .2 .8 .35],  'Visible', 'off');

            tabout = uitab(tg(2), 'Title', 'View');

            uicontrol(tabout, 'Style', 'text', 'String', 'Cluster : ', ...
                'Units', 'Normalized', 'Position', [.05 .6 .4 .3], ...
                'FontSize', 12);

            popup = uicontrol(tabout, 'Style','popupmenu',...
                         'String', 0, ...
                         'Units', 'normalized',...
                         'callback', @popupcb, ...
                         'Position', [.45 .6 .5 .3]);
                     
            chc(1) = uicontrol(tabout, 'Style','checkbox', ...
                        'String', 'Building', ...
                        'Units', 'normalized',...
                        'Value', 1, ...
                        'Position', [.45 .4 .5 .3], ...
                        'callback', @chckcb);
            chc(2) = uicontrol(tabout, 'Style','checkbox', ...
                        'String', 'Boundaries', ...
                        'Units', 'normalized',...
                        'Value', 1, ...
                        'Position', [.45 .2 .5 .3], ...
                        'callback', @chckcb2);
             
            exportpb = uicontrol(bg, 'Style','push',...
                         'String', 'Export', ...
                         'Units', 'normalized',...
                         'Visible', 'off', ...
                         'Position', [.45 .1 .4 .06], ...
                         'callback', @exportcb);
                     
            function bselection(~, event)
                cla
                if strcmp(tg(2).Visible, 'on')
                exportpb.Visible = 'off' ;
                chc(1).Value = 1 ;
                chc(2).Value = 1 ;
                popup.Value = 1 ;
                end
                plot3(ax, self.Area(:,1), self.Area(:,2), self.Area(:,3),'.r') ;
                tabkmeans.Title =  event.NewValue.String;
                tg(2).Visible = 'off';
                if strcmp(event.NewValue.String, 'K-Means')
                    kmeantx.Visible = 'on' ;
                    kmeaned.Visible = 'on' ;
                    hdbtx1.Visible = 'off' ;
                    hdbtx2.Visible = 'off' ;
                    hdbed1.Visible = 'off' ;
                    hdbed2.Visible = 'off' ;
                else
                    hdbtx1.Visible = 'on' ;
                    hdbtx2.Visible = 'on' ;
                    hdbed1.Visible = 'on' ;
                    hdbed2.Visible = 'on' ;
                    kmeantx.Visible = 'off' ;
                    kmeaned.Visible = 'off' ;
                end
            end
            function [] = printcall(~, ~)
                [file, path] = uiputfile('*.tif','tif kaydet');
                print('-dtiff', fullfile(path, file), '-r600');
            end
            function [] = callb(src, ~)
                self.clustSize = str2double(get(src,'string'));
            end
            function [] = callb2(src, ~)
                self.MinPts = str2double(get(src,'string'));
            end
            function [] = callb3(src, ~)
                self.epsilon = str2double(get(src,'string'));
            end
            function [] = chckcb(src, ~)
                value = src.Value ;
                clust = popup.Value - 1 ;
                if clust == 0
                    for i = 1: self.clustSize
                        if value == 1
                            self.build{i}.Visible = 'on' ;
                        else
                            self.build{i}.Visible = 'off' ;
                        end
                    end
                else
                if value == 1
                    self.build{clust}.Visible = 'on' ;
                else
                    self.build{clust}.Visible = 'off' ;
                end
                end
            end
            function [] = chckcb2(src, ~)
                value = src.Value ;
                clust = popup.Value - 1 ;
                if clust == 0
                    for i = 1: self.clustSize
                        if value == 1
                            self.bound{i}.Visible = 'on' ;
                        else
                            self.bound{i}.Visible = 'off' ;
                        end
                    end
                else
                if value == 1
                    self.bound{clust}.Visible = 'on' ;
                else
                    self.bound{clust}.Visible = 'off' ;
                end
                end
            end
            function popupcb(src, ~)
                chc(1).Value = 1 ;
                chc(2).Value = 1 ;
                set(gca, 'XLim', self.Limite(1, :)) ;
                set(gca, 'YLim', self.Limite(2, :)) ;
                set(gca, 'ZLim', self.Limite(3, :)) ;
                Value = src.Value - 1 ;
                if Value ~= 0
                    for i = 1 : self.clustSize
                        if Value == i
                            self.build{i}.Visible = 'on' ;
                            self.bound{i}.Visible = 'on' ;
                        continue
                        end
                        self.build{i}.Visible = 'off' ;
                        self.bound{i}.Visible = 'off' ;
                    end
                else
                    for i = 1: self.clustSize
                        self.build{i}.Visible = 'on' ;
                        self.bound{i}.Visible = 'on' ;
                    end
                end
            end
            function buttoncallb(~, ~)
                cla
                tg(2).Visible = 'on';
                exportpb.Visible = 'on' ;
                chc(1).Value = 1 ;
                chc(2).Value = 1 ;
                popup.Value = 1 ;
                if strcmp(tabkmeans.Title, 'K-Means')
                    self.kMeanPlot();
                else
                    self.hdbscanPlot();
                end
                popup.String = 0 : self.clustSize ;
                self.Limite(1, :) = get(gca, 'XLim') ;
                self.Limite(2, :) = get(gca, 'YLim') ;
                self.Limite(3, :) = get(gca, 'ZLim') ;
                set(gca, 'XLim', self.Limite(1, :)) ;
                set(gca, 'YLim', self.Limite(2, :)) ;
                set(gca, 'ZLim', self.Limite(3, :)) ;
            end
            function exportcb(~, ~)
                [file, path] = uiputfile('*.shp','shp kaydet');
                expression = '\.' ;
                txtStr = regexp(file, expression, 'split') ;
                textfilename = [txtStr{1},'.txt'] ;
                filename = fullfile(path, file);
                SHP = self.shape ;
                for i = 1 : self.clustSize
                    SHP(i).Geometry= 'Polygon'; % format
                    SHP(i).X= self.bound{i}.XData ; % X koord
                    SHP(i).Y= self.bound{i}.YData ; % Y koord
                    SHP(i).Area= polyarea(self.bound{i}.XData, self.bound{i}.YData); % Alan
                    SHP(i).BinaNo= i; % bina numarasý
                end
                self.BoundSHP =mapshape(SHP);
                shapewrite(self.BoundSHP, filename);
                txtout = self.BB ;
                self.Build = txtout ;
                save (textfilename, 'txtout', '-ascii')
            end
            waitfor(gcf)
        end
    end
    methods (Access = private)
        function kMeanPlot(self)
            if ~isempty(self.A)
                self.A = {} ;
                self.build = {} ;
                self.bound = {} ;
                self.Legends = {} ;
            end
            n = self.clustSize ;
            Colors = hsv(n);
            [idx, ~]=kmeans(self.Area, n);
            hold on ;
            for i = 1 : n
            self.A{i} = self.Area(idx==i,:);
            Style = 'x';
            MarkerSize = 8;
            Color = Colors(i,:);
            self.Legends{end+1} = ['Cluster #' num2str(i)];
            self.build{i} = plot3(gca, self.A{1,i}(:,1), self.A{1,i}(:,2), self.A{1,i}(:,3), ...
                Style,'MarkerSize',MarkerSize,'Color',Color);
            end
            for j = 1 : n
            % -- Boundary
            x = self.A{1, j}(:,1);
            y = self.A{1, j}(:,2);
            k = boundary(x,y);
            self.bound{j} = plot(x(k),y(k),'b','LineWidth',2);
            end
            hold off ;
            legend(self.Legends);
            legend('Location', 'NorthEastOutside');
        end
        %hdbscan
        function hdbscanPlot(self)
            if ~isempty(self.A)
                self.A = {} ;
                self.build = {} ;
                self.bound = {} ;
                self.Legends = {} ;
            end
            [class, ~] = slowdbscan(self.Area, self.epsilon, self.MinPts);
            self.clustSize = max(class) ;
            n = self.clustSize ;
            Colors = hsv(n);
            hold on
            for i = 1 : n
            self.A{i} = self.Area(class == i, :);
            Style = 'x';
            MarkerSize = 8;
            Color = Colors(i,:);
            self.Legends{end+1} = ['Cluster #' num2str(i)];
            self.build{i} = plot3(gca, self.A{1,i}(:,1), self.A{1,i}(:,2), self.A{1,i}(:,3), ...
                Style,'MarkerSize',MarkerSize,'Color',Color);
            end
            % -- Boundary
            for j = 1: n
            x = self.A{1,j}(:,1);
            y = self.A{1,j}(:,2);
            k = boundary(x,y);
            self.bound{j} = plot(x(k),y(k),'b','LineWidth',2);
            end
            hold off ;
            legend(self.Legends);
            legend('Location', 'NorthEastOutside');
        end
        % build algorithm
        function checkElevation(self)
            elev = max(self.BB(:, 3)) ;
            if elev <= 30
                high = 10 ;
            else
                idx = floor(elev / 6) * 2 ;
                high = elev - idx ;
            end
            check = self.BB(:, 3) > high ;
            self.Area = self.BB(check, :) ;
        end
    end
end