----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.09.2024 13:43:06
-- Design Name: 
-- Module Name: top_filter2D - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

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
entity top_filter2D_Laplacian is
    Port (  CLK : IN STD_LOGIC; -- Clock input
            RST : IN STD_LOGIC; -- Reset input
            DATA_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Input of pixels into 2D Filter
            DATA_IN_VALID : IN STD_LOGIC; -- Signal indicating that the incoming pixels are valid
            PROG_FULL_THRESH : IN STD_LOGIC_VECTOR(9 DOWNTO 0); -- Threshold value of the two FIFOs, which allows the FIFO to be unstacked when this value is exceeded
            DATA_OUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Filtered pixels outgoing
            DATA_OUT_VALID : OUT STD_LOGIC -- Signal indicating that the outgoing pixels are valid
           );
end top_filter2D_Laplacian;

architecture Behavioral of top_filter2D_Laplacian is

--------------------------------------------------
-- COMPONENTS DECLARATION
--------------------------------------------------
component delayed_line is
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
end component delayed_line;

--------------------------------------------------
-- SIGNALS DECLARATION
--------------------------------------------------
TYPE state IS (INIT, IDLE, WAIT_FIRST_PIXEL, AVERAGE_START,AVERAGE_PROCESSING,AVERAGE_STOP );
SIGNAL FSM: state ;

signal s_line_data_1 : STD_LOGIC_VECTOR(23 DOWNTO 0) := (others => '0'); -- Data which contains pixels value
signal s_line_data_2 : STD_LOGIC_VECTOR(23 DOWNTO 0) := (others => '0'); -- Data which contains pixels value
signal s_line_data_3 : STD_LOGIC_VECTOR(23 DOWNTO 0) := (others => '0'); -- Data which contains pixels value
signal data_valid_out_rl : STD_LOGIC := '0'; -- Signal indicating that outgoing pixels of the delayed line are valid 
signal data_valid_out_rl_r : STD_LOGIC := '0'; -- Signal indicating that outgoing pixels of the delayed line are valid (one period late)
signal s_full_1 : STD_LOGIC := '0'; -- This signal equals one when the first FIFO is full
signal s_full_2 : STD_LOGIC := '0'; -- This signal equals one when the second FIFO is full
signal s_prog_full : STD_LOGIC := '0'; -- This signal equals one when the number of input data exceeds threshold value
signal data_out_rl : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0'); -- Filtered pixels comming out of the delayed line
signal counter : STD_LOGIC_VECTOR(2 DOWNTO 0) := (others => '0'); -- counter of clock period
signal reset_counter : STD_LOGIC := '1'; -- permit to reset the counter of clock period
signal valid_output : STD_LOGIC := '0'; -- Signal indicating that the outgoing pixels are valid
signal result_add_1_1 : signed(13 DOWNTO 0) := (others => '0'); -- Result of pixels addition 
signal result_add_1_2 : signed(13 DOWNTO 0) := (others => '0'); -- Result of pixels addition 
signal result_add_1_3 : signed(13 DOWNTO 0) := (others => '0'); -- Result of pixels addition 
signal result_add_1_4 : signed(13 DOWNTO 0) := (others => '0'); -- Result of pixels addition 
signal result_add_2_1 : signed(14 DOWNTO 0) := (others => '0'); -- Result of pixels addition 
signal result_add_2_2 : signed(14 DOWNTO 0) := (others => '0'); -- Result of pixels addition 
signal result_add_3 : signed(15 DOWNTO 0) := (others => '0'); -- Result of pixels addition 
signal result_mult_1 : signed(12 DOWNTO 0) := (others => '0'); -- Result of pixels multiplication
signal result_mult_2 : signed(12 DOWNTO 0) := (others => '0'); -- Result of pixels multiplication
signal result_mult_3 : signed(12 DOWNTO 0) := (others => '0'); -- Result of pixels multiplication
signal result_mult_4 : signed(12 DOWNTO 0) := (others => '0'); -- Result of pixels multiplication
signal result_mult_5 : signed(12 DOWNTO 0) := (others => '0'); -- Result of pixels multiplication
signal result_mult_6 : signed(12 DOWNTO 0) := (others => '0'); -- Result of pixels multiplication
signal result_mult_7 : signed(12 DOWNTO 0) := (others => '0'); -- Result of pixels multiplication
signal result_mult_8 : signed(12 DOWNTO 0) := (others => '0'); -- Result of pixels multiplication
signal result_mult_9 : signed(12 DOWNTO 0) := (others => '0'); -- Result of pixels multiplication
signal coef_1 : signed(3 DOWNTO 0) := "0000";  -- 0
signal coef_2 : signed(3 DOWNTO 0) := "0001";  -- 1
signal coef_3 : signed(3 DOWNTO 0) := "0000";  -- 0
signal coef_4 : signed(3 DOWNTO 0) := "0001";  -- 1
signal coef_5 : signed(3 DOWNTO 0) := "1100";  -- -4
signal coef_6 : signed(3 DOWNTO 0) := "0001";  -- 1
signal coef_7 : signed(3 DOWNTO 0) := "0000";  -- 0
signal coef_8 : signed(3 DOWNTO 0) := "0001";  -- 1
signal coef_9 : signed(3 DOWNTO 0) := "0000";  -- 0

begin

--------------------------------------------------
-- WIRING OUTPUT SIGNALS
--------------------------------------------------
DATA_OUT_VALID<=valid_output;
    
