library verilog;
use verilog.vl_types.all;
entity ADD is
    port(
        dst             : out    vl_logic_vector(31 downto 0);
        src1            : in     vl_logic_vector(31 downto 0);
        src2            : in     vl_logic_vector(31 downto 0)
    );
end ADD;
