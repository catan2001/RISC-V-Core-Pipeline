----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.04.2023 16:31:02
-- Design Name: 
-- Module Name: data_path - Behavioral
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

entity data_path is
port(
    -- sinhronizacioni signali
    clk : in std_logic;
    reset : in std_logic;
    -- interfejs ka memoriji za instrukcije
    instr_mem_address_o : out std_logic_vector (31 downto 0);
    instr_mem_read_i : in std_logic_vector(31 downto 0);
    instruction_o : out std_logic_vector(31 downto 0);
    -- interfejs ka memoriji za podatke
    data_mem_address_o : out std_logic_vector(31 downto 0);
    data_mem_write_o : out std_logic_vector(31 downto 0);
    data_mem_read_i : in std_logic_vector (31 downto 0);
    -- kontrolni signali
    mem_to_reg_i : in std_logic;
    alu_op_i : in std_logic_vector (4 downto 0);
    alu_src_b_i : in std_logic;
    alu_src_a_i : in std_logic; -- DODANO!
    pc_next_sel_i : in std_logic;
    rd_we_i : in std_logic;
    branch_condition_o : out std_logic; -- IF OPERANDS ARE EQUAL THE OUTPUT OF BRANCH CONDITION IS 1
    -- kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
    alu_forward_a_i : in std_logic_vector (1 downto 0);
    alu_forward_b_i : in std_logic_vector (1 downto 0);
    branch_forward_a_i : in std_logic;
    branch_forward_b_i : in std_logic;
    -- kontrolni signal za resetovanje if/id registra
    if_id_flush_i : in std_logic;
    -- kontrolni signali za zaustavljanje protocne obrade
    pc_en_i : in std_logic;
    if_id_en_i : in std_logic);
end entity;

architecture Behavioral of data_path is
    --INSTRUCTION FETCH
    signal mux_out_pc_if, adder_out_if, pc_out_if: std_logic_vector(31 downto 0) := (others => '0');
    --INSTRUCTION DECODE
    signal if_id_reg_in1, if_id_reg_in2, if_id_reg_in3, if_id_reg_out1, if_id_reg_out2, if_id_reg_out3: std_logic_vector(31 downto 0):= (others => '0');
    signal rs1_address,  rs2_address, rd_address: std_logic_vector(4 downto 0) := (others => '0');
    signal rd_data, rs1_data, rs2_data: std_logic_vector(31 downto 0) := (others => '0');
    signal mux_comp_id1, mux_comp_id2: std_logic_vector(31 downto 0) := (others => '0');
    signal immediate_id, shifter_output_id: std_logic_vector(31 downto 0):= (others => '0');
    --INSTRUCTION EXECUTE
    signal  id_ex_reg_out1, id_ex_reg_out2, id_ex_reg_out3, id_ex_reg_out4, id_ex_reg_out5, id_ex_reg_out6: std_logic_vector(31 downto 0):= (others => '0');
    signal mux_a_ex1, mux_a_ex2, mux_b_ex1, mux_b_ex2: std_logic_vector(31 downto 0) := (others => '0');
    signal alu_result: std_logic_vector(31 downto 0) := (others => '0');
    --MEMORY PHASE
    signal ex_mem_reg_out1, ex_mem_reg_out2, ex_mem_reg_out3: std_logic_vector(31 downto 0) := (others => '0');
    -- WRITE BACK
    signal mem_wb_reg_out1, mem_wb_reg_out2, mem_wb_reg_out3: std_logic_vector(31 downto 0) := (others => '0');
    signal mux_mem_to_reg_wb: std_logic_vector(31 downto 0) := (others => '0');

