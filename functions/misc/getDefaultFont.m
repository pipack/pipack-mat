function [default_font_name] = getDefaultFont()
%GETDEFAULTFONT Returns default font for plots. Searches through existing fonts and finds preferred match

default_font_name = '';
available_fonts = listfonts;
preferred_fonts = {
    'Minion Pro'
    'Linux Biolinum O'      % Fedora Compatible
    'Universalis ADF Std'
    'AvantGarde'
    'Times'
};

for i = 1 : length(preferred_fonts)
    if(ismember(preferred_fonts{i}, available_fonts))
        default_font_name = preferred_fonts{i};
        break;
    end
end

end