--------------------------------------------------
-- COMPONENTS INSTANTIATION
--------------------------------------------------
inst_delayed_line : delayed_line 
       port map(CLK => CLK,
                RST => RST,
                DATA_IN => DATA_IN,
                DATA_IN_VALID => DATA_IN_VALID,
                PROG_FULL_THRESH => PROG_FULL_THRESH,
                FULL_1=>s_full_1,
                FULL_2=>s_full_2,
                EMPTY_1=>open,
                EMPTY_2=>open,
                DATA_OUT_VALID=>data_valid_out_rl,
                LINE_DATA_1=>s_line_data_1,
                LINE_DATA_2=>s_line_data_2,   
                LINE_DATA_3=>s_line_data_3      
             );

-- Implementation of a clock period counter
Counter_process : process(CLK,RST)
    begin
         if (RST='1') then 
            counter<="000";
         else
            if(rising_edge(CLK))then
                if(reset_counter='1') then
                    counter<="000"; -- Counter reset
                else
                    counter<=STD_LOGIC_VECTOR(unsigned(counter) + to_unsigned(1,3)); -- Counter incrementation
                end if;         
            end if;
            
         end if;
    end process;       

--------------------------------------------------
-- PROCESSING
-------------------------------------------------- 
 delayed_line_control_processing : process(CLK,RST)
    begin
         if (RST='1') then 
            FSM <= INIT; 
         else
            if(rising_edge(CLK))then
                   data_valid_out_rl_r<=data_valid_out_rl; -- Permit to create data_valid_out_rl signal delayed of one clock period
            
                   case FSM is
                        
                        when INIT =>
                            -- Waiting FIFOs are available 
                            if (s_full_1 = '0' and s_full_2 = '0')then 
                                FSM <= IDLE;
                            end if;
                            --    
                            
                        when IDLE =>
                            -- Waiting data incoming
                            if(DATA_IN_VALID='1') then 
                                FSM <= AVERAGE_START;
                            end if;
                            --
                        
                        when AVERAGE_START =>
                            --rising edge of data_valid_out_rl note that picture reading begin
                            if (data_valid_out_rl='1' and data_valid_out_rl_r='0') then 
                                reset_counter<='0'; -- Counter started
                                FSM <= AVERAGE_PROCESSING;
                            end if;
                            --
                
                        when AVERAGE_PROCESSING =>
                            -- Waiting first addition finishes before set valid_output at higl level
                            if(counter="100")then
                                reset_counter<='1'; -- Counter stoped
                                valid_output<='1';
                            end if; 
                            -- Falling edge of DATA_IN_VALID note that picture reading is finished
                            if (DATA_IN_VALID='0')then 
                                reset_counter<='0'; -- Counter started
                                FSM <= AVERAGE_STOP;       
                            end if;
                            --
                                    
                        when AVERAGE_STOP =>
                            -- Waiting last addition finishes before set valid_output at low level
                            if(counter="011")then
                                 reset_counter<='1'; -- Counter stoped
                                 valid_output<='0'; 
                                 FSM <= INIT;  
                            end if;
                            
                        when OTHERS => 
                    end case;
            end if;
         end if;   
    end process; 

image_processing : process (CLK)
begin
    if(rising_edge(CLK))then       
        if ( (FSM=AVERAGE_PROCESSING) or (FSM=AVERAGE_STOP) )then
        
            -- The pixels are multiplied by the coefficients of the filter matrix
            result_mult_1<=signed('0' & s_line_data_1(7 downto 0))* coef_9; 
            result_mult_2<=signed('0' & s_line_data_1(15 downto 8))* coef_8;
            result_mult_3<=signed('0' & s_line_data_1(23 downto 16))* coef_7;
            result_mult_4<=signed('0' & s_line_data_2(7 downto 0))* coef_6;
            result_mult_5<=signed('0' & s_line_data_2(15 downto 8))* coef_5;
            result_mult_6<=signed('0' & s_line_data_2(23 downto 16))* coef_4;
            result_mult_7<=signed('0' & s_line_data_3(7 downto 0))* coef_3;
            result_mult_8<=signed('0' & s_line_data_3(15 downto 8))* coef_2;
            result_mult_9<=signed('0' & s_line_data_3(23 downto 16))* coef_1;
            
            -- The pixels are added each others
            result_add_1_1<= (result_mult_1(10) & result_mult_1) + (result_mult_2(10) & result_mult_2); 
            result_add_1_2<= (result_mult_3(10) & result_mult_3) + (result_mult_4(10) & result_mult_4);
            result_add_1_3<= (result_mult_5(10) & result_mult_5) + (result_mult_6(10) & result_mult_6);
            result_add_1_4<= (result_mult_7(10) & result_mult_7) + (result_mult_8(10) & result_mult_8) 
                                + (result_mult_9(10) & result_mult_9);
                                    
            result_add_2_1<=(result_add_1_1(11) & result_add_1_1) + (result_add_1_2(11) & result_add_1_2);
            result_add_2_2<= (result_add_1_3(11) & result_add_1_3) + (result_add_1_4(11) & result_add_1_4);
                                    
            result_add_3<= (result_add_2_1(12) & result_add_2_1) + (result_add_2_2(12) & result_add_2_2);
            --
        end if;
    end if;  
end process;

output_processing : process (result_add_3,valid_output)
begin
    if(valid_output='1') then
        DATA_OUT<=STD_LOGIC_VECTOR(abs(result_add_3(9 downto 2))); -- Absolute value of pixels and division by the normalisation factor
     else 
        DATA_OUT<=(others => '0');
     end if;
 end process;
end Behavioral;


