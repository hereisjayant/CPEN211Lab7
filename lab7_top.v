
//NOTE: Instance name of your memory is MEM for the auto-grader.

//inputs to mem_cmd for read/write operation
`define MREAD       2'b01
`define MWRITE      2'b10

module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
  input [3:0] KEY;
  input [9:0] SW;
  output [9:0] LEDR;
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

//------------------------------------------------------------------------------

//Wires:

  //from memory
  wire [15:0] dout;

  //CPU
  wire [15:0] read_data; //this goes into the instruction register
  wire [1:0] mem_cmd; //output from FSM
  wire [8:0] mem_addr;  //output from addr_selMux
  wire [15:0] write_data; //datapath_out of the CPU
  wire N, V, Z; //give the value of negative, overflow
                    //and zero status register bits.
                    //w set to 1 if state machine is in the reset state and is waiting for s to be 1

  //Equals Comparators:
  wire equalsMRead;
  wire equalsMWrite;
  wire msel;

  //Memory mapped IO:
  wire switchEnable;
  wire ledEnable;

//------------------------------------------------------------------------------

//Declared modules:

  //CPU
  cpu CPU(.clk        (~KEY[0]),
          .reset      (~KEY[1]),
          .read_data  (read_data),
          .mem_cmd    (mem_cmd),
          .mem_addr   (mem_addr),
          .write_data (write_data),
          .N          (N),
          .V          (V),
          .Z          (Z)    );

  assign HEX5[0] = ~Z;
  assign HEX5[6] = ~N;
  assign HEX5[3] = ~V;


//------------------------------------------------------------------------------
  //Comparator for MREAD
  equals #(2) forMREAD(`MREAD, mem_cmd, equalsMRead);

//------------------------------------------------------------------------------
  //Comparator for MWRITE
  equals #(2) forMWRITE(`MWRITE, mem_cmd, equalsMWrite);

//------------------------------------------------------------------------------
  //Comparator for Msel
  equals #(1) forMsel(1'b0, mem_addr[8:8], msel);

//------------------------------------------------------------------------------

  //RAM (memory)
  RAM MEM(.clk             (~KEY[0]),
          .read_address    (mem_addr),
          .write_address   (mem_addr),
          .write           (equalsMWrite && msel),
          .din             (write_data),
          .dout            (dout)    );

//------------------------------------------------------------------------------

  //triStateBuffer:
  triStateBuffer TriSB_for_Dout(dout, equalsMRead && msel, read_data);

//------------------------------------------------------------------------------

  //Enable for switches:
  enableSwitches enaSW(mem_cmd, mem_addr, switchEnable);

  //Enable for LEDs:
  enableLEDs enaLEDs(mem_cmd, mem_addr, ledEnable);

//------------------------------------------------------------------------------

  //triStateBuffer for Memory mapped IOs:

  //for Switches:
  triStateBuffer tsb_for_switches({8'b0,SW[7:0]}, switchEnable, read_data);

//------------------------------------------------------------------------------

  vDFFE #(8) Register_for_LEDS(~KEY[0], ledEnable, write_data, LEDR[7:0]) ; 

//------------------------------------------------------------------------------

  endmodule


//------------------------------------------------------------------------------

//helper modules:

  module equals(ain, bin, out);
    parameter  k = 1;
    input [k-1:0] ain, bin;
    output out;

    assign out = (ain==bin) ? 1'b1:1'b0;

  endmodule

  module enableSwitches(cmd, address, enable);
    input [1:0] cmd;
    input [8:0] address;
    output enable;

    assign enable = (cmd==`MREAD && address==0'h140) ? 1'b1:1'b0;

  endmodule

  module enableLEDs(cmd, address, enable);
    input [1:0] cmd;
    input [8:0] address;
    output enable;

    assign enable = (cmd==`MWRITE && address==0'h100) ? 1'b1:1'b0;

  endmodule


  module triStateBuffer(in, enable, out);
    parameter k = 16;
    input [k-1:0] in;
    input enable;
    output [k-1:0] out;

    assign out = enable ? in : {k{1'bz}};
  endmodule
