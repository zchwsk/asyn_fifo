`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HIT
// Engineer: Shock_Wang
// 
// Create Date: 2022/03/26 21:20:15
// Design Name: 
// Module Name: ˫��RAM��SRAM����ģ��
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dual_port_RAM #(parameter DEPTH = 16,
					   parameter WIDTH = 8)(
	 input wclk
	,input wenc
	,input [$clog2(DEPTH)-1:0] waddr  //��ȶ�2ȡ�������õ���ַ��λ��
	,input [WIDTH-1:0] wdata      	//����д��
	,input rclk
	,input renc
	,input [$clog2(DEPTH)-1:0] raddr  //��ȶ�2ȡ�������õ���ַ��λ��
	,output reg [WIDTH-1:0] rdata 		//�������
);

reg [WIDTH-1:0] RAM_MEM [0:DEPTH-1];

always @(posedge wclk) begin
	if(wenc)
		RAM_MEM[waddr] <= wdata;
end 

always @(posedge rclk) begin
	if(renc)
		rdata <= RAM_MEM[raddr];
end 

endmodule  
