%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 23/5/2023
%--------------------------------------------------------------------------

function []                                         = ShowTrajectory(cache,mode)
    figure(999);
    switch mode
        case 'single'
            plot(cache.pos_px.shiftx,cache.pos_px.shifty,'-o');
            xlabel('pixel');
            ylabel('pixel');
            title('Trajectory Map');
        case 'double'
            %-------------------------------------
            %make sure that all pos are positive
            min_x_px                                = min(min(cache.pos_px.shiftx));
            min_y_px                                = min(min(cache.pos_px.shifty));
            min_xy                                  = min(min_x_px,min_y_px);
            if min_xy                               < 0
                cache.pos_px.shiftx                 = cache.pos_px.shiftx - min_xy  + 1;
                cache.pos_px.shifty                 = cache.pos_px.shifty - min_xy  + 1;
            end
            min_x_px                                = min(min(cache.pos_px_old.shiftx));
            min_y_px                                = min(min(cache.pos_px_old.shifty));
            min_xy                                  = min(min_x_px,min_y_px);
            if min_xy                               < 0
                cache.pos_px_old.shiftx             = cache.pos_px_old.shiftx - min_xy  + 1;
                cache.pos_px_old.shifty             = cache.pos_px_old.shifty - min_xy  + 1;
            end
            %-------------------------------------
            %match position
            cache.pos_px.shiftx                     = cache.pos_px.shiftx - cache.pos_px.shiftx(1);
            cache.pos_px.shifty                     = cache.pos_px.shifty - cache.pos_px.shifty(1);
            cache.pos_px_old.shiftx                 = cache.pos_px_old.shiftx - cache.pos_px_old.shiftx(1);
            cache.pos_px_old.shifty                 = cache.pos_px_old.shifty - cache.pos_px_old.shifty(1);
            %-------------------------------------
            %plot
            plot(cache.pos_px_old.shiftx,cache.pos_px_old.shifty,'-o');
            hold on;
            plot(cache.pos_px.shiftx,cache.pos_px.shifty,'-o');
            legend('Position Old','Position Refined');
            xlabel('pixel');
            ylabel('pixel');
            title('Trajectory map');
        case 'error'
            %-------------------------------------
            %make sure that all pos are positive
            min_x_px                                = min(min(cache.pos_px.shiftx));
            min_y_px                                = min(min(cache.pos_px.shifty));
            min_xy                                  = min(min_x_px,min_y_px);
            if min_xy                               < 0
                cache.pos_px.shiftx                 = cache.pos_px.shiftx - min_xy  + 1;
                cache.pos_px.shifty                 = cache.pos_px.shifty - min_xy  + 1;
            end
            min_x_px                                = min(min(cache.pos_px_old.shiftx));
            min_y_px                                = min(min(cache.pos_px_old.shifty));
            min_xy                                  = min(min_x_px,min_y_px);
            if min_xy                               < 0
                cache.pos_px_old.shiftx             = cache.pos_px_old.shiftx - min_xy  + 1;
                cache.pos_px_old.shifty             = cache.pos_px_old.shifty - min_xy  + 1;
            end
            %-------------------------------------
            %match position
            cache.pos_px.shiftx                     = cache.pos_px.shiftx - cache.pos_px.shiftx(1);
            cache.pos_px.shifty                     = cache.pos_px.shifty - cache.pos_px.shifty(1);
            cache.pos_px_old.shiftx                 = cache.pos_px_old.shiftx - cache.pos_px_old.shiftx(1);
            cache.pos_px_old.shifty                 = cache.pos_px_old.shifty - cache.pos_px_old.shifty(1);
            %-------------------------------------
            %caldulate vector
            U                                       = cache.pos_px_old.shiftx - cache.pos_px.shiftx;
            V                                       = cache.pos_px_old.shifty - cache.pos_px.shifty;
            %-------------------------------------
            %plot
            subplot(3,3,[2 3 5 6]);
            plot(cache.pos_px_old.shiftx,cache.pos_px_old.shifty,'-o');
            hold on;
            q = quiver(cache.pos_px.shiftx,cache.pos_px.shifty,U,V);
            hold on;
            plot(cache.pos_px.shiftx,cache.pos_px.shifty,'-o');
%             q.Alignment = "tail";
            legend('old position','error vector','new position');
            q.AutoScale = 'off';
            title('Position error map');
            xlabel('pixel');
            ylabel('pixel');
            %plot pos error map
            %plot y axies error map
            subplot(3,3,[1,4]);
            plot(U,'-o');
            set(gca,'XLim',[1,length(U)]);
            title('Y axies error map');
            xlabel('number');
            ylabel('pixel');
            
            %plot x axies error map
            subplot(3,3,[8,9]);
            plot(V,'-o');
            set(gca,'XLim',[1,length(V)]);
            title('X axies error map');
            xlabel('number');
            ylabel('pixel');
    end
end

