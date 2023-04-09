-- Implementing ALU datapath
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_signed.all;
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
    res_o : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) --rezultat
    );
--    zero_o : out STD_LOGIC; -- signal da je rezultat nula
--    of_o : out STD_LOGIC); -- signal da je doslo do prekoracenja opsega
END ALU;

architecture Behavioral of ALU is
    signal result_alu: std_logic_vector(31 downto 0) := (others => '0');
    signal sub_res, add_res, first_operand, second_operand : std_logic_vector(32 downto 0) := (others => '0');  
begin

    process(a_i, b_i, op_i, add_res, sub_res) is
    begin
        case (op_i) is
            when "00000" => result_alu <= a_i and b_i;
            when "00001" => result_alu <= a_i or b_i;
            when "00010" => result_alu <= add_res(31 downto 0); -- da li moze ista za addi?
            when "00110" => result_alu <= sub_res(31 downto 0);
            when others => result_alu <= x"00000000";
        end case;            
    end process;

    first_operand <= '0' & a_i;
    second_operand <= '0' & b_i;

    add_res <= std_logic_vector(signed(first_operand)+ signed(second_operand));
    sub_res <= std_logic_vector(signed(first_operand)- signed(second_operand));
    --zero_o <= '0' when result_alu = "000000000000000000000000000000000" else '1';
    --of_o <= '1' when add_res(32) = '1' or sub_res(32) = '1';

    res_o <= result_alu(31 downto 0);

end Behavioral;
