# 实验2：单周期 MIPS 处理器



实验时间：3.22 - 4.21

实验人员：杨乙 21307130076

指导老师：王雪平



## 实验目的

- 熟悉 Vivado 软件
- 熟悉在 Vivado 软件下进行硬件设计的流程
- 设计单周期 MIPS 处理器，包括 
  - 完成单周期 MIPS 处理器的设计
  - 在 Vivado 软件上进行仿真
  - 编写 MIPS 代码验证单周期 MIPS 处理器；
  - 在 NEXYS4 DDR 板上进行验证



## 实验任务



### 1.设计单周期MIPS处理器

- 由于处理器的基本框架及代码和部分指令的控制信号已在参考资料上给出，本报告将重点分析 `andi`、`ori`、`slti`、`bne`、`nop` 指令的扩展。
- 根据参考资料，处理器不判断溢出功能



#### 控制信号

各控制信号的作用及为真条件如下表：

|  控制信号   |                作用                |        为真条件        |
| :---------: | :--------------------------------: | :--------------------: |
|  RegWrite   |            寄存器写使能            |   需要写寄存器的指令   |
|   RegDst    |         选择写入寄存器编号         |        R 型指令        |
|   ALUsrc    |         选择 ALU B 端输入          | lw、sw、立即数运算指令 |
|   Branch    |            分支指令信号            |        分支指令        |
|  MemWrite   |             内存写使能             |        sw 指令         |
|  MemtoReg   |           内存写入寄存器           |         lw指令         |
|    Jump     |            跳转指令信号            |        跳转指令        |
|    ALUOp    |           运算操作控制符           |      选择运算方式      |
|  *ImmExt*   | *选择扩展方式（符号扩展、0 扩展）* |    *ori、andi 指令*    |
| *BranchBne* |           *bne指令信号*            |       *bne 指令*       |



#### ALU 运算功能

ALUControl 值、ALU 运算功能与指令的对应关系如下表：

| ALUControl |        运算功能         |         对应指令         |
| :--------: | :---------------------: | :----------------------: |
|    000     |     Result = X + Y      | **add**   lw   sw   addi |
|    001     |     Result = X - Y      |  **sub**   beq   *bne*   |
|    010     |     Result = X & Y      |     **and**   *andi*     |
|    011     |     Result = X \| Y     |      **or**   *ori*      |
|    100     | Result = (X < Y) ? 1: 0 |     **slt**   *slti*     |
|    101     |            /            |          *nop*           |





#### 指令扩展 - `andi`、`ori` 指令

二者对立即数的扩展方式是 0 扩展，而现有的立即数扩展指令都是符号扩展。因此需要引入控制信号 ImmExt 来选择扩展方式。同时引入二路选择器 extmux，以 signimm（符号扩展立即数）作为输入信号 0，以 zeroimm（0 扩展立即数）作为输入信号 1，以 ImmExt 作为选择信号，将输出信号记为 imm。



datapath 模块修改如下：

```systemverilog
	//......
	signext     se(instr[15:0], signimm);                     
	zeronext    ze(instr[15:0], zeroimm);			      //进行0扩展
	mux2 #(32)  extmux(signimm, zeroimm, ImmExt, imm);	  //二路选择器extmux
	mux2 #(32)  srcbmux(writedata, imm, alusrc, srcb);	  //srcbmux的输入信号1改为imm
```

加入 zeronext 模块：

```systemverilog
module zeronext(
    input  logic [15:0] a,
    output logic [31:0] y );
    
    assign y = {{16'b0}, a};    //进行0扩展
endmodule
```



对于这两条指令，ALU 执行的运算分别与 `and`、`or` 指令相同。为此将二者的 ALUControl 值设置如下（在 aludec 模块中添加如下代码）：

```systemverilog
case (aluop)
    //......
	3'b011: alucontrol <= 3'b011;  //对ori指令，ALU执行or运算
	3'b100: alucontrol <= 3'b010;  //对andi指令，ALU执行and运算
```



二者都需要写寄存器，是立即数运算指令，立即数扩展方式是 0 扩展。控制信号取值如下表：

