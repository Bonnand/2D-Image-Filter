-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity fifo_tb is
end;

architecture bench of fifo_tb is

  component fifo
  PORT (
    clk : IN STD_LOGIC; -- Clock input
    rst : IN STD_LOGIC; -- Reset input
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Input data 
    wr_en : IN STD_LOGIC; -- Signal which enables FIFO writing
    rd_en : IN STD_LOGIC; -- Signal which enables FIFO reading
    prog_full_thresh : IN STD_LOGIC_VECTOR(9 DOWNTO 0); -- Threshold value of the FIFO, which allows the FIFO to be unstacked when this value is exceeded
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Output data 
    full : OUT STD_LOGIC; -- This signal equals one when the FIFO is full
    empty : OUT STD_LOGIC; -- This signal equals one when the FIFO is empty
    prog_full : OUT STD_LOGIC -- This signal equals one when the number of input data exceeds threshold value
  );
  end component;

  signal clk: STD_LOGIC; -- Clock input
  signal rst: STD_LOGIC; -- Reset input
  signal din: STD_LOGIC_VECTOR(7 DOWNTO 0); -- Input data 
  signal wr_en: STD_LOGIC; -- Signal which enables FIFO writing
  signal rd_en: STD_LOGIC; -- Signal which enables FIFO reading
  signal prog_full_thresh: STD_LOGIC_VECTOR(9 DOWNTO 0); -- Threshold value of the FIFO, which allows the FIFO to be unstacked when this value is exceeded
  signal dout: STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal full: STD_LOGIC; -- This signal equals one when the FIFO is full
  signal empty: STD_LOGIC; -- This signal equals one when the FIFO is empty
  signal prog_full: STD_LOGIC ; -- This signal equals one when the number of input data exceeds threshold value


begin

  uut: fifo port map ( clk              => clk,
                       rst              => rst,
                       din              => din,
                       wr_en            => wr_en,
                       rd_en            => rd_en,
                       prog_full_thresh => prog_full_thresh,
                       dout             => dout,
                       full             => full,
                       empty            => empty,
                       prog_full        => prog_full );

  fifo_storage: process
    variable compteur : integer := 0;
  begin
    rst<='1';
    din<="00000000"; 
    wr_en<='0';          
    prog_full_thresh<="0000100001";            
    wait for 100 ns;
    rst<='0';
    wait until full = '0';
    wr_en<='1';
    
    while (compteur /= 100) loop
      compteur:=compteur+1;
        din<=std_logic_vector(to_unsigned(compteur,8));
      wait for 10ns;
    end loop;
    
    wr_en<='0';
    wait;
  end process;
  
  fifo_unstack : process
    variable compteur : integer := 0;
  begin
    rd_en<='0';
    wait until falling_edge(wr_en);
    rd_en<='1';  
    wait until empty = '1';
    rd_en<='0';  
        
    wait;
  end process;
  

  CLOCK: process
  begin
    loop
        clk<='0';
        wait for 5 ns;
        clk<='1';
        wait for 5 ns;
        -- Put test bench stimulus code here
    end loop;
    wait;
  end process;  

end;
  