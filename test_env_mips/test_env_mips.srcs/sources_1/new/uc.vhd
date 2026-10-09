library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UC is
    Port ( 
        Instr    : in  std_logic_vector (5 downto 0); -- opcode
        RegDst   : out std_logic;
        ExtOp    : out std_logic;
        ALUSrc   : out std_logic;
        Branch   : out std_logic;
        Jump     : out std_logic;
        MemWrite : out std_logic;
        MemtoReg : out std_logic;
        RegWrite : out std_logic;
        ALUOp    : out std_logic_vector (2 downto 0)
    );
end UC;

architecture Behavioral of UC is
begin

process(Instr)
begin
    
    RegDst <= '0'; 
    ExtOp <= '0'; 
    ALUSrc <= '0'; 
    Branch <= '0'; 
    Jump <= '0';
    MemWrite <= '0'; 
    MemtoReg <= '0'; 
    RegWrite <= '0'; 
    ALUOp <= "000";

    case Instr is
        when "000000" => -- type R
            RegDst   <= '1';
            RegWrite <= '1';
            ALUOp    <= "000";
            
        when "010000" => --addi
            ExtOp    <= '1'; 
            ALUSrc   <= '1'; 
            RegWrite <= '1';
            ALUOp    <= "001"; 
            
        when "010001" => --load word
            ExtOp    <= '1';
            ALUSrc   <= '1';
            MemtoReg <= '1'; 
            RegWrite <= '1';
            ALUOp    <= "001";
            
            when "010010" => -- store word
            ExtOp    <= '1';
            ALUSrc   <= '1';
            MemWrite <= '1';
            ALUOp    <= "001";
            
        when "010011" => --beq
            ExtOp    <= '1';
            Branch   <= '1';
            ALUOp    <= "010";
            

        when "010101" => --andi
            ALUSrc   <= '1';
            RegWrite <= '1';
            ALUOp    <= "011"; 

        when "100000" => --jump
            Jump     <= '1';
           

        when others =>
            null;
            
    end case;
    
end process;

end Behavioral;