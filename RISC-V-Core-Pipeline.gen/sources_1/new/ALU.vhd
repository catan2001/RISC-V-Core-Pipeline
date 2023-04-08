-- Implementing ALU datapath
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;
--use work.alu_ops_pkg.all;

ENTITY ALU IS
GENERIC(
    WIDTH : NATURAL := 32);
PORT(
    a_i : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --prvi operand
    b_i : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --drugi operand
    op_i : in STD_LOGIC_VECTOR(4 DOWNTO 0); --port za izbor operacije
    res_o : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --rezultat
    zero_o : out STD_LOGIC; -- signal da je rezultat nula
    of_o : out STD_LOGIC); -- signal da je doslo do prekoracenja opsega
END ALU;

architecture Behavioral of ALU is

begin


end Behavioral;
