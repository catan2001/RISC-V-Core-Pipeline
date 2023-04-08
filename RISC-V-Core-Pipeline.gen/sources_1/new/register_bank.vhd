----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2023 12:51:10 PM
-- Design Name: 
-- Module Name: register_bank - Behavioral
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
--***************OPIS MODULA*********************
--Registarska banka sa dva interfejsa za citanje
--podataka i jednim interfejsom za upis podataka.
--Broj registara u banci je 32.
--WIDTH je parametar koji odredjuje sirinu poda-
--data u registrima
--***********************************************
entity register_bank is
generic (WIDTH : positive := 32);
port (clk : in std_logic;
      reset : in std_logic;
            -- Interfejs 1 za citanje podataka
        rs1_address_i : in std_logic_vector(4 downto 0);
        rs1_data_o : out std_logic_vector(WIDTH - 1 downto 0);
            -- Interfejs 2 za citanje podataka
        rs2_address_i : in std_logic_vector(4 downto 0);
        rs2_data_o : out std_logic_vector(WIDTH - 1 downto 0);
            -- Interfejs za upis podataka
        rd_we_i : in std_logic; -- port za dozvolu upisa
        rd_address_i : in std_logic_vector(4 downto 0);
        rd_data_i : in std_logic_vector(WIDTH - 1 downto 0));
end entity;

architecture Behavioral of register_bank is
    type registerFile is array(0 to 31) of std_logic_vector(WIDTH-1 downto 0);
    signal registers : registerFile := (others => (others => '0'));
begin

register_bank_write: process(clk) is
begin
    if rising_edge(clk) then
        if(reset = '1') then
            registers(to_integer(unsigned(rd_address_i))) <= (others => '0');
        else
            if(rd_we_i = '1') then
                registers(to_integer(unsigned(rd_address_i))) <= rd_data_i;
            end if;
        end if;
     end if;       
end process;

rs1_data_o <= registers(to_integer(unsigned(rs1_address_i)));
rs2_data_o <= registers(to_integer(unsigned(rs2_address_i)));

end Behavioral;