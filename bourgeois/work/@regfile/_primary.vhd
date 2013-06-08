library verilog;
use verilog.vl_types.all;
entity Regfile is
    port(
        Clk             : in     vl_logic;
        Raddr           : in     vl_logic_vector(5 downto 0);
        Rval            : out    vl_logic_vector(31 downto 0);
        Write           : in     vl_logic;
        Waddr           : in     vl_logic_vector(5 downto 0);
        WVal            : in     vl_logic_vector(31 downto 0)
    );
end Regfile;
