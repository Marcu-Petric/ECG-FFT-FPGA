library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BPM is
    port (
        aclk : IN STD_LOGIC;
        s_axis_val_tvalid : IN STD_LOGIC;
        s_axis_val_tready : OUT STD_LOGIC;
        s_axis_val_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        bpm: out std_logic_vector(15 downto 0)
    );
end BPM;

architecture rtl of BPM is

    type state_type is (S_READ, S_WRITE);
    signal state : state_type := S_READ;

    signal res_valid : STD_LOGIC := '0';

    signal val_ready : STD_LOGIC := '0';
    signal internal_ready, external_ready, inputs_valid : STD_LOGIC := '0';

    signal s_bpm : integer := 0;
    constant form_num : std_logic_vector := x"0000EA60"; -- 60.000

begin

    s_axis_val_tready <= external_ready;

    internal_ready <= '1' when state = S_READ else '0';
    inputs_valid <= s_axis_val_tvalid;
    external_ready <= internal_ready and inputs_valid;

    bpm <= conv_std_logic_vector(s_bpm, bpm'length);

    PROC : process(aclk)
    begin
        if rising_edge(aclk) then
            case state is
            
                when S_READ =>
                    if external_ready = '1' and inputs_valid = '1' then
                        
                        s_bpm <= conv_integer(unsigned(form_num)) / conv_integer(unsigned(s_axis_val_tdata)); -- 60.000 / R-R Interval (in ms)
                        state <= S_WRITE;
                    end if;                    
                when S_WRITE => 
                    state <= S_READ;
                when others =>
                    state <= S_READ;
            end case;
        end if;
        
    end process;



end architecture;