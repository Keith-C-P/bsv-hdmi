#include "VmkHDMI_TB.h"  // Changed from Vmktb_tmds
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    
    VmkHDMI_TB *top = new VmkHDMI_TB;  // Changed
    VerilatedVcdC *tfp = new VerilatedVcdC;
    
    top->trace(tfp, 99);
    tfp->open("dump.vcd");
    
    // No CLK/RST_N - testbench generates its own clocks
    top->eval();

    vluint64_t sim_time = 0;
    for (sim_time = 0; sim_time < 1000000000 && !Verilated::gotFinish(); sim_time++) {
        top->eval();
        tfp->dump(sim_time);
    }
    
    top->final();
    tfp->close();
    delete top;
    return 0;
}
