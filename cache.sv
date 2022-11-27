module oper;
parameter i=2**15;
logic j;
typedef enum {I,M,E,S} MESI;
bit TAG_HIT ;
bit TAG_MISS;
int hit_way;
typedef struct packed 
{
  MESI state;
bit [10:0] tag;
} line;

typedef struct packed 
{
 bit [6:0] PRE_LRU ;
  line [0:7] ways;
}sets;

logic [31:0] address;
logic [5:0] byte_offset;
logic [14:0] add_index;
logic [10:0] add_tag;

sets SUN [i];
task LRU(int add_set,int hit_way);
case (hit_way)

0: SUN[add_index].PRE_LRU  = (SUN[add_index].PRE_LRU & 7'b1110100)|7'b00000000;
1: SUN[add_index].PRE_LRU = (SUN[add_index].PRE_LRU & 7'b1111000) | 7'b0001000;
2: SUN[add_index].PRE_LRU  = (SUN[add_index].PRE_LRU  & 7'b1101100) | 7'b0000010;
3: SUN[add_index].PRE_LRU  = (SUN[add_index].PRE_LRU  & 7'b1101100) | 8'b0010010 ;
4: SUN[add_index].PRE_LRU  = (SUN[add_index].PRE_LRU  & 7'b1011010) |7'b0000001;
5: SUN[add_index].PRE_LRU  = (SUN[add_index].PRE_LRU  & 7'b1011010) | 7'b0100001;
6: SUN[add_index].PRE_LRU = (SUN[add_index].PRE_LRU & 7'b0111010) |7'b0000101;
7: SUN[add_index].PRE_LRU = (SUN[add_index].PRE_LRU  & 7'b 0111010) | 7'b1000101;
endcase

endtask
function int get_LRU(int set);
int  way;

if(SUN[set].PRE_LRU[0] == 0)
begin
   if(SUN[set].PRE_LRU[2] == 0)
    begin 
        if(SUN[set].PRE_LRU[6] == 0)
            way = 7;
        else
             way = 6;
    end
   else
   begin
       if(SUN[set].PRE_LRU[5] == 0)
            way = 5;
       else 
            way  = 4;
   end
end
else
begin
    if(SUN[set].PRE_LRU[1] == 0)
	 begin
	     if(SUN[set].PRE_LRU[4] == 0)
	        way = 3;
		 else 
		     way = 2;
	end
	else
	begin
	if(SUN[set].PRE_LRU[3] == 0)
	    way =1;
    else 
         way =0;
    end
end	


/*initial begin
#10;
$display("%b %b",way,PRE_LRU[0]);
$finish;
end*/
return way;
endfunction

initial begin
string data,new_str;
int trace;
//logic [31:0] address;
trace = $fopen("./trace.txt", "r+");
if (trace)
begin
$display("File open  %d", trace);
while(! $feof(trace)) begin
$fgets(data,trace);
new_str = data.substr(2,data.len()-1);
address = new_str.atohex();
$display("%p",address);
//address = data[31:0];
//new_str = data.substr(2,data.len()-1);
//address = new_str.atohex();
//for(int j=0;j<13;j++)
//begin 
//$display("%p",SUN[add_index].PRE_LRU);
//hit_way =(j%8)-1; 
//address =32'b1001100111111111111110000111111;
byte_offset=address[5:0];
add_index = address[20:6];
add_tag = address[31:21];



 
 
 //SUN[32767].ways[5].tag = 11'b 11111111111;
 /*SUN[32767].ways[0]. state = E;
 
 SUN[32767].ways[6]. state = E;
 SUN[32767].ways[1]. state = E;
 SUN[32767].ways[2]. state = E;
 SUN[32767].ways[3]. state = E;
 SUN[32767].ways[4]. state = E;
 SUN[32767].ways[5]. state = E;
 SUN[32767].ways[7]. state = E;
 SUN[32767].PRE_LRU = 7'b 1111011;*/
for(int n=0;n<8;n=n+1)
begin

int temp;
hit_way =n;
//$display("hii");
//$display("%p",SUN[add_index].ways[n].state);
if (SUN[add_index].ways[n].state ==  I)
     
	  begin 
	$display("TAG MISS");
     TAG_MISS = 1;
	  SUN[add_index].ways[n].tag = add_tag;
	  SUN[add_index].ways[n].state = E;
	  
	  LRU(add_index,hit_way);
	  
	  break;
	  
  end
	  

else 
    begin
     //$display("hello");
     
         if(SUN[add_index].ways[n].tag == add_tag)
      	    begin
		     $display("TAG HIT");
	           TAG_HIT =1;
			   //hit_way = n;
			   LRU(add_index,hit_way);
			   break;
	         end
		 else 
		    if(n==7)
			begin
			$display("%p",SUN[add_index].PRE_LRU);
		    $display("conflict miss");
			get_LRU(add_index);
			temp=get_LRU(add_index);
			//hit_way = temp;
			$display("evicted way is %d",get_LRU(add_index));
			
		
			SUN[add_index].ways[temp].tag = add_tag;
			  LRU(add_index,get_LRU(add_index));
			
			$display("%p,%p,%p,%p,%p ,%p ,%d", SUN[add_index],TAG_HIT,add_index,add_tag,TAG_MISS,hit_way,temp);
			
			break;
			end
			else
			begin
			//n=0;
			continue;
			end
		   
			
	  
	  end
	  //$display("%p,%p,%p",SUN[add_index],hit_way,temp);
  end
  
  end
  end
  end

 initial 
 begin
 //#50 $stop;
 $display("%p,%p,%p,%p,%p ,%p ",SUN[add_index],TAG_HIT,add_index,add_tag,TAG_MISS,hit_way);
 end

endmodule
