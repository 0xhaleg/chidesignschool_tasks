library verilog;
use verilog.vl_types.all;
entity riscv_imm_gen is
    port(
        clk             : in     vl_logic;
        aresetn         : in     vl_logic;
        instr           : in     vl_logic_vector(31 downto 0);
        i_imm           : out    vl_logic_vector(31 downto 0);
        s_imm           : out    vl_logic_vector(31 downto 0);
        b_imm           : out    vl_logic_vector(31 downto 0);
        u_imm           : out    vl_logic_vector(31 downto 0);
        j_imm           : out    vl_logic_vector(31 downto 0)
    );
end riscv_imm_gen;
