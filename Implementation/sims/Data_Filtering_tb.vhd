library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity Data_Filtering_tb is
end Data_Filtering_tb;

architecture Behavioral of Data_Filtering_tb is
    -- Component Declaration
    component Data_Filtering is
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
    constant FFT_SIZE   : integer := 512;

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
    signal real_part_filtered:  STD_LOGIC_VECTOR(15 DOWNTO 0);

    -- Test control
    signal sim_done : boolean := false;
    signal sample_count : integer := 0;

begin
    -- Instantiate the Unit Under Test (UUT)
    UUT: Data_Filtering port map (
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
    
    real_part_filtered <= m_axis_data_tdata(15 downto 0);
    
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
        file_open(input_file, "real.txt", read_mode);
        file_open(output_file, "C:\Users\marcu\Desktop\SCS\project\scs_projecgt\scs_projecgt.srcs\resources\output_data.txt", write_mode);

        -- Process data frame by frame
        while not endfile(input_file) loop
            -- Process one frame (FFT_SIZE samples)
            for i in 0 to FFT_SIZE-1 loop
                -- Wait for ready
                wait until rising_edge(aclk) and s_axis_data_tready = '1';
                
                -- Read data from file
                if not endfile(input_file) then
                    readline(input_file, input_line);
                    hread(input_line, input_data);
                    
                    -- Set input signals
                    s_axis_data_tvalid <= '1';
                    s_axis_data_tdata <= input_data;
                    s_axis_data_tlast <= '0';
                    if i = FFT_SIZE-1 then
                        s_axis_data_tlast <= '1';  -- Mark end of frame
                    end if;
                end if;
            end loop;

            -- Wait for processing to complete
            wait until rising_edge(aclk) and m_axis_data_tvalid = '1';
            
            -- Capture output frame
            while m_axis_data_tvalid = '1' loop
                if m_axis_data_tready = '1' then
                    hwrite(output_line, m_axis_data_tdata);
                    writeline(output_file, output_line);
                end if;
                wait until rising_edge(aclk);
            end loop;
            
            -- Reset signals for next frame
            s_axis_data_tvalid <= '0';
            s_axis_data_tlast <= '0';
            
            -- Wait a few cycles between frames
            wait for CLK_PERIOD * 5;
        end loop;

        -- Close files
        file_close(input_file);
        file_close(output_file);

        -- Wait for final processing
        wait for CLK_PERIOD * 50;

        -- End simulation   
        sim_done <= true;
        wait;
    end process;


end Behavioral;
