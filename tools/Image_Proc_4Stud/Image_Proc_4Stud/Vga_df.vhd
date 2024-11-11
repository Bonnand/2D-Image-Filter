
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.math_real.all;

entity Vga_df is
    Port ( 	CLK_I : in  STD_LOGIC;
				pxl_clk_O : out STD_LOGIC;
				fifo_full_orig : IN STD_LOGIC;
				fifo_empty_orig : IN STD_LOGIC;
				fifo_prog_full_orig : IN STD_LOGIC;
				rd_en_fifo_orig : OUT STD_LOGIC;
				fifo_orig_out	: IN STD_LOGIC_VECTOR (8 downto 0);
				
				fifo_full_proc : IN STD_LOGIC;
				fifo_empty_proc : IN STD_LOGIC;
				fifo_prog_full_proc : IN STD_LOGIC;
				rd_en_fifo_proc : OUT STD_LOGIC;
				fifo_proc_out	: IN STD_LOGIC_VECTOR (8 downto 0);
				data_fifo_orig_ready : IN STD_LOGIC;
				data_fifo_proc_ready : IN STD_LOGIC;
           -- VGA Output Signals
           VGA_HS_O : out  STD_LOGIC; -- HSYNC OUT
           VGA_VS_O : out  STD_LOGIC; -- VSYNC OUT
           VGA_RED_O    : out  STD_LOGIC_VECTOR (3 downto 0); -- Red signal going to the VGA interface
           VGA_GREEN_O  : out  STD_LOGIC_VECTOR (3 downto 0); -- Green signal going to the VGA interface
           VGA_BLUE_O   : out  STD_LOGIC_VECTOR (3 downto 0) -- Blue signal going to the VGA interface
         
           );
end Vga_df;

architecture Vga_df_arch of Vga_df is

-------------------------------------------------------------------------

-- Component Declarations

-------------------------------------------------------------------------


   -- To generate the 108 MHz Pixel Clock
   -- needed for a resolution of 1280*1024 pixels
   COMPONENT PxlClkGen
   PORT
    (-- Clock in ports
     CLK_IN1           : in std_logic;
     -- Clock out ports
     CLK_OUT1          : out std_logic;
     -- Status and control signals
     LOCKED            : out std_logic
    );
   END COMPONENT;

   
   
component BackgroundVGA 
    Port ( CLK_I : in  STD_LOGIC;
           VSYNC_I : in  STD_LOGIC;
           ACTIVE_I : in  STD_LOGIC;
           BACKGROUND_O : out  STD_LOGIC
           );
