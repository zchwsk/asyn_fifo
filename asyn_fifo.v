`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HIT
// Engineer: Shock_Wang
// 
// Create Date: 2022/03/26 21:18:44
// Design Name: 
// Module Name: 异步FIFO
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


    parameter Addr_Width = $clog2(DEPTH);  //地址宽度
    
    //生成对应的地址(二进制)   为了等会满足格雷码 设为5位 后四位为放入sram的地址
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


   //地址二进制转化为格雷码
    wire[Addr_Width : 0] waddr_gray;
    wire[Addr_Width : 0] raddr_gray;
    
    assign waddr_gray = waddr_bin ^ (waddr_bin >> 1);  //采用组合逻辑，字符自身异或字符右移一位
    assign raddr_gray = raddr_bin ^ (raddr_bin >> 1);
    
    reg[Addr_Width : 0] wptr;  //写指针
    reg[Addr_Width : 0] rptr;  //读指针
    
    always @(posedge wclk or negedge wrstn) begin  //本地时钟去采样本地地址指针
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
    
    
    
    //写地址（格雷码）二级同步到读时钟域    
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
    
    
    //读地址（格雷码）二级同步到写时钟域
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


    //组合逻辑判断wfull 、 rempty
    assign rempty = (rptr == wptr_d1)? 1'b1 : 1'b0;
    assign wfull  = (wptr == {~rptr_d1[Addr_Width : Addr_Width-1] , rptr_d1[Addr_Width-2 : 0]})? 1'b1 : 1'b0;

    
    //例化SRAM
    wire wenc;
    wire renc;
    wire[Addr_Width-1 : 0] waddr;   //sram的读写地址，其实只有4位 无格雷码 且为addr_bin的后四位
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
