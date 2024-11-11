
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity MyPicDisplayRomBRAM is
	 Generic (
		 H_BEGIN : integer range 2 to (Integer'high) := 40;
           V_BEGIN : integer := 512
	 );
    Port ( CLK_I : in  STD_LOGIC;
           H_COUNT_I : in  STD_LOGIC_VECTOR(11 downto 0);
           V_COUNT_I : in  STD_LOGIC_VECTOR(11 downto 0);
           RED_O : out  STD_LOGIC_VECTOR(3 downto 0);
           BLUE_O : out  STD_LOGIC_VECTOR(3 downto 0);
           GREEN_O : out  STD_LOGIC_VECTOR(3 downto 0));
end MyPicDisplayRomBRAM;


architecture MyPicDisplayRomBRAM_arch of MyPicDisplayRomBRAM is

COMPONENT imgROM_pixRGB_12b
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
END COMPONENT;

constant PIC_WIDTH 	   : natural := 100;
constant PIC_HEIGHT 	: natural := 100; 


signal addr_reg : std_logic_vector(13 downto 0) := (others => '0');
signal douta	: std_logic_vector(11 downto 0);
signal rst		: std_logic;
signal en,ena		: std_logic;


begin

logo_annee : imgROM_pixRGB_12b
  PORT MAP (
    clka => CLK_I,
    ena => ena,
    addra => addr_reg,
    douta => douta
  );

rst <= '1' when (H_COUNT_I = 0 and V_COUNT_I = V_BEGIN-1) else '0';
en <= '1' when (H_COUNT_I > H_BEGIN-3 and H_COUNT_I < H_BEGIN + PIC_WIDTH - 2 
            and V_COUNT_I > V_BEGIN and V_COUNT_I < V_BEGIN + PIC_HEIGHT -1 ) 
          else '0';
		  
process (CLK_I, rst)
begin
	if(rising_edge(CLK_I))then 
		ena <= en;
		if(rst = '1') then
			addr_reg <= (others => '0');
		--			ctr <=0;
		elsif(en = '1') then
			addr_reg <= addr_reg + 1;
		--	ctr <= ctr +1;
		end if;
		RED_O <= douta(11 downto 8);
		BLUE_O <= douta(7 downto 4);
		GREEN_O <= douta(3 downto 0);
	end if;	

end process;

end MyPicDisplayRomBRAM_arch;

