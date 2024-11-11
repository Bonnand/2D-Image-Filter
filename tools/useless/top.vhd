----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.12.2020 14:06:03
-- Design Name: 
-- Module Name: top - top_arch
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

entity top is
    Port ( CLK : in STD_LOGIC;
           RESET : in STD_LOGIC;
           D1 : in  STD_LOGIC_VECTOR (7 downto 0);
           Q1 : out  STD_LOGIC_VECTOR (7 downto 0);
           en1 : in  STD_LOGIC
           );
end top;

architecture top_arch of top is

component FlipFlop 
   Port ( D : in  STD_LOGIC_VECTOR (7 downto 0);
           Q : out  STD_LOGIC_VECTOR (7 downto 0);
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           en : in  STD_LOGIC
			  );
end component;

signal temp :STD_LOGIC_VECTOR (7 downto 0);

begin

c1: FlipFlop port map(D => D1, Q => temp, clk => CLK, reset => RESET, en => en1);
c2: FlipFlop port map(D => temp, Q => Q1, clk => CLK, reset => RESET, en => en1);

end top_arch;