| 指令 | Opcode | RegWrite | RegDst | ALUSrc | Branch | MemWrite | MemtoReg | ALUOp | Jump | ImmExt | *BranchBne* |
| :--: | :----: | :------: | :----: | :----: | :----: | :------: | :------: | :---: | :--: | :----: | ----------- |
| andi | 001100 |    1     |   0    |   1    |   0    |    0     |    0     |  010  |  0   |   1    | 0           |
| ori  | 001101 |    1     |   0    |   1    |   0    |    0     |    0     |  011  |  0   |   1    | 0           |

在 maindec 模块中添加如下代码：

```systemverilog
//    assign { regwrite, regdst, alusrc, branch,
//             memwrite, memtoreg, aluop, jump, ImmExt, BranchBne } = controls;
	case(op)
        //......
        6'b001000: controls <= 12'b101000_000_0_00;  //addi
        6'b001101: controls <= 12'b101000_011_0_10;  //ori
```





#### 指令扩展 - `slti` 指令

这一指令对立即数的扩展方式是符号扩展，ALU 执行的运算与 `slt` 指令相同。为此将其 ALUControl 值设置如下（在 aludec 模块中添加如下代码）：

```systemverilog
case (aluop)
    //......
	3'b101: alucontrol <= 3'b100;  //slt(for slti)
```



指令需要写寄存器，是立即数运算指令，进行符号扩展，控制信号取值如下表：

| 指令 | Opcode | RegWrite | RegDst | ALUSrc | Branch | MemWrite | MemtoReg | ALUOp | Jump | ImmExt | *BranchBne* |
| :--: | :----: | :------: | :----: | :----: | :----: | :------: | :------: | :---: | :--: | :----: | :---------: |
| slti | 001010 |    1     |   0    |   1    |   0    |    0     |    0     |  101  |  0   |   0    |      0      |

在 maindec 模块中添加如下代码：

```systemverilog
//    assign { regwrite, regdst, alusrc, branch,
//             memwrite, memtoreg, aluop, jump, ImmExt, BranchBne } = controls;
	case(op)
		//......
		6'b001010: controls <= 12'b101000_101_0_00;  //slti
```





#### 指令扩展 - `bne` 指令

`bne` 指令和 `beq` 指令只有转移条件相反这一处不同，因此不必设置新的 ALUControl 值，而是引入控制信号 BranchBne 来指示 `bne` 指令。

和 `beq` 指令一样，对于 `bne` 指令，ALU 执行的运算与 `sub` 指令相同，因此将 `bne` 的 ALUOp 设置为与 `beq` 相同，因此 ALUOp 为 001；控制信号只有 BranchBne 为 1，如下表：

| 指令 | Opcode | RegWrite | RegDst | ALUSrc | Branch | MemWrite | MemtoReg | ALUOp | Jump | ImmExt | *BranchBne* |
| :--: | :----: | :------: | :----: | :----: | :----: | :------: | :------: | :---: | :--: | :----: | :---------: |
| bne  | 000101 |    0     |   0    |   0    |   0    |    0     |    0     |  001  |  0   |   0    |             |

在 maindec 模块中添加如下代码：

```systemverilog
//    assign { regwrite, regdst, alusrc, branch,
//             memwrite, memtoreg, aluop, jump, ImmExt, BranchBne } = controls;
	case(op)
        //......
        6'b000101: controls <= 12'b000000_001_0_01;  //bne
```



`beq` 指令是通过 pcsrc 的值来判断 pcnext 值置为 pcplus4 还是 pcbranch，Branch 信号和 Zero 值都为真时 pcsrc 为真；而 `bne` 指令要实现非 0 跳转，需要进行如下修改（controller 模块）：

```systemverilog
	assign pcsrc = (branch & zero) | ((~zero) & BranchBne); 
```



事实上对于 `bne` 指令扩展，还有如下方案：因为 `beq` 和 `bne` 的 Opcode 仅有末位不同，且二者都是分支指令，因此可将二者的 Branch 信号都设置为 1，对 pcsrc 进行如下修改即可（controller 模块）：

```systemverilog
	assign pcsrc = branch & (zero ^ op[0])	//branch为1、zero与op[0]相异时为真
```

