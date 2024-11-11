LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY tb_fifo IS
END tb_fifo;
 
ARCHITECTURE tb_fifo_arch OF tb_fifo IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
  COMPONENT top_fifo
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    prog_full_thresh : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    almost_full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
    wr_data_count : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
    prog_full : OUT STD_LOGIC;
    wr_rst_busy : OUT STD_LOGIC;
    rd_rst_busy : OUT STD_LOGIC
  );
END COMPONENT;

   --Inputs
    signal rst : STD_LOGIC;
    signal wr_clk : STD_LOGIC;
    signal rd_clk : STD_LOGIC;
    signal din : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal wr_en : STD_LOGIC;
    signal rd_en : STD_LOGIC;
    signal prog_full_thresh : STD_LOGIC_VECTOR(9 DOWNTO 0);
    signal dout : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal full : STD_LOGIC;
    signal almost_full : STD_LOGIC;
    signal empty : STD_LOGIC;
    signal rd_data_count : STD_LOGIC_VECTOR(9 DOWNTO 0);
    signal wr_data_count : STD_LOGIC_VECTOR(9 DOWNTO 0);
    signal prog_full : STD_LOGIC;
    signal wr_rst_busy : STD_LOGIC;
    signal  rd_rst_busy : STD_LOGIC;

   -- Clock period definitions
   constant clk_period_wr : time := 10 ns;
   constant clk_period_rd : time := 33 ns;
 
BEGIN
 
	-- Instantiate the component 
    compo_top_fifo1: top_fifo port map (rst, wr_clk, rd_clk, din, wr_en, rd_en, prog_full_thresh, dout, full,
    almost_full, empty , rd_data_count, wr_data_count, prog_full, wr_rst_busy, rd_rst_busy );
    
   -- WR Clock process definitions
   wr_clk_process :process
   begin
		wr_clk <= '0';
		wait for clk_period_wr/2;
		wr_clk <= '1';
		wait for clk_period_wr/2;
   end process;
 
   -- RD Clock process definitions
   rd_clk_process :process
   begin
		rd_clk <= '0';
		wait for clk_period_rd/2;
		rd_clk <= '1';
		wait for clk_period_rd/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
      rst <= '1';
      din <= (others => '1');
      wr_en <= '0';
      rd_en <= '0';
      prog_full_thresh <= "0000000100";
      wait for 200 ns;
      rst <= '0';
      wait for clk_period_wr*10;
      
      wait until (full='0' and empty='1');
      wait for clk_period_wr*5;
      
      wait until (wr_clk'event and wr_clk ='1');
      wait for 2 ns;
	  din <= x"AA";	
      wr_en <= '1';	
	  wait for clk_period_wr*1;
	  din <= x"04";	
	  wait for clk_period_wr*1;
	  din <= x"05";	
	  wait for clk_period_wr*1;
	  din <= x"06";	
  	  wait for clk_period_wr*1;
	  din <= x"07";	
	  wr_en <= '0';	
	  wait for clk_period_wr*5;
	  rd_en <= '1';
	  wait for clk_period_rd*10;
	  rd_en <= '0';
	  wait for clk_period_rd*5;
     --wait for clk_period_rd*10;
      wait;
   end process;

END;
