module FULLADDER(a, b, cin, s, cout);
    input a, b, cin;
    output s, cout;

    // assign s = a ^ b ^ cin;
    // assign cout = (a&b)|(a&cin)|(b&cin);
    assign {cout, s} = a + b + cin;
endmodule

module testbench;

    reg a, b, cin;
    wire s, cout;

    FULLADDER fadder(a, b, cin, s, cout);
    always @(*)
        $monitor(,$time, " a=%b, b=%b, cin=%b, s=%b, cout=%b", a, b, cin, s, cout);

    initial begin
        a = 1'b0;
        b = 1'b1;
        cin = 1'b1;

        #1
        a = 1'b1;
        b = 1'b1;
        cin = 1'b1;

        #1
        a = 1'b0;
        b = 1'b1;
        cin = 1'b0;
    end
endmodule