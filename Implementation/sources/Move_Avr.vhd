library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity Move_Avr is
    Generic (
        WINDOW_SIZE : integer := 8
    );
    Port (
        aclk : IN STD_LOGIC;
        s_axis_val_tvalid : IN STD_LOGIC;
        s_axis_val_tready : OUT STD_LOGIC;
        s_axis_val_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axis_sum_tvalid : OUT STD_LOGIC;
        m_axis_sum_tready : IN STD_LOGIC;
        m_axis_sum_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
end Move_Avr;

architecture rtl of Move_Avr is

    type state_type is (S_READ, S_WRITE);
    signal state : state_type := S_READ;

    signal cnt : integer := 0;

    signal res_valid : STD_LOGIC := '0';
    signal sum : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

    signal val_ready : STD_LOGIC := '0';
    signal internal_ready, external_ready, inputs_valid : STD_LOGIC := '0';

    type arr_type is array (0 to  WINDOW_SIZE-1) of std_logic_vector(31 downto 0);

    signal arr: arr_type := (others => (others => '0'));
    signal index : std_logic_vector(2 downto 0) := (others => '0');

begin

    s_axis_val_tready <= external_ready;
    internal_ready <= '1' when state = S_READ else '0';
    inputs_valid <= s_axis_val_tvalid;
    external_ready <= internal_ready;

    m_axis_sum_tvalid <= '1' when state = S_WRITE else '0';
    m_axis_sum_tdata <= "000" & sum(31 downto 3) when cnt = 8 else (others => '0');

    PROC : process(aclk)
    begin
        if rising_edge(aclk) then
            case state is
            
                when S_READ =>
                    if external_ready = '1' and inputs_valid = '1' then
                        sum <= sum - arr(to_integer(unsigned(index))) + s_axis_val_tdata;
                        arr(to_integer(unsigned(index))) <= s_axis_val_tdata;
                        
                        index <= index + '1';

                        -- Transition to WRITE state if buffer is full
                        if cnt < WINDOW_SIZE - 1 then
                            cnt <= cnt + 1;
                        else
                            cnt <= WINDOW_SIZE;
                            state <= S_WRITE;
                        end if;

                    end if;
                    
                when S_WRITE => 
                    
                    if m_axis_sum_tready = '1' then
                        state <= S_READ;
                    end if;


                when others =>
                    state <= S_READ;
            end case;
        end if;
        
    end process;

end architecture;