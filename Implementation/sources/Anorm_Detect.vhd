library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Anorm_Detect is
    port (
        aclk : IN STD_LOGIC;
        s_axis_val_tvalid : IN STD_LOGIC;
        s_axis_val_tready : OUT STD_LOGIC;
        s_axis_val_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        brady: out std_logic; -- Bradycardia
        tachy: out std_logic; -- Tachycardia
        dng: out std_logic; -- Dangerous heart function
        dead: out std_logic -- 0 BPM
    );
end Anorm_Detect;

architecture rtl of Anorm_Detect is

    constant brady_c : std_logic_vector(31 downto 0) := x"0000003C";
    constant tachy_c : std_logic_vector(31 downto 0) := x"00000064";
    constant dng_low_c : std_logic_vector(31 downto 0) := x"0000001E";
    constant dng_high_c : std_logic_vector(31 downto 0) := x"000000C8";

    type state_type is (S_READ, S_WRITE);
    signal state : state_type := S_READ;

    signal res_valid : STD_LOGIC := '0';
    signal sum : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

    signal val_ready : STD_LOGIC := '0';
    signal internal_ready, external_ready, inputs_valid : STD_LOGIC := '0';

begin


    s_axis_val_tready <= external_ready;

    internal_ready <= '1' when state = S_READ else '0';
    inputs_valid <= s_axis_val_tvalid;
    external_ready <= internal_ready and inputs_valid;

    PROC : process(aclk)
    begin
        if rising_edge(aclk) then
            case state is
            
                when S_READ =>
                    if external_ready = '1' and inputs_valid = '1' then
                        brady <= '0';
                        tachy <= '0';
                        dng <= '0';
                        dead <= '0';
                        
                        if  s_axis_val_tdata > dng_high_c then                           
                            dng <=  '1'; 
                        elsif s_axis_val_tdata > tachy_c then                           
                            tachy <=  '1';
                        elsif s_axis_val_tdata = x"00000000" then
                            dead <= '1';
                        elsif s_axis_val_tdata < dng_low_c then
                            dng <= '1';   
                        elsif s_axis_val_tdata < brady_c then
                            brady <=  '1';                     
                        end if;
                        
                    end if;
                    
                when S_WRITE => 
                        state <= S_READ;

                when others =>
                    state <= S_READ;
            end case;
        end if;
        
    end process;

end architecture;