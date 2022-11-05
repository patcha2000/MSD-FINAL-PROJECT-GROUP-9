module tb;
initial 
begin
int trace;
string data,new_str;
logic [31:0] hex_data;
trace = $fopen("./trace.txt", "r+");
if (trace)
begin
$display("File open  %d", trace);
while(! $feof(trace)) begin
$fgets(data,trace);
new_str = data.substr(2,data.len()-1);
hex_data = new_str.atohex();
if(data[0]=="9")
begin
$display("silent mode %s %h",data[0], hex_data); 
end
else
begin
$display("normal mode %s %h",data[0], hex_data); 
end
end
end
else 
$display("No file");
$fclose(trace);
end
endmodule

