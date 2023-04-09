library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ctrl_decoder is
port (
-- opcode instrukcije
opcode_i : in std_logic_vector (6 downto 0); -- opcode of instruction fetched into ctrl_decoder
-- kontrolni signali
branch_o : out std_logic; -- If instruction is of B type, in other words BEQ then it's output is = '1' 
mem_to_reg_o : out std_logic; -- choses if the output from MEM_WB_RG that goes back to register, should be from ALU or memmory 
data_mem_we_o : out std_logic; -- enables writing the data to memory 
alu_src_b_o : out std_logic; -- choses if the ALU is calculating second data or the immediate value as an operand
alu_src_a_o : out std_logic; -- ADDED FOR AUIPC INSTRUCTION SO THE ALU CHOSES BETWEEN THE PC AND a OPERAND
rd_we_o : out std_logic; -- enables data to be written to register bank
rs1_in_use_o : out std_logic; -- Checks if the instruction uses source register(for Hazard UNIT)
rs2_in_use_o : out std_logic; -- Checks if the instruction uses source register(for Hazard UNIT)
alu_2bit_op_o : out std_logic_vector(1 downto 0) -- outputs the alu_2bit_op for alu_decoder depending on the operation needed
);
end entity;

--POTREBNO DODATNO IMPLEMENTOVATI ZA AUIPC INSTRUKCIJU MYB?
    -- 0010111  AUIPC       U-Type
    -- 1100011  BEQ         B-Type
    -- 0000011  LW          I-Type
    -- 0100011  SW          S-Type
    -- 0010011  ADDI        I-Type
    -- 0110011  ADD         R-Type
    --          OR          same
    --          AND         same
    --          SUB         same
    
architecture Behavioral of ctrl_decoder is
begin
    process(opcode_i) is
    begin
        case opcode_i is    -- STAVI IF A NE CASE ZBOG NPR NOP INSTRUKCIJE
        when "0110011" =>   branch_o <= '0';        -- R
                            mem_to_reg_o <= '0';    -- sends back to reg_bank from EX_MEM_REG(ALU) not from MEM
                            data_mem_we_o <= '0';   -- disables writing data
                            alu_src_b_o <= '0';     -- choses second operand to be data from register and not from immediate
                            alu_src_a_o <= '0';
                            rd_we_o <= '1';          -- enables writing output to register bank
                            rs1_in_use_o <= '1';    -- PROVJERI **
                            rs2_in_use_o <= '1';    -- PROVJERI **
                            alu_2bit_op_o <= "10";
                            
        when "0010011" =>   branch_o <= '0';        -- ADDI
                            mem_to_reg_o <= '0';    -- sends back to reg_bank from EX_MEM_REG(ALU) not from MEM
                            data_mem_we_o <= '0';   -- disables writing data
                            alu_src_b_o <= '1';     -- choses second operand to be data from register and not from immediate
                            alu_src_a_o <= '0';
                            rd_we_o <= '1';          -- enables writing output to register bank
                            rs1_in_use_o <= '1';    -- PROVJERI **
                            rs2_in_use_o <= '0';    -- PROVJERI **
                            alu_2bit_op_o <= "00";  -- DA LI OVO TREBA OVAKO NEMA LOGIKE! ZAR NE 00 a ne 11
                            
        when "0100011" =>   branch_o <= '0';        -- SW
                            mem_to_reg_o <= '0';    -- sends back to reg_bank from EX_MEM_REG(ALU) not from MEM
                            data_mem_we_o <= '1';   -- enables writing data
                            alu_src_b_o <= '1';     -- choses second operand to be data from register and not from immediate
                            alu_src_a_o <= '0';
                            rd_we_o <= '0';         -- enables writing output to register bank
                            rs1_in_use_o <= '1';    -- PROVJERI **
                            rs2_in_use_o <= '1';    -- PROVJERI **
                            alu_2bit_op_o <= "00";  
                            
        when "0000011" =>   branch_o <= '0';        -- LW
                            mem_to_reg_o <= '1';    -- sends back to reg_bank from EX_MEM_REG(ALU) not from MEM
                            data_mem_we_o <= '0';   -- disables writing data
                            alu_src_b_o <= '1';     -- choses second operand to be data from register and not from immediate
                            alu_src_a_o <= '0';
                            rd_we_o <= '1';          -- enables writing output to register bank
                            rs1_in_use_o <= '1';    -- PROVJERI **
                            rs2_in_use_o <= '0';    -- PROVJERI **
                            alu_2bit_op_o <= "00";                        
                            
        when "1100011" =>   branch_o <= '1';        -- BEQ
                            mem_to_reg_o <= '0';    -- sends back to reg_bank from EX_MEM_REG(ALU) not from MEM
                            data_mem_we_o <= '0';   -- disables writing data
                            alu_src_b_o <= '0';     -- choses second operand to be data from register and not from immediate
                            alu_src_a_o <= '0';
                            rd_we_o <= '0';          -- enables writing output to register bank
                            rs1_in_use_o <= '1';    -- PROVJERI **
                            rs2_in_use_o <= '1';    -- PROVJERI **
                            alu_2bit_op_o <= "01";  -- ODUZIMANJE?     

        when "0010111" =>   branch_o <= '0';        -- AUIPC
                            mem_to_reg_o <= '0';    -- sends back to reg_bank from EX_MEM_REG(ALU) not from MEM
                            data_mem_we_o <= '0';   -- disables writing data
                            alu_src_b_o <= '1';     
                            alu_src_a_o <= '1';
                            rd_we_o <= '0';          -- enables writing output to register bank
                            rs1_in_use_o <= '0';    -- PROVJERI **
                            rs2_in_use_o <= '0';    -- PROVJERI **                       
                            alu_2bit_op_o <= "00";   -- PROVJERI ZA AUIPC
                            
        when others =>      branch_o <= '0'; 
                            mem_to_reg_o <= '0';    -- sends back to reg_bank from EX_MEM_REG(ALU) not from MEM
                            data_mem_we_o <= '0';   -- disables writing data
                            alu_src_b_o <= '0';     -- choses second operand to be data from register and not from immediate
                            alu_src_a_o <= '0';
                            rd_we_o <= '0';          -- enables writing output to register bank
                            rs1_in_use_o <= '0';    -- PROVJERI **
                            rs2_in_use_o <= '0';    -- PROVJERI **
                            alu_2bit_op_o <= "00";   
        end case;                                                                                                                                                                 
    end process;
end Behavioral;