begin

    --INSTRUCTION FETCH PHASE

    -- Selection Mux for pc_next
    mux_if: process(pc_next_sel_i, adder_out_if, if_id_reg_out3) is
    begin
        if(pc_next_sel_i = '0') then
            mux_out_pc_if <= adder_out_if;
        else
            mux_out_pc_if <= if_id_reg_out3;
        end if;
    end process;

    program_counter: process(clk, pc_en_i) is 
    begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                if(pc_en_i = '1') then
                    pc_out_if <= mux_out_pc_if;
                end if;
            else
                pc_out_if <= (others => '0');
            end if;
        end if;
    end process;

    adder_if: process(pc_out_if) is
    begin
        adder_out_if <= std_logic_vector(unsigned(pc_out_if) + 4);
    end process;

    --instruction memory part
    instr_mem_address_o <= pc_out_if; 
    if_id_reg_in1 <= instr_mem_read_i;

    -- ************** DODAJ OSTALE DIJELOVE!!!!!!!!!! ***********
    -- PROVJERI DA LI TREBA DODATI RESET NA SVAKI REGISTAR DODATNI
    -- PAZI IMAS GRESKU ZA POVRATAK U KOMPARATOR ZBOG PDFA ZA BRANCH FORWARD
    -- dodaj konju i resete na registre isto dodaj na if_ID_REGISTAR instruction_o
    -- SVI RESETI SU NA NULI
    -- NAVODNO TRECI SIGNAL U IF_ID TREBA DA ZAPRAVO ZAOBIDJE REGISTAR
    if_id_reg: process(clk) is -- IF_ID_REGISTER
    begin
        if(rising_edge(clk)) then
            if(if_id_en_i = '1') then
                if(if_id_flush_i = '1') then
                    if_id_reg_out1 <= (others => '0');
                    if_id_reg_out2 <= (others => '0');
                    if_id_reg_out3 <= (others => '0');
                else
                    if_id_reg_out1 <= if_id_reg_in1;
                    if_id_reg_out2 <= if_id_reg_in2;
                    if_id_reg_out3 <= if_id_reg_in3;
                end if;
            end if;                 
        end if;
    end process;

    --Instruction decode part

    rs1_address <= if_id_reg_out1(19 downto 15);    -- IDE DALJE U BANKU
    rs2_address <= if_id_reg_out1(24 downto 20);    --IDE DALJE U BANKU
    --rd_address <= if_id_reg_out1(11 downto 7); -- IDE DALJE U REG

    register_bank: entity work.register_bank -- Register Bank 
        port map(
        clk => clk,
        reset => reset,
        rs1_address_i => rs1_address,
        rs1_data_o  => rs1_data,
            -- Interfejs 2 za citanje podataka
        rs2_address_i => rs2_address,
        rs2_data_o => rs2_data,
            -- Interfejs za upis podataka
        rd_we_i => rd_we_i,
        rd_address_i => rd_address,
        rd_data_i => rd_data    
        );
        
    rd_data <= mux_mem_to_reg_wb; -- FOR EASE OF USE
    rd_address <= mem_wb_reg_out3(11 downto 7);
    -- ISPOD JE GRESKA I TREBA DA ISPRAVIS
    mux_comp1: process(branch_forward_a_i, rs1_data, mux_mem_to_reg_wb) -- MUX that goes into comparator as a branch condition
    begin
        if(branch_forward_a_i = '0') then
            mux_comp_id1 <= rs1_data;
        else
            mux_comp_id1 <= mux_mem_to_reg_wb;
        end if;
    end process;

    mux_comp2: process(branch_forward_b_i, rs2_data, mux_mem_to_reg_wb)-- MUX that goes into comparator as a branch condition
    begin
        if(branch_forward_b_i = '0') then
            mux_comp_id2 <= rs2_data;
        else
            mux_comp_id2 <= mux_mem_to_reg_wb;
        end if;
    end process;

    comparator: process(mux_comp_id1, mux_comp_id2) is
    begin
        if(unsigned(mux_comp_id1) = unsigned(mux_comp_id2)) then
            branch_condition_o <= '1';
        else
            branch_condition_o <= '0';
        end if;
    end process;

    immediate: entity work.immediate -- IMMEDIATE LOGIC
        port map(
        instruction_i => if_id_reg_out1,
        immediate_extended_o => immediate_id
        );

    shifter: process(immediate_id) is
    begin
        shifter_output_id <= immediate_id(30 downto 0)&'0';
    end process;

    adder: process(if_id_reg_in2, shifter_output_id) is
    begin
        if_id_reg_in3 <= std_logic_vector(unsigned(if_id_reg_in2) + unsigned(shifter_output_id));
    end process;

    id_ex_reg: process(clk) is
    begin
        if(rising_edge(clk)) then
            id_ex_reg_out1 <= rs1_data;
            id_ex_reg_out2 <= rs2_data;
            id_ex_reg_out3 <= immediate_id;
            id_ex_reg_out4 <= rs2_data; -- NE MORA DVA VALJDA MOZE SAMO JEDAN?
            id_ex_reg_out5 <= if_id_reg_out1;
            id_ex_reg_out6 <= if_id_reg_out2;
        end if;
    end process;
    -- EXECUTE PHASE
    --mux_a_ex1, mux_a_ex2, mux_b_ex1, mux_b_ex2:

    mux_a1: process(alu_forward_a_i, id_ex_reg_out1, mux_mem_to_reg_wb, ex_mem_reg_out1) is
    begin
        if(alu_forward_a_i = "00") then
            mux_a_ex1 <= id_ex_reg_out1;
        elsif(alu_forward_a_i = "01") then
            mux_a_ex1 <= mux_mem_to_reg_wb;
        elsif(alu_forward_a_i = "10") then
            mux_a_ex1 <= ex_mem_reg_out1;
        else
            mux_a_ex1 <= (others => '0');
        end if;
    end process;

    mux_b1: process(alu_forward_b_i, id_ex_reg_out2, mux_mem_to_reg_wb, ex_mem_reg_out1) is
    begin
        if(alu_forward_b_i = "00") then
            mux_b_ex1 <= id_ex_reg_out2;
        elsif(alu_forward_b_i = "01") then
            mux_b_ex1 <= mux_mem_to_reg_wb;
        elsif(alu_forward_b_i = "10") then
            mux_b_ex1 <= ex_mem_reg_out1;
        else
            mux_b_ex1 <= (others => '0');
        end if;
    end process;

    mux_a2: process(alu_src_a_i, mux_a_ex1, id_ex_reg_out6) is
    begin
        if(alu_src_a_i = '0') then
            mux_a_ex2 <= mux_a_ex1;
        else
            mux_a_ex2 <= id_ex_reg_out6;
        end if;
    end process;

    mux_b2: process(alu_src_b_i, mux_b_ex1, id_ex_reg_out3) is
    begin
        if(alu_src_b_i = '0') then
            mux_b_ex2 <= mux_b_ex1;
        else
            mux_b_ex2 <= id_ex_reg_out3;
        end if;
    end process;

    alu_unit: entity work.ALU
        port map(
        a_i => mux_a_ex2,
        b_i => mux_b_ex2,
        op_i => alu_op_i,
        res_o => alu_result
        );

    ex_mem_reg: process(clk) is
    begin
        if(rising_edge(clk)) then
            ex_mem_reg_out1 <= alu_result;
            ex_mem_reg_out2 <= id_ex_reg_out4;
            ex_mem_reg_out3 <= id_ex_reg_out5;
        end if;    
    end process;

    --MEMORY PHASE

    data_mem_address_o <= ex_mem_reg_out1;
    data_mem_write_o <= ex_mem_reg_out2;

    -- WRITE BACK PHASE

    mem_wb_reg: process(clk) is
    begin   
        if(rising_edge(clk)) then
            mem_wb_reg_out1 <= ex_mem_reg_out1;
            mem_wb_reg_out2 <= data_mem_read_i;
            mem_wb_reg_out3 <= ex_mem_reg_out3;
        end if;
    end process;

    mux_mem_wb: process(mem_to_reg_i, mem_wb_reg_out1, mem_wb_reg_out2) is
    begin
        if(mem_to_reg_i = '1') then
            mux_mem_to_reg_wb <= mem_wb_reg_out2;
        else
            mux_mem_to_reg_wb <= mem_wb_reg_out1;
        end if;
    end process;
    --updated
end Behavioral;




