library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is
    Port ( enable : out STD_LOGIC; btn : in STD_LOGIC; clk : in STD_LOGIC);
end component;

component SSD is
    Port ( clk : in STD_LOGIC; digits : in STD_LOGIC_VECTOR(31 downto 0); an : out STD_LOGIC_VECTOR(7 downto 0); cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component IFetch is
    Port ( jump : in STD_LOGIC; jumpAddress : in STD_LOGIC_VECTOR (31 downto 0); PCSrc : in STD_LOGIC; branchAddress : in STD_LOGIC_VECTOR (31 downto 0); en : in STD_LOGIC; rst : in STD_LOGIC; clk : in STD_LOGIC; pc : out STD_LOGIC_VECTOR (31 downto 0); instruction : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component ID is
    Port ( 
        regWrite : in std_logic; 
        Instr    : in std_logic_vector (25 downto 0); 
        -- regDst   : in std_logic; 
        en       : in std_logic; 
        extOp    : in std_logic; 
        RD1      : out std_logic_vector (31 downto 0); 
        RD2      : out std_logic_vector (31 downto 0); 
        WD       : in std_logic_vector (31 downto 0); 
        ext_Imm  : out std_logic_vector (31 downto 0); 
        func     : out std_logic_vector (5 downto 0); 
        sa       : out std_logic_vector (4 downto 0); 
        rt       : out std_logic_vector (4 downto 0); 
        rd       : out std_logic_vector (4 downto 0); 
        rWA      : in std_logic_vector (4 downto 0); 
        clk      : in std_logic
    );
end component;

component UC is
    Port ( instr : in std_logic_vector (5 downto 0);
        regDst : out std_logic;
        extOp : out std_logic;
        ALUSrc : out std_logic;
        branch : out std_logic;
        jump : out std_logic;
        MemWrite : out std_logic;
        MemtoReg : out std_logic;
        RegWrite : out std_logic;
        ALUOp : out std_logic_vector (2 downto 0));
end component;

component ex is
    Port ( RD1: in std_logic_vector(31 downto 0);
               ALUSrc: in std_logic;
               RD2: in std_logic_vector(31 downto 0);
               Ext_Imm: in std_logic_vector(31 downto 0);
               sa: in std_logic_vector(4 downto 0);
               func: in std_logic_vector(5 downto 0);
               ALUOp: in std_logic_vector(2 downto 0);
               pc_plus_4: in std_logic_vector(31 downto 0);
               rt: in std_logic_vector(4 downto 0);
               rd: in std_logic_vector(4 downto 0);
               RegDst: in std_logic;
               rWA: out std_logic_vector(4 downto 0);
               zero: out std_logic;
               alu_res: out std_logic_vector(31 downto 0);
               BranchAddress: out std_logic_vector(31 downto 0));
end component;

component mem is
    Port ( mem_write: in std_logic;
           alu_in: in std_logic_vector(31 downto 0);
           RD2: in std_logic_vector(31 downto 0);
           clk: in std_logic;
           en: in std_logic;
           mem_data: out std_logic_vector(31 downto 0);
           alu_out: out std_logic_vector(31 downto 0));
end component;

signal en_sig, rst_sig: std_Logic;
signal instr_sig, pc_plus_sig: std_logic_vector(31 downto 0);
signal rd1_sig, rd2_sig, ext_sig: std_Logic_vector(31 downto 0);
signal sa_sig: std_logic_vector(4 downto 0);
signal rt_sig, rd_sig: std_logic_vector(4 downto 0);
signal func_sig: std_Logic_vector(5 downto 0);
signal regdst_sig, extop_sig, alusrc_sig, branch_sig, jump_sig, memwrite_sig, memtoreg_sig, regwrite_sig: std_Logic;
signal aluop_sig: std_logic_vector(2 downto 0);
signal alu_res_sig, alu_out_sig, mem_data_sig : std_logic_vector(31 downto 0);
signal branch_addr_sig, jump_addr_sig : std_logic_vector(31 downto 0);
signal zero_sig, pc_src_sig : std_logic;
signal wd_sig, mux_out: std_Logic_vector(31 downto 0);
signal rWA_sig: std_logic_vector(4 downto 0);

-- IF/ID
signal IF_ID_instr, IF_ID_pc_plus_4 : std_logic_vector(31 downto 0);
-- ID/EX
signal ID_EX_RD1, ID_EX_RD2, ID_EX_ext_Imm, ID_EX_pc_plus_4 : std_logic_vector(31 downto 0);
signal ID_EX_func : std_logic_vector(5 downto 0);
signal ID_EX_sa : std_logic_vector(4 downto 0);
signal ID_EX_rt, ID_EX_rd : std_logic_vector(4 downto 0);
signal ID_EX_regDst, ID_EX_ALUSrc, ID_EX_branch, ID_EX_memWrite, ID_EX_memtoReg, ID_EX_regWrite : std_logic;
signal ID_EX_aluOp : std_logic_vector(2 downto 0);
-- EX/MEM
signal EX_MEM_brachAddress, EX_MEM_alu_res, EX_MEM_RD2 : std_logic_vector(31 downto 0);
signal EX_MEM_zero, EX_MEM_branch, EX_MEM_memWrite, EX_MEM_memtoReg, EX_MEM_regWrite : std_logic;
signal EX_MEM_rWA : std_logic_vector(4 downto 0);
-- MEM/WB
signal MEM_WB_mem_data, MEM_WB_alu_out : std_logic_vector(31 downto 0);
signal MEM_WB_rWA : std_logic_vector(4 downto 0);
signal MEM_WB_memtoReg, MEM_WB_regWrite : std_logic;

begin

mpg1: MPG port map(en_sig, btn(0), clk);
rst_sig <= btn(1);

jump_addr_sig <= IF_ID_pc_plus_4(31 downto 28) & IF_ID_instr(25 downto 0) & "00";
pc_src_sig <= EX_MEM_branch and EX_MEM_zero;

instr_fetch: IFetch port map(
    jump          => jump_sig, 
    jumpAddress   => jump_addr_sig, 
    PCSrc         => pc_src_sig, 
    branchAddress => EX_MEM_brachAddress,
    en            => en_sig, rst => rst_sig, clk => clk,
    pc            => pc_plus_sig, instruction => instr_sig
);

id1: ID port map(
    regWrite => MEM_WB_regWrite,
    Instr    => IF_ID_instr(25 downto 0), 
    -- regDst => regdst_sig, 
    en => en_sig, extOp => extop_sig,
    RD1      => rd1_sig, RD2 => rd2_sig, 
    WD       => wd_sig, 
    ext_Imm  => ext_sig, func => func_sig, sa => sa_sig,
    rt       => rt_sig, rd => rd_sig, 
    clk      => clk,
    rWA      => MEM_WB_rWA
);

unitate_control: UC port map(
    instr => IF_ID_instr(31 downto 26),
    regDst => regdst_sig, extOp => extop_sig, ALUSrc => alusrc_sig, branch => branch_sig,
    jump => jump_sig, MemWrite => memwrite_sig, MemtoReg => memtoreg_sig, RegWrite => regwrite_sig,
    ALUOp => aluop_sig
);

ex_inst: ex port map(
    RD1 => ID_EX_RD1, ALUSrc => ID_EX_ALUSrc, RD2 => ID_EX_RD2, Ext_Imm => ID_EX_ext_Imm,
    sa => ID_EX_sa, func => ID_EX_func, ALUOp => ID_EX_aluOp, pc_plus_4 => ID_EX_pc_plus_4,
    rt => ID_EX_rt, rd => ID_EX_rd, RegDst => ID_EX_regDst,
    rWA => rWA_sig, zero => zero_sig, alu_res => alu_res_sig, BranchAddress => branch_addr_sig
);

mem_inst: mem port map(
    mem_write => EX_MEM_memWrite, alu_in => EX_MEM_alu_res, RD2 => EX_MEM_RD2,
    clk => clk, en => en_sig, mem_data => mem_data_sig, alu_out => alu_out_sig
);

--WB
wd_sig <= MEM_WB_mem_data when MEM_WB_memtoReg = '1' else MEM_WB_alu_out;

process(clk)
begin
    if rising_edge(clk) then
        if en_sig = '1' then
            -- IF/ID
            IF_ID_instr <= instr_sig;
            IF_ID_pc_plus_4 <= pc_plus_sig;

            -- ID/EX
            ID_EX_RD1 <= rd1_sig;
            ID_EX_RD2 <= rd2_sig;
            ID_EX_ext_Imm <= ext_sig;
            ID_EX_func <= func_sig;
            ID_EX_sa <= sa_sig;
            ID_EX_rt <= rt_sig;
            ID_EX_rd <= rd_sig;
            ID_EX_pc_plus_4 <= IF_ID_pc_plus_4;
            ID_EX_regDst <= regdst_sig;
            ID_EX_ALUSrc <= alusrc_sig;
            ID_EX_aluOp <= aluop_sig;
            ID_EX_branch <= branch_sig;
            ID_EX_memWrite <= memwrite_sig;
            ID_EX_memtoReg <= memtoreg_sig;
            ID_EX_regWrite <= regwrite_sig;

            -- EX/MEM
            EX_MEM_brachAddress <= branch_addr_sig;
            EX_MEM_zero <= zero_sig;
            EX_MEM_alu_res <= alu_res_sig;
            EX_MEM_RD2 <= ID_EX_RD2;
            EX_MEM_rWA <= rWA_sig;
            EX_MEM_branch <= ID_EX_branch;
            EX_MEM_memWrite <= ID_EX_memWrite;
            EX_MEM_memtoReg <= ID_EX_memtoReg;
            EX_MEM_regWrite <= ID_EX_regWrite;

            -- MEM/WB
            MEM_WB_mem_data <= mem_data_sig;
            MEM_WB_alu_out <= alu_out_sig;
            MEM_WB_rWA <= EX_MEM_rWA;
            MEM_WB_memtoReg <= EX_MEM_memtoReg;
            MEM_WB_regWrite <= EX_MEM_regWrite;
        end if;
    end if;
end process;

-- wd_sig <= mem_data_sig when memtoreg_sig = '1' else alu_out_sig;  -- ciclu unic WB direct
-- pc_src_sig <= branch_sig and zero_sig;                              -- ciclu unic branch direct

process(sw(7 downto 5), IF_ID_instr, IF_ID_pc_plus_4, ID_EX_RD1, ID_EX_RD2, ID_EX_ext_Imm, alu_res_sig, mem_data_sig, wd_sig)
begin
   case sw(7 downto 5) is
       when "000" => mux_out <= IF_ID_instr;        -- Instructiunea (IF/ID)
       when "001" => mux_out <= IF_ID_pc_plus_4;    -- PC+4 (IF/ID)
       when "010" => mux_out <= ID_EX_RD1;          -- RD1 (ID/EX)  -- ciclu unic rd1_sig
       when "011" => mux_out <= ID_EX_RD2;          -- RD2 (ID/EX)  -- ciclu unic rd2_sig
       when "100" => mux_out <= ID_EX_ext_Imm;      -- Ext_Imm (ID/EX) -- ciclu unic ext_sig
       when "101" => mux_out <= alu_res_sig;         -- ALURes (EX)
       when "110" => mux_out <= mem_data_sig;        -- MemData (MEM)
       when "111" => mux_out <= wd_sig;              -- WD (WB)
       when others => mux_out <= (others => '0');
  end case;
end process;

ssd1: SSD port map(clk, mux_out, an, cat);
led(10 downto 0) <= aluop_sig & regdst_sig & extop_sig & alusrc_sig & branch_sig & jump_sig & memwrite_sig & memtoreg_sig & regwrite_sig;
led(15 downto 11) <= (others => '0');

end Behavioral;