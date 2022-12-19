function ebptab = ebp_table(fig, hObj,do,Cdata)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% initialise parameters for table     
minRows = 4;
NCols=4; 
RowSize=15;
switch do
    case 'Table'
        ebptab.figure = fig;
        set(hObj, 'units', 'pixels');
        axe_pos = get(hObj, 'position');

        % set up grid info structure
        SCdata = size(Cdata);
        ebptab.maxRows = SCdata(1);
        if ebptab.maxRows < minRows
            blanks = cell(1, SCdata(2));
            for ii = ebptab.maxRows+1:minRows
                Cdata = [Cdata; blanks];
            end
            ebptab.maxRows = minRows;
        end
        ebptab.data = Cdata;
        ebptab.hObj = hObj;
        
        % Set axes 
        set(fig, 'CurrentAxes', ebptab.hObj);
        set(ebptab.hObj, 'xlim', [0 1], 'ylim', [0 1], 'xtick', [], 'ytick', []);

        % Scrolling table
        fcn = sprintf('ebp_table(%14.13f, %14.13f, ''Scroll'');',fig, hObj);
        ebptab.slider = uicontrol('parent',fig,'style', 'slider', 'units', 'pixels',...
            'position', [axe_pos(1)+axe_pos(3)+2 axe_pos(2) 16 axe_pos(4)],...
            'Callback', fcn,'tag','sctab');
        set(hObj, 'UserData', ebptab);

        axe_pos = get(hObj,'position');
        ebptab.numRows = floor((axe_pos(4)-(2*RowSize))/RowSize);
        if ebptab.numRows > ebptab.maxRows
            ebptab.numRows = ebptab.maxRows;
        end

        if(ebptab.numRows < ebptab.maxRows)
            set(ebptab.slider,'parent',fig,...
                            'position', [axe_pos(1)+axe_pos(3)+1 axe_pos(2) 16 axe_pos(4)], ...
                            'min', 0,...
                            'max', ebptab.maxRows - ebptab.numRows, 'value', ebptab.maxRows - ebptab.numRows, ...
                            'sliderstep', [1/(ebptab.maxRows-ebptab.numRows) ebptab.numRows/(ebptab.maxRows-ebptab.numRows)]);
        else 
            set(ebptab.slider,'parent',fig,...
                            'position', [axe_pos(1)+axe_pos(3)+1 axe_pos(2) 16 axe_pos(4)], ...
                            'min', 0,...
                            'max', 0.1, 'value', 0, ...
                            'sliderstep', [0 100]);
        end

        % Horizontal line positions
        hx = ones(2, ebptab.numRows+2);
        hx(1, :) = 0;
        hy = [0:ebptab.numRows+1; 0:ebptab.numRows+1]/(ebptab.numRows+1);

        % Vertical line positions
        vy = ones(2, NCols+1);
        vy(1, :) = 0;
        vx = [0:NCols;0:NCols]/NCols;

        % Color in grey the first Row
        a = ebptab.numRows /(ebptab.numRows+1);
        b = a + (1/(ebptab.numRows+1)) - .001;
        hpatch =patch([0 1 1 0],[a a b b ],[204 204 204]/255,'parent',hObj);

        % Draw table
        HL  = line(hx, hy,'parent',hObj);
        HL1 = line(hx, hy,'parent',hObj);
        VL  = line(vx, vy,'parent',hObj);
        VL1 = line(vx, vy,'parent',hObj);
        set(HL , 'color', [159 159 159]/255, 'LineWidth', 2);
        set(HL1, 'color', [232 232 232]/255, 'LineWidth', 0.5);
        set(VL , 'color', [159 159 159]/255, 'LineWidth', 2);
        set(VL1, 'color', [232 232 232]/255, 'LineWidth', 0.5);

        % Display data in table   
        txt_x = [0:NCols-1]/NCols + 4/(axe_pos(3));
        for i = 2:NCols
          txt_x(i) = txt_x(i-1) + 1/4;
        end
        ebptab.txt_x = txt_x;

        % Write Title
        Ctitles = text(txt_x, ones(1, NCols), {'Level','H-estimated','Lower Bound','Upper Bound'},'parent',hObj);
        set(Ctitles(:, :), 'FontSize', 9, 'FontWeight', 'bold', ...
                                 'HorizontalAlignment','Center','VerticalAlignment', 'top');
        for i = 1:length(Ctitles)
            if i > 1
                dpos = 0.85*(vx(1,i) - vx(1,i-1)) / 2;
            else
                dpos  = (vx(1,i+1)) / 2;
            end
            pos = get(Ctitles(i), 'position');
            pos(1) = pos(1) + dpos;
            set(Ctitles(i), 'position', pos);
        end
        
        txt_x(1)=txt_x(1)+0.12;
        
        % Write Data
        ebptab.txtCells = zeros(ebptab.numRows, NCols);
        for j = 1:ebptab.numRows
            txt_y = (ebptab.numRows-j+1)/(ebptab.numRows+1) * ones(1, NCols);
            txt_y = txt_y - (0.9/(ebptab.numRows + 1)); 
            ebptab.txtCells(j, :) = text(txt_x, txt_y, 'a','parent',hObj);
            for i = 1:NCols
                set(ebptab.txtCells(j, i), 'string', num2str(ebptab.data{j, i}, '%3.7g'), 'Position', [txt_x(i), txt_y(i)]);
            end
        end

        set(ebptab.txtCells(:, 3:end), 'FontSize', 9, 'FontWeight', 'normal', ...
                                 'HorizontalAlignment','left','VerticalAlignment', 'bottom');
        set(ebptab.txtCells(:, 2), 'FontSize', 9, 'FontWeight', 'bold', ...
                                 'HorizontalAlignment','left','VerticalAlignment', 'bottom');
        set(ebptab.txtCells(:, 1), 'FontSize', 10, 'FontWeight', 'bold', ...
                                 'HorizontalAlignment','Center','VerticalAlignment', 'bottom');
        set(hObj, 'UserData', ebptab);
        return

    case 'Scroll'
        ebptab = get(hObj, 'UserData');
        if isempty(ebptab)
            return
        end
        set(ebptab.slider,'Units','pixels');
        val = get(ebptab.slider, 'Value');
        max_val = get(ebptab.slider, 'Max');
        min_val = get(ebptab.slider, 'Min');
        val0 = ebptab.maxRows - ebptab.numRows;
        slid_pos = round(val0-val);
 
        % Scroll table
        for i = slid_pos+1:(slid_pos+ebptab.numRows)
            for j = 1:NCols
                set(ebptab.txtCells(i-slid_pos, j), 'string', num2str(ebptab.data{i, j}, '%3.6g'));
            end
        end

        % Scroll position
        ebptab.slid_pos = slid_pos;
        set(ebptab.slider,'Units','normalized');
        set(hObj, 'UserData', ebptab);
        return
end