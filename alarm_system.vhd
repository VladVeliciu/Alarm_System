----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Veliciu Vlad, Pop Emanuel
-- Coordinator: Farago Paul
-- 
-- Create Date: 05/02/2022 12:09:53 PM
-- Design Name: 
-- Module Name: alarm_system - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alarm_system is
    Port ( clk : in STD_LOGIC;
           sw : in std_logic;
           rst: in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (3 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0));
end alarm_system;

architecture Behavioral of alarm_system is

type states is (armed,led_flash,read_next,read_next1,read_next2,disarmed,arm_alarm,
arm_alarm1,arm_alarm2,arm_alarm3);

signal current_state,next_state:states;
shared variable count : integer := 0;
signal flag:std_logic;
signal en_count:std_logic;
signal en_armed:std_logic;

--component read_code is
--    Port ( clk : in STD_LOGIC; --100MHz board clock input
--           btn:in std_logic_vector (3 downto 0);
--           flag:out std_logic;
--           rst : in STD_LOGIC); --global reset
--end component read_code;

component DeBouncer is
    port(   Clock : in std_logic;
            Reset : in std_logic;
            button_in : in std_logic;
            pulse_out : out std_logic
        );
end component DeBouncer;

signal btn_db : std_logic_vector (3 downto 0);
signal btnL,btnR,btnU,btnD:std_logic;

signal cy : std_logic;
signal cnt : integer;

begin

db3 : DeBouncer port map (Clock => clk,
                          Reset => rst,
                          button_in => btn(3),
                          pulse_out => btn_db (3));

db2 : DeBouncer port map (Clock => clk,
                          Reset => rst,
                          button_in => btn(2),
                          pulse_out => btn_db (2));

db1 : DeBouncer port map (Clock => clk,
                          Reset => rst,
                          button_in => btn(1),
                          pulse_out => btn_db (1));

db0 :DeBouncer port map (Clock => clk,
                          Reset => rst,
                          button_in => btn(0),
                          pulse_out => btn_db (0));    
--u: read_code port map(clk=>clk;
--                      btn
btnL<=btn_db(0);
btnR<=btn_db(1);
btnU<=btn_db(2);
btnD<=btn_db(3);
   
--process (clk,sw)

--variable q : integer := 0;
----variable flag1:integer:=0;

--begin
--    if count=15 then
--        q := 0;
--        led<="1111111111111111";
--    elsif sw='0' then
--        led<="1000000000000000";
----    elsif en_count='0' then
----            led<="0000000000000001";
--   elsif rising_edge(clk) and en_count='1' then
--    if count=0 then
--        flag<='0';
--        led<="1111111111111111";
--      end if;
--     if current_state/=disarmed then
--      if q = 10**8 - 1 then
--        q := 1;
--        count:=count+1;
--      else
--        q := q + 1;
--        end if;
--        if q=(10**8-1)/2 and flag='0' then
--        led<="0000000000000000";
--        flag<='1';
--       elsif q=(10**8-1)/2 and flag='1' then
--        led<="1111111111111111";
--        flag<='0';
--      end if;
--     end if; 
--     end if;   
   
  
--  end process;
  
ff:process(rst,clk)

begin
    if rst='1' and sw='0' then
        current_state<=armed;
        --en_armed<='1';
        elsif rising_edge(clk) then
            current_state<=next_state;
    end if;
    
end process;  
  
  
process (sw,btn)
begin
    case current_state is
    when armed=> if sw='1' then
              
                        next_state <= led_flash;
                    else
                    next_state<=armed;
                    end if;
     when led_flash=>   en_count<='1';
                        if btnL='1' then
                            next_state<=read_next;
                        else
                        next_state<=led_flash;
                       -- end if;
                        end if;
    when read_next=> --if inc1sec='1' then
                         en_count<='1';
                         if btnR='1' then
                        next_state<=read_next1;
                        else
                        next_state<=read_next;
                      --  end if;
                        end if;
    when read_next1=>-- if inc1sec='1' then
                        en_count<='1';
                        if btnU='1' then
                        next_state<=read_next2;
                        else
                        next_state<=read_next1;
                        end if;
                      --  end if;
    when read_next2=> --if inc1sec='1' then
                        en_count<='1';
                        if btnD='1' then
                            next_state<=disarmed;
                            
                        else
                        next_state<=read_next2;
                        end if;
                       -- end if;
   when disarmed=>   en_count<='0';
                    if sw='0' then
                    --en_armed<='0';
                    next_state<=arm_alarm;
                    else
                    next_state<=disarmed;
                    end if;
   when arm_alarm=> if btnL='1' then
                        next_state<=arm_alarm1;
                        else
                        next_state<=arm_alarm;
                        end if;
  when arm_alarm1=>if btnR='1' then
                        next_state<=arm_alarm2;
                        else
                        next_state<=arm_alarm1;
                        end if;
  when arm_alarm2=> if btnU='1' then
                        next_state<=arm_alarm3;
                        else
                        next_state<=arm_alarm2;
                        end if;
  when arm_alarm3=>if btnD='1' then
                        next_state<=armed;
                        --en_armed<='1';
--                        led<="0000000000000001";
                        else
                        next_state<=arm_alarm3;
                        end if;
   end case;
    
end process;

process (clk, rst)
variable q : integer := 0;
begin
  if rst = '1' then
    q := 0;
    cnt <= 0;
  elsif rising_edge(clk) then
    if en_count = '1' then
      if cnt < 15 then 
        if q = 10 ** 8 - 1 then
          q := 0;
          cy <= '1';
          cnt <= cnt + 1;
        else
          q := q+ 1;
          cy <= '0';
          cnt <= cnt;
        end if;  
      end if;
    end if;
  end if;        
end process;

led <= x"0000" when (en_count = '1') and (cnt = 0 or cnt = 2 or cnt = 4 or cnt = 6 or cnt = 8 or cnt = 10 or cnt = 12 or cnt = 14)
   else x"FFFF" when (en_count = '1') and (cnt = 1 or cnt = 3 or cnt = 5 or cnt = 7 or cnt = 9 or cnt = 11 or cnt = 13 or cnt = 15)
   else x"8000" when (current_state = armed)
   else x"0001" when (current_state = disarmed)
   else x"4000" when (current_state = arm_alarm);

end Behavioral;
