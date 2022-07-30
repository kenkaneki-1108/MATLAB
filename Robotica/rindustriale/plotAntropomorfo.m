function plotAntropomorfo(P,Q,d,a,alpha,position)

% Plot tramite Robotics Toolbox
link1 = Link([Q(1,1),d(1),a(1),alpha(1),0],'standard');
link2 = Link([Q(2,1),d(2),a(2),alpha(2),0],'standard');
link3 = Link([Q(3,1),d(3),a(3),alpha(3),0],'standard');
links = [link1 link2 link3];
robot = SerialLink(links,'name','Antropomorfo');

figure("Name","Plot by RoboticsToolbox"), hold on, axis([-2 2 -2 2 -2 3])
    plot3(P(1,1),P(2,1),P(3,1),'or'), text(P(1,1)-0.2,P(2,1)+0.2,P(3,1)+0.01,'P1')
    plot3(P(1,2),P(2,2),P(3,2),'or'), text(P(1,2)+0.2,P(2,2),P(3,2)+0.01,'P2')
    plot3(P(1,3),P(2,3),P(3,3),'or'), text(P(1,3),P(2,3)+0.2,P(3,3)+0.01,'P3')
    plot3(position(1,:),position(2,:),position(3,:),'LineStyle','-','Color','blue')
    
    robot.plot(Q');
end