这种做法虽然简单，但因为在 pcsrc 的逻辑表达式中引入 Opcode 值，封装性差，指令不易扩充和维护。





####  指令扩展 - `nop` 指令

`nop` 指令的机器码为全 0，作用是作为流水线填充、使指令按字对齐、产生延迟等。事实上，按照 MIPS 的编码方案，`nop` 指令会被解释为：`sll	$0, $0, 0`，相当于 `sll` 指令作了一次无意义的移位操作。

因为已有指令不包含 `sll` 指令，且由于 `sll` 指令与其他 R 型指令结构不同，对它进行扩充需要取 `instr[10:6]` 的立即数偏移量，并引入新的控制信号，较为繁琐。因此我的做法是在 alu 模块中用空语句代替 `nop` 指令。在 aludec 模块添加如下代码：

```systemverilog
case (aluop)
	//......
    3'b010:
        case(funct)
            //......
            6'b000000: alucontrol <= 3'b101;    //nop(sll)
```

在 alu 模块中添加如下代码：

```systemverilog
case(alucontrol)
	//......
    3'b101: ;	//用空语句代替nop指令的执行
```





至此，单周期 MIPS 处理器已包含了所有要求的指令。原理图如下：

![屏幕截图(593)](D:\Desktop\屏幕截图(593).png)





















## 仿真



#### regFile 模块仿真测试

用给出的测试代码对 regFile 模块进行测试。100ns 时 regWriteData 获得数据 `1234abcd`，110ns 时时钟上升沿到来，RsData 获得数据

![屏幕截图(597)](C:\Users\杨乙\Pictures\Screenshots\屏幕截图(597).png)



#### 指令仿真测试

用给出的测试代码和 memfile.dat 文件进行测试。最后 writedata 值为 7，dataadr 值为 84，仿真波形图与参考资料相同。说明 `lw`、`sw`、`add`、`sub`、`and`、`or`、`slt`、`beq`、`addi`、`j` 指令正常执行

![屏幕截图(598)](C:\Users\杨乙\Pictures\Screenshots\屏幕截图(598).png)



用给出的测试代码和 memfileExt.dat 文件进行测试。最后 writedata 值为 7，dataadr 值为 84，仿真波形图与参考资料相同。说明 `andi`、`ori`、`bne` 指令正常执行

![屏幕截图(599)](C:\Users\杨乙\Pictures\Screenshots\屏幕截图(599).png)



为验证 `slti` 指令和 `nop` 指令，我编写了如下代码：

```
addi	$2, $0, 5		# initialize $2 = 5
slti	$1, $2, 6		# 5 < 6   $1 should be 1
addi	$1, $1, 6		# $1 should be 7
nop						# nop
sw		$1, 84($0)		# write mem[84] = 7
```

指令译码得到 memfile2.dat 文件如下：

```
20020005
28410006
20210006
00000000
ac010054
```

用给出的测试代码和 memfileExt.dat 文件进行测试。最后 writedata 值为 7，dataadr 值为 84，仿真波形图如下：

![屏幕截图(602)](C:\Users\杨乙\Pictures\Screenshots\屏幕截图(602).png)

可以看到，pc = 4 时执行 `slti` 指令，dataadr 值置为 1；pc = 12 时执行 `nop` 指令，writedata 值置 0，dataadr 值置 0；最后 writedata 值为 7，dataadr 值为 84。以上现象说明 `slti` 指令和 `nop` 指令正常执行



















## 验证

我们在这一步加入了 I/O 接口。为了模拟存储器映像的 I/O 接口结构，我们扩充了存储器空间，将 0x80 - 0xFF 作为 I/O 接口空间。根据这种方案，我们可以：

1. 通过 `addr[7]` 的值即可区分存储器空间和 I/O 接口空间
2. 通过 `addr[3:2]` 的值来编码各 I/O 端口地址



### 数据存储译码器模块

将数据存储器、I/O接口、七段数码管三个模块封装为数据存储译码器（dMemoryDecoder），原理图如下：

![屏幕截图(605)](C:\Users\杨乙\Pictures\Screenshots\屏幕截图(605).png)

对 dmem 模块的空间作如下调整：

