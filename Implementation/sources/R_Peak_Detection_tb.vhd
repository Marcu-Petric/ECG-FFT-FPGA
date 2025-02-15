library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity R_Peak_Detection_tb is
end R_Peak_Detection_tb;

architecture Behavioral of R_Peak_Detection_tb is
    -- Component Declaration
    component R_Peak_Detection is
        Port (
            aclk : in STD_LOGIC;
            aresetn : in STD_LOGIC;
            s_axis_ecg_tvalid : in STD_LOGIC;
            s_axis_ecg_tready : out STD_LOGIC;
            s_axis_ecg_tdata : in STD_LOGIC_VECTOR(31 downto 0);
            r_peak : out STD_LOGIC
        );
    end component;

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

    -- Signals for test
    signal aclk : STD_LOGIC := '0';
    signal aresetn : STD_LOGIC := '0';
    signal s_axis_ecg_tvalid : STD_LOGIC := '0';
    signal s_axis_ecg_tready : STD_LOGIC;
    signal s_axis_ecg_tdata : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal r_peak : STD_LOGIC;

    -- Test control
    signal sim_done : boolean := false;

begin
    -- Instantiate the Unit Under Test (UUT)
    UUT: R_Peak_Detection port map (
        aclk => aclk,
        aresetn => aresetn,
        s_axis_ecg_tvalid => s_axis_ecg_tvalid,
        s_axis_ecg_tready => s_axis_ecg_tready,
        s_axis_ecg_tdata => s_axis_ecg_tdata,
        r_peak => r_peak
    );

    aclk <= not aclk after CLK_PERIOD / 2;

    -- Stimulus process
    stim_proc: process
        file input_file : text;
        variable input_line : line;
        variable input_data : std_logic_vector(31 downto 0);
    begin
        -- Reset
        aresetn <= '0';
        wait for CLK_PERIOD * 5;
        aresetn <= '1';
        wait for CLK_PERIOD * 2;

        -- Open input file
        file_open(input_file, "input_rpeak_data.txt", read_mode);

        -- Read data from file and send through R-peak detector
        while not endfile(input_file) loop
            readline(input_file, input_line);
            hread(input_line, input_data);
            
            s_axis_ecg_tvalid <= '1';
            s_axis_ecg_tdata <= input_data;
            
            wait for CLK_PERIOD;
            
        end loop;
        file_close(input_file);


        s_axis_ecg_tvalid <= '0';

        wait for CLK_PERIOD * 10;

        -- End simulation   
        sim_done <= true;
        wait;
    end process;

end Behavioral;
