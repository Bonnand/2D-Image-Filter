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

entity fifo is
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
end fifo;

architecture Behavioral of fifo is

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


begin

u2: fifo_generator_0 
            port map(clk => clk,
                     rst => rst,
                     din => din,
                     wr_en => wr_en,
                     rd_en => rd_en,
                     prog_full_thresh => prog_full_thresh,
                     dout=>dout,
                     full=> full,
                     empty=> empty,
                     prog_full=> prog_full
                     );
end Behavioral;
