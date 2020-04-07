function rgb = color_hex2rgb(hex)
    rgb = upper(hex);
    rgb = hex(2:end) - 48; %'0'
    letters = find(rgb > 9);
    rgb(letters) = rgb(letters) - 7;
    rgb = rgb.*[240 15 240 15 240 15]/3825;

    rgb = [rgb(1) + rgb(2) rgb(3) + rgb(4) rgb(5) + rgb(6)];
end