end component;



  COMPONENT MyPicDisplay
   Generic (
			  H_BEGIN : integer range 2 to (Integer'high) := 40;
           V_BEGIN : integer := 512
	 );
	PORT(
		CLK_I : IN std_logic;
		H_COUNT_I : IN std_logic_vector(11 downto 0);
		V_COUNT_I : IN std_logic_vector(11 downto 0);          
		RED_O : OUT std_logic_vector(3 downto 0);
		BLUE_O : OUT std_logic_vector(3 downto 0);
		GREEN_O : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;
	
	


	COMPONENT MyPicDisplayRomBRAM is
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
	end COMPONENT;  

-------------------------------------------------------------

-- Constants for various VGA Resolutions

-------------------------------------------------------------


--***1280x1024@60Hz***--
constant FRAME_WIDTH : natural := 1280;
constant FRAME_HEIGHT : natural := 1024;

constant H_FP : natural := 48; --H front porch width (pixels)
constant H_PW : natural := 112; --H sync pulse width (pixels)
constant H_MAX : natural := 1688; --H total period (pixels)

constant V_FP : natural := 1; --V front porch width (lines)
constant V_PW : natural := 3; --V sync pulse width (lines)
constant V_MAX : natural := 1066; --V total period (lines)

constant H_POL : std_logic := '1';
constant V_POL : std_logic := '1';

-----------------------------------------------------------------------------

-- Constants for setting size and location for the Microphone signal display

-----------------------------------------------------------------------------
constant SZ_MIC_WIDTH  		: natural := 960; -- Width of the Microphone frame
constant SZ_MIC_HEIGHT 		: natural := 291; -- Height of the Microphone frame

constant FRM_MIC_H_LOC 		: natural := 240; -- Microphone frame starting horizontal location
constant FRM_MIC_V_LOC 		: natural := 64; -- Microphone frame starting vertical location
constant MIC_LEFT				: natural := FRM_MIC_H_LOC - 1;
constant MIC_RIGHT			: natural := FRM_MIC_H_LOC + SZ_MIC_WIDTH + 1;
constant MIC_TOP				: natural := FRM_MIC_V_LOC - 1;
constant MIC_BOTTOM			: natural := FRM_MIC_V_LOC + SZ_MIC_HEIGHT + 1;




constant SZ_MIC_WIDTH_OP  		: natural := 960; -- Width of the Microphone frame
constant SZ_MIC_HEIGHT_OP 		: natural := 291; -- Height of the Microphone frame

constant FRM_MIC_H_LOC_OP 		: natural := 240; -- Microphone frame starting horizontal location
constant FRM_MIC_V_LOC_OP 		: natural := 544; -- Microphone frame starting vertical location
constant MIC_LEFT_OP				: natural := FRM_MIC_H_LOC_OP - 1;
constant MIC_RIGHT_OP			: natural := FRM_MIC_H_LOC_OP + SZ_MIC_WIDTH_OP + 1;
constant MIC_TOP_OP				: natural := FRM_MIC_V_LOC_OP - 1;
constant MIC_BOTTOM_OP			: natural := FRM_MIC_V_LOC_OP + SZ_MIC_HEIGHT_OP + 1;

constant MYIMG_WIDTH 	   : natural := 128; -- Width of the lena frame
constant MYIMG_HEIGHT 	: natural := 128; -- Height of the lena frame

constant MYIMG_H_LOC 	: natural := 600; --  Starting horizontal location of the lena frame
constant MYIMG_V_LOC 	: natural := 150; -- Starting vertical location of the lena frame

constant MYIMG_LEFT 			: natural := MYIMG_H_LOC - 1;
constant MYIMG_RIGHT 		   : natural := MYIMG_H_LOC + MYIMG_WIDTH + 1;
constant MYIMG_TOP 			: natural := MYIMG_V_LOC - 1;
constant MYIMG_BOTTOM 		: natural := MYIMG_V_LOC + MYIMG_HEIGHT + 1;

constant MYIMGP_WIDTH 	   : natural := 128; -- Width of the lena frame
constant MYIMGP_HEIGHT 	: natural := 128; -- Height of the lena frame

constant MYIMGP_H_LOC 	: natural := 600; --  Starting horizontal location of the lena frame
constant MYIMGP_V_LOC 	: natural := 600; -- Starting vertical location of the lena frame

constant MYIMGP_LEFT 			: natural := MYIMGP_H_LOC - 1;
constant MYIMGP_RIGHT 		   : natural := MYIMGP_H_LOC + MYIMGP_WIDTH + 1;
constant MYIMGP_TOP 			: natural := MYIMGP_V_LOC - 1;
constant MYIMGP_BOTTOM 		: natural := MYIMGP_V_LOC + MYIMGP_HEIGHT + 1;

----------------------------------------------------
constant MYPIC_WIDTH 	   : natural := 100; -- Width of the logo frame
constant MYPIC_HEIGHT 	: natural := 100; -- Height of the logo frame

constant MYPIC_H_LOC 	: natural := 388; --  Starting horizontal location of the logo frame
constant MYPIC_V_LOC 	: natural := 888; -- Starting vertical location of the logo frame

constant MYPIC_LEFT 			: natural := MYPIC_H_LOC - 1;
constant MYPIC_RIGHT 		   : natural := MYPIC_H_LOC + MYPIC_WIDTH + 1;
constant MYPIC_TOP 			: natural := MYPIC_V_LOC - 1;
constant MYPIC_BOTTOM 		: natural := MYPIC_V_LOC + MYPIC_HEIGHT + 1;



constant IOSIFPIC_WIDTH 	   : natural := 100; -- Width of the logo frame
constant IOSIFPIC_HEIGHT 	: natural := 100; -- Height of the logo frame

constant IOSIFPIC_H_LOC 	: natural := 820; --  Starting horizontal location of the logo frame
constant IOSIFPIC_V_LOC 	: natural := 888; -- Starting vertical location of the logo frame

constant IOSIFPIC_LEFT 			: natural := IOSIFPIC_H_LOC - 1;
constant IOSIFPIC_RIGHT 		   : natural := IOSIFPIC_H_LOC + IOSIFPIC_WIDTH + 1;
constant IOSIFPIC_TOP 			: natural := IOSIFPIC_V_LOC - 1;
constant IOSIFPIC_BOTTOM 		: natural := IOSIFPIC_V_LOC + IOSIFPIC_HEIGHT + 1;
---------------------------------------

signal pxl_clk : std_logic;
signal active  : std_logic;
signal h_cntr_reg : std_logic_vector(11 downto 0) := (others =>'0');
signal v_cntr_reg : std_logic_vector(11 downto 0) := (others =>'0');
signal h_cntr_reg_dly   : std_logic_vector(11 downto 0) := (others => '0');
signal v_cntr_reg_dly   : std_logic_vector(11 downto 0) := (others => '0');
signal h_sync_reg : std_logic := not(H_POL);
signal v_sync_reg : std_logic := not(V_POL);
signal h_sync_reg_dly : std_logic := not(H_POL);
signal v_sync_reg_dly : std_logic :=  not(V_POL);
signal vga_red_cmb   : std_logic_vector(3 downto 0);
signal vga_green_cmb : std_logic_vector(3 downto 0);
signal vga_blue_cmb  : std_logic_vector(3 downto 0);
signal vga_red    : std_logic_vector(3 downto 0);
signal vga_green  : std_logic_vector(3 downto 0);
signal vga_blue   : std_logic_vector(3 downto 0);
signal vga_red_reg   : std_logic_vector(3 downto 0) := (others =>'0');
signal vga_green_reg : std_logic_vector(3 downto 0) := (others =>'0');
signal vga_blue_reg  : std_logic_vector(3 downto 0) := (others =>'0');



signal MIC_M_DATA_I_REG : STD_LOGIC;
signal MIC_M_DATA_I_REG_OP : STD_LOGIC;



signal mic_red 			: std_logic_vector(3 downto 0);
signal mic_blue 			: std_logic_vector(3 downto 0);
signal mic_green 			: std_logic_vector(3 downto 0);

signal mic_red_OP 			: std_logic_vector(3 downto 0);
signal mic_blue_OP 			: std_logic_vector(3 downto 0);
signal mic_green_OP 			: std_logic_vector(3 downto 0);



signal mypic_red   : std_logic_vector(3 downto 0);
signal mypic_blue 	: std_logic_vector(3 downto 0);
signal mypic_green : std_logic_vector(3 downto 0);

signal iosifpic_red   : std_logic_vector(3 downto 0);
signal iosifpic_blue 	: std_logic_vector(3 downto 0);
signal iosifpic_green : std_logic_vector(3 downto 0);


signal data_fifo_org_16level : std_logic_vector(3 downto 0);
signal data_fifo_proc_16level : std_logic_vector(3 downto 0);


-- Registered Microphone data display signals
signal mic_red_dly 			: std_logic_vector(3 downto 0);
signal mic_blue_dly 			: std_logic_vector(3 downto 0);
signal mic_green_dly 		: std_logic_vector(3 downto 0);

signal mic_red_dly_OP 			: std_logic_vector(3 downto 0);
signal mic_blue_dly_OP 			: std_logic_vector(3 downto 0);
signal mic_green_dly_OP 		: std_logic_vector(3 downto 0);

signal mypic_red_dly			: std_logic_vector(3 downto 0);
signal mypic_blue_dly 		: std_logic_vector(3 downto 0);
signal mypic_green_dly 		: std_logic_vector(3 downto 0);


signal iosifpic_red_dly			: std_logic_vector(3 downto 0);
signal iosifpic_blue_dly 		: std_logic_vector(3 downto 0);
signal iosifpic_green_dly 		: std_logic_vector(3 downto 0);

signal BG_O :std_logic;
signal BG_O_dly :std_logic;

signal data_fifo_orig_ready_reg1, data_fifo_orig_ready_reg2 : std_logic;
signal data_fifo_proc_ready_reg1, data_fifo_proc_ready_reg2 : std_logic;

begin
    	pxl_clk_O <= pxl_clk;
		
		Inst_BackgroundVGA: BackgroundVGA 
      PORT MAP
      (
		CLK_I       => pxl_clk,
		VSYNC_I     => v_sync_reg,
		ACTIVE_I    => active,
		BACKGROUND_O   => BG_O
      );
		 
  
   Inst_PxlClkGen: PxlClkGen
   port map
    (-- Clock in ports
     CLK_IN1   => CLK_I,
     -- Clock out ports
     CLK_OUT1  => pxl_clk,
     -- Status and control signals
     LOCKED   => open
    );

  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if (h_cntr_reg = (H_MAX - 1)) then
        h_cntr_reg <= (others =>'0');
      else
        h_cntr_reg <= h_cntr_reg + 1;
      end if;
    end if;
  end process;
  -- Vertical counter
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if ((h_cntr_reg = (H_MAX - 1)) and (v_cntr_reg = (V_MAX - 1))) then
        v_cntr_reg <= (others =>'0');
      elsif (h_cntr_reg = (H_MAX - 1)) then
        v_cntr_reg <= v_cntr_reg + 1;
      end if;
    end if;
  end process;
  -- Horizontal sync
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if (h_cntr_reg >= (H_FP + FRAME_WIDTH - 1)) and (h_cntr_reg < (H_FP + FRAME_WIDTH + H_PW - 1)) then
        h_sync_reg <= H_POL;
      else
        h_sync_reg <= not(H_POL);
      end if;
    end if;
  end process;
  -- Vertical sync
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if (v_cntr_reg >= (V_FP + FRAME_HEIGHT - 1)) and (v_cntr_reg < (V_FP + FRAME_HEIGHT + V_PW - 1)) then
        v_sync_reg <= V_POL;
      else
        v_sync_reg <= not(V_POL);
      end if;
    end if;
  end process;
  
  -- active signal
  active <= '1' when h_cntr_reg_dly < FRAME_WIDTH and v_cntr_reg_dly < FRAME_HEIGHT
            else '0';

--register_inputs: process (pxl_clk, v_sync_reg)
--  begin
--    if (rising_edge(pxl_clk)) then   
--      -- Incoming Microphone data rate is faster than VSYNC, therefore is registered on the pixel clock
--      MIC_M_DATA_I_REG <= MIC_M_DATA_I;
--		MIC_M_DATA_I_REG_OP <= MIC_M_DATA_I_OP;
--    end if;
--end process register_inputs;



--	Inst_MicDisplay: MicDisplay 
--	GENERIC MAP(
--		X_WIDTH 	         => SZ_MIC_WIDTH,
--      Y_HEIGHT 		   => SZ_MIC_HEIGHT,
--      X_START 			   => FRM_MIC_H_LOC,
--      Y_START 			   => FRM_MIC_V_LOC,
--      PXLCLK_FREQ_HZ    => 108000000,
--      H_MAX             => H_MAX,
--      SAMPLE_RATE_DIV   => 4096,
--      BG_COLOR 		   => x"000",
--      ACTIVE_COLOR	   => x"00F"
--	)
--	PORT MAP(
--		CLK_I             => pxl_clk,
--      SYSCLK            => CLK_I,
--		MIC_M_DATA_I      => MIC_M_DATA_I_REG,
--      MIC_M_CLK_RISING  => MIC_M_CLK_RISING,
--		H_COUNT_I         => h_cntr_reg,
--		V_COUNT_I         => v_cntr_reg,
--		RED_O             => mic_red,
--		GREEN_O           => mic_green,
--		BLUE_O            => mic_blue
--      );
--
-- 
-- --------------------------------------
--	Inst_MicDisplay_OP: MicDisplay 
--	GENERIC MAP(
--		X_WIDTH 	         => SZ_MIC_WIDTH_OP,
--      Y_HEIGHT 		   => SZ_MIC_HEIGHT_OP,
--      X_START 			   => FRM_MIC_H_LOC_OP,
--      Y_START 			   => FRM_MIC_V_LOC_OP,
--      PXLCLK_FREQ_HZ    => 108000000,
--      H_MAX             => H_MAX,
--      SAMPLE_RATE_DIV   => 4096,
--      BG_COLOR 		   => x"000",
--      ACTIVE_COLOR	   => x"F00"
--	)
--	PORT MAP(
--		CLK_I             => pxl_clk,
--      SYSCLK            => CLK_I,
--		MIC_M_DATA_I      => MIC_M_DATA_I_REG_OP,
--      MIC_M_CLK_RISING  => MIC_M_CLK_RISING_OP,
--		H_COUNT_I         => h_cntr_reg,
--		V_COUNT_I         => v_cntr_reg,
--		RED_O             => mic_red_OP,
--		GREEN_O           => mic_green_OP,
--		BLUE_O            => mic_blue_OP
--      );             
				  

	 	Inst_mp: MyPicDisplayRomBRAM 
	GENERIC MAP(
		H_BEGIN	=> MYPIC_H_LOC,
		V_BEGIN	=> MYPIC_V_LOC
	)
	PORT MAP(
		CLK_I => pxl_clk,
		H_COUNT_I => h_cntr_reg,
		V_COUNT_I => v_cntr_reg,
		RED_O    => mypic_red,
		BLUE_O   => mypic_blue,
		GREEN_O  => mypic_green
	);
 
--	 	Inst_mp: MyPicDisplay 
--	GENERIC MAP(
--		H_BEGIN	=> MYPIC_H_LOC,
--		V_BEGIN	=> MYPIC_V_LOC
--	)
--	PORT MAP(
--		CLK_I => pxl_clk,
--		H_COUNT_I => h_cntr_reg,
--		V_COUNT_I => v_cntr_reg,
--		RED_O    => mypic_red,
--		BLUE_O   => mypic_blue,
--		GREEN_O  => mypic_green
--	);

 
				  
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
   
	   mic_red_dly			<= mic_red;
		mic_green_dly		<= mic_green;
		mic_blue_dly		<= mic_blue;
		
		mic_red_dly_OP		<= mic_red_OP;
		mic_green_dly_OP		<= mic_green_OP;
		mic_blue_dly_OP		<= mic_blue_OP;
   
      mypic_red_dly		<= mypic_red;
		mypic_green_dly	   <= mypic_green;
		mypic_blue_dly		<= mypic_blue;

         
      iosifpic_red_dly		<= iosifpic_red;
		iosifpic_green_dly	   <= iosifpic_green;
		iosifpic_blue_dly		<= iosifpic_blue;
     
      h_cntr_reg_dly <= h_cntr_reg;
		v_cntr_reg_dly <= v_cntr_reg;
       BG_O_dly <= BG_O;
      
    end if;
  end process;


  rd_en_fifo_orig <= '1' when h_cntr_reg_dly > (MYIMG_LEFT - 1) and (h_cntr_reg_dly < MYIMG_RIGHT - 2)
										and v_cntr_reg_dly < MYIMG_BOTTOM and v_cntr_reg_dly > MYIMG_TOP and data_fifo_orig_ready_reg2 = '1'
						else '0';
  rd_en_fifo_proc <= '1' when h_cntr_reg_dly > (MYIMGP_LEFT - 1) and (h_cntr_reg_dly < MYIMGP_RIGHT - 2)
										and v_cntr_reg_dly < MYIMGP_BOTTOM and v_cntr_reg_dly > MYIMGP_TOP and data_fifo_proc_ready_reg2 = '1'
						else '0';
  vga_red <=   
               mic_red_dly when not (mic_red_dly = "000") and h_cntr_reg_dly > MIC_LEFT and h_cntr_reg_dly < MIC_RIGHT 
                            and v_cntr_reg_dly > MIC_TOP and v_cntr_reg_dly < MIC_BOTTOM  
               else
					mic_red_dly_OP when not (mic_red_dly = "000") and  h_cntr_reg_dly > MIC_LEFT_OP and h_cntr_reg_dly < MIC_RIGHT_OP 
                            and v_cntr_reg_dly > MIC_TOP_OP and v_cntr_reg_dly < MIC_BOTTOM_OP  
               else
					data_fifo_org_16level when h_cntr_reg_dly > MYIMG_LEFT and h_cntr_reg_dly < MYIMG_RIGHT 
										and v_cntr_reg_dly < MYIMG_BOTTOM and v_cntr_reg_dly > MYIMG_TOP 
										
					else
					data_fifo_proc_16level when h_cntr_reg_dly > MYIMGP_LEFT and h_cntr_reg_dly < MYIMGP_RIGHT 
										and v_cntr_reg_dly < MYIMGP_BOTTOM and v_cntr_reg_dly > MYIMGP_TOP 
					else
					mypic_red_dly when h_cntr_reg_dly > MYPIC_LEFT and h_cntr_reg_dly < MYPIC_RIGHT 
                             and v_cntr_reg_dly < MYPIC_BOTTOM and v_cntr_reg_dly > MYPIC_TOP               
               
--					
--					iosifpic_red_dly when h_cntr_reg_dly > IOSIFPIC_LEFT and h_cntr_reg_dly < IOSIFPIC_RIGHT 
--                             and v_cntr_reg_dly < IOSIFPIC_BOTTOM and v_cntr_reg_dly > IOSIFPIC_TOP               
--               else


					else
					"1111" when h_cntr_reg_dly > 963 and v_cntr_reg_dly > 847 and BG_O_dly = '1'
					else
					"0011" when v_cntr_reg_dly > 835 and   h_cntr_reg_dly > 0  and h_cntr_reg_dly < 230 and BG_O_dly = '1'
					else
					"1000" when  h_cntr_reg_dly > 230  and h_cntr_reg_dly < 1210 and v_cntr_reg_dly < 365  and BG_O_dly = '1' --top grid
					else
					"1000" when  h_cntr_reg_dly > 230 and  v_cntr_reg_dly > 530  and h_cntr_reg_dly < 1210 and v_cntr_reg_dly < 840  and BG_O_dly = '1' --top grid
				   else
					"1101" when  h_cntr_reg_dly < 148 and v_cntr_reg_dly < 836 and BG_O_dly = '1'
					else
					"1101" when  h_cntr_reg_dly > 420 and  v_cntr_reg_dly > 380  and h_cntr_reg_dly < 1024 and v_cntr_reg_dly < 512  and BG_O_dly = '1' --top grid
					else				
					"1111" when BG_O_dly = '1'
					else
					"0000";
                
-----------
-- Green
-----------

  vga_green <= 
               mic_green_dly when not (mic_green_dly = "000") and h_cntr_reg_dly > MIC_LEFT and h_cntr_reg_dly < MIC_RIGHT 
                              and v_cntr_reg_dly > MIC_TOP and v_cntr_reg_dly < MIC_BOTTOM
               else
					mic_green_dly_OP when not (mic_green_dly_OP = "000")and  h_cntr_reg_dly > MIC_LEFT_OP and h_cntr_reg_dly < MIC_RIGHT_OP 
                              and v_cntr_reg_dly > MIC_TOP_OP and v_cntr_reg_dly < MIC_BOTTOM_OP
               else
					data_fifo_org_16level  when h_cntr_reg_dly > MYIMG_LEFT and h_cntr_reg_dly < MYIMG_RIGHT 
										and v_cntr_reg_dly < MYIMG_BOTTOM and v_cntr_reg_dly > MYIMG_TOP 
										
					else
					data_fifo_proc_16level when h_cntr_reg_dly > MYIMGP_LEFT and h_cntr_reg_dly < MYIMGP_RIGHT 
										and v_cntr_reg_dly < MYIMGP_BOTTOM and v_cntr_reg_dly > MYIMGP_TOP
					else
					mypic_green_dly when h_cntr_reg_dly > MYPIC_LEFT and h_cntr_reg_dly < MYPIC_RIGHT 
                             and v_cntr_reg_dly < MYPIC_BOTTOM and v_cntr_reg_dly > MYPIC_TOP               
               else
--					iosifpic_green_dly when h_cntr_reg_dly > IOSIFPIC_LEFT and h_cntr_reg_dly < IOSIFPIC_RIGHT 
--                             and v_cntr_reg_dly < IOSIFPIC_BOTTOM and v_cntr_reg_dly > IOSIFPIC_TOP               
--               else

					
					"0110" when h_cntr_reg_dly > 963 and v_cntr_reg_dly > 847 and BG_O_dly = '1'
					else
					"1010" when v_cntr_reg_dly > 835 and   h_cntr_reg_dly > 0  and h_cntr_reg_dly < 230 and BG_O_dly = '1'
					else
					"1000" when  h_cntr_reg_dly > 230  and h_cntr_reg_dly < 1210 and v_cntr_reg_dly < 365  and BG_O_dly = '1' --top grid
				   else
					"1000" when  h_cntr_reg_dly > 230 and  v_cntr_reg_dly > 530  and h_cntr_reg_dly < 1210 and v_cntr_reg_dly < 840  and BG_O_dly = '1' --top grid
					else
					"1101" when  h_cntr_reg_dly < 148 and v_cntr_reg_dly < 836 and BG_O_dly = '1'
					else
					"1111" when  h_cntr_reg_dly > 420 and  v_cntr_reg_dly > 380  and h_cntr_reg_dly < 1024 and v_cntr_reg_dly < 512  and BG_O_dly = '1' --top grid

					else 					
					"1111" when BG_O_dly = '1'
					else
					"0000";
-----------
-- Blue
-----------

  vga_blue <= 	mic_blue_dly when not (mic_blue_dly = "000") and h_cntr_reg_dly > MIC_LEFT and h_cntr_reg_dly < MIC_RIGHT 
                             and v_cntr_reg_dly > MIC_TOP and v_cntr_reg_dly < MIC_BOTTOM
               else
					mic_blue_dly_OP when not (mic_blue_dly_OP = "000") and  h_cntr_reg_dly > MIC_LEFT_OP and h_cntr_reg_dly < MIC_RIGHT_OP 
                             and v_cntr_reg_dly > MIC_TOP_OP and v_cntr_reg_dly < MIC_BOTTOM_OP
               else
					data_fifo_org_16level when h_cntr_reg_dly > MYIMG_LEFT and h_cntr_reg_dly < MYIMG_RIGHT 
										and v_cntr_reg_dly < MYIMG_BOTTOM and v_cntr_reg_dly > MYIMG_TOP

					else
					data_fifo_proc_16level when h_cntr_reg_dly > MYIMGP_LEFT and h_cntr_reg_dly < MYIMGP_RIGHT 
										and v_cntr_reg_dly < MYIMGP_BOTTOM and v_cntr_reg_dly > MYIMGP_TOP										
					else
					mypic_blue_dly when h_cntr_reg_dly > MYPIC_LEFT and h_cntr_reg_dly < MYPIC_RIGHT 
                             and v_cntr_reg_dly < MYPIC_BOTTOM and v_cntr_reg_dly > MYPIC_TOP               
               else
--					iosifpic_blue_dly when h_cntr_reg_dly > IOSIFPIC_LEFT and h_cntr_reg_dly < IOSIFPIC_RIGHT 
--                             and v_cntr_reg_dly < IOSIFPIC_BOTTOM and v_cntr_reg_dly > IOSIFPIC_TOP               
--               else


					"0001" when h_cntr_reg_dly > 963 and v_cntr_reg_dly > 847 and BG_O_dly = '1'
					else
					"1110" when  h_cntr_reg_dly > 0  and h_cntr_reg_dly < 230 and v_cntr_reg_dly > 835  and BG_O_dly = '1' --MSCV LOGO
					else
					"1000" when  h_cntr_reg_dly > 230  and h_cntr_reg_dly < 1210 and v_cntr_reg_dly < 365  and BG_O_dly = '1' --top grid
					else
					"1000" when  h_cntr_reg_dly > 230 and  v_cntr_reg_dly > 530  and h_cntr_reg_dly < 1210 and v_cntr_reg_dly < 840  and BG_O_dly = '1' --top grid
					else
					"1001" when  h_cntr_reg_dly < 148 and v_cntr_reg_dly < 836 and BG_O_dly = '1'
				   else
					"0110" when  h_cntr_reg_dly > 420 and  v_cntr_reg_dly > 380  and h_cntr_reg_dly < 1024 and v_cntr_reg_dly < 512  and BG_O_dly = '1' --top grid

					else 
										
					"1111" when BG_O_dly = '1'
					else
					"0000";
                

------------------------------------------------------------
-- Turn Off VGA RBG Signals if outside of the active screen
-- Make a 4-bit AND logic with the R, G and B signals
------------------------------------------------------------
 vga_red_cmb <= (active & active & active & active) and vga_red;
 vga_green_cmb <= (active & active & active & active) and vga_green;
 vga_blue_cmb <= (active & active & active & active) and vga_blue;
 

 -- Register Outputs
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then

      v_sync_reg_dly <= v_sync_reg;
      h_sync_reg_dly <= h_sync_reg;
      vga_red_reg    <= vga_red_cmb;
      vga_green_reg  <= vga_green_cmb;
      vga_blue_reg   <= vga_blue_cmb;      
    end if;
  end process;

  -- Assign outputs
  VGA_HS_O     <= h_sync_reg_dly;
  VGA_VS_O     <= v_sync_reg_dly;
  VGA_RED_O    <= vga_red_reg;
  VGA_GREEN_O  <= vga_green_reg;
  VGA_BLUE_O   <= vga_blue_reg;
  
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
    data_fifo_orig_ready_reg1 <= data_fifo_orig_ready;
    data_fifo_orig_ready_reg2 <= data_fifo_orig_ready_reg1;
    data_fifo_proc_ready_reg1 <= data_fifo_proc_ready;
    data_fifo_proc_ready_reg2 <= data_fifo_proc_ready_reg1;
    
		if ((fifo_orig_out >= 0) and (fifo_orig_out <=15)) then data_fifo_org_16level <= "0000";
		elsif ((fifo_orig_out >= 16) and (fifo_orig_out <=31)) then data_fifo_org_16level <= "0001";
		elsif ((fifo_orig_out >= 32) and (fifo_orig_out <=47)) then data_fifo_org_16level <= "0010"; 
		elsif ((fifo_orig_out >= 48) and (fifo_orig_out <=63)) then data_fifo_org_16level <= "0011";   
		elsif ((fifo_orig_out >= 64) and (fifo_orig_out <=79)) then data_fifo_org_16level <= "0100";                       
		elsif ((fifo_orig_out >= 80) and (fifo_orig_out <=95)) then data_fifo_org_16level <= "0101"; 
		elsif ((fifo_orig_out >= 96) and (fifo_orig_out <=111)) then data_fifo_org_16level <= "0110"; 
		elsif ((fifo_orig_out >= 112) and (fifo_orig_out <=127)) then data_fifo_org_16level <= "0111";
		elsif ((fifo_orig_out >= 128) and (fifo_orig_out <=143)) then data_fifo_org_16level <= "1000";
		elsif ((fifo_orig_out >= 144) and (fifo_orig_out <=159)) then data_fifo_org_16level <= "1001";
		elsif ((fifo_orig_out >= 160) and (fifo_orig_out <=175)) then data_fifo_org_16level <= "1010";
		elsif ((fifo_orig_out >= 176) and (fifo_orig_out <=191)) then data_fifo_org_16level <= "1011";
		elsif ((fifo_orig_out >= 192) and (fifo_orig_out <=207)) then data_fifo_org_16level <= "1100";
		elsif ((fifo_orig_out >= 208) and (fifo_orig_out <=223)) then data_fifo_org_16level <= "1101";
		elsif ((fifo_orig_out >= 224) and (fifo_orig_out <=239)) then data_fifo_org_16level <= "1110";
		else data_fifo_org_16level <= "1110";
		end if;
		if ((fifo_proc_out >= 0) and (fifo_proc_out <=15)) then data_fifo_proc_16level <= "0000";
		elsif ((fifo_proc_out >= 16) and (fifo_proc_out <=31)) then data_fifo_proc_16level <= "0001";
		elsif ((fifo_proc_out >= 32) and (fifo_proc_out <=47)) then data_fifo_proc_16level <= "0010"; 
		elsif ((fifo_proc_out >= 48) and (fifo_proc_out <=63)) then data_fifo_proc_16level <= "0011";   
		elsif ((fifo_proc_out >= 64) and (fifo_proc_out <=79)) then data_fifo_proc_16level <= "0100";                       
		elsif ((fifo_proc_out >= 80) and (fifo_proc_out <=95)) then data_fifo_proc_16level <= "0101"; 
		elsif ((fifo_proc_out >= 96) and (fifo_proc_out <=111)) then data_fifo_proc_16level <= "0110"; 
		elsif ((fifo_proc_out >= 112) and (fifo_proc_out <=127)) then data_fifo_proc_16level <= "0111";
		elsif ((fifo_proc_out >= 128) and (fifo_proc_out <=143)) then data_fifo_proc_16level <= "1000";
		elsif ((fifo_proc_out >= 144) and (fifo_proc_out <=159)) then data_fifo_proc_16level <= "1001";
		elsif ((fifo_proc_out >= 160) and (fifo_proc_out <=175)) then data_fifo_proc_16level <= "1010";
		elsif ((fifo_proc_out >= 176) and (fifo_proc_out <=191)) then data_fifo_proc_16level <= "1011";
		elsif ((fifo_proc_out >= 192) and (fifo_proc_out <=207)) then data_fifo_proc_16level <= "1100";
		elsif ((fifo_proc_out >= 208) and (fifo_proc_out <=223)) then data_fifo_proc_16level <= "1101";
		elsif ((fifo_proc_out >= 224) and (fifo_proc_out <=239)) then data_fifo_proc_16level <= "1110";
		else data_fifo_proc_16level <= "1110";
		end if;
  end if;
  end process;
  

end Vga_df_arch;
