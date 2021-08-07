function C = contour(X, Y, d)
    %Input ： polyin is Polyspaces
    %         d is  
    
    C = 0;

    %构造g1、g2，分别为g对应点的相邻两点
    n = size(X,2) - 1;
    g = [X;Y];
    g = g(:,1:n);
    g1 = [g(:,n) g(:,1:n-1)];
    g2 = [g(:,2:n) g(:,1)];
    
    %求相邻点的向量
    v1 = g1 - g;
    v2 = g2 - g;
    
    %求出向量长度
    v1_l = sqrt(v1(1,:).^2+v1(2,:).^2);
    v2_l = sqrt(v2(1,:).^2+v2(2,:).^2); 
    nv1 = v1./v1_l;
    nv2 = v2./v2_l;
    
    %角平分线方向向量
    q = nv1 + nv2;
    L = sqrt(q(1,:).^2+q(2,:).^2);
    nq = q./L;
    
    %根据sin值修正向量方向，由叉乘的z方向值判定,得到内轮廓点集
    z = zeros(1,n);
    for i=1:n
        z(i) = nv1(1,i)*nv2(2,i) - nv2(1,i)*nv1(2,i);
        z(i) = z(i)/abs(z(i));  %归一
    end
    inpoint = g + [z;z]*d.*nq;
    
    %此处设立inpoint_new用于作图,同时增加一个标记维度
    %    设立inpoint_real用于完成处理后进入下一轮递归
    inpoint_real = inpoint;
    inpoint_view = [inpoint;1:length(inpoint)];
    
    %开始处理发生自相交的点
    iPt = 2;
    
    %通过对inpoint循环，对inpoint_view进行处理
    while iPt < length(inpoint)
        
        %首先取得当前坐标点二元组
        x_couple = sort(inpoint(1,iPt-1:iPt));
        y_couple = sort(inpoint(2,iPt-1:iPt));
        
        %向前取点，比较剩下各点于该二元组的方位关系
        right = x_couple(2) < inpoint(1,iPt+1:end);
        left = x_couple(1) > inpoint(1,iPt+1:end);
        above = y_couple(2) < inpoint(2,iPt+1:end);
        below = y_couple(1) > inpoint(2,iPt+1:end);
        
        %将上述点与二元组的关系，转化为点组与该二元组的关系
        right = right(1:end-1) & right(2:end); 
        left = left(1:end-1) & left(2:end);
        above = above(1:end-1) & above(2:end);
        below = below(1:end-1) & below(2:end);
        
        %得到相交候选点组
        cands = find(~(right | left | above | below));
        
        %开始处理相交线段
        if ~isempty(cands)                      
            [xi, yi, flag] = arrayfun(@(x,y) ...
                intersectSeg(inpoint(1,iPt-1), inpoint(2,iPt-1), inpoint(1,iPt), inpoint(2,iPt), ...
                inpoint(1,x), inpoint(2,x), inpoint(1,x+1), inpoint(2,x+1)), (iPt+cands));
            iflag = find(flag == 1, 1, 'last');
            if ~isempty(iflag)
                %更新inpoint_view
                %插入入交点
                [index_row, index_col] = find(inpoint_view==iPt-1);
                inpoint_view = [inpoint_view(:,1:index_col) [xi(iflag);yi(iflag);-1] inpoint_view(:,index_col+1:end)];
                %插入出交点
                [index_row, index_col] = find(inpoint_view==iPt+cands(iflag));
                inpoint_view = [inpoint_view(:,1:index_col) [xi(iflag);yi(iflag);-2] inpoint_view(:,index_col+1:end)];
            end
        end
        iPt = iPt+1;
    end
    
    
    
    %单独对首尾连线进行相交判别
    %首先取得当前坐标点二元组
    x_couple = sort([inpoint(1,end) inpoint(1,1)]);
    y_couple = sort([inpoint(2,end) inpoint(2,1)]);
        
    %向前取点，比较剩下各点于该二元组的方位关系
    right = x_couple(2) < inpoint(1,2:end);
    left = x_couple(1) > inpoint(1,2:end);
    above = y_couple(2) < inpoint(2,2:end);
    below = y_couple(1) > inpoint(2,2:end);
        
    %将上述点与二元组的关系，转化为点组与该二元组的关系
    right = right(1:end-1) & right(2:end); 
    left = left(1:end-1) & left(2:end);
    above = above(1:end-1) & above(2:end);
    below = below(1:end-1) & below(2:end);
        
    %得到相交候选点组
    cands = find(~(right | left | above | below));
        
    %开始处理相交线段
    if ~isempty(cands)
        [xi, yi, flag] = arrayfun(@(x,y) ...
                    intersectSeg(inpoint(1,end), inpoint(2,end), inpoint(1,1), inpoint(2,1),...
                    inpoint(1,x), inpoint(2,x), inpoint(1,x+1), inpoint(2,x+1)), (1+cands));
        iflag = find(flag == 1, 1, 'first');
        if ~isempty(iflag)
            %更新inpoint_view
            %插入入交点
            [index_row, index_col] = find(inpoint_view==cands(iflag));
            inpoint_view = [inpoint_view(:,1:index_col) [xi(iflag);yi(iflag);-1] inpoint_view(:,index_col+1:end)];
            %插入出交点
            inpoint_view = [inpoint_view [xi(iflag);yi(iflag);-2]];
        end
    end    
    
