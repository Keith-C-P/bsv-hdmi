#include "Vmktb_tmds.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    Vmktb_tmds *top = new Vmktb_tmds;

    VerilatedVcdC *tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("dump.vcd");

    top->RST_N = 0;
    top->CLK = 0;
    top->eval();

    for (int i = 0; i < 5; i++) {
        top->CLK = !top->CLK;
        top->eval();
    }

    top->RST_N = 1;   // release reset

    for (int i = 0; i < 1000 && !Verilated::gotFinish(); i++) {
        top->CLK = 0;
        top->eval();
        tfp->dump(i * 10);

        top->CLK = 1;
        top->eval();
        tfp->dump(i * 10 + 5);
    }

    top->final();
    tfp->close();
    delete top;
    return 0;
}

