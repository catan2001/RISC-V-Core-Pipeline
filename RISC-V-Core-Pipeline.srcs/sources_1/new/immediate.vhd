----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2023 01:41:02 PM
-- Design Name: 
-- Module Name: immediate - Behavioral
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

entity immediate is
port (instruction_i : in std_logic_vector (31 downto 0);
immediate_extended_o : out std_logic_vector (31 downto 0));

end entity;

architecture Behavioral of immediate is

begin


end Behavioral;
