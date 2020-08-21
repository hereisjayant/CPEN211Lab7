//1. each cycle takes a state + one state for "wait"
//2. NOTE: that in your Verilog you need to set all outputs in every state—
//    including those outputs that are zero or for which you don’t care what the value is
//3. Replace readnum and writenum by nsel for the operation

//Observations:
//1. AND and ADD have the same operation for fsm
//2. MOV Rd,Rm{,<sh_op>} and MVN have the same operation for fsm
//3. MOV Rn,#<im8> will have a unique state

//DEFINING STATES:

//0. Wait                                                State: sWait
//1. loading Rm to B is the same for all instructions->  State: sGetB
//2. loading Rn to A is the same for some instructions-> State: sGetA
//3. Computing and saving AND/ADD to reg. C->            State: sAND_ADD
//4. Computing and saving MVN/MOV to reg. C->            State: sMVN_MOV
//5. Getting the status flags:                           State: sGetStatus
//6. Saving result to Rd:                                State: sResultToRd
//7. Moving sximm8 to Rn:                                State: sMovImToRn


module control(   //inputs to fsm
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

                //inputs to fsm
  input clk;
  input reset;
  input s;
  input [2:0] opcode;
  input [1:0] op;
                //input to the first multiplexer b4 regfile
  output [1:0] vsel;
                //input to the REGFILE
  output write;
                //pipeline registers a & b
  output loada;
  output loadb;
                //Select to mux before ALU
  output asel;
  output bsel;
                //pipeline c
  output loadc;
                //status register
  output loads;
                //Use the 1-HOT-select for Rn | Rd | Rm
  output [2:0] nsel;
                //signal for wait state
  output w;

//------------------------------------------------------------------------------

  // state encoding for control FSM //Modified for lab 7
  `define SW          5
  `define sReset      5'b00_000
  `define sIF1        5'b00_001
  `define sIF2        5'b00_010
  `define sUpdatePC   5'b00_011
  `define sDecode     5'b00_100
  `define sGetB       5'b00_101
  `define sGetA       5'b00_110
  `define sAND_ADD    5'b00_111
  `define sMVN_MOV    5'b01_000
  `define sGetStatus  5'b01_001
  `define sResultToRd 5'b01_010
  `define sMovImToRn  5'b01_011

//------------------------------------------------------------------------------

//Wires and Regs
  wire [`SW-1:0] present_state, state_next_reset, state_next;
  reg [(`SW+13)-1:0] nextSignals;

  // state DFF for control FSM
  vDFF #(`SW) STATE(clk,state_next_reset,present_state);

  // Assigns the reset state or next state after checking signal reset
  assign state_next_reset = reset ? `sWait : state_next;

  // combinational logic for control FSM for exponent circuit

       // {state_next, vsel, write,
       //    loada, loadb, asel, bsel,
       //    loadc, loads, nsel, w} = nextSignals

  always @(*)
    casex ( {present_state, s, {opcode, op}} )

    //Wait State                                            //turn the wait signal on
      {`sWait, 1'b0, 5'bx}: nextSignals = {`sWait, 13'b1}; // sWait->sWait as long as s==0
      {`sWait, 1'b1, 5'bx}: nextSignals = {`sDecode, 13'b1}; // sWait->sDecode as s==1

//------------------------------------------------------------------------------

    //Decode State
      //for instruction MOV Rn,#<im8>
      {`sDecode, 1'bx, 5'b110_10}: nextSignals = {`sMovImToRn, 13'b0}; // sDecode->sMovImToRn
      //for other instructions
      {`sDecode, 1'bx, 5'b110_00}: nextSignals = {`sGetB, 13'b0}; // sDecode->sGetB
      {`sDecode, 1'bx, 5'b101_xx}: nextSignals = {`sGetB, 13'b0};


//------------------------------------------------------------------------------

    //MovImToRn State
      {`sMovImToRn, 1'bx, 5'bx}: nextSignals = {`sWait, 2'b10, 1'b1,      // {state_next, vsel, write,
                                                1'b0, 1'b0, 1'b0, 1'b0,   //  loada, loadb, asel, bsel,
                                                1'b0, 1'b0, 3'b100, 1'b0 //    loadc, loads, nsel, w} = nextSignals
                                                }; // sDecode->sGetB

//------------------------------------------------------------------------------

    //GetB State
      //for MOV Rd, Rm
      {`sGetB, 1'bx, 5'b110_00}: nextSignals = {`sMVN_MOV, 2'b00, 1'b0,      // {state_next, vsel, write,
                                                1'b0, 1'b1, 1'b0, 1'b0,   //  loada, loadb, asel, bsel,
                                                1'b0, 1'b0, 3'b001, 1'b0 //    loadc, loads, nsel, w} = nextSignals
                                                };
      //for MVN Rd, Rm
      {`sGetB, 1'bx, 5'b101_11}: nextSignals = {`sMVN_MOV, 2'b00, 1'b0,      // {state_next, vsel, write,
                                                1'b0, 1'b1, 1'b0, 1'b0,   //  loada, loadb, asel, bsel,
                                                1'b0, 1'b0, 3'b001, 1'b0 //    loadc, loads, nsel, w} = nextSignals
                                                };
      //for ADD Rd,Rn Rm and for AND Rd,Rn Rm (Check the x in op)
      {`sGetB, 1'bx, 5'b101_x0}: nextSignals = {`sGetA, 2'b00, 1'b0,      // {state_next, vsel, write,
                                                1'b0, 1'b1, 1'b0, 1'b0,   //  loada, loadb, asel, bsel,
                                                1'b0, 1'b0, 3'b001, 1'b0 //    loadc, loads, nsel, w} = nextSignals
                                                };
      //for CMP Rn, Rm
      {`sGetB, 1'bx, 5'b101_01}: nextSignals = {`sGetA, 2'b00, 1'b0,      // {state_next, vsel, write,
                                                1'b0, 1'b1, 1'b0, 1'b0,   //  loada, loadb, asel, bsel,
                                                1'b0, 1'b0, 3'b001, 1'b0 //    loadc, loads, nsel, w} = nextSignals
                                                };

//------------------------------------------------------------------------------

    //GetA State
     //for ADD Rd,Rn Rm and for AND Rd,Rn Rm (Check the x in op)
     {`sGetA, 1'bx, 5'b101_x0}: nextSignals = {`sAND_ADD, 2'b00, 1'b0,      // {state_next, vsel, write,
                                               1'b1, 1'b0, 1'b0, 1'b0,   //  loada, loadb, asel, bsel,
                                               1'b0, 1'b0, 3'b100, 1'b0 //    loadc, loads, nsel, w} = nextSignals
                                               };
     //for CMP Rn, Rm
     {`sGetA, 1'bx, 5'b101_01}: nextSignals = {`sGetStatus, 2'b00, 1'b0,      // {state_next, vsel, write,
                                               1'b1, 1'b0, 1'b0, 1'b0,   //  loada, loadb, asel, bsel,
                                               1'b0, 1'b0, 3'b100, 1'b0 //    loadc, loads, nsel, w} = nextSignals
                                               };

//------------------------------------------------------------------------------

    //MVN_MOV State (Cycle 2)
     //for MOV Rd, Rm and for MVN Rd, Rm
     {`sMVN_MOV, 1'bx, 5'bx}: nextSignals = {`sResultToRd, 2'b00, 1'b0,      // {state_next, vsel, write,
                                                 1'b0, 1'b0, 1'b1, 1'b0,   //  loada, loadb, asel, bsel,
                                                 1'b1, 1'b0, 3'b000, 1'b0 //    loadc, loads, nsel, w} = nextSignals
                                                 };

//------------------------------------------------------------------------------

    //AND_ADD State
    //for ADD Rd,Rn Rm and for AND Rd,Rn Rm (Check the x in op)
    {`sAND_ADD, 1'bx, 5'bx}: nextSignals = {`sResultToRd, 2'b00, 1'b0,      // {state_next, vsel, write,
                                              1'b0, 1'b0, 1'b0, 1'b0,   //  loada, loadb, asel, bsel,
                                              1'b1, 1'b0, 3'b000, 1'b0 //    loadc, loads, nsel, w} = nextSignals
                                              };

//------------------------------------------------------------------------------

  //GetStatus State
    //for CMP Rn, Rm
    {`sGetStatus, 1'bx, 5'b101_01}: nextSignals = {`sWait, 2'b00, 1'b0,// {state_next, vsel, write,
                                              1'b0, 1'b0, 1'b0, 1'b0,   //  loada, loadb, asel, bsel,
                                              1'b0, 1'b1, 3'b000, 1'b0 //    loadc, loads, nsel, w} = nextSignals
                                              };

//------------------------------------------------------------------------------

  //ResultToRd State
    //all in this state
    {`sResultToRd, 1'bx, 5'bx}: nextSignals = {`sWait, 2'b00, 1'b1,// {state_next, vsel, write,
                                              1'b0, 1'b0, 1'b0, 1'b0,   //  loada, loadb, asel, bsel,
                                              1'b0, 1'b0, 3'b010, 1'b0 //    loadc, loads, nsel, w} = nextSignals
                                              };

//------------------------------------------------------------------------------


      default:     nextSignals = {{`SW{1'bx}},{13{1'bx}}}; // only get here if present_state, s, or zero are x’s
    endcase

  // copy to module outputs
  assign {state_next, vsel, write,
          loada, loadb, asel, bsel,
          loadc, loads, nsel, w} = nextSignals;
endmodule
