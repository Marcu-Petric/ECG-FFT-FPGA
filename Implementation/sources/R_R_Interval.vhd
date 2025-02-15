library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity R_R_Interval is
    port (
        aclk : in std_logic; -- axi4 clock
        clk : in std_logic; -- 100 Hz ( 10 ms )
        r_peak: in std_logic; -- 1 when a R peak is detected
        m_axis_interval_tvalid : OUT STD_LOGIC;
        m_axis_interval_tready : IN STD_LOGIC;
        m_axis_interval_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
end R_R_Interval;

architecture rtl of R_R_Interval is
    type state_type is (S_READ, S_WRITE);
    signal state : state_type := S_READ;
    
    signal cnt : std_logic_vector(31 downto 0) := (others => '0');
    signal r_interval : std_logic_vector(31 downto 0) := (others => '0');
    signal start_counting : std_logic := '0';

begin

    m_axis_interval_tvalid <= '1' when state = S_WRITE else '0';
    m_axis_interval_tdata <= r_interval;

    CNT_1MS : process(clk)
    begin
        if rising_edge(clk) then
            cnt <= cnt + 1;
        end if;
    end process;

    AXI: process(aclk)
    begin
        
        if rising_edge(aclk) then
            case state is
            
                when S_READ =>
                    if r_peak = '1' then
                        if start_counting = '1' then
                            start_counting <= '0';
                            r_interval <= cnt;
                            state <= S_WRITE;                          
                        else
                            start_counting <= '1';
                            r_interval <= (others => '0');
                            cnt <= (others => '0');
                        end if;
                    end if;
                    
                when S_WRITE => 
                    if m_axis_interval_tready = '1' then
                        state <= S_READ;
                    end if;


                when others =>
                    state <= S_READ;
            end case;
        end if;

    end process;

end architecture;