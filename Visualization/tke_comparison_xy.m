% t=time
% k=horizontal
% j=meridional
% i=zonal
clc;
clear all;
%read data and coordinates
% filename_ug5 = 'ug5_50m/ug5_50m_av_xy.000.nc';  %filename for ug5
% filename_ug10 = 'ug10_50m/ug10_50m_av_xy.003.nc'; %filename for ug10
% topo_mask = load('topo_mask_50m.mat');
% topo = load('topo_50m.mat');

filename_ug5 = 'ug5_25m/ug5_25m_av_xy.000.nc';  %filename for ug5
filename_ug10 = 'ug10_25m/ug10_25m_av_xy.001.nc'; %filename for ug10
topo_mask = load('topo_mask_25m.mat');
topo = load('topo_25m.mat');

topo_mask = cell2mat(struct2cell(topo_mask));
topo = cell2mat(struct2cell(topo));

 x = ncread(filename_ug5,'x');
 xu = ncread(filename_ug5,'xu');
 y = ncread(filename_ug5,'y');
 yv = ncread(filename_ug5,'yv');
 zu_xy = ncread(filename_ug5,'zu_xy');
 zw_xy = ncread(filename_ug5,'zw_xy');
 time = ncread(filename_ug5,'time');
 
 u_ug5 = ncread(filename_ug5,'u_xy'); 
 v_ug5 = ncread(filename_ug5,'v_xy'); 
 w_ug5 = ncread(filename_ug5,'w_xy'); 
 u2_ug5 = ncread(filename_ug5,'u2_xy');
 v2_ug5 = ncread(filename_ug5,'v2_xy');
 w2_ug5 = ncread(filename_ug5,'w2_xy');
 
 u_ug10 = ncread(filename_ug10,'u_xy'); 
 v_ug10 = ncread(filename_ug10,'v_xy'); 
 w_ug10 = ncread(filename_ug10,'w_xy'); 
 u2_ug10 = ncread(filename_ug10,'u2_xy');
 v2_ug10 = ncread(filename_ug10,'v2_xy');
 w2_ug10 = ncread(filename_ug10,'w2_xy');
 

 %load indices
 time_count = size(u_ug5,4);
 level_count = size(u_ug5,3);
 
 
 %create coordinate matrices
 [X, Y]=meshgrid(x./1000,y./1000); %notice the usage of x/xu, y/yv, etc
 t = time_count; %set the time step we're interested
 
%% 
%start plotting
 for k=3:2:5%level_count
     figure;
     matrix_for_plot_5 =( u2_ug5(:,:,k,time_count) + v2_ug5(:,:,k,time_count) ...
         + w2_ug5(:,:,k,time_count) )' *0.5;
     matrix_for_plot_10 =( u2_ug10(:,:,k,time_count) + v2_ug10(:,:,k,time_count) ...
         + w2_ug10(:,:,k,time_count) )' *0.5;
     %Cmax = max(max(max(max(source_ug5(:,:,k,:)))),max(max(max(source_ug10(:,:,k,:)))));
     %Cmin = min(min(min(min(source_ug5(:,:,k,:)))),min(min(min(source_ug10(:,:,k,:)))));
     Cmax = max(max(max(matrix_for_plot_5)),max(max(matrix_for_plot_10)));
     Cmin = min(min(min(matrix_for_plot_5)),min(min(matrix_for_plot_10)));
%     for t=1:1%time_count
         p1 = subplot(2,2,1);
         %left plot
         h1 = pcolor(X,Y,matrix_for_plot_5);
         set(h1,'EdgeColor','none');
         xlabel('km');
         ylabel('km');
         hold on;
         q = contour(X,Y,topo_mask,'LineWidth',0.5,'LineColor',[0.5,0.5,0.5]);  
         shading flat;
         hold on;
         q2 = contour(X,Y,topo,[100 300 500],'LineWidth',0.5,'LineColor',...
             [0.5,0.5,0.5],'ShowText','on');
         title(['Mean Kinetic Energy u_g = 5m/s']);
         
         %right plot
         p2 = subplot(2,2,2);
         h2 = pcolor(X,Y,matrix_for_plot_10);
         set(h2,'EdgeColor','none');
         xlabel('km');
         ylabel('km');
         hold on;
         q = contour(X,Y,topo_mask,'LineWidth',0.5,'LineColor',[0.5,0.5,0.5]);  
         shading flat;
         hold on;
         q2 = contour(X,Y,topo,[100 300 500],'LineWidth',0.5,'LineColor',...
             [0.5,0.5,0.5],'ShowText','on');
         title(['Mean Kinetic Energy u_g = 10m/s']);
         
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

     matrix_for_plot_5 = 0.5* (...
           u2_ug5(:,:,k,time_count)' - (u_ug5(:,:,k,time_count).^2)'...
         + v2_ug5(:,:,k,time_count)' - (v_ug5(:,:,k,time_count).^2)'...
         + w2_ug5(:,:,k,time_count)' - (w_ug5(:,:,k,time_count).^2)');
     matrix_for_plot_10 = 0.5* (...
           u2_ug10(:,:,k,time_count)' - (u_ug10(:,:,k,time_count).^2)'...
         + v2_ug10(:,:,k,time_count)' - (v_ug10(:,:,k,time_count).^2)'...
         + w2_ug10(:,:,k,time_count)' - (w_ug10(:,:,k,time_count).^2)');

     Cmax = max(max(max(matrix_for_plot_5)),max(max(matrix_for_plot_10)));
     Cmin = min(min(min(matrix_for_plot_5)),min(min(matrix_for_plot_10)));
     
         p3 = subplot(2,2,3);
         h3 = pcolor(X,Y,matrix_for_plot_5);
         set(h3,'EdgeColor','none');
         xlabel('km');
         ylabel('km');
         hold on;
         q = contour(X,Y,topo_mask,'LineWidth',0.5,'LineColor',[0.5,0.5,0.5]);  
         shading flat;
         hold on;
         q3 = contour(X,Y,topo,[100 300 500],'LineWidth',0.5,'LineColor',...
             [0.5,0.5,0.5],'ShowText','on');
         title(['Mean Turbulent Kinetic Energy TKE u_g = 5m/s']);
         
         p4 = subplot(2,2,4);
         h4 = pcolor(X,Y,matrix_for_plot_10);
         set(h4,'EdgeColor','none');
         xlabel('km');
         ylabel('km');
         hold on;
         q = contour(X,Y,topo_mask,'LineWidth',0.5,'LineColor',[0.5,0.5,0.5]);  
         shading flat;
         hold on;
         q4 = contour(X,Y,topo,[100 300 500],'LineWidth',0.5,'LineColor',...
             [0.5,0.5,0.5],'ShowText','on');
         title(['Mean Turbulent Kinetic Energy u_g = 10m/s']);

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
         
     plotname=['PALM 25m resolution Kinetic Energy comparisons at z=', num2str(zw_xy(k)), ...
         'm, t=', num2str(time_count*0.5), 'h'];
     sgtitle(plotname,'Interpreter','None','FontSize',10);
     set(gcf,'Position',[406 42 973 1320]);
     %print(gcf,['ug10_50m-w_av_xy-z=',num2str(zw_xy(k)), 'm'],'-dpdf');
    saveas(gcf,['variance_comparison/tke_res25_ug at z=',num2str(zw_xy(k)), ...
        'm, t=', num2str(time_count*0.5), 'h'],'png');
 end
 
 
 