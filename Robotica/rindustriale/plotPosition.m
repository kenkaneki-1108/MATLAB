function plotPosition(numPoint,P,position)
figure("Name","Position"), axis([0 2 0 2 0 2]), hold on, grid on
    for i=1:numPoint
        plot3(position(1,i),position(2,i),position(3,i),'ob')
    end
    plot3(P(1,1),P(2,1),P(3,1),'or','LineWidth',2), text(P(1,1)-0.1,P(2,1)+0.001,P(3,1)+0.001,'P1')
    plot3(P(1,2),P(2,2),P(3,2),'or','LineWidth',2), text(P(1,2)+0.05,P(2,2)+0.001,P(3,2)+0.001,'P2')
    plot3(P(1,3),P(2,3),P(3,3),'or','LineWidth',2), text(P(1,3),P(2,3)+0.08,P(3,3)+0.001,'P3')
end