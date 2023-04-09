----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.04.2023 19:24:03
-- Design Name: 
-- Module Name: control_path - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_path is
    port (
    -- sinhronizacija
    clk : in std_logic;
    reset : in std_logic;
    -- instrukcija dolazi iz datapah-a
    instruction_i : in std_logic_vector (31 downto 0);
    -- Statusni signaln iz datapath celine
    branch_condition_i : in std_logic;
    -- kontrolni signali koji se prosledjiuju u datapath
    mem_to_reg_o : out std_logic;
    alu_op_o : out std_logic_vector(4 downto 0);
    alu_src_b_o : out std_logic;
    alu_src_a_o : out std_logic;
    rd_we_o : out std_logic;
    pc_next_sel_o : out std_logic;
    data_mem_we_o : out std_logic_vector(3 downto 0);
    -- kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
    alu_forward_a_o : out std_logic_vector (1 downto 0);
    alu_forward_b_o : out std_logic_vector (1 downto 0);
    branch_forward_a_o : out std_logic; -- mux a
    branch_forward_b_o : out std_logic; -- mux b
    -- kontrolni signal za resetovanje if/id registra
    if_id_flush_o : out std_logic;
    -- kontrolni signali za zaustavljanje protocne obrade
    pc_en_o : out std_logic;
    if_id_en_o : out std_logic
    );
    end entity;    

architecture Behavioral of control_path is
    --signals going into the ID_EX_CTRL_REG
    signal control_pass: std_logic := '0';
    signal rs1_in_use_id, rs2_in_use_id : std_logic := '0';
    signal mem_to_reg_id_s, data_mem_we_id_s, rd_we_id_s, alu_src_b_id_s, alu_src_a_id_s, branch_id_s: std_logic := '0';
    signal alu_2bit_op_id_s : std_logic_vector(1 downto 0) := (others => '0');
    signal funct3_id_s : std_logic_vector(2 downto 0) := (others => '0');
    signal funct7_id_s : std_logic_vector(6 downto 0) := (others => '0');
    signal rd_address_id_s, rs1_address_id_s, rs2_address_id_s : std_logic_vector(4 downto 0) := (others => '0');
    --signals going out of the ID_EX_CTRL_REG register
    signal mem_to_reg_ex_s, data_mem_we_ex_s, rd_we_ex_s, alu_src_b_ex_s, alu_src_a_ex_s: std_logic; --, branch_ex_s: std_logic;
    signal alu_2bit_op_ex_s : std_logic_vector(1 downto 0) := (others => '0');
    signal funct3_ex_s : std_logic_vector(2 downto 0) := (others => '0');
    signal funct7_ex_s : std_logic_vector(6 downto 0) := (others => '0');
    signal rd_address_ex_s, rs1_address_ex_s, rs2_address_ex_s : std_logic_vector(4 downto 0) := (others => '0');
    --signals going out of the EX_MEM_REG register
    signal rd_address_mem_s: std_logic_vector(4 downto 0) := (others => '0');
    signal mem_to_reg_mem_s, data_mem_we_mem_s, rd_we_mem_s: std_logic := '0';
    --sgingal goint out of the MEM_WB_REG register
    signal mem_to_reg_wb_s, rd_we_wb_s: std_logic := '0';
    signal rd_address_wb_s: std_logic_vector(4 downto 0) := (others => '0');
