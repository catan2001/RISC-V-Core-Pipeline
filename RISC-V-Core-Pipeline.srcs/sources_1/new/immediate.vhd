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
    type INSTR_FORMAT is (I_TYPE, S_TYPE, B_TYPE, U_TYPE, J_TYPE, OTHERS_TYPE); -- kreiramo tip pomocu koga cemo lakse odredjivati koji je tip
    signal format_type : INSTR_FORMAT := I_TYPE;
    signal temp_extended : std_logic_vector(31 downto 0) := (others => '0');
    signal op_code: std_logic_vector(6 downto 0) := (others => '0'); -- selektujemo prvih 7 bitova instrukcije
begin
    op_code <= instruction_i(6 downto 0);

    formated_type: process(op_code) is
    begin
        case op_code is
            when "0010011" => format_type <= I_TYPE;        
            when "0110111" => format_type <= U_TYPE;        -- ZASTO SAM DODAO LUI? NIJE POTREBNO ali neka stoji
            when "0000011" => format_type <= I_TYPE;
            when "0100011" => format_type <= S_TYPE;        
            when "1100011" => format_type <= B_TYPE;
            when "0010111" => format_type <= U_TYPE;        -- ZA AUIPC INSTRUKCIJU
            when "1101111" => format_type <= J_TYPE;        -- NIJE POTREBNO ali neka stoji
            when others => format_type <= OTHERS_TYPE;      -- MOZDA SREDITI DA NE BUDE OTHERS 
        end case;
    end process;

    immediate_type: process(instruction_i, format_type) is
    begin 
        if(format_type = OTHERS_TYPE) then
            temp_extended <= (others => '0');
        elsif(format_type = I_TYPE) then
            if(instruction_i(31) = '0') then
                temp_extended <= (x"00000" & instruction_i(31 downto 20));
            else
                temp_extended <= (x"fffff" & instruction_i(31 downto 20));
            end if;
        elsif(format_type = S_TYPE) then
            if(instruction_i(31) = '0') then
                temp_extended <= (x"00000" & instruction_i(31 downto 25) & instruction_i(11 downto 7));
            else
                temp_extended <= (x"fffff" & instruction_i(31 downto 25) & instruction_i(11 downto 7));     
            end if;
        elsif(format_type = B_TYPE) then
            if(instruction_i(31) = '0') then
                temp_extended <= (x"00000" & instruction_i(31) & instruction_i(7) & instruction_i(30 downto 25) & instruction_i(11 downto 8));
            else
                temp_extended <= (x"fffff" & instruction_i(31) & instruction_i(7) & instruction_i(30 downto 25) & instruction_i(11 downto 8));    
            end if;     
        elsif(format_type = U_TYPE) then -- KONKATANIRA DONJIH 12 ZA AUIPC
            temp_extended <= (instruction_i(31 downto 12) & x"000");
    --        if(instruction_i(31) = '0') then
    --            temp_extended <= (x"000" & instruction_i(31 downto 12));
    --         else
    --            temp_extended <= (x"fff" & instruction_i(31 downto 12));    
    --        end if; 
        else --(format_type = J_TYPE) then
            if(instruction_i(31) = '0') then
                temp_extended <= (x"000" & instruction_i(31) & instruction_i(21 downto 12) & instruction_i(22) & instruction_i(30 downto 23));
            else
                temp_extended <= (x"fff" & instruction_i(31) & instruction_i(21 downto 12) & instruction_i(22) & instruction_i(30 downto 23));
            end if;
        end if;   
    end process;

    immediate_extended_o <= temp_extended;
end Behavioral;
