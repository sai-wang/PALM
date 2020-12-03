% t=time
% k=horizontal
% j=meridional
% i=zonal
clc;
clear all;
%read data and coordinates

% load 'topo_mask_50m.mat';
% load 'topo_50m.mat';
% 
% filename_50 = 'ug5_50m/ug5_50m_av_xy.000.nc';  %filename for 50
% filename_25 = 'ug5_25m/ug5_25m_av_xy.000.nc'; %filename for 25

filename_50 = 'ug10_50m/ug10_50m_av_xy.003.nc';  %filename for 50
filename_25 = 'ug10_25m/ug10_25m_av_xy.001.nc'; %filename for 25

topo_mask_50 = load('topo_mask_50m.mat');
topo_50 = load('topo_50m.mat');
topo_mask_25 = load('topo_mask_25m.mat');
topo_25 = load('topo_25m.mat');

topo_mask_50 = cell2mat(struct2cell(topo_mask_50));
topo_50 = cell2mat(struct2cell(topo_50));
topo_mask_25 = cell2mat(struct2cell(topo_mask_25));
topo_25 = cell2mat(struct2cell(topo_25));

 x_50 = ncread(filename_50,'x');
 xu_50 = ncread(filename_50,'xu');
 y_50 = ncread(filename_50,'y');
 yv_50 = ncread(filename_50,'yv');
 zu_xy_50 = ncread(filename_50,'zu_xy');
 zw_xy_50 = ncread(filename_50,'zw_xy');
 time_50 = ncread(filename_50,'time');
 
 u_50 = ncread(filename_50,'u_xy'); 
 v_50 = ncread(filename_50,'v_xy'); 
 w_50 = ncread(filename_50,'w_xy'); 
 u2_50 = ncread(filename_50,'u2_xy');
 v2_50 = ncread(filename_50,'v2_xy');
 w2_50 = ncread(filename_50,'w2_xy');
 
 x_25 = ncread(filename_25,'x');
 xu_25 = ncread(filename_25,'xu');
 y_25 = ncread(filename_25,'y');
 yv_25 = ncread(filename_25,'yv');
 zu_xy_25 = ncread(filename_25,'zu_xy');
 zw_xy_25 = ncread(filename_25,'zw_xy');
 time_25 = ncread(filename_25,'time');
 
 u_25 = ncread(filename_25,'u_xy'); 
 v_25 = ncread(filename_25,'v_xy'); 
 w_25 = ncread(filename_25,'w_xy'); 
 u2_25 = ncread(filename_25,'u2_xy');
 v2_25 = ncread(filename_25,'v2_xy');
 w2_25 = ncread(filename_25,'w2_xy');
 

 %load indices
 time_count = size(u_50,4);
 level_count = size(u_50,3);
 
 
 %create coordinate matrices
 [X50, Y50]=meshgrid(x_50./1000,y_50./1000); %notice the usage of x/xu, y/yv, etc
 [X25, Y25]=meshgrid(x_25./1000,y_25./1000);
 t = time_count; %set the time step we're interested
 
%% 
%start plotting
 for k=3:2:5%level_count
     figure;
     matrix_for_plot_50 =( u2_50(:,:,k,time_count) + v2_50(:,:,k,time_count) ...
         + w2_50(:,:,k,time_count) )' *0.5;
     matrix_for_plot_25 =( u2_25(:,:,k,time_count) + v2_25(:,:,k,time_count) ...
         + w2_25(:,:,k,time_count) )' *0.5;
     %Cmax = max(max(max(max(source_50(:,:,k,:)))),max(max(max(source_25(:,:,k,:)))));
     %Cmin = min(min(min(min(source_50(:,:,k,:)))),min(min(min(source_25(:,:,k,:)))));
     Cmax = max(max(max(matrix_for_plot_50)),max(max(matrix_for_plot_25)));
     Cmin = min(min(min(matrix_for_plot_50)),min(min(matrix_for_plot_25)));
%     for t=1:1%time_count
         p1 = subplot(2,2,1);
         %left plot
         h1 = pcolor(X50,Y50,matrix_for_plot_50);
         set(h1,'EdgeColor','none');
         xlabel('km');
         ylabel('km');
         hold on;
         q = contour(X50,Y50,topo_mask_50,'LineWidth',0.5,'LineColor',[0.5,0.5,0.5]);  
         shading flat;
         hold on;
         q2 = contour(X50,Y50,topo_50,[100 300 500],'LineWidth',0.5,'LineColor',...
             [0.5,0.5,0.5],'ShowText','on');
         title(['Mean Kinectic Energy 50m']);
         
         %right plot
         p2 = subplot(2,2,2);
         h2 = pcolor(X25,Y25,matrix_for_plot_25);
         set(h2,'EdgeColor','none');
         xlabel('km');
         ylabel('km');
         hold on;
         q = contour(X25,Y25,topo_mask_25,'LineWidth',0.5,'LineColor',[0.5,0.5,0.5]);  
         shading flat;
         hold on;
         q2 = contour(X25,Y25,topo_25,[100 300 500],'LineWidth',0.5,'LineColor',...
             [0.5,0.5,0.5],'ShowText','on');
         title(['Mean Kinetic Energy 25m']);
         
         %set colormaps and colorbars
          if(Cmin >= 0)
             if(Cmax >= 3*Cmin)
                 colormap(p1,redblueu_reversed(256,[Cmin, Cmax]));
                 colormap(p2,redblueu_reversed(256,[Cmin, Cmax]));
             else
                 colormap(p1,redblueu_reversed(256,[Cmin/3, Cmax]));
                 colormap(p2,redblueu_reversed(256,[Cmin/3, Cmax]));
             end
             colorbar(p2);colorbar(p1);
             caxis(p1,[Cmin, Cmax]);caxis(p2,[Cmin,Cmax]);
         elseif(Cmax <= 0)
             colormap(p1,redblueu_reversed(256,[Cmin, 0]));
             colormap(p2,redblueu_reversed(256,[Cmin, 0]));
             colorbar(p2);colorbar(p1);
             caxis(p1,[Cmin, 0]);caxis(p2,[Cmin, 0]);
         else
             colormap(p1,redblueu_reversed(256,[Cmin, Cmax]));
             colormap(p2,redblueu_reversed(256,[Cmin, Cmax]));
             colorbar(p2);colorbar(p1);
             caxis(p1,[Cmin, Cmax]);caxis(p2,[Cmin, Cmax]);
         end
