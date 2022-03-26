`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HIT
// Engineer: Shock_Wang
// 
// Create Date: 2022/03/26 21:18:44
// Design Name: 
// Module Name: �첽FIFO
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


module asyn_fifo#(
	parameter	WIDTH = 8,
	parameter 	DEPTH = 16
)(
	input 					wclk	, 
	input 					rclk	,   
	input 					wrstn	,
	input					rrstn	,
	input 					winc	,
	input 			 		rinc	,
	input 		[WIDTH-1:0]	wdata	,

	output wire				wfull	,
	output wire				rempty	,
	output wire [WIDTH-1:0]	rdata
);


    parameter Addr_Width = $clog2(DEPTH);  //��ַ���
    
    //���ɶ�Ӧ�ĵ�ַ(������)   Ϊ�˵Ȼ���������� ��Ϊ5λ ����λΪ����sram�ĵ�ַ
    reg[Addr_Width : 0] waddr_bin;
    reg[Addr_Width : 0] raddr_bin;
    
    always @(posedge wclk or negedge wrstn) begin
        if(!wrstn)
            waddr_bin <= 'd0;
        else if(winc && !wfull)
            waddr_bin <= waddr_bin + 1'b1;
        else
            waddr_bin <= waddr_bin;
    end
    
    always @(posedge rclk or negedge rrstn) begin
        if(!rrstn)
            raddr_bin <= 'd0;
        else if(rinc && !rempty)
            raddr_bin <= raddr_bin + 1'b1;
        else
            raddr_bin <= raddr_bin;
    end


   //��ַ������ת��Ϊ������
    wire[Addr_Width : 0] waddr_gray;
    wire[Addr_Width : 0] raddr_gray;
    
    assign waddr_gray = waddr_bin ^ (waddr_bin >> 1);  //��������߼����ַ���������ַ�����һλ
    assign raddr_gray = raddr_bin ^ (raddr_bin >> 1);
    
    reg[Addr_Width : 0] wptr;  //дָ��
    reg[Addr_Width : 0] rptr;  //��ָ��
    
    always @(posedge wclk or negedge wrstn) begin  //����ʱ��ȥ�������ص�ַָ��
        if(!wrstn)
            wptr <= 'd0;
        else
            wptr <= waddr_gray;
    end
    
    always @(posedge rclk or negedge rrstn) begin
        if(!rrstn)
            rptr <= 'd0;
        else
            rptr <= raddr_gray;
    end
    
    
    
    //д��ַ�������룩����ͬ������ʱ����    
    reg[Addr_Width : 0] wptr_d0;
    reg[Addr_Width : 0] wptr_d1;
    
    always @(posedge rclk or negedge rrstn) begin
        if(!rrstn) begin
            wptr_d0 <= 'd0;
            wptr_d1 <= 'd0;
        end
        else begin
            wptr_d0 <= wptr;
            wptr_d1 <= wptr_d0;
        end
    end
    
    
    //����ַ�������룩����ͬ����дʱ����
    reg[Addr_Width : 0] rptr_d0;
    reg[Addr_Width : 0] rptr_d1;
    
    always @(posedge wclk or negedge wrstn) begin
        if(!wrstn) begin
            rptr_d0 <= 'd0;
            rptr_d1 <= 'd0;
        end
        else begin
            rptr_d0 <= rptr;
            rptr_d1 <= rptr_d0;
        end
    end


    //����߼��ж�wfull �� rempty
    assign rempty = (rptr == wptr_d1)? 1'b1 : 1'b0;
    assign wfull  = (wptr == {~rptr_d1[Addr_Width : Addr_Width-1] , rptr_d1[Addr_Width-2 : 0]})? 1'b1 : 1'b0;

    
    //����SRAM
    wire wenc;
    wire renc;
    wire[Addr_Width-1 : 0] waddr;   //sram�Ķ�д��ַ����ʵֻ��4λ �޸����� ��Ϊaddr_bin�ĺ���λ
    wire[Addr_Width-1 : 0] raddr;
    
    assign wenc = (winc && !wfull)?  1'b1 : 1'b0;
    assign renc = (rinc && !rempty)? 1'b1 : 1'b0;
    
    assign waddr = waddr_bin[Addr_Width-1 : 0];
    assign raddr = raddr_bin[Addr_Width-1 : 0];
    
    dual_port_RAM  #(.WIDTH(WIDTH),
                     .DEPTH(DEPTH))
                    
                    u_dual_port_RAM(.wclk(wclk),
                                    .wenc(wenc),
                                    .waddr(waddr),
                                    .wdata(wdata),
                                    .rclk(rclk),
                                    .renc(renc),
                                    .raddr(raddr),
                                    .rdata(rdata));

endmodule
