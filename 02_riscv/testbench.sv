module testbench;

    // Тактовый сигнал и сигнал сброса
    logic clk;
    logic aresetn;

    // Остальные сигналы
    logic [31:0] instr;
    logic [31:0] i_imm;
    logic [31:0] s_imm;
    logic [31:0] b_imm;
    logic [31:0] u_imm;
    logic [31:0] j_imm;

    riscv_imm_gen DUT (
        .clk     ( clk     ),
        .aresetn ( aresetn ),
        .instr   ( instr   ),
        .i_imm   ( i_imm   ),
        .s_imm   ( s_imm   ),
        .b_imm   ( b_imm   ),
        .u_imm   ( u_imm   ),
        .j_imm   ( j_imm   )
    );

    `ifdef __ICARUS__
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end
    `endif

    // TODO:
    // Определите период тактового сигнала
    parameter CLK_PERIOD = 10;

    // TODO:
    // Cгенерируйте тактовый сигнал
    initial begin
        clk <= 0;
        forever begin
            #(CLK_PERIOD/2) clk <= ~clk;
        end
    end
    
    // Генерация сигнала сброса
    initial begin
        aresetn <= 0;
        #(CLK_PERIOD);
        aresetn <= 1;
    end

    // TODO:
    // Сгенерируйте входные сигналы
    // Не забудьте про ожидание сигнала сброса!
    initial begin
        wait(aresetn);
        repeat(8) begin
            @(posedge clk);
            instr <= $urandom_range(0, $pow(2, 32)-1);
        end

        @(posedge clk);
        @(posedge clk);
        $stop;
    end

    // Пользуйтесь этой структурой
    `ifdef __ICARUS__
    typedef struct packed {
    `else
    typedef struct {
    `endif
        logic [31:0] instr;
        logic [31:0] i_imm;
        logic [31:0] s_imm;
        logic [31:0] b_imm;
        logic [31:0] u_imm;
        logic [31:0] j_imm;
    } packet;

    `ifdef __ICARUS__
        event e1;
        event e2;
    `else
        mailbox#(packet) mon2chk = new();
    `endif
    // TODO:
    // Сохраняйте сигналы каждый положительный
    // фронт тактового сигнала
    
    `ifdef __ICARUS__
        packet pkt;
    `endif

    initial begin
        `ifndef __ICARUS__
            packet pkt;
        `endif
        wait(aresetn);
        forever begin
            @(posedge clk);
            // Пишите здесь.
            pkt.i_imm = i_imm;
            pkt.s_imm = s_imm;
            pkt.b_imm = b_imm;
            pkt.u_imm = u_imm;
            pkt.j_imm = j_imm;
            `ifdef __ICARUS__
                ->e1;
                @(e2);
                pkt.instr = instr;
            `else
                pkt.instr = instr;
                mon2chk.put(pkt);
            `endif
        end
    end

    // TODO:
    // Выполните проверку выходных сигналов.
    initial begin
        `ifndef __ICARUS__
            packet pkt_prev, pkt_cur;
        `endif
        wait(aresetn);
        `ifndef __ICARUS__
            mon2chk.get(pkt_prev);
        `endif
        forever begin
            // Пишите здесь.
            `ifndef __ICARUS__
                mon2chk.get(pkt_cur);
                     if ( pkt_cur.i_imm != {{21{pkt_prev.instr[31]}}, pkt_prev.instr[30:25], pkt_prev.instr[24:21], pkt_prev.instr[   20]} )
                $error("BAD i_imm");
                else if ( pkt_cur.s_imm != {{21{pkt_prev.instr[31]}}, pkt_prev.instr[30:25], pkt_prev.instr[11: 8], pkt_prev.instr[    7]} )
                $error("BAD s_imm");
                else if ( pkt_cur.b_imm != {{20{pkt_prev.instr[31]}}, pkt_prev.instr[    7], pkt_prev.instr[30:25], pkt_prev.instr[11: 8], 1'b0} )
                $error("BAD b_imm");
                else if ( pkt_cur.u_imm != {    pkt_prev.instr[31]  , pkt_prev.instr[30:20], pkt_prev.instr[19:12], 12'b0} )
                $error("BAD u_imm");
                else if ( pkt_cur.j_imm != {{12{pkt_prev.instr[31]}}, pkt_prev.instr[19:12], pkt_prev.instr[   20], pkt_prev.instr[30:25], pkt_prev.instr[24:21], 1'b0} )
                $error("BAD j_imm");

                pkt_prev = pkt_cur;
            
            `else
                @(e1);
                     if ( i_imm != {{21{pkt.instr[31]}}, pkt.instr[30:25], pkt.instr[24:21], pkt.instr[   20]} )
                    $error("BAD i_imm");
                else if ( s_imm != {{21{pkt.instr[31]}}, pkt.instr[30:25], pkt.instr[11: 8], pkt.instr[    7]} )
                    $error("BAD s_imm");
                else if ( b_imm != {{20{pkt.instr[31]}}, pkt.instr[    7], pkt.instr[30:25], pkt.instr[11: 8], 1'b0} )
                    $error("BAD b_imm");
                else if ( u_imm != {    pkt.instr[31]  , pkt.instr[30:20], pkt.instr[19:12], 12'b0} )
                    $error("BAD u_imm");
                else if ( j_imm != {{12{pkt.instr[31]}}, pkt.instr[19:12], pkt.instr[   20], pkt.instr[30:25], pkt.instr[24:21], 1'b0} )
                    $error("BAD j_imm");
                ->e2;
            `endif
        end
    end

endmodule
