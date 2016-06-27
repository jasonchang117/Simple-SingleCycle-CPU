`timescale 1ns / 1ps
//Subject:     Architecture project 2 - Simple Single CPU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: Structure for R-type
//--------------------------------------------------------------------------------
module Simple_Single_CPU(
    clk_i,
	rst_i
);
		
//I/O port
input         clk_i;
input         rst_i;

//Internal Signals
wire [32-1:0] mux_dataMem_result_w, ext_data, sum_to_mux;
wire ctrl_register_write_w, Branch, RegDst, MemRead, MemtoReg, MemWrite, ALUSrc , zero;
wire [32-1:0] add_pc, pc_out, instr, ReadData_one, ReadData_two, mux_ReadData, ALUResult, memory_ReadData, left_ext_data, PC_return;
wire [3-1:0] ALUOp;
wire [4-1:0] ALUCtrl;
wire [5-1:0] mux_RDinstr;
wire PCSrc;

//Create components
ProgramCounter PC(
        .clk_i(clk_i),      
	    .rst_i (rst_i),     
	    .pc_in_i(PC_return),   
	    .pc_out_o(pc_out) 
	    );
	
Adder Adder1(
        .src1_i(pc_out),     
	    .src2_i(4),
	    .sum_o(add_pc)
	    );
	
Instr_Memory IM(
        .pc_addr_i(pc_out),  
	    .instr_o(instr)
	    );

MUX_2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(instr[20:16]),
        .data1_i(instr[15:11]),
        .select_i(RegDst),
        .data_o(mux_RDinstr)
        );	

//DO NOT MODIFY	.RDdata_i && .RegWrite_i
Reg_File RF(
        .clk_i(clk_i),
		.rst_i(rst_i),
		.RSaddr_i(instr[25:21]) ,
		.RTaddr_i(instr[20:16]) ,
		.RDaddr_i(mux_RDinstr) ,
		.RDdata_i(mux_dataMem_result_w[31:0]),
		.RegWrite_i(ctrl_register_write_w),
		.RSdata_o(ReadData_one) ,
		.RTdata_o(ReadData_two)
        );
	
//DO NOT MODIFY	.RegWrite_o
Decoder Decoder(
        .instr_op_i(instr[31:26]), 
	    .RegWrite_o(ctrl_register_write_w), 
	    .ALU_op_o(ALUOp),   
	    .ALUSrc_o(ALUSrc),   
	    .RegDst_o(RegDst),   
		.Branch_o(Branch), 
		.MemWrite_o(MemWrite),
		.MemRead_o(MemRead),
		.MemtoReg_o(MemtoReg)
	    );

ALU_Ctrl AC(
        .funct_i(instr[5:0]),   
        .ALUOp_i(ALUOp),   
        .ALUCtrl_o(ALUCtrl) 
        );
	
Sign_Extend SE(
        .data_i(instr[15:0]),
        .data_o(ext_data)
        );

MUX_2to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(ReadData_two),
        .data1_i(ext_data),
        .select_i(ALUSrc),
        .data_o(mux_ReadData)
        );
		
ALU ALU(
        .src1_i(ReadData_one),
	    .src2_i(mux_ReadData),
	    .ctrl_i(ALUCtrl),
	    .result_o(ALUResult),
		.zero_o(zero)
	    );
		
Adder Adder2(
        .src1_i(add_pc),
	    .src2_i(left_ext_data),
	    .sum_o(sum_to_mux)
	    );
		
Shift_Left_Two_32 Shifter(
        .data_i(ext_data),
        .data_o(left_ext_data)
        ); 		
		
MUX_2to1 #(.size(32)) Mux_PC_Source(
        .data0_i(add_pc),
        .data1_i(sum_to_mux),
        .select_i(PCSrc),
        .data_o(PC_return)
        );	
		
Data_Memory DataMemory(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.addr_i(ALUResult),
		.data_i(ReadData_two),
		.MemRead_i(MemRead),
		.MemWrite_i(MemWrite),
		.data_o(memory_ReadData)
		);

//DO NOT MODIFY	.data_o
MUX_2to1 #(.size(32)) Mux_DataMem_Read(
        .data0_i(ALUResult),
        .data1_i(memory_ReadData),
        .select_i(MemtoReg),
        .data_o(mux_dataMem_result_w)
		);

assign PCSrc = Branch & zero;
		
endmodule