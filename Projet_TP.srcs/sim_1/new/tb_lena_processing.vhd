library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_lena_processing is
       
end;

architecture arch_tb_lena_processing of tb_lena_processing is
    
    component top_filter2D_Sobel is
    Port (  CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            DATA_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            DATA_IN_VALID : IN STD_LOGIC;
            PROG_FULL_THRESH : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            DATA_OUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            DATA_OUT_VALID : OUT STD_LOGIC
           );
    end component;

  signal I1 : std_logic_vector (7 downto 0);
  signal O1 : std_logic_vector (7 downto 0); 
  signal DATA_AVAILABLE : std_logic;
  signal pixel_in : integer range 0 to 17000 := 0;
  signal pixel_out : integer range 0 to 17000 := 0;
  
  signal CLK : std_logic;
  signal RST : std_logic := '0';
  signal s_data_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal s_data_in_valid : STD_LOGIC;
  signal s_prog_full_thresh : STD_LOGIC_VECTOR(9 DOWNTO 0);
  signal s_data_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal s_data_out_valid : STD_LOGIC;

  
begin

uut: top_filter2D_Sobel port map ( CLK              => CLK,
                                RST              => RST,
                                DATA_IN          => s_data_in,
                                DATA_IN_VALID    => s_data_in_valid,
                                PROG_FULL_THRESH => s_prog_full_thresh,
                                DATA_OUT         => s_data_out,
                                DATA_OUT_VALID   => s_data_out_valid
                             );
                                
 p_read : process
  FILE vectors : text;
  variable Iline : line;
  variable I1_var :std_logic_vector (7 downto 0);
 
    begin
	DATA_AVAILABLE <= '0';
	RST<='1';
	s_prog_full_thresh<="0001111011"; 
    file_open (vectors,"Lena128x128g_8bits.dat", read_mode);
    wait for 100 ns;
    RST<='0';
    wait for 300 ns;
    while not endfile(vectors) loop
      readline (vectors,Iline);
      read (Iline,I1_var);
                
      I1 <= I1_var;
      pixel_in<=pixel_in+1;
	  DATA_AVAILABLE <= '1';
	  wait for 10 ns;
    end loop;
    DATA_AVAILABLE <= '0';
    wait for 1 us; 
    file_close (vectors);
    wait;
 end process;

p_write: process
  file results : text;
  variable OLine : line;
  variable O1_var :std_logic_vector (7 downto 0);
    
    begin
    file_open (results,"Lena128x128g_8bits_filtered.dat", write_mode);
    wait for 10 ns;
    wait until s_data_out_valid = '1';
    wait for 10 ns;
    
    while s_data_out_valid ='1' loop
      write (Oline, O1, right, 2);
      writeline (results, Oline);
      pixel_out<=pixel_out+1;
      wait for 10 ns;  
    end loop;
    wait for 1 us; 
    file_close (results);
    wait;
 end process;
--Instancier composant filtre à place de la simple recopie entre I1 vers sortie O1 (top)
s_data_in<= I1;
O1<=s_data_out;
s_data_in_valid<=DATA_AVAILABLE;

p_clock: process
begin
  CLK<='0';
  wait for 5ns;
  CLK<='1';
  wait for 5ns;   
 end process;
  
end arch_tb_lena_processing;

