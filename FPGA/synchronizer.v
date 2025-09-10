module synchronizer
(
    input wire clk,
    input wire rst,

    input wire data,
    output reg sync_data
);



always @(posedge clk or negedge rst) begin
    if (!rst) begin
        sync_data <= 1'b0;
    end
    else begin
        
    end
end

endmodule