```
logic [31:0] RAM[255:0]
```

dMemoryDecoder 模块核心代码如下：

```systemverilog
	//addr[7] == 1 说明是IO接口空间

	//从IO读使能
    assign pRead    = (addr[7] == 1'b1) ? 1 : 0;
    
    //向IO写使能
    assign pWrite   = (addr[7] == 1'b1) ? writeEn : 0;
    
    //向数据存储器写使能
    assign we       = (addr[7] == 1'b0) ? writeEn : 0;

    //向MIPS处理器写使能
    assign readData = (addr[7] == 1'b0) ? ReadData1 : ReadData2;
```

以上代码通过 `addr[7]` 的值实现了对存储器空间和 I/O 接口空间读写操作的选择



### I/O 接口模块

I/O 接口模块的代码已经在参考资料上给出，在此仅作简要分析。为了实现 CPU 查询方式 I/O 输入输出，引入状态端口 `status[1:0]`，将 `status[0]` 作为 LED 状态位，将 `status[1]` 作为 switch 状态位，使得可以通过开关 BTNR 和 BTNL 控制开关数据输入和 LED 数据输出。同时，我们通过 `addr[3:2]` 来编码 switch 高 8 位端口、switch 低 8 位端口、LED端口、状态端口的地址，用以向不同的 I/O 端口读写数据



### 7 段数码管模块

7 段数码管模块可设计为 mux7seg 和 Hex7Seg 模块。前者控制各组数码管的分时复用（an值）并传入数据，后者根据传入的数据控制数码管的显示（a2g）值。为了得到正确的仿真结果，在这一步仅需要传入最右侧数码管组的数据，不需要进行分时复用。mux7seg 模块核心代码如下：

```systemverilog
	//仿真用
    assign an = 8'b1111_1110;
    assign digit1 = {1'b0, digit[3:0]};
```

Hex7Seg 模块核心代码如下：

```systemverilog
	//......
	always_comb
        begin
            case(data)
                'h0:  a2g = 7'b1000000;
                //......
                'hF:  a2g = 7'b0001110;
                'h10: a2g = 7'b1110110;		//等号
                default: a2g = 7'b0000000; 
            endcase
        end
```



### 仿真验证

用给出的测试代码和 TestIO.dat 文件进行测试。A2G 值出现了 40（显示 0）到 46（显示 C）的变化，仿真波形图与参考资料相同

![屏幕截图(607)](C:\Users\杨乙\Pictures\Screenshots\屏幕截图(607).png)







## 板上验证

进行板上验证需要添加约束文件，并对 mux7seg 模块进行如下修改，实现各数码管组的分时复用，通过 LED 的频闪和视觉暂留效果来实现数字的显示：

```systemverilog
    assign s = clkdiv[19:17];
     
    always_comb
        begin
            case(s)
                0: digit1 = {1'b0, digit[3:0]};
                //......
                3: digit1 =  5'h10;					//等号
                //......
                7: digit1 = {1'b0, digit[31:28]};
            endcase
        end
            
    always_comb
        case(s)
            0: an = 8'b1111_1110;
            //......
            7: an = 8'b0111_1111;
        endcase
      
    always @(posedge clk, posedge reset)
        if(reset == 1) clkdiv <= 0;
        else           clkdiv <= clkdiv + 1;
```

三组板上验证效果如下（BTNL、BTNC、BTNR 功能正常）：

![aded6964ce184fcc42577c2315506e2](D:\Desktop\aded6964ce184fcc42577c2315506e2.jpg)

![d59110b6b32024eb142db4585491b31](D:\Desktop\d59110b6b32024eb142db4585491b31.jpg)

![44e85b70f15026226f3b3a7b3654f7f](D:\Desktop\44e85b70f15026226f3b3a7b3654f7f.jpg)







## 实验感想

1. 在 CPU 的设计中，对指令的实现不仅要考虑简便性，更需要考虑到后续扩充和维护的兼容性问题。
2. 通过仿真可以很方便地对实现效果进行验证，减小成本，节省时间
3. 封装是贯穿硬件设计（包括软件设计）的核心思想。封装使得项目层次分明，逻辑清晰



