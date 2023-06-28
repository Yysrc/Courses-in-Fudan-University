`timescale 1ns / 1ps

module maindec( input  logic       clk,
                input  logic       reset,
                input  logic [5:0] op,
                output logic       pcwrite, memwrite, irwrite, regwrite,
                output logic       alusrca, branch, iord, memtoreg, regdst,
                output logic [1:0] alusrcb, pcsrc, 
                output logic [2:0] aluop,
                output logic       branchbne, immext );
    localparam FETCH   = 4'b0000; //state 0
    localparam DECODE  = 4'b0001; //state 1
    localparam MEMADR  = 4'b0010; //state 2
    localparam MEMRD   = 4'b0011; //state 3
    localparam MEMWB   = 4'b0100; //state 4
    localparam MEMWR   = 4'b0101; //state 5
    localparam RTYPEEX = 4'b0110; //state 6
    localparam RTYPEWB = 4'b0111; //state 7
    localparam BEQEX   = 4'b1000; //state 8
    localparam ADDIEX  = 4'b1001; //state 9
    localparam ADDIWB  = 4'b1010; //state 10
    localparam JEX     = 4'b1011; //state 11
    localparam BNEEX   = 4'b1100; //state 12
    localparam ORIEX   = 4'b1101; //state 13
    localparam ANDIEX  = 4'b1110; //state 14
    
    //opcode
    localparam LW      = 6'b100011;
    localparam SW      = 6'b101011;
    localparam RTYPE   = 6'b000000;
    localparam BEQ     = 6'b000100;
    localparam ADDI    = 6'b001000;
    localparam J       = 6'b000010;
    localparam BNE     = 6'b000101;
    localparam ANDI    = 6'b001100;
    localparam ORI     = 6'b001101;
    
    logic [3:0]  state, nextstate;
    logic [17:0] controls;
    
    //state register
    always_ff @(posedge clk or posedge reset)
        if(reset) state <= FETCH;
        else      state <= nextstate;
        
    //next state logic
    always_comb
        case(state)
            FETCH: nextstate = DECODE;
            DECODE:  case(op)
                   LW:      nextstate = MEMADR;
                   SW:      nextstate = MEMADR;
                   RTYPE:   nextstate = RTYPEEX;
                   BEQ:     nextstate = BEQEX;
                   ADDI:    nextstate = ADDIEX;
                   J:       nextstate = JEX;
                   BNE:     nextstate = BNEEX;
                   ORI:     nextstate = ORIEX;
                   ANDI:    nextstate = ANDIEX;
                   default: nextstate = 4'bx;
            endcase
            
            MEMADR:  case(op)
                   LW:      nextstate = MEMRD;
                   SW:      nextstate = MEMWR;
                   default: nextstate = 4'bx;
                endcase
            MEMRD:   nextstate = MEMWB;
            MEMWB:   nextstate = FETCH;
            MEMWR:   nextstate = FETCH;
            RTYPEEX: nextstate = RTYPEWB;
            RTYPEWB: nextstate = FETCH;
            BEQEX:   nextstate = FETCH;
            ADDIEX:  nextstate = ADDIWB;
            ADDIWB:  nextstate = FETCH;
            JEX:     nextstate = FETCH;
            BNEEX:   nextstate = FETCH;
            ANDIEX:  nextstate = ADDIWB;
            ORIEX:   nextstate = ADDIWB;
            default: nextstate = 4'bx;
        endcase
        
        //output logic
        assign { pcwrite, memwrite, irwrite, regwrite,
                 alusrca, branch, iord, memtoreg, regdst,
                 alusrcb, pcsrc, aluop, branchbne, immext } = controls;
        always_comb
            case(state)
                FETCH:    controls = 18'b1010_00000_0100_00000;
                DECODE:   controls = 18'b0000_00000_1100_00000;
                MEMADR:   controls = 18'b0000_10000_1000_00000;
                MEMRD:    controls = 18'b0000_00100_0000_00000;
                MEMWB:    controls = 18'b0001_00010_0000_00000;
                MEMWR:    controls = 18'b0100_00100_0000_00000;
                RTYPEEX:  controls = 18'b0000_10000_0000_01000;
                RTYPEWB:  controls = 18'b0001_00001_0000_00000;
                BEQEX:    controls = 18'b0000_11000_0001_00100;
                ADDIEX:   controls = 18'b0000_10000_1000_00000;
                ADDIWB:   controls = 18'b0001_00000_0000_00000;
                JEX:      controls = 18'b1000_00000_0010_00000;
                BNEEX:    controls = 18'b0000_10000_0001_00110;
                ANDIEX:   controls = 18'b0000_10000_1000_10001;
                ORIEX:    controls = 18'b0000_10000_1000_01101;
                default: controls = 18'bxxxx_xxxxx_xxxx_xxxxx;
            endcase
endmodule