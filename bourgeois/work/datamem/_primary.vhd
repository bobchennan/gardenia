library verilog;
use verilog.vl_types.all;
entity datamem is
    port(
        clk             : in     vl_logic;
        \in\            : in     vl_logic_vector(7 downto 0);
        \out\           : out    vl_logic_vector(1023 downto 0)
    );
end datamem;
