----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.04.2023 02:53:51
-- Design Name: 
-- Module Name: hazard_unit - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity hazard_unit is
    port (
    -- ulazni signali
    rs1_address_id_i : in std_logic_vector(4 downto 0);
    rs2_address_id_i : in std_logic_vector(4 downto 0);
    rs1_in_use_i : in std_logic;
    rs2_in_use_i : in std_logic;
    branch_id_i : in std_logic;
    rd_address_ex_i : in std_logic_vector(4 downto 0);
    mem_to_reg_ex_i : in std_logic;
    rd_we_ex_i : in std_logic;
    rd_address_mem_i : in std_logic_vector(4 downto 0);
    mem_to_reg_mem_i : in std_logic;
    -- izlazni kontrolni signali
    -- pc_en_o je signal dozvole rada za pc registar
    pc_en_o : out std_logic;
    -- if_id_en_o je signal dozvole rada za if/id registar
    if_id_en_o : out std_logic;
    -- control_pass_o kontrolise da li ce u execute fazu biti prosledjeni
    -- kontrolni signali iz ctrl_decoder-a ili sve nule
    control_pass_o : out std_logic
);
end entity;

architecture Behavioral of hazard_unit is
begin
    hazard: process(rs1_address_id_i, rs2_address_id_i, rs1_in_use_i, rs2_in_use_i, rd_address_ex_i, mem_to_reg_ex_i, rd_we_ex_i, branch_id_i, rd_address_mem_i, mem_to_reg_mem_i) is
    begin
        pc_en_o <= '1';
        if_id_en_o <= '1';
        control_pass_o <= '1';
        if(branch_id_i = '0') then -- LW HAZARD
            if((rs1_address_id_i = rd_address_ex_i and rs1_in_use_i = '1') or (rs2_address_id_i = rd_address_ex_i and rs2_in_use_i = '1')) and (mem_to_reg_ex_i = '1' and rd_we_ex_i = '1') then
                pc_en_o <= '0';
                if_id_en_o <= '0';
                control_pass_o <= '0';
            end if;
        else   --BEQ hazard
            if((rs1_address_id_i = rd_address_ex_i or rs2_address_id_i = rd_address_ex_i) and rd_we_ex_i = '1') then
                pc_en_o <= '0';
                if_id_en_o <= '0';
                control_pass_o <= '0';
            elsif((rs1_address_id_i = rd_address_mem_i or rs2_address_id_i = rd_address_mem_i) and mem_to_reg_mem_i = '1') then
                pc_en_o <= '0';
                if_id_en_o <= '0';
                control_pass_o <= '0';
            end if;
        end if;         
    end process;
end Behavioral;
