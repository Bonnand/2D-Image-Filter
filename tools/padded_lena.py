import shutil

file_path = '../Projet_TP.sim/sim_1/behav/xsim/Lena128x128g_8bits_filtered.dat'

''' Reading content of the file '''
with open(file_path, 'r') as file:
    lines = file.readlines()

''' Adding 258 pixels, all set to 0, 129 at the bottom and 129 at the top of the image '''
zero_lines = ['00000000\n'] * 129
lines = zero_lines + lines + zero_lines

''' Overwrites the old image with the new padded image '''
with open(file_path, 'w') as file:
    file.writelines(lines)

''' Copy the new padded image into "tools" directory '''
shutil.copy(file_path, './')
