library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Move_Avr_sim is
end Move_Avr_sim;

architecture Tb of Move_Avr_sim is

component Move_Avr is
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
end component;

constant T : time := 20 ns;

signal aclk: STD_LOGIC := '0';
signal s_axis_val_tdata, m_axis_sum_tdata: STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal s_axis_val_tready: STD_LOGIC := '0';
signal s_axis_val_tvalid, m_axis_sum_tvalid: STD_LOGIC := '0';
signal end_of_reading : std_logic := '0';

begin

    aclk <= not aclk after T / 2;
    
    -- design under test
    dut : temperature_subtractor port map (
        aclk => aclk,
        s_axis_val_tvalid => s_axis_val_tvalid,
        s_axis_val_tready => s_axis_val_tready,
        s_axis_val_tdata => s_axis_val_tdata,
        m_axis_sum_tvalid => m_axis_sum_tvalid,
        m_axis_sum_tready => '1',
        m_axis_sum_tdata => m_axis_sum_tdata
    );

    -- read values from the input file
    process (aclk)
        file avr_data : text open read_mode is "move_avr_stimuli.csv";
        variable in_line : line;
        
        variable value : std_logic_vector(31 downto 0);
    begin
        if rising_edge(aclk) then
            if end_of_reading = '0' then
            
                if not endfile(avr_data) then     
                    
                    if s_axis_val_tready = '1' then     -- read from the file only when the module is ready to accept data
                        readline(avr_data, in_line);
                        s_axis_val_tvalid <= '1';
                        read(in_line, value);
                        s_axis_val_tdata <= value;
                          
                    else
                        s_axis_val_tvalid <= '0';
                    end if;
                        
                else
                    file_close(avr_data);
                    end_of_reading <= '1';
                end if;
            end if;
        end if;
    end process;
    

end Tb;
