function choixbornes(Etape,gcfig)
% No help found
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

switch(Etape)
    case('init')
        gcfig=gcf;
        h=guidata(gcfig);
        set(gcfig,'KeyPressFcn','choixbornes(''Sortie'')');
        h.efface=0;
        h.dim=[];
        h.bounds=[];
        guidata(gcf,h);
        set(gcf,'Pointer','crosshair');
        memorise_etape(gcfig,'ChoixPremierPoint');
        set(gcf,'CreateFcn',[]);
    case('ChoixPremierPoint')
        subplot(2,1,1);
        gcfig = fl_PointerWindow();
        h=guidata(gcfig);
        if h.efface
            delete(h.rouge);
            delete(h.bleu);
        end
        coo=get(gca,'CurrentPoint');
        h.X1=coo(1,1);
        h.Y1=coo(1,2);
        [min1,h.I1]=min(abs(h.X1-h.x));
        h.rouge=plot(h.x(h.I1),h.y(h.I1),'ro');
        guidata(gcfig,h);
        memorise_etape(gcfig,'ChoixSecondPoint');
    case('ChoixSecondPoint')
        gcfig = fl_PointerWindow();
        h=guidata(gcfig);
        figure(gcfig);
        subplot(2,1,1);
        lesx=get(gca,'Xlim');
        x=h.x;
        y=h.y;
        RegParam_bis=h.RegParam;
        coo=get(gca,'CurrentPoint');
        X2=coo(1,1);
        Y2=coo(1,2);
        x_diminue=x(find(x~=x(h.I1)));
        [min2,I2]=min(abs(X2-x_diminue));
        % Points concernés par la regression
        xmin=min(x(h.I1),x_diminue(I2));
        xmax=max(x(h.I1),x_diminue(I2));
        Indexes=find((x>=xmin)&(x<=xmax));
        bounds=[xmin,xmax];
        % Mise à jour du graphique
        delete(h.rouge);
        subplot(2,1,1);
        h.rouge=plot(x(Indexes),y(Indexes),'ro');
        % Calcul de la droite de régression
        if strcmp(RegParam_bis{1},'wls')
            RegParam_bis{2}=RegParam_bis{2}(Indexes);
        end
        [a_hat,b_hat]=fl_monolr(x(Indexes),y(Indexes),RegParam_bis{:});
        % Calcul de dim et des évaluateurs du fit.
        dim=eval(h.FORMULE);
        cor=corrcoef(a_hat*Indexes+b_hat,y(Indexes));
        cor=cor(1,2);
        errmax=max(abs(h.y(Indexes)-(a_hat*x(Indexes)+b_hat)));
        var=max(y(Indexes))-min(y(Indexes));
        errmaxpcent=errmax/var;
        % Mise à jour du graphique
        h.bleu=plot(lesx,a_hat*lesx+b_hat,'b');
      	title_estimated=h.texts(3,:);
        title([title_estimated,num2str(dim,3),'    Corr Coeff : ',num2str(cor,2),'    MaxErr/Amplitude : ',num2str(errmaxpcent*100,2),'%']);
        h.efface=1;
        h.dim=dim;
        h.bounds=bounds;
        guidata(gcf,h);
        memorise_etape(gcfig,'ChoixPremierPoint');
    case('Sortie')
        if nargin<2
            gcfig = fl_PointerWindow();
        end
        h=guidata(gcfig);
        figure(gcfig);
        set(gcf,'ButtonDownFcn','choixbornes(''Entree'')');
        subplot(2,1,2);
        set(gca,'ButtonDownFcn','choixbornes(''Entree'')');
        handles_children=get(gca,'Children');
        for i=1:length(handles_children)
            set(handles_children(i),'ButtonDownFcn','choixbornes(''Entree'')');
        end
        subplot(2,1,1);
        set(gca,'ButtonDownFcn','choixbornes(''Entree'')');
        handles_children=get(gca,'Children');
        for i=1:length(handles_children)
            set(handles_children(i),'ButtonDownFcn','choixbornes(''Entree'')');
        end
        guidata(gcfig,h);
        set(gcfig,'Pointer','arrow');
        set(gcfig,'CreateFcn','ComputationOK');
        set(h.TextER,'String','Click on the figure to change the regression range');
        if ishandle(h.HandleOut)
            set(h.HandleOut,'String',num2str(h.dim));
        end
    case('Entree')
        gcfig = fl_PointerWindow();
        h=guidata(gcfig);
        set(gcfig,'Pointer','crosshair');
        figure(gcfig);
        set(gcfig,'ButtonDownFcn','');
        subplot(2,1,1);
        set(gca,'ButtonDownFcn','');
        subplot(2,1,2);
        set(gca,'ButtonDownFcn','');
        handles_children=get(gca,'Children');
        for i=1:length(handles_children)
            set(handles_children(i),'ButtonDownFcn','');
        end
        set(h.TextER,'String','Choose the bounds of the interval. Press ESCAPE or RETURN to end');
        memorise_etape(gcfig,h.Etape);
    case('FullRange')
        gcfig=gcf;
        h=guidata(gcfig);
        lesx=get(gca,'Xlim');
        x=h.x;
        y=h.y;
        RegParam_bis=h.RegParam;
        Indexes=[1:length(x)];
        bounds=[min(x),max(x)];
        subplot(2,1,1);
        h.rouge=plot(x(Indexes),y(Indexes),'ro');
        % Calcul de la droite de régression
        if strcmp(RegParam_bis{1},'wls')
            RegParam_bis{2}=RegParam_bis{2}(Indexes);
        end
        [a_hat,b_hat]=fl_monolr(x(Indexes),y(Indexes),RegParam_bis{:});
        % Calcul de dim et des évaluateurs du fit.
        dim=eval(h.FORMULE);
        cor=corrcoef(a_hat*y(Indexes)+b_hat,y(Indexes));
        cor=cor(1,2);
        errmax=max(abs(h.y(Indexes)-(a_hat*x(Indexes)+b_hat)));
        var=max(y(Indexes))-min(y(Indexes));
        errmaxpcent=errmax/var;
        % Mise à jour du graphique
        h.bleu=plot(lesx,a_hat*lesx+b_hat,'b');
      	title_estimated=h.texts(3,:);
        title([title_estimated,num2str(dim,3),'    Corr Coeff : ',num2str(cor,2),'    MaxErr/Amplitude : ',num2str(errmaxpcent*100,2),'%']);
        h.efface=1;
        h.dim=dim;
        h.bounds=bounds;
        guidata(gcfig,h);
        memorise_etape(gcfig,'ChoixPremierPoint');
