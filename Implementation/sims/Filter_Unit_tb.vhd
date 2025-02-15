library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity Filter_Unit_tb is
end Filter_Unit_tb;

architecture Behavioral of Filter_Unit_tb is
    -- Component Declaration
    component Filter_Unit is
        Port (
            aclk                : in  STD_LOGIC;
            aresetn             : in  STD_LOGIC;
            s_axis_data_tdata   : in  STD_LOGIC_VECTOR(31 DOWNTO 0);
            s_axis_data_tvalid  : in  STD_LOGIC;
            s_axis_data_tready  : out STD_LOGIC;
            s_axis_data_tlast   : in  STD_LOGIC;
            m_axis_data_tdata   : out STD_LOGIC_VECTOR(31 DOWNTO 0);
            m_axis_data_tvalid  : out STD_LOGIC;
            m_axis_data_tready  : in  STD_LOGIC;
            m_axis_data_tlast   : out STD_LOGIC
        );
    end component;

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

    -- Signals for test
    signal aclk              : STD_LOGIC := '0';
    signal aresetn           : STD_LOGIC := '0';
    signal s_axis_data_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    signal s_axis_data_tvalid: STD_LOGIC := '0';
    signal s_axis_data_tready: STD_LOGIC;
    signal s_axis_data_tlast : STD_LOGIC := '0';
    signal m_axis_data_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal m_axis_data_tvalid: STD_LOGIC;
    signal m_axis_data_tready: STD_LOGIC := '1';
    signal m_axis_data_tlast : STD_LOGIC;

    -- Test control
    signal sim_done : boolean := false;

begin
    -- Instantiate the Unit Under Test (UUT)
    UUT: Filter_Unit port map (
        aclk                => aclk,
        aresetn             => aresetn,
        s_axis_data_tdata   => s_axis_data_tdata,
        s_axis_data_tvalid  => s_axis_data_tvalid,
        s_axis_data_tready  => s_axis_data_tready,
        s_axis_data_tlast   => s_axis_data_tlast,
        m_axis_data_tdata   => m_axis_data_tdata,
        m_axis_data_tvalid  => m_axis_data_tvalid,
        m_axis_data_tready  => m_axis_data_tready,
        m_axis_data_tlast   => m_axis_data_tlast
    );

    -- Clock generation
    clk_process: process
    begin
        while not sim_done loop
            aclk <= '0';
            wait for CLK_PERIOD/2;
            aclk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
        file input_file : text;
        file output_file : text;
        variable input_line : line;
        variable output_line : line;
        variable input_data : std_logic_vector(31 downto 0);
    begin
        -- Reset
        aresetn <= '0';
        wait for CLK_PERIOD * 5;
        aresetn <= '1';
        wait for CLK_PERIOD * 2;

        -- Open files
        file_open(input_file, "input_filter_data.txt", read_mode);
        file_open(output_file, "C:\Users\marcu\Desktop\SCS\project\scs_projecgt\scs_projecgt.srcs\resources\output_filter_data.txt", write_mode);

        -- Read data from file and send through filter
        while not endfile(input_file) loop
            readline(input_file, input_line);
            hread(input_line, input_data);
            
            s_axis_data_tvalid <= '1';
            s_axis_data_tdata <= input_data;
            
            wait for CLK_PERIOD;
            
            -- Write filtered output to file when valid
            if m_axis_data_tvalid = '1' then
                hwrite(output_line, m_axis_data_tdata);
                writeline(output_file, output_line);
            end if;
        end loop;

        -- Close files
        file_close(input_file);
        file_close(output_file);

        -- Deassert valid after all data sent
        s_axis_data_tvalid <= '0';

        -- Wait for a few cycles
        wait for CLK_PERIOD * 10;

        -- End simulation   
        sim_done <= true;
        wait;
    end process;

end Behavioral;
