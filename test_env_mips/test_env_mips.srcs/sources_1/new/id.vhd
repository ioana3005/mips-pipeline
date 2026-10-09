library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity id is
    Port ( 
        clk      : in std_logic;
        en       : in std_logic;
        Instr    : in std_logic_vector(25 downto 0);
        WD       : in std_logic_vector(31 downto 0); 
        RegWrite : in std_logic;                     
        rWA      : in std_logic_vector(4 downto 0);  
        ExtOp    : in std_logic;
        RD1      : out std_logic_vector(31 downto 0);
        RD2      : out std_logic_vector(31 downto 0);
        Ext_Imm  : out std_logic_vector(31 downto 0);
        func     : out std_logic_vector(5 downto 0);
        sa       : out std_logic_vector(4 downto 0);
        rt       : out std_logic_vector(4 downto 0); 
        rd       : out std_logic_vector(4 downto 0)
        -- regDst : in std_logic  -- pipeline
    );
end id;

architecture Behavioral of id is
    type reg_array is array (0 to 31) of std_logic_vector(31 downto 0);
    signal reg_file : reg_array := (others => X"00000000");
begin

    RD1 <= reg_file(conv_integer(Instr(25 downto 21)));
    RD2 <= reg_file(conv_integer(Instr(20 downto 16)));

    process(clk)
    begin
        if falling_edge(clk) then
            if en = '1' and RegWrite = '1' then
                reg_file(conv_integer(rWA)) <= WD;
            end if;
        end if;
    end process;

    Ext_Imm <= (X"0000" & Instr(15 downto 0)) when ExtOp = '0' else 
               (X"FFFF" & Instr(15 downto 0)) when Instr(15) = '1' else 
               (X"0000" & Instr(15 downto 0));

    func <= Instr(5 downto 0);
    sa   <= Instr(10 downto 6);
    rt   <= Instr(20 downto 16);
    rd   <= Instr(15 downto 11);

end Behavioral;