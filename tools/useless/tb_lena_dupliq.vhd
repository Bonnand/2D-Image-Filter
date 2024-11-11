library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_lena_dupliq is
       
end;

architecture arch_tb_lena_dupliq of tb_lena_dupliq is


  signal I1 : std_logic_vector (7 downto 0);
  signal CLK : std_logic;
  signal O1 : std_logic_vector (7 downto 0); 
  signal DATA_AVAILABLE : std_logic;
  
begin
 process
  FILE vectors : text;
  file results : text;
  variable Iline, OLine : line;
  variable I1_var, I2_var :std_logic_vector (7 downto 0);
  variable O1_var :std_logic_vector (7 downto 0);
    
    begin
	DATA_AVAILABLE <= '0';
    file_open (vectors,"Lena128x128g_8bits.dat", read_mode);
    file_open (results,"Lena128x128g_8bits_r.dat", write_mode);
    
    while not endfile(vectors) loop
      readline (vectors,Iline);
      read (Iline,I1_var);
            
      I1 <= I1_var;
	  DATA_AVAILABLE <= '1';
	  wait for 10 ns;
      

      write (Oline, O1, right, 2);
      writeline (results, Oline);
      
    end loop;
    file_close (vectors);
    file_close (results);
    wait;
 end process;


O1 <= I1;
  
end arch_tb_lena_dupliq;

