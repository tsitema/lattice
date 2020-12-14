include

par=struct('loss',1,'alpha',0,'input',0,'pump',1.2,'tr',100,'M',0);
eqn=ClassBdetuning(par);
rr=RandomNetwork(5,6,eqn);
H=Solver.calch(rr);
Visual.showH(H);
soln=Solver.calctime(rr,100);
Visual.graphTimeAmp(soln);