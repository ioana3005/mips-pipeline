----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2026 10:22:02 AM
-- Design Name: 
-- Module Name: mem - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mem is
  Port (
    mem_write: in std_logic;
    alu_in:in std_logic_vector(31 downto 0);
    RD2:in std_logic_vector(31 downto 0);
    clk:in std_logic;
    en:in std_logic;
    mem_data:out std_logic_vector(31 downto 0);
    alu_out:out std_logic_vector(31 downto 0)
   );
end mem;

architecture Behavioral of mem is

type ram_type is array (0 to 63) of std_logic_vector(31 downto 0);
--signal mem : ram_type := (others => X"00000000"); 
signal mem : ram_type := (
    0      => X"00000005", -- X = 5 
    1      => X"00000009", -- Y = 9
    2      => X"00000005", -- N = 5
    3      => X"0000000C", -- Element 0 
    4      => X"0000000A", -- Element 1  
    5      => X"00000001", -- Element 2
    6      => X"00000007", -- Element 3
    7      => X"00000009", -- Element 4
    others => X"00000000"
);
    
begin

    process(clk)
    begin
        if rising_edge(clk) then
           
            if en = '1' and mem_write = '1' then
             
                mem(conv_integer(alu_in(7 downto 2))) <= RD2;
            end if;
        end if;
    end process;
    
    mem_data <= mem(conv_integer(alu_in(7 downto 2)));
 
    alu_out <= alu_in;

end Behavioral;
