data = load('..\Projet_TP.sim\sim_1\behav\xsim\Lena128x128g_8bits_filtered.dat');

w = 128;
h = 128;

d = mat2gray(bin2dec(num2str(data)));
im = reshape(d, w,h)';
imwrite(im, 'Lena128x128g_8bits_filtered.bmp');
