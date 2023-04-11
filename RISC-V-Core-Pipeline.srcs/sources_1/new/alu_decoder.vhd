----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.04.2023 02:57:24
-- Design Name: 
-- Module Name: alu_decoder - Behavioral
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu_decoder is
port (
--******** Controlpath ulazi *********
alu_2bit_op_i : in std_logic_vector(1 downto 0);
--******** Polja instrukcije *******
funct3_i : in std_logic_vector (2 downto 0);
funct7_i : in std_logic_vector (6 downto 0);
--******** Datapath izlazi ********
alu_op_o : out std_logic_vector(4 downto 0));
end entity;

architecture Behavioral of alu_decoder is
    signal alu_output: std_logic_vector(4 downto 0) := (others => '0');
begin
    -- ZASTO SAM KORISTIO SIGNED DOLE????
    -- KREIRA NEPOTREBAN LATCH???
    alu_dec: process(alu_2bit_op_i, funct3_i, funct7_i) is
    begin
        if(alu_2bit_op_i = "00") then -- FOR OTHER INSTRUCTIONS LW, SW... AUIPC ALSO
            alu_output <= "00010";      
        elsif(alu_2bit_op_i(1) = '1' and alu_2bit_op_i(0) = '0') then       --(alu_2bit_op_i(0) = '0' or alu_2bit_op_i(0) = '1')) then RIJESI SE LATCH
            if(signed(funct7_i) = "0000000" and signed(funct3_i) = "000") then
                alu_output <= "00010";  -- ADD INSTRUCTION
            elsif(signed(funct7_i) = "0100000" and signed(funct3_i) = "000") then
                alu_output <= "00110";  -- SUBTRACT INSTRUCTION
            elsif(signed(funct7_i) = "0000000" and signed(funct3_i) = "111") then
                alu_output <= "00000";  -- AND INSTRUCTION
            else--(signed(funct7_i) = "0000000" and signed(funct3_i) = "110") then
                alu_output <= "00001";  -- OR INSTRUCTION      
            end if; 
        else    --elsif(alu_2bit_op_i(0) = '1' and (alu_2bit_op_i(1) = '0' or alu_2bit_op_i(1) = '1')) then RIJESI SE LATCH
            alu_output <= "00110";
        end if;
    end process;   
    alu_op_o <= alu_output;
end Behavioral;
