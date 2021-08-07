%% contour parallel hatch of the single-layer contour pattern
polyin = polyshape(MT(1,:), MT(2,:));
plot(MT(1,:), MT(2,:));
hold on;
contour(MT(1,:), MT(2,:),1);
%C = polymultilayer(polyin, 1);
%disp(C);

%% contour parallel hatch of the mutually nested multi-layer contour patterns
%polyin = polyshape({MT1(1,:), MT2(1,:), MT3(1,:), MT4(1,:)},{MT1(2,:), MT2(2,:), MT3(2,:), MT4(2,:)});
%C = zigzag(polyin, 0.5);
%C = polymultilayer(polyin, 1);
%disp(C)
%disp(C);