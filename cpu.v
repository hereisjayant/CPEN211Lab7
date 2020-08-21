

module cpu(clk,reset,s,load,in,out,N,V,Z,w);

//I/Os
  input clk;
  input reset, s; //input for FSM

  input load; //load for the instruction register

  input [15:0] in; //this goes into the instruction register
  output [15:0] out; //gives out the contents of register C (component 5)
  output N, V, Z, w; //give the value of negative, overflow
                    //and zero status register bits.
                    //w set to 1 if state machine is in the reset state and is waiting for s to be 1

//------------------------------------------------------------------------------

//Wires

  //Wires to instruction decoder
  wire [15:0] iRegToiDec;
  wire [2:0] nsel; //fsm to IDec

  //Wires to the state machine
  wire [2:0] opcode;
  wire [1:0] op;

  //Wires to the datapath

    //from Instruction decoder
    wire [1:0] ALUop;
    wire [15:0] sximm5;
    wire [15:0] sximm8;
    wire [1:0] shift;
    wire [2:0] readnum;
    wire [2:0] writenum;

    //from the FSM
    wire [1:0] vsel;    //input to the REGFILE
    wire write;
    wire loada;        //pipeline registers a & b
    wire loadb;
    wire asel;        //Select to mux before ALU
    wire bsel;
    wire loadc;        //pipeline c
    wire loads;        //status register






//------------------------------------------------------------------------------

//Declared modules:


  //Instruction Register:
  vDFFE #(16) InstructionReg(clk, load, in, iRegToiDec);

//------------------------------------------------------------------------------

  //InstructionDecoder
 InstructionDecoder InstrDec(iRegToiDec,//Inputs to the Decoder
                              nsel,

                              opcode,//To FSM
                              op,

                              ALUop,//To datapath
                              sximm5,
                              sximm8,
                              shift,
                              readnum,
                              writenum);


//------------------------------------------------------------------------------

  //FSM:
  control FSM(   //inputs to fsm
                clk,
                reset,
                s,
                opcode,
                op,
                    //input to the first multiplexer b4 regfile
                vsel,
                    //input to the REGFILE
                write,
                    //pipeline registers a & b
                loada,
                loadb,
                    //Select to mux before ALU
                asel,
                bsel,
                    //pipeline c
                loadc,
                    //status register
                loads,
                    //Use the 1-HOT select for Rn | Rd | Rm
                nsel,
                    //signal for wait state
                w);


//------------------------------------------------------------------------------

  //NOTE: instantiate Datapath as DP
  //NOTE: when instantiating datapath set PC and mdata to 0
  //Datapath
  datapath DP     (16'b0,  //mdata is the 16-bit output of a memory block (Lab 7)
                  sximm8, //sign ex. lower 8-bits of the instruction register.
                  8'b0,     //“program counter” input lab8

                  vsel, //input to the first multiplexer b4 regfile

                  writenum,  //inputs to register file
                  write,
                  readnum,
                  clk,

                  loada,  //pipeline registers a & b
                  loadb,

                  shift,  //input to shifter unit

                  sximm5, //input for toBin MUX

                  asel,   //source opperand multiplexers
                  bsel,

                  ALUop,  //ALU input

                  loadc,  //pipeline c
                  loads,  //status register

                  {V,N,Z},  //status output
                  out); //datapath output


                  //status output ->                          Z_out[0] = Zero flag(STATUS)
                  //                                   // -> Z_out[1] =negative flag
                  //                                   // -> Z_out[2] = overflow flag




endmodule

//******************************************************************************
