----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.09.2024 15:57:59
-- Design Name: 
-- Module Name: fifo - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--------------------------------------------------
-- ENTITY DECLARATION
--------------------------------------------------
entity delayed_line is
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
end delayed_line;

architecture Behavioral of delayed_line is

--------------------------------------------------
-- COMPONENTS DECLARATION
--------------------------------------------------
component fifo_generator_0 IS
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
END component fifo_generator_0;


--------------------------------------------------
-- SIGNALS DECLARATION
--------------------------------------------------
signal s_line_data_1 : STD_LOGIC_VECTOR(23 DOWNTO 0) := (others => '0'); -- Data which contains pixels value
signal s_line_data_2 : STD_LOGIC_VECTOR(23 DOWNTO 0) := (others => '0'); -- Data which contains pixels value
signal s_line_data_3 : STD_LOGIC_VECTOR(23 DOWNTO 0) := (others => '0'); -- Data which contains pixels value
signal line_valid_1 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (others => '0');  -- Signal data valid delayed
signal line_valid_2 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (others => '0');  -- Signal data valid delayed
signal line_valid_3 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (others => '0');  -- Signal data valid delayed
signal data_out_fifo_1 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0'); -- Output pixels of first FIFO
signal data_out_fifo_2 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0'); -- Output pixels of second FIFO
signal s_wr_en_1 : STD_LOGIC := '0'; -- Write enable signal of first FIFO
signal s_wr_en_2 : STD_LOGIC := '0'; -- Write enable signal of second FIFO
signal s_prog_full_1 : STD_LOGIC := '0'; -- Prog full signal of first FIFO
signal s_prog_full_2 : STD_LOGIC := '0'; -- Prog full signal of second FIFO
signal s_full_1 : STD_LOGIC := '0'; -- Full signal of first FIFO
signal s_full_2 : STD_LOGIC := '0'; -- Full signal of second FIFO
signal s_empty_1 : STD_LOGIC := '0'; -- Empty signal of first FIFO
signal s_empty_2 : STD_LOGIC := '0'; -- Empty signal of second FIFO

begin

--------------------------------------------------
-- WIRING OUTPUT SIGNALS
--------------------------------------------------
LINE_DATA_1 <=s_line_data_1;
LINE_DATA_2 <=s_line_data_2;
LINE_DATA_3 <=s_line_data_3;
DATA_OUT_VALID<=line_valid_3(2);

FULL_1<=s_full_1;
FULL_2<=s_full_2;
EMPTY_1<=s_empty_1;
EMPTY_2<=s_empty_2;

--------------------------------------------------
-- COMPONENTS INSTANTIATION
--------------------------------------------------

-- Wiring signals as expected in 2D_FILTER architecture
fifo1 : fifo_generator_0 
            port map(clk => CLK,
                     rst => RST,
                     din => s_line_data_1(23 downto 16),
                     wr_en => line_valid_1(2),
                     rd_en => s_prog_full_1,
                     prog_full_thresh => PROG_FULL_THRESH,
                     dout=>data_out_fifo_1,
                     full=> s_full_1,
                     empty=> s_empty_1,
                     prog_full=> s_prog_full_1
                     );
                     
fifo2 : fifo_generator_0 
            port map(clk => CLK,
                     rst => RST,
                     din => s_line_data_2(23 downto 16),
                     wr_en => line_valid_2(2),
                     rd_en => s_prog_full_2,
                     prog_full_thresh => PROG_FULL_THRESH,
                     dout=>data_out_fifo_2,
                     full=> s_full_2,
                     empty=> s_empty_2,
                     prog_full=> s_prog_full_2
                     );
--

--------------------------------------------------
-- PROCESSING
-------------------------------------------------- 
    process(CLK,RST)
    begin
         if (RST='1') then -- Asynchronous reset
            -- Pixels value
            s_line_data_1<=(others => '0');
            s_line_data_2<=(others => '0');
            s_line_data_3<=(others => '0');
            -- Signal data valid delayed        
            line_valid_1<=(others => '0');
            line_valid_2<=(others => '0');
            line_valid_3<=(others => '0');
            --
         else
            if(rising_edge(CLK))then
               if((s_full_1='1' and s_empty_1='1') or (s_full_2='1' and s_empty_2='1')) then -- Data reset until FIFOs are available
                    -- Pixels value
                    s_line_data_1<=(others => '0');
                    s_line_data_2<=(others => '0');
                    s_line_data_3<=(others => '0');
                    -- Signal data valid delayed
                    line_valid_1<=(others => '0');
                    line_valid_2<=(others => '0');
                    line_valid_3<=(others => '0');
                    --
               else -- Implementation of shift registers that replace flip-flops
                    -- Pixels value
                    s_line_data_1<=s_line_data_1(15 downto 0) & DATA_IN;
                    s_line_data_2<=s_line_data_2(15 downto 0) & data_out_fifo_1;
                    s_line_data_3<=s_line_data_3(15 downto 0) & data_out_fifo_2;
                    -- Signal data valid delayed
                    line_valid_1<=line_valid_1(1 downto 0) & DATA_IN_VALID;
                    line_valid_2<=line_valid_2(1 downto 0) & s_prog_full_1;
                    line_valid_3<=line_valid_3(1 downto 0) & s_prog_full_2;
                    --  
                end if;           
            end if;
         end if;     
    end process;       
end Behavioral;
