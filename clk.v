`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: vga_auto_circles
// Descriere: Doua cercuri care se misca automat pe orizontala si pot fi mutate pe verticala
//           cu butoanele UP si DOWN. Daca se ciocnesc, cercurile nu-si mai schimba pozitia.
//           Afisare pe ecran VGA FullHD.
//////////////////////////////////////////////////////////////////////////////////

module clk (
    input wire clk,        // Semnal ceas 148.5 MHz (frecventa de lucru)
    input wire reset,      // Reset activ pe nivel LOW (0)
    input wire btnU,       // Buton UP pentru miscare sus
    input wire btnD,       // Buton DOWN pentru miscare jos
    output wire Hsync,     // Semnal sincronizare orizontala VGA
    output wire Vsync,     // Semnal sincronizare verticala VGA
    output reg [3:0] red,  //  rosu (4 biti)
    output reg [3:0] green,//  verde (4 biti)
    output reg [3:0] blue  //  albastru (4 biti)
);

    // Parametrii pentru ecran Full HD (1920x1080)
    localparam HV  = 1920;  // Numar pixeli vizibili orizontal
    localparam HFP = 88;    // Front porch orizontal (pauza inainte de pulsul Hsync)
    localparam HSP = 44;    // Pulsul Hsync (sincronizare orizontala)
    localparam HBP = 148;   // Back porch orizontal (pauza dupa pulsul Hsync)
    localparam HTOT = HV + HFP + HSP + HBP; // Total pixeli pe linie

    localparam VV  = 1080;  // Numar pixeli vizibili vertical
    localparam VFP = 4;     // Front porch vertical
    localparam VSP = 5;     // Pulsul Vsync (sincronizare verticala)
    localparam VBP = 36;    // Back porch vertical
    localparam VTOT = VV + VFP + VSP + VBP; // Total linii pe ecran

    // Contoare pentru pozitia curenta pe ecran
    reg [11:0] h_count; // Contor pozitie orizontala
    reg [11:0] v_count; // Contor pozitie verticala

    // Incrementam contorul orizontal la fiecare ciclu de ceas
    always @(posedge clk or negedge reset) begin
        if (!reset)                  // Daca reset-ul e activ (0)
            h_count <= 0;            // Resetam contorul orizontal la 0
        else if (h_count == HTOT - 1) // Daca am ajuns la finalul liniei
            h_count <= 0;            // Resetam la inceputul liniei
        else
            h_count <= h_count + 1;  // Altfel incrementam pozitia orizontala
    end

    // Incrementam contorul vertical cand ajungem la finalul liniei orizontale
    always @(posedge clk or negedge reset) begin
        if (!reset)                  // Daca reset-ul e activ (0)
            v_count <= 0;            // Resetam contorul vertical la 0
        else if (h_count == HTOT - 1) begin // Cand o linie s-a terminat
            if (v_count == VTOT - 1)         // Daca am terminat toate liniile
                v_count <= 0;                // Resetam la prima linie
            else
                v_count <= v_count + 1;      // Altfel incrementam linia curenta
        end
    end

    // Generam semnalele de sincronizare (active low)
    assign Hsync = ~((h_count >= HV + HFP) && (h_count < HV + HFP + HSP));
    assign Vsync = ~((v_count >= VV + VFP) && (v_count < VV + VFP + VSP));

    // Verificam daca pixelul curent este in zona vizibila a ecranului
    wire visible = (h_count < HV) && (v_count < VV);

    // Parametrii pentru cercuri
    localparam CIRCLE_RADIUS = 50;         // Raza cercului in pixeli
    localparam CIRCLE_RADIUS_SQ = CIRCLE_RADIUS * CIRCLE_RADIUS; // Raza la patrat
    localparam MOVE_PERIOD = 500000;       // Perioada de miscare (intarziere)

    // Variabile pentru miscarea cercurilor
    reg [25:0] move_count;      // Contor pentru a face miscarea mai lenta
    reg [10:0] circle1_x;       // Pozitia pe orizontala a cercului 1
    reg [10:0] circle2_x;       // Pozitia pe orizontala a cercului 2
    reg [10:0] circle_y_pos;    // Pozitia comuna pe verticala a cercurilor
    reg dir1;                   // Directia de miscare pentru cercul 1 (1 = spre dreapta)
    reg dir2;                   // Directia de miscare pentru cercul 2 (0 = spre stanga)
    reg collision;              // Flag pentru coliziune curenta

    // Debounce simplu: folosim direct semnalul butoanelor, fara filtrare
    wire up_debounced = btnU;    // Citim buton UP fara debounce complex
    wire down_debounced = btnD;  // Citim buton DOWN fara debounce complex

    // Logica pentru miscarea cercurilor si controlul vertical
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            move_count    <= 0;                 // Resetam contorul de miscare
            circle1_x     <= 100;               // Pornim cercul 1 in pozitia 100 pe orizontala
            circle2_x     <= HV - 200;          // Pornim cercul 2 aproape de capatul ecranului
            circle_y_pos  <= VV - 300;          // Pornim cercurile in pozitie verticala fixa
            dir1          <= 1'b1;               // Cercul 1 merge spre dreapta la inceput
            dir2          <= 1'b0;               // Cercul 2 merge spre stanga la inceput
            collision     <= 1'b0;               // Nu e coliziune la inceput
        end else if (move_count == MOVE_PERIOD - 1) begin
            move_count <= 0;                    // Resetam contorul de miscare

            if (!collision) begin
                // Daca nu este coliziune, miscarea cercurilor pe orizontala este activa

                // Miscare cerc 1 pe orizontala
                if (dir1) begin  // Daca cercul 1 merge spre dreapta
                    if (circle1_x + CIRCLE_RADIUS * 2 >= circle2_x) 
                        dir1 <= 1'b0;  // Schimba directia la stanga daca aproape se ciocneste cu cercul 2
                    else
                        circle1_x <= circle1_x + 1;  // Altfel, muta cercul 1 cu 1 pixel spre dreapta
                end else begin  // Daca cercul 1 merge spre stanga
                    if (circle1_x <= 0)
                        dir1 <= 1'b1;  // Schimba directia spre dreapta daca ajunge la marginea stanga a ecranului
                    else
                        circle1_x <= circle1_x - 1;  // Altfel, muta cercul 1 cu 1 pixel spre stanga
                end

                // Miscare cerc 2 pe orizontala
                if (!dir2) begin  // Daca cercul 2 merge spre stanga
                    if (circle2_x <= circle1_x + CIRCLE_RADIUS * 2)
                        dir2 <= 1'b1;  // Schimba directia spre dreapta daca aproape se ciocneste cu cercul 1
                    else
                        circle2_x <= circle2_x - 1;  // Altfel, muta cercul 2 cu 1 pixel spre stanga
                end else begin  // Daca cercul 2 merge spre dreapta
                    if (circle2_x + CIRCLE_RADIUS * 2 >= HV)
                        dir2 <= 1'b0;  // Schimba directia spre stanga daca ajunge la marginea dreapta a ecranului
                    else
                        circle2_x <= circle2_x + 1;  // Altfel, muta cercul 2 cu 1 pixel spre dreapta
                end
            end
            // Daca este coliziune, cercurile nu se mai misca pe orizontala

            // Control vertical cu butoane UP si DOWN
            if (up_debounced && circle_y_pos > CIRCLE_RADIUS + 1)
                circle_y_pos <= circle_y_pos - 1;  // Muta cercurile cu 1 pixel in sus, daca nu sunt in limita superioara
            else if (down_debounced && circle_y_pos < VV - CIRCLE_RADIUS - 1)
                circle_y_pos <= circle_y_pos + 1;  // Muta cercurile cu 1 pixel in jos, daca nu sunt in limita inferioara

        end else begin
            move_count <= move_count + 1;  // Daca nu s-a atins perioada de miscare, incrementeaza contorul de miscare
        end
    end

    // Calculam distanta pixelului curent fata de centrul cercurilor (folosind formula distantei in plan)
    wire signed [12:0] dx1 = h_count - (circle1_x + CIRCLE_RADIUS); // diferenta orizontala pentru cerc 1
    wire signed [12:0] dy1 = v_count - circle_y_pos;               // diferenta verticala pentru cerc 1
    wire [25:0] dist_sq1 = dx1*dx1 + dy1*dy1;                      // distanta la patrat (fara radacina)

    wire signed [12:0] dx2 = h_count - (circle2_x + CIRCLE_RADIUS); // diferenta orizontala pentru cerc 2
    wire signed [12:0] dy2 = v_count - circle_y_pos;               // diferenta verticala pentru cerc 2
    wire [25:0] dist_sq2 = dx2*dx2 + dy2*dy2;                      // distanta la patrat

    wire in_circle1 = (dist_sq1 < CIRCLE_RADIUS_SQ);               // pixelul e in interiorul cercului 1?
    wire in_circle2 = (dist_sq2 < CIRCLE_RADIUS_SQ);               // pixelul e in interiorul cercului 2?

    // Controlul culorii pentru fiecare pixel
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            red   <= 4'b0000;    // Negru daca reset
            green <= 4'b0000;
            blue  <= 4'b0000;
        end else if (visible) begin   // Daca pixelul e in zona vizibila
            if (in_circle1) begin      // Daca pixelul e in cercul 1
                red   <= 4'b0000;      // cyan (verde+albastru)
                green <= 4'b1111;
                blue  <= 4'b1111;
            end else if (in_circle2) begin  // Daca pixelul e in cercul 2
                red   <= 4'b1111;      // Galben (rosu + verde)
                green <= 4'b1111;
                blue  <= 4'b0000;
            end else begin
                // Fundal magenta (rosu + albastru)
                red   <= 4'b1111;
                green <= 4'b0000;
                blue  <= 4'b1111;
            end
        end else begin
            // In afara zonei vizibile, culoare neagra
            red   <= 4'b0000;
            green <= 4'b0000;
            blue  <= 4'b0000;
        end
    end

endmodule
