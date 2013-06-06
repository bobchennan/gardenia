library verilog;
use verilog.vl_types.all;
entity datamem is
    port(
        clk             : in     vl_logic;
        \in\            : in     vl_logic_vector(7 downto 0);
        writable        : in     vl_logic;
        write           : in     vl_logic_vector(1023 downto 0);
        out1            : out    vl_logic_vector(1023 downto 0);
        out2            : out    vl_logic_vector(1023 downto 0)
    );
end datamem;