%     end

     matrix_for_plot_50 = 0.5* (...
           u2_50(:,:,k,time_count)' - (u_50(:,:,k,time_count).^2)'...
         + v2_50(:,:,k,time_count)' - (v_50(:,:,k,time_count).^2)'...
         + w2_50(:,:,k,time_count)' - (w_50(:,:,k,time_count).^2)');
     matrix_for_plot_25 = 0.5* (...
           u2_25(:,:,k,time_count)' - (u_25(:,:,k,time_count).^2)'...
         + v2_25(:,:,k,time_count)' - (v_25(:,:,k,time_count).^2)'...
         + w2_25(:,:,k,time_count)' - (w_25(:,:,k,time_count).^2)');

     Cmax = max(max(max(matrix_for_plot_50)),max(max(matrix_for_plot_25)));
     Cmin = min(min(min(matrix_for_plot_50)),min(min(matrix_for_plot_25)));
     
         p3 = subplot(2,2,3);
         h3 = pcolor(X50,Y50,matrix_for_plot_50);
         set(h3,'EdgeColor','none');
         xlabel('km');
         ylabel('km');
         hold on;
         q = contour(X50,Y50,topo_mask_50,'LineWidth',0.5,'LineColor',[0.5,0.5,0.5]);  
         shading flat;
         hold on;
         q3 = contour(X50,Y50,topo_50,[100 300 500],'LineWidth',0.5,'LineColor',...
             [0.5,0.5,0.5],'ShowText','on');
         title(['Mean Turbulent Kinetic Energy 50m']);
         
         p4 = subplot(2,2,4);
         h4 = pcolor(X25,Y25,matrix_for_plot_25);
         set(h4,'EdgeColor','none');
         xlabel('km');
         ylabel('km');
         hold on;
         q = contour(X25,Y25,topo_mask_25,'LineWidth',0.5,'LineColor',[0.5,0.5,0.5]);  
         shading flat;
         hold on;
         q4 = contour(X25,Y25,topo_25,[100 300 500],'LineWidth',0.5,'LineColor',...
             [0.5,0.5,0.5],'ShowText','on');
         title(['Mean Turbulent Kinetic Energy 25m']);

          if(Cmin >= 0)
             if(Cmax >= 3*Cmin)
                 colormap(p3,redblueu_reversed(256,[Cmin, Cmax]));
                 colormap(p4,redblueu_reversed(256,[Cmin, Cmax]));
             else
                 colormap(p3,redblueu_reversed(256,[Cmin/3, Cmax]));
                 colormap(p4,redblueu_reversed(256,[Cmin/3, Cmax]));
             end
             colorbar(p4);colorbar(p3);
             caxis(p3,[Cmin, Cmax]);caxis(p4,[Cmin,Cmax]);
         elseif(Cmax <= 0)
             colormap(p3,redblueu_reversed(256,[Cmin, 0]));
             colormap(p4,redblueu_reversed(256,[Cmin, 0]));
             colorbar(p4);colorbar(p3);
             caxis(p3,[Cmin, 0]);caxis(p4,[Cmin, 0]);
         else
             colormap(p3,redblueu_reversed(256,[Cmin, Cmax]));
             colormap(p4,redblueu_reversed(256,[Cmin, Cmax]));
             colorbar(p4);colorbar(p3);
             caxis(p3,[Cmin, Cmax]);caxis(p4,[Cmin, Cmax]);
          end
         
     plotname=['PALM u_g = 10m Kinetic Energy comparisons at z=', num2str(zw_xy_50(k)), ...
         'm, t=', num2str(time_count*0.5), 'h'];
     sgtitle(plotname,'Interpreter','None','FontSize',10);
     set(gcf,'Position',[406 42 973 1320]);
     %print(gcf,['25_50m-w_av_xy-z=',num2str(zw_xy(k)), 'm'],'-dpdf');
    saveas(gcf,['variance_comparison/tke_res_ug10 at z=',num2str(zw_xy_50(k)), ...
        'm, t=', num2str(time_count*0.5), 'h'],'png');
 end
 
 
 