module maindec(input  logic [5:0] op,
               output logic       memtoreg, memwrite,
               output logic       branch, alusrc,
               output logic       regdst, regwrite,
               output logic [2:0] aluop,
               output logic       jump,
               output logic       ImmExt,
               output logic       BranchBne );
               
    logic [11:0] controls;
    
    assign { regwrite, regdst, alusrc, branch,
             memwrite, memtoreg, aluop, jump, ImmExt, BranchBne } = controls;

    always_comb
        case(op)
            6'b000000: controls <= 12'b110000_010_0_00;  //RTYPE
            6'b100011: controls <= 12'b101001_000_0_00;  //LW
            6'b101011: controls <= 12'b0x101x_000_0_00;  //SW
            6'b000100: controls <= 12'b0x010x_001_0_00;  //BEQ
            6'b001000: controls <= 12'b101000_000_0_00;  //ADDI
            6'b000010: controls <= 12'b0xxx0x_xxx_1_00;  //J
            6'b000101: controls <= 12'b000000_001_0_01;  //BNE
            6'b001101: controls <= 12'b101000_011_0_10;  //ORI
            6'b001100: controls <= 12'b101000_100_0_10;  //ANDI
            6'b001010: controls <= 12'b101000_101_0_10;  //SLTI
          
            default:   controls <= 12'bxxxxxx_xxx_x_x;  //illegal op
        endcase
    
endmodule
