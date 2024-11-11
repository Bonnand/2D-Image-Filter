-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity delayed_line_tb is
end;

architecture bench of delayed_line_tb is

  component delayed_line
  PORT (
    CLK : IN STD_LOGIC; -- Clock input
    RST : IN STD_LOGIC; -- Reset input
    DATA_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Input of pixels into delayed line
    DATA_IN_VALID : IN STD_LOGIC; -- Signal indicating that the incoming pixels are valid
    PROG_FULL_THRESH : IN STD_LOGIC_VECTOR(9 DOWNTO 0); -- Threshold value of the two FIFOs, which allows the FIFO to be unstacked when this value is exceeded
    FULL_1 : OUT STD_LOGIC; -- This signal equals one when the first FIFO is full
    FULL_2 : OUT STD_LOGIC; -- This signal equals one when the second FIFO is full
    EMPTY_1 : OUT STD_LOGIC; -- This signal equals one when the first FIFO is empty
    EMPTY_2 : OUT STD_LOGIC; -- This signal equals one when the second FIFO is empty
    DATA_OUT_VALID : OUT STD_LOGIC;  -- Signal indicating that outgoing pixels are valid
    LINE_DATA_1 : OUT STD_LOGIC_VECTOR(23 DOWNTO 0); -- Data which contains pixels value
    LINE_DATA_2 : OUT STD_LOGIC_VECTOR(23 DOWNTO 0); -- Data which contains pixels value
    LINE_DATA_3 : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)  -- Data which contains pixels value 
  );
  end component;

    signal CLK : STD_LOGIC; -- Clock input
    signal RST : STD_LOGIC; -- Reset input
    signal DATA_IN : STD_LOGIC_VECTOR(7 DOWNTO 0); -- Input of pixels into delayed line
    signal DATA_IN_VALID : STD_LOGIC; -- Signal indicating that the incoming pixels are valid
    signal PROG_FULL_THRESH : STD_LOGIC_VECTOR(9 DOWNTO 0); -- Threshold value of the two FIFOs, which allows the FIFO to be unstacked when this value is exceeded
    signal FULL_1 : STD_LOGIC; -- This signal equals one when the first FIFO is full
    signal FULL_2 : STD_LOGIC; -- This signal equals one when the second FIFO is full
    signal EMPTY_1 : STD_LOGIC; -- This signal equals one when the first FIFO is empty
    signal EMPTY_2 : STD_LOGIC; -- This signal equals one when the second FIFO is empty
    signal DATA_OUT_VALID : STD_LOGIC;  -- Signal indicating that outgoing pixels are valid
    signal LINE_DATA_1 : STD_LOGIC_VECTOR(23 DOWNTO 0); -- Data which contains pixels value
    signal LINE_DATA_2 : STD_LOGIC_VECTOR(23 DOWNTO 0); -- Data which contains pixels value
    signal LINE_DATA_3 : STD_LOGIC_VECTOR(23 DOWNTO 0);  -- Data which contains pixels value 

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: delayed_line port map ( CLK              => CLK,
                                RST              => RST,
                                DATA_IN          => DATA_IN,
                                DATA_IN_VALID    => DATA_IN_VALID,
                                PROG_FULL_THRESH => PROG_FULL_THRESH,
                                FULL_1           => FULL_1,
                                FULL_2           => FULL_2,
                                EMPTY_1          => EMPTY_1,
                                EMPTY_2          => EMPTY_2,
                                DATA_OUT_VALID   => DATA_OUT_VALID,
                                LINE_DATA_1      => LINE_DATA_1,
                                LINE_DATA_2      => LINE_DATA_2,
                                LINE_DATA_3      => LINE_DATA_3
                                 );

  stimulus: process
   variable compteur : integer := 0; 
  begin 
    RST<='1';
    DATA_IN<="00000000"; 
    DATA_IN_VALID<='0';          
    PROG_FULL_THRESH<="0000000101";            
    wait for 100 ns;
    RST<='0';
    wait for 200 ns;
    DATA_IN_VALID<='1';  
    
    while (compteur /= 100) loop
      compteur:=compteur+1;
      DATA_IN<=std_logic_vector(to_unsigned(compteur,8));
      wait for 10ns;
    end loop;
    
    DATA_IN_VALID<='0';  
    wait;

    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      CLK <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;
  