end
 
function memorise_etape(gcfig,Etape);
h=guidata(gcfig);
h.Etape=Etape;
figure(gcfig);
subplot(2,1,1);
set(gca,'ButtonDownFcn',['choixbornes(''',Etape,''')']);
handles_children=get(gca,'Children');
for i=1:length(handles_children)
    set(handles_children(i),'ButtonDownFcn',['choixbornes(''',Etape,''')']);
end

subplot(2,1,2);
set(gca,'ButtonDownFcn',['choixbornes(''',Etape,''')']);
handles_children=get(gca,'Children');
for i=1:length(handles_children)
    set(handles_children(i),'ButtonDownFcn',['choixbornes(''',Etape,''')']);
end
guidata(gcfig,h);


% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%
%     % Choix des bornes et calcul du résultat
%     dim=[];
%     BUTTON=0;
%     efface=0;
%     while BUTTON~=27
%         % Choix de la première borne
%         [X1 Y1 BUTTON]=fl_ginput(gcf,gca);
%         figure(handlefig);
%         if isempty(BUTTON); return;end
%         if (BUTTON==27)|(BUTTON==13) ;return;end
%         
%         % Mise à jour du graphique
%         if efface
%             delete(rouge);
%             delete(bleu);
%         end
%         [min1,I1]=min(abs(X1-x));
%         hold on;
%         subplot(2,1,1);
%         rouge=plot(x(I1),y(I1),'ro');
%         % Choix de la seconde borne
%         [X2 Y2 BUTTON]=fl_ginput(gcf,gca);
%         figure(handlefig);
%         if isempty(BUTTON);return;end
%         if (BUTTON==27)|(BUTTON==13);return;end
%         
%         x_diminue=x(find(x~=x(I1)));
%         [min2,I2]=min(abs(X2-x_diminue));
%         % Points concernés par la regression
%         xmin=min(x(I1),x_diminue(I2));
%         xmax=max(x(I1),x_diminue(I2));
%         Indexes=find((x>=xmin)&(x<=xmax));
%         bounds=[xmin,xmax];
%         % Mise à jour du graphique
%         delete(rouge);
%         subplot(2,1,1);
%         rouge=plot(x(Indexes),y(Indexes),'ro');
%         % Calcul de la droite de régression
%         if strcmp(RegParam{1},'wls')
%             RegParam_bis{2}=RegParam{2}(Indexes);
%         end
%         [a_hat,b_hat]=fl_monolr(x(Indexes),y(Indexes),RegParam_bis{:});
%         % Calcul de dim et des évaluateurs du fit.
%         dim=eval(FORMULE);
%         cor=corrcoef(a_hat*Indexes+b_hat,y(Indexes));
%         cor=cor(1,2);
%         errmax=max(abs(y(Indexes)-(a_hat*x(Indexes)+b_hat)));
%         var=max(y(Indexes))-min(y(Indexes));
%         errmaxpcent=errmax/var;
%         % Mise à jour du graphique
%         bleu=plot(lesx,a_hat*lesx+b_hat,'b');
%         title([title_estimated,num2str(dim,3),'    Corr Coeff : ',num2str(cor,2),'    MaxErr/Amplitude : ',num2str(errmaxpcent*100,2),'%']);
%         efface=1;
% 	end;
% end;
