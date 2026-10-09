library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 

entity ex is
    Port ( 
        RD1           : in std_logic_vector(31 downto 0);
        ALUSrc        : in std_logic;
        RD2           : in std_logic_vector(31 downto 0);
        Ext_Imm       : in std_logic_vector(31 downto 0);
        sa            : in std_logic_vector(4 downto 0);
        func          : in std_logic_vector(5 downto 0);
        ALUOp         : in std_logic_vector(2 downto 0);
        pc_plus_4     : in std_logic_vector(31 downto 0);
        rt            : in std_logic_vector(4 downto 0);
        rd            : in std_logic_vector(4 downto 0);
        RegDst        : in std_logic;
        rWA           : out std_logic_vector(4 downto 0); 
        zero          : out std_logic;
        alu_res       : out std_logic_vector(31 downto 0);
        BranchAddress : out std_logic_vector(31 downto 0)
    );
end ex;

architecture Behavioral of ex is
    signal ALuCtrl : std_logic_vector(2 downto 0);
    signal B       : std_logic_vector(31 downto 0);
    signal C       : std_logic_vector(31 downto 0);
    
begin

    --mux
    rWA <= rt when RegDst = '0' else rd;

    B <= RD2 when ALUSrc = '0' else Ext_Imm;
    BranchAddress <= pc_plus_4 + (Ext_Imm(29 downto 0) & "00");

    process(AluOp, func)
    begin
        case AluOp is
            when "000" => -- Tip R
                case func is
                    when "000001" => ALuCtrl <= "000"; -- ADD
                    when "000010" => ALuCtrl <= "001"; -- SUB
                    when "000011" => ALuCtrl <= "010"; -- SLL
                    when "000100" => ALuCtrl <= "011"; -- SRL
                    when "000101" => ALuCtrl <= "100"; -- AND
                    when "000110" => ALuCtrl <= "101"; -- OR
                    when "000111" => ALuCtrl <= "110"; -- XOR
                    when "001000" => ALuCtrl <= "111"; -- SRA
                    when others   => ALuCtrl <= "000";
                end case;
            when "001" => ALuCtrl <= "000"; -- ADDI, LW, SW
            when "010" => ALuCtrl <= "001"; -- BEQ, BNQ
            when "100" => ALuCtrl <= "100"; -- ANDI
            when others => ALuCtrl <= "111"; 
        end case;
    end process;

    --ALU
    process(RD1, B, ALUCtrl, sa)
    begin
        case ALUCtrl is
            when "000" => C <= RD1 + B; 
            when "001" => C <= RD1 - B; 
            when "010" => C <= to_stdlogicvector(to_bitvector(B) sll conv_integer(sa)); 
            when "011" => C <= to_stdlogicvector(to_bitvector(B) srl conv_integer(sa)); 
            when "100" => C <= to_stdlogicvector(to_bitvector(B) sra conv_integer(sa)); 
            when "101" => 
                if signed(RD1) < signed(B) then C <= X"00000001";
                else C <= X"00000000"; end if;
            when others => C <= (others => 'X');
        end case;
    end process;

    alu_res <= C;
    zero    <= '1' when C = x"00000000" else '0';

end Behavioral;