begin
    --LOGIC BEFORE REGISTER ID_EX_CTRL_REG
    funct3_id_s <= instruction_i(14 downto 12);
    funct7_id_s <= instruction_i(31 downto 25);
    rd_address_id_s <= instruction_i(11 downto 7);
    rs1_address_id_s <= instruction_i(19 downto 15);
    rs2_address_id_s <= instruction_i(24 downto 20);

    hazard: entity work.hazard_unit -- HAZARD UNIT
    port map(
        rs1_address_id_i => rs1_address_id_s,
        rs2_address_id_i => rs2_address_id_s,
        rs1_in_use_i => rs1_in_use_id,
        rs2_in_use_i => rs2_in_use_id,
        branch_id_i => branch_id_s,
        rd_address_ex_i => rd_address_ex_s,
        mem_to_reg_ex_i => mem_to_reg_ex_s,
        rd_we_ex_i => rd_we_ex_s,
        rd_address_mem_i => rd_address_mem_s,
        mem_to_reg_mem_i => mem_to_reg_mem_s,
        -- izlazni kontrolni signali
        -- pc_en_o je signal dozvole rada za pc registar
        pc_en_o => pc_en_o,
        -- if_id_en_o je signal dozvole rada za if/id registar
        if_id_en_o => if_id_en_o,
        -- control_pass_o kontrolise da li ce u execute fazu biti prosledjeni
        -- kontrolni signali iz ctrl_decoder-a ili sve nule
        control_pass_o => control_pass
    );

    control_decoder: entity work.ctrl_decoder  -- DECODER
    port map(
        -- opcode instrukcije
        opcode_i => instruction_i(6 downto 0),
        -- kontrolni signali
        branch_o => branch_id_s,
        mem_to_reg_o => mem_to_reg_id_s,
        data_mem_we_o => data_mem_we_id_s, 
        alu_src_b_o => alu_src_b_id_s,
        alu_src_a_o => alu_src_a_id_s,
        rd_we_o => rd_we_id_s,
        rs1_in_use_o => rs1_in_use_id,
        rs2_in_use_o => rs2_in_use_id,
        alu_2bit_op_o => alu_2bit_op_id_s
    );

    branch_and_gate: process(branch_condition_i, branch_id_s) is -- MUX
        begin
            pc_next_sel_o <= branch_condition_i and branch_id_s;
            if_id_flush_o <= branch_condition_i and branch_id_s;
        end process;

    --ID_EX_CTRL_REG
    id_ex_ctrl_reg: process(clk) is
        begin
            if(rising_edge(clk)) then
                if(reset = '1') then
                    if(control_pass = '1') then
                        mem_to_reg_ex_s <= mem_to_reg_id_s;
                        data_mem_we_ex_s <= data_mem_we_id_s;
                        rd_we_ex_s <= rd_we_id_s;
                        alu_src_b_ex_s <= alu_src_b_id_s;
                        alu_src_a_ex_s <= alu_src_a_id_s;
                        alu_2bit_op_ex_s <= alu_2bit_op_id_s;
                        funct3_ex_s <= funct3_id_s;
                        funct7_ex_s <= funct7_id_s;
                        rd_address_ex_s <= rd_address_id_s;
                        rs1_address_ex_s <= rs1_address_id_s;
                        rs2_address_ex_s <= rs2_address_id_s;
                    else
                        mem_to_reg_ex_s <= '0';
                        data_mem_we_ex_s <= '0';
                        rd_we_ex_s <= '0';
                        alu_src_b_ex_s <= '0';
                        alu_src_a_ex_s <= '0';
                        alu_2bit_op_ex_s <= "00";
                        funct3_ex_s <= "000";
                        funct7_ex_s <= "0000000";
                        rd_address_ex_s <= "00000";
                        rs1_address_ex_s <= "00000";
                        rs2_address_ex_s <= "00000";
                    end if;
                else
                    mem_to_reg_ex_s <= '0';
                    data_mem_we_ex_s <= '0';
                    rd_we_ex_s <= '0';
                    alu_src_b_ex_s <= '0';
                    alu_src_a_ex_s <= '0';
                    alu_2bit_op_ex_s <= "00";
                    funct3_ex_s <= "000";
                    funct7_ex_s <= "0000000";
                    rd_address_ex_s <= "00000";
                    rs1_address_ex_s <= "00000";
                    rs2_address_ex_s <= "00000"; 
                end if;         
            end if;
        end process;
    ---
    forwarding: entity work.forwarding_unit 
    port map(
        -- ulazi iz ID faze
        rs1_address_id_i => rs1_address_id_s,
        rs2_address_id_i => rs2_address_id_s,
        -- ulazi iz EX faze
        rs1_address_ex_i => rs1_address_ex_s,
        rs2_address_ex_i => rs2_address_ex_s,
        -- ulazi iz MEM faze
        rd_we_mem_i => rd_we_mem_s,
        rd_address_mem_i => rd_address_mem_s,
        -- ulazi iz WB faze
        rd_we_wb_i => rd_we_wb_s,
        rd_address_wb_i => rd_address_wb_s,
        -- izlazi za prosledjivanje operanada ALU jedinici
        alu_forward_a_o => alu_forward_a_o,
        alu_forward_b_o => alu_forward_b_o,
        -- izlazi za prosledjivanje operanada komparatoru za odredjivanje uslova skoka
        branch_forward_a_o => branch_forward_a_o,
        branch_forward_b_o => branch_forward_b_o
    );

    alu_src_b_o <= alu_src_b_ex_s;
    alu_src_a_o <= alu_src_a_ex_s;

    --ALU DECODER
    alu_dec: entity work.alu_decoder 
    port map(
        --******** Controlpath ulazi *********
        alu_2bit_op_i => alu_2bit_op_ex_s,
        --******** Polja instrukcije *******
        funct3_i => funct3_ex_s,
        funct7_i => funct7_ex_s,
        --******** Datapath izlazi ********
        alu_op_o => alu_op_o
    );

    ex_mem_ctrl_reg: process(clk) is
        begin
            if(rising_edge(clk)) then
                if(reset = '1') then
                    mem_to_reg_mem_s <= mem_to_reg_ex_s;
                    rd_we_mem_s <= rd_we_ex_s;
                    data_mem_we_mem_s <= data_mem_we_ex_s;
                    rd_address_mem_s <= rd_address_ex_s;
                else
                    mem_to_reg_mem_s <= '0';
                    rd_we_mem_s <= '0';
                    data_mem_we_mem_s <= '0';
                    rd_address_mem_s <= "00000";
                end if;
            end if;                  
        end process;
    
    write_mux: process(data_mem_we_mem_s) is
        begin
            if(data_mem_we_mem_s='1') then
                data_mem_we_o<="1111";
            else
                data_mem_we_o<="0000";
            end if;
        end process;
    
    mem_wb_ctrl_reg: process(clk) is
        begin
            if(rising_edge(clk)) then
                if(reset = '1') then
                    mem_to_reg_wb_s <= mem_to_reg_mem_s;
                    rd_we_wb_s <= rd_we_mem_s;
                    rd_address_wb_s <= rd_address_mem_s;
                else
                    mem_to_reg_wb_s <= '0';
                    rd_we_wb_s <= '0';
                    rd_address_wb_s <= "00000";   
                end if;
            end if;             
        end process;
    
    mem_to_reg_o <= mem_to_reg_wb_s;
    rd_we_o <= rd_we_wb_s;
end Behavioral;
