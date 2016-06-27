//Subject:     Architecture project 2 - Sign extend
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module Sign_Extend(
    data_i,
    data_o
    );

//I/O ports
input   [16-1:0] data_i;
output  [32-1:0] data_o;

//Internal Signals
reg     [32-1:0] data_o;
reg		[16-1:0] zero = 16'b0;
reg		[16-1:0] one = 16'b1111111111111111;

//Sign extended
always@ (*)begin
	if(data_i[15] == 0)begin
		data_o = {zero, data_i};
	end else begin
		data_o = {one, data_i};
	end
end

endmodule