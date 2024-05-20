module tt_um_TD4_Assy_KosugiSubaru (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

wire [7:0] data;
wire [3:0] port_i, port_o, addres, ALU_to_reg, sel_to_ALU, regA_to_sel, regB_to_sel, load, op, im;
wire [1:0] select;
wire carry, cf, co_from_pc;

assign uio_oe [3:0] = 4'b0000;
assign uio_oe [7:4] = 4'b1111;

assign port_i [3:0] = uio_in [3:0];
assign uio_out [7:4] = port_o [3:0];
assign uo_out [3:0] = addres;
assign data [7:0] = ui_in [7:0];
assign op = data[7:4], im = data[3:0];
assign uo_out [4] = cf;

assign uio_out [3:0] = 4'b0000;
assign uo_out [7:5] = 3'b000;

register_ff_4bit reg_A (.in(ALU_to_reg), .out(regA_to_sel), .ld(~load [0]), .clk(clk), .rst(rst_n));
register_ff_4bit reg_B (.in(ALU_to_reg), .out(regB_to_sel), .ld(~load[1]), .clk(clk), .rst(rst_n));
register_ff_4bit OUT   (.in(ALU_to_reg), .out(port_o), .ld(~load [2]), .clk(clk), .rst(rst_n));

ALU_adder_4bit ALU0    (.in_a(sel_to_ALU), .in_b(im), .out(ALU_to_reg), .ci(1'b0), .co(carry));

pc       pc0  (.in(ALU_to_reg), .out(addres), .ld(~load [3]), .clk(clk), .rst(rst_n), .co(co_from_pc));

decoder  dec0 (.op(op), .c_n(~cf), .s(select), .ld_n(load));

selector sel0 (.in_a(regA_to_sel), .in_b(regB_to_sel), .in_c(port_i), .in_d(4'b0000), .s(select), .out(sel_to_ALU));

ff_1bit  cf0  (.in(carry), .out(cf), .clk(clk), .rst(rst_n), .pr(1'b1));

endmodule
