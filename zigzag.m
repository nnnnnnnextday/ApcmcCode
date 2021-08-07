function C = zigzag(polyin, d)
    %输入：polyin is input polyspace
    %      d is boundary distance and lining space
    %输出：C perimeter
    C = 0;
    
    plot(polyin,'FaceColor', 'w');
    hold on;
    
    %取一层内轮廓
    innerpoly = polybuffer(polyin, -d);

    X_inner = (innerpoly.Vertices(:,1))';
    Y_inner = (innerpoly.Vertices(:,2))';
    %调整inner坐标数组，去除NaN,用该图的首点替代
    flag_record = zeros(1);
    flag = 1;
    for i = 1:size(X_inner,2)
        if isnan(X_inner(i))
            X_inner(i) = X_inner(flag);
            Y_inner(i) = Y_inner(flag);
            flag = i + 1;
            flag_record = [flag_record flag];
        end
    end
    X_inner = [X_inner X_inner(flag)];
    Y_inner = [Y_inner Y_inner(flag)];

    %找到横纵坐标最大值和最小值
    max_width = max(X_inner);
    min_width = min(X_inner);
    max_height = max(Y_inner);
    min_height = min(Y_inner);
    
    counter = 0;
    intersection_last=zeros(2,1);
    
    for a = min_height :  d : max_height %平行线y值
        counter = counter + 1;
        intersection = zeros(2,1);
        label = 0;
        for i = 1:size(X_inner,2)-1   %遍历寻找焦点
            x_curr = X_inner(i);
            y_curr = Y_inner(i);
            x_next = X_inner(i+1);
            y_next = Y_inner(i+1);
           if(((a-y_curr) * (a-y_next) < 0) && (min(abs(flag_record - i - 1) ~= 0)))   %找到交点,且相交的不是两图形上的点
               x = x_curr + (a-y_curr) * (x_next - x_curr)/(y_next - y_curr);
               intersection = [intersection [x;a]];
               label = 1;
           end
        end
        
        if label == 1
            n = fix(size(intersection,2)/2);
            intersection_sorted = sort(intersection(:,2:size(intersection,2))')';
            for j = 1:n
                plot(intersection_sorted(1,2*j-1:2*j),intersection_sorted(2,2*j-1:2*j),'r');
                C = C + norm(intersection_sorted(1,2*j-1:2*j) - intersection_sorted(2,2*j-1:2*j), 2);
            end
        end

       
        %连接平行线
        if intersection_last~=zeros(2,1)
            for j = 1:n
                %使用计数器判断用左点连接还是右点连接
                if mod(counter, 2) == 1
                    %左点连接
                    %首先找到最近点
                    rep = repmat(intersection_sorted(:,2*j-1), 1, size(intersection_last,2));
                    rep = sqrt(sum((intersection_last - rep).^2));
                    [min_v,min_index] = min(rep);
                    %连接,根据d设定阈值，超过则不连接
                    threshold = 2*d;
                    if min_v <= threshold
                        plot([intersection_sorted(1,2*j-1) intersection_last(1, min_index)], [intersection_sorted(2,2*j-1) intersection_last(2, min_index)], 'r');
                        C = C + min_v;
                    end
                else
                    %右点连接
                    %首先找到最近点
                    rep = repmat(intersection_sorted(:,2*j), 1, size(intersection_last,2));
                    rep = sqrt(sum((intersection_last - rep).^2));
                    [min_v,min_index] = min(rep);
                    %连接,根据d设定阈值，超过则不连接
                    threshold = 2*d;
                    if min_v <= threshold
                        plot([intersection_sorted(1,2*j) intersection_last(1, min_index)], [intersection_sorted(2,2*j-1) intersection_last(2, min_index)], 'r');
                        C = C + min_v;
                    end
                end
            end
        end
        
        if label == 1
            %维护上一交点向量
            intersection_last = intersection_sorted;
        end
    end
   
end