%     %inpoint_view构建完毕，开始构建inpoint_real
%     %依据为inpoint的出入交点标志
%     delete_total = 0;
%     counter = 0;
%     in_index = find(inpoint_view(3,:)==-1);
%     out_index = find(inpoint_view(3,:)==-2);
%     in_out_index = sort([in_index out_index]);
%     %基本思想同括号判别栈
%     for index=in_out_index
%         if any(in_index==index)
%             counter = counter+1;
%             %计数器为1时，添加交点进入inpoint_real
%             if counter == 1
%                 in_index_value = inpoint_view(3,index-1)+1;
%                 inpoint_real(:,in_index_value) =  inpoint_view(1:2,index);
%             end
%         else
%             counter = counter-1;
%             %计数器为0时，删除交点间所有轮廓点
%             if counter == 0
%                 out_index_value = inpoint_view(3,index-1);
%                 n=1;
%                 while out_index_value==-2
%                     out_index_value = inpoint_view(3,index-1-n);
%                     n=n+1;
%                 end
%                 inpoint_real(:,in_index_value+1-delete_total:out_index_value-delete_total)=[];
%                 delete_total = delete_total+out_index_value-in_index_value+1;
%             end
%         end
% 
%         %计数器为0时，删除交点间所有轮廓点
%     end

    %构建inpoint_real
    iPt = 2;
    while iPt < length(inpoint_real)
        
        %首先取得当前坐标点二元组
        x_couple = sort(inpoint_real(1,iPt-1:iPt));
        y_couple = sort(inpoint_real(2,iPt-1:iPt));
        
        %向前取点，比较剩下各点于该二元组的方位关系
        right = x_couple(2) < inpoint_real(1,iPt+1:end);
        left = x_couple(1) > inpoint_real(1,iPt+1:end);
        above = y_couple(2) < inpoint_real(2,iPt+1:end);
        below = y_couple(1) > inpoint_real(2,iPt+1:end);
        
        %将上述点与二元组的关系，转化为点组与该二元组的关系
        right = right(1:end-1) & right(2:end); 
        left = left(1:end-1) & left(2:end);
        above = above(1:end-1) & above(2:end);
        below = below(1:end-1) & below(2:end);
        
        %得到相交候选点组
        cands = find(~(right | left | above | below));
        
        %开始处理相交线段
        if ~isempty(cands)
            [xi, yi, flag] = arrayfun(@(x,y) ...
                intersectSeg(inpoint_real(1,iPt-1), inpoint_real(2,iPt-1), inpoint_real(1,iPt), inpoint_real(2,iPt), ...
                inpoint_real(1,x), inpoint_real(2,x), inpoint_real(1,x+1), inpoint_real(2,x+1)), (iPt+cands));
            iflag = find(flag == 1, 1, 'last');
            if ~isempty(iflag)
                inpoint_real(1,iPt) = xi(iflag);
                inpoint_real(2,iPt) = yi(iflag);
                inpoint_real(:,iPt+1:iPt+cands(iflag)) = [];
            end
        end
        iPt = iPt+1;
    end
    
    %单独对首尾连线进行相交判别
    %首先取得当前坐标点二元组
    x_couple = sort([inpoint_real(1,end) inpoint_real(1,1)]);
    y_couple = sort([inpoint_real(2,end) inpoint_real(2,1)]);
        
    %向前取点，比较剩下各点于该二元组的方位关系
    right = x_couple(2) < inpoint_real(1,2:end);
    left = x_couple(1) > inpoint_real(1,2:end);
    above = y_couple(2) < inpoint_real(2,2:end);
    below = y_couple(1) > inpoint_real(2,2:end);
        
    %将上述点与二元组的关系，转化为点组与该二元组的关系
    right = right(1:end-1) & right(2:end); 
    left = left(1:end-1) & left(2:end);
    above = above(1:end-1) & above(2:end);
    below = below(1:end-1) & below(2:end);
        
    %得到相交候选点组
    cands = find(~(right | left | above | below));
        
    %开始处理相交线段
    if ~isempty(cands)
        [xi, yi, flag] = arrayfun(@(x,y) ...
                    intersectSeg(inpoint_real(1,end), inpoint_real(2,end), inpoint_real(1,1), inpoint_real(2,1),...
                    inpoint_real(1,x), inpoint_real(2,x), inpoint_real(1,x+1), inpoint_real(2,x+1)), (1+cands));
        iflag = find(flag == 1, 1, 'first');
        if ~isempty(iflag)
            inpoint_real(:,cands(iflag):end) = [];
            inpoint_real = [inpoint_real [xi(iflag);yi(iflag)]];
        end
    end    
    
    inpoint_real = [inpoint_real inpoint_real(:,1)];
    inpoint_view = [inpoint_view inpoint_view(:,1)];
    
    %根据inpoint_view作图
    index = sort([find(inpoint_view(3,:)==-1) find(inpoint_view(3,:)==-2)]);
    index = [1 index length(inpoint_view)];
    
    if 1
        for j = 1:(length(index)/2)
            plot(inpoint_view(1,index(2*j-1):index(2*j)), inpoint_view(2,index(2*j-1):index(2*j)),'r');
        end
    else
        for j = 1:(length(index)/2-1)
            plot(inpoint_view(1,index(2*j):index(2*j+1)), inpoint_view(2,index(2*j):index(2*j+1)),'r');
        end
    end
    
    
%     plot(inpoint_view(1,:), inpoint_view(2,:));
    if ~isnan(inpoint_real(1,1))
        contour(inpoint_real(1,:), inpoint_real(2,:),d);
    end
end

function [xi, yi, flag] = intersectSeg(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2)
    eps = 10^-10;
    adx = ax2-ax1; ady = ay2-ay1;
    bdx = bx2-bx1; bdy = by2-by1;
    
    xprod = @(x1, y1, x2, y2) x1*y2 - x2*y1;
    rxs = xprod(adx, ady, bdx, bdy);
    
    if abs(rxs) < eps % Parallel segments
        xi = NaN; yi = NaN; flag = 0;
    else
        t = xprod(bx1-ax1, by1-ay1, bdx, bdy) / rxs;
        u = xprod(bx1-ax1, by1-ay1, adx, ady) / rxs;

        xi = ax1 + t*adx;
        yi = ay1 + t*ady;
        if t>=0 && t <= 1 && u >= 0 && u <= 1
            flag = 1;
        else
            flag = 2;
        end
    end
end