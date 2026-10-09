library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
    Port ( Jump : in STD_LOGIC;
           JumpAddress : in STD_LOGIC_VECTOR (31 downto 0);
           PCSrc : in STD_LOGIC;
           BranchAddress : in STD_LOGIC_VECTOR (31 downto 0);
           en : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           pc : out STD_LOGIC_VECTOR (31 downto 0);
           instruction : out STD_LOGIC_VECTOR (31 downto 0));
end IFetch;

architecture Behavioral of IFetch is
    signal pc_out: std_logic_vector(31 downto 0):=(others=>'0');
    signal add_4_pc : std_logic_vector(31 downto 0);
    signal mux_1_out:  std_logic_vector(31 downto 0);
    signal mux_2_out:  std_logic_vector(31 downto 0);

    type rom_type is array(0 to 63) of std_logic_vector(31 downto 0);

    signal ROM: rom_type := (

        0  => B"010001_00000_00001_0000000000000000", -- Hexa: X"44010000" | Poz 0:  lw   $1, 0($0)          # incarca valoarea limita inferioara X in $1
        1  => B"010001_00000_00010_0000000000000100", -- Hexa: X"44020004" | Poz 1:  lw   $2, 4($0)          # incarca valoarea limita superioara Y in $2
        2  => B"010001_00000_00011_0000000000001000", -- Hexa: X"44030008" | Poz 2:  lw   $3, 8($0)          # incarca nr total de elemente N in $3
        3  => B"010000_00000_00100_0000000000001100", -- Hexa: X"4004000C" | Poz 3:  addi $4, $0, 12         # seteaza adresa de start a sirului la 12 in $4

        -- loop:
        4  => B"010011_00011_00000_0000000000100000", -- Hexa: X"4C600020" | Poz 4:  beq  $3, $0, 32         # daca N ($3) este 0, sare la final la pozitia 37
        5  => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 5:  add  $0, $0, $0         # noop
        6  => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 6:  add  $0, $0, $0         # noop
        7  => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 7:  add  $0, $0, $0         # noop
        8  => B"010001_00100_00101_0000000000000000", -- Hexa: X"44850000" | Poz 8:  lw   $5, 0($4)          # incarca elementul curent in $5
        9  => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 9:  add  $0, $0, $0         # noop
        10 => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 10: add  $0, $0, $0         # noop
        11 => B"000000_00101_00001_00110_00000_000010", -- Hexa: X"00A13002" | Poz 11: sub  $6, $5, $1         # calc (element curent - X) in $6
        12 => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 12: add  $0, $0, $0         # noop
        13 => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 13: add  $0, $0, $0         # noop
        14 => B"000000_00000_00110_00110_11111_000100", -- Hexa: X"000637C4" | Poz 14: srl  $6, $6, 31         # bitul de semn, daca e 1, element < X
        15 => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 15: add  $0, $0, $0         # noop
        16 => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 16: add  $0, $0, $0         # noop

        -- Evaluare(X):
        17 => B"010011_00110_00000_0000000000000100", -- Hexa: X"4CC00004" | Poz 17: beq  $6, $0, 4          # daca $6 este 0 (element >= X), sare la check_Y (poz 22)
        18 => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 18: add  $0, $0, $0         # noop
        19 => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 19: add  $0, $0, $0         # noop
        20 => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 20: add  $0, $0, $0         # noop
        21 => B"010010_00100_00001_0000000000000000", -- Hexa: X"48810000" | Poz 21: sw   $1, 0($4)          # element < X, scrie valoarea X in memorie

        -- check_Y: Evaluare(Y):
        22 => B"000000_00010_00101_00110_00000_000010", -- Hexa: X"00453002" | Poz 22: sub  $6, $2, $5         # calc (Y - element curent) in $6
        23 => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 23: add  $0, $0, $0         # noop
        24 => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 24: add  $0, $0, $0         # noop
        25 => B"000000_00000_00110_00110_11111_000100", -- Hexa: X"000637C4" | Poz 25: srl  $6, $6, 31         # bitul de semn, daca e 1, Y < element
        26 => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 26: add  $0, $0, $0         # noop
        27 => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 27: add  $0, $0, $0         # noop

        28 => B"010011_00110_00000_0000000000000100", -- Hexa: X"4CC00004" | Poz 28: beq  $6, $0, 4          # daca $6 este 0 (Y >= element), sare la next (poz 33)
        29 => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 29: add  $0, $0, $0         # noop
        30 => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 30: add  $0, $0, $0         # noop
        31 => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 31: add  $0, $0, $0         # noop
        32 => B"010010_00100_00010_0000000000000000", -- Hexa: X"48820000" | Poz 32: sw   $2, 0($4)          # element > Y, scrie valoarea Y in memorie

        -- next:
        33 => B"010000_00100_00100_0000000000000100", -- Hexa: X"40840004" | Poz 33: addi $4, $4, 4          # trece la urm element
        34 => B"010000_00011_00011_1111111111111111", -- Hexa: X"4063FFFF" | Poz 34: addi $3, $3, -1         # N = N - 1
        35 => B"100000_00000000000000000000000100",   -- Hexa: X"80000004" | Poz 35: j    4                  # salt la loop:
        36 => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 36: add  $0, $0, $0         # noop - Jump

        -- end:
        37 => B"000000_00000_00000_00000_00000_000001", -- Hexa: X"00000001" | Poz 37: add  $0, $0, $0         # noop final

        OTHERS => X"00000000"
    );

begin

    process(clk, rst)
    begin
        if rst = '1' then
            pc_out <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                pc_out <= mux_2_out;
            end if;
        end if;
    end process;

    instruction <= ROM(conv_integer(pc_out(7 downto 2)));

    add_4_pc <= pc_out + X"00000004";
    pc <= add_4_pc;

    process(PCSrc, BranchAddress, add_4_pc)
    begin
        case PCSrc is
            when '1'    => mux_1_out <= BranchAddress;
            when '0'    => mux_1_out <= add_4_pc;
            when others => mux_1_out <= (others => '0');
        end case;
    end process;

    process(Jump, JumpAddress, mux_1_out)
    begin
        case Jump is
            when '1'    => mux_2_out <= JumpAddress;
            when '0'    => mux_2_out <= mux_1_out;
            when others => mux_2_out <= (others => '0');
        end case;
    end process;

end Behavioral;