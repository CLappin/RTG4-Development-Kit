module COREJTAGDEBUG (
    // JTAG tap Inputs
    TDI,
    TCK,
    TMS,
    TRSTB,
    
    // Target inputs
    TGT_TDO,
    
    // JTAG tap outputs
    TDO,

    // Target Outputs
    TGT_TCK,
    TGT_TRST,
    TGT_TMS,
    TGT_TDI
);
////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////
parameter [7:0] IR_CODE = 8'h55;

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
// JTAG tap Inputs
input       TDI;
input       TCK;
input       TMS;
input       TRSTB;

// Target inputs
inout       TGT_TDO;

// JTAG tap outputs
output      TDO;

// Target Outputs
output      TGT_TCK;
output      TGT_TRST;
output      TGT_TMS;
output      TGT_TDI;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
wire        UTDO;
wire        UDRCAP;
wire        UDRSH;
wire        UDRUPD;
wire [7:0]  UIREG;
wire        URSTB;
wire        UDRCK;
wire        UTDI;
wire        UTDO_0;
wire        UTDODRV_0;
wire        TGT_TRSTB;
wire        iTGT_TCK;

////////////////////////////////////////////////////////////////////////////////
// UJTAG:  Macro which converts from Physical JTAG ports to an intermediate
// representation
////////////////////////////////////////////////////////////////////////////////
UJTAG UJTAG_0(
    // Inputs
    .UTDO               (UTDO),
    .TDI                (TDI),
    .TMS                (TMS),
    .TCK                (TCK),
    .TRSTB              (TRSTB),
    // Outputs
    .UDRCAP             (UDRCAP),
    .UDRSH              (UDRSH),
    .UDRUPD             (UDRUPD),
    .UIREG              (UIREG[7:0]),
    .URSTB              (URSTB),
    .UDRCK              (UDRCK),
    .UTDI               (UTDI),
    .TDO                (TDO) 
);

assign UTDO     = UTDO_0 & UTDODRV_0;
assign TGT_TRST = ~TGT_TRSTB;

////////////////////////////////////////////////////////////////////////////////
// uj jtag instantiation
////////////////////////////////////////////////////////////////////////////////
uj_jtag #(
    .uj_jtag_ircode     (IR_CODE)
) UJ_JTAG_0(
    // UJTAG port (to I/O)
    .uireg              (UIREG[7:0]),
    .urstb              (URSTB),
    .udrupd             (UDRUPD),
    .udrck              (UDRCK),
    .udrcap             (UDRCAP),
    .udrsh              (UDRSH),
    .utdi               (UTDI),
    .utdo               (UTDO_0),
    .utdodrv            (UTDODRV_0),
    
    // JTAG port (to DUT)
    .dutntrst           (TGT_TRSTB),
    .duttck             (iTGT_TCK), 
    .duttms             (TGT_TMS), 
    .duttdi             (TGT_TDI),
    .duttdo             (TGT_TDO),
    
    // gpio output port
    .gpout              (),
    .gpin               (4'b0)
);
        
////////////////////////////////////////////////////////////////////////////////
// CLKINT macro instantiation
////////////////////////////////////////////////////////////////////////////////
CLKINT coretck_clkint(
    .A                  (iTGT_TCK),
    .Y                  (TGT_TCK)
);

endmodule //COREJTAGDEBUG