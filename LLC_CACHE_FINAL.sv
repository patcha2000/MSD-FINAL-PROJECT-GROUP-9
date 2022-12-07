module finalproject;
parameter i=2**15;   //
//parameter MODE = 1;
int SNOOPRESULT;
parameter GETLINE = 1;
parameter SENDLINE = 2;
parameter INVALIDATELINE = 3;
parameter EVICTLINE = 4;
int Message;


parameter READ = 1;
parameter WRITE = 2;
parameter INVALIDATE = 3;
parameter RWIM = 4;
int BusOp;

//int command;
string MODE;
string put_SnoopResult;
logic j;
int num;
typedef enum {I,M,E,S} MESI;
parameter NOHIT =2 | 3 ; 
parameter HIT = 0;
parameter HITM = 1;
//parameter NOHIT = 3;
int temp;
bit CACHE_HIT ;
bit CACHE_MISS;
int hit_way,read,write,conflict_miss;
real cache_hits,cache_misses;
real hitratio;

logic [31:0] address;
logic [5:0] byte_offset;
logic [14:0] add_index;
logic [10:0] add_tag;
logic [1:0] snoop_bits;
int command;


          /////////  INITIALIZATION OF CACHE  ///////////

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

sets SUN [i];

           ///////////////////////////////////////////////////


           //////////  GET SNOOP //////////////////////

function void GetSnoopResult(address);

      if(snoop_bits == 2'b00)
	    SNOOPRESULT = HIT;
	  else if(snoop_bits  == 2'b01)
	    SNOOPRESULT = HITM;
	  else 
	    SNOOPRESULT = NOHIT;

endfunction

           //////////////////////////////////////////

	        ////////// PUT SNOOPREUSLT TASK ///////////
	
function void  PutSnoopResult(logic [31:0]address, int SNOOPRESULT );
    if(MODE == "N")
	$display("Address %h,\t SnoopResult{HIT,HITM,NOHIT}: %0d", address, SNOOPRESULT);
	
endfunction

            //////////////////////////////////////////////////

            ///////////BusOperation///////////////////////////
function void BusOperation(int BusOp, logic[31:0] address, int SNOOPRESULT);
   GetSnoopResult(address);
   if(MODE == "N")
    $display("BusOp{R,W,I,RWIM}: %d, Address: %h, Snoop Result{HIT,HITM,NOHIT}: %d\n",BusOp,address,SNOOPRESULT);
endfunction
	        /////////////////////////////////////////////////////

          //////// Message to Cache task    ////////
		  
function void MessagetoCache(int Message,logic [31:0]address);
if(MODE == "N")
$display("Message To cache L1: {GET LINE,SEND LINE,INVALIDATE LINE,EVICT LINE}: %d %h\n ", Message, address);
endfunction

          /////////////////////////////////////////
 
              /////// CHECK CACHE FUNCTION  /////////

function int check_cache(logic [31:0]address);
for(int n=0;n<8;n=n+1)
begin
hit_way = n;

if (SUN[add_index].ways[n].state ==  I)
     
	  begin 
	     CACHE_MISS = 1;
		 CACHE_HIT = 0;
		 conflict_miss =0;
		 	cache_misses = cache_misses +1;	
		     //$display("No of miss = %d",cache_misses);
	         //$display("CACHE_MISS=1");
	         if(MODE == "N")
			 $display("CACHE MISS");	  
	  
	  break;
	  
  end
else 
    begin
         if(SUN[add_index].ways[n].tag == add_tag)
      	    begin
			CACHE_HIT =1;
			if(MODE == "N")
		     $display("CACHE HIT");
			 //$display("CACHE_HIT=1");
	        CACHE_MISS = 0;
		 CACHE_HIT = 1;
		 conflict_miss =0;
			   //cache_hits = cache_hits + 1;
			   //$display("%d",cache_hits);
			  
			   break;
	         end
		 else 
		    if(n==7)
			begin
			CACHE_MISS = 0;
		    CACHE_HIT = 0;
		    conflict_miss =1;
			//cache_misses = cache_misses +1;
			 //$display("%d",cache_misses);
		    if(MODE == "N")
		    $display("conflict miss");
			//$display("%p,%p,%p,%p,%p ,%p ,%d", SUN[add_index],CACHE_HIT,add_index,add_tag,CACHE_MISS,hit_way,temp);
			
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
  return CACHE_MISS;
  return CACHE_HIT;
  return cache_hits;
  return cache_misses;
  //$display("%d,%d",CACHE_HIT,CACHE_MISS);
  endfunction
         
		   /////////////////////////////////////////////////////////////////////

          //////////////////////  CLEAR /////////////////////

  task clear;
	cache_hits 	= 0;
	cache_misses 	= 0;
	read 	= 0;
	write 	= 0;
	foreach(SUN[i])
	begin
	 for(int j = 0;j<8;j=j+1)
	   begin
	     SUN[i].ways[j].tag = 0;
		 SUN[i].ways[j].state = I;
		 end
		 end
		 
	//$display("CACHE_MISS = 1");
   // cache_misses = cache_misses + 1;
  endtask
           /////////////////////////////////////////////////////////
	

                             //PRINT TASK////

task print;

$display("*********************\nStart of Data Cache");
	for(int i=0; i< 2**15; i++)
	begin
		for(int j=0; j< 8; j++) 
		begin
			if(SUN[i].ways[j].state != I)
			begin
				$display("--------------------------------");
				$display(" Set = %p \t Way = %p \t Tag = %p \t MESI = %p \t LRU = %p", i, j, SUN[i].ways[j].tag, SUN[i].ways[j].state, SUN[i].PRE_LRU);
				

	
	
end
	end
end
	$display("********************\nEnd of Data cache.\n********************\n\n");

	
endtask

        ////////////////////////////////////////////////////////////
		

           ////////////    UPDATE LRU   //////////

task LRU(int add_set,int hit_way);
case (hit_way)

0: SUN[add_index].PRE_LRU  = (SUN[add_index].PRE_LRU & 7'b1110100)|7'b0000000;
1: SUN[add_index].PRE_LRU = (SUN[add_index].PRE_LRU & 7'b1110100) | 7'b0001000;
2: SUN[add_index].PRE_LRU  = (SUN[add_index].PRE_LRU  & 7'b1101100) | 7'b0000010;
3: SUN[add_index].PRE_LRU  = (SUN[add_index].PRE_LRU  & 7'b1101100) | 7'b0010010 ;
4: SUN[add_index].PRE_LRU  = (SUN[add_index].PRE_LRU  & 7'b1011010) |7'b0000001;
5: SUN[add_index].PRE_LRU  = (SUN[add_index].PRE_LRU  & 7'b1011010) | 7'b0100001;
6: SUN[add_index].PRE_LRU = (SUN[add_index].PRE_LRU & 7'b0111010) |7'b0000101;
7: SUN[add_index].PRE_LRU = (SUN[add_index].PRE_LRU  & 7'b 0111010) | 7'b1000101;
endcase

endtask

        ///////////////////////////////////////////////////////// 

         /////////    GET LRU FUNCTION ////////////


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
return way;
endfunction


         //////////////////////////////////////////////////////////
 
           ////////////////      MESI PROTOCOL TASK ///////////
  
  task mesi( logic [31:0]address);
  
  if(CACHE_HIT)
  begin
  case(SUN[add_index].ways[hit_way].state)
  
  M : begin
      if(command == 0)
	  begin
	 // $display("I am in tag hit Modified at command 0");
	  SUN[add_index].ways[hit_way].state = M;
      MessagetoCache(SENDLINE,address);
	  end
      else if(command == 1)
       begin
	      //$display("I am in tag hit Modified at command 1");
       	  SUN[add_index].ways[hit_way].state = M;
          MessagetoCache(SENDLINE,address);
       end
	   else if(command == 2)
	    begin
		 //$display("I am in tag hit Modified at command 2");
	     SUN[add_index].ways[hit_way].state = M;
         MessagetoCache(SENDLINE,address);
	  end
	  

	  
	  else if(command == 4)
	   begin
	   //$display("I am in tag hit Modified at command 4");
		 PutSnoopResult(address,HITM);
		 BusOperation(WRITE,address,HITM);
		 MessagetoCache(GETLINE,address);
         SUN[add_index].ways[hit_way].state = S;
		end
		
		else if(command == 6)
		begin
		//$display("I am in tag hit Modified at command 6");
		  BusOperation(WRITE,address,HITM);
		  PutSnoopResult(address,HITM);
		  MessagetoCache(GETLINE,address);
		  MessagetoCache(EVICTLINE,address);
		  SUN[add_index].ways[hit_way].state = I;
        end
		end
	
	E : begin
        if(command == 0)
		begin
		//$display("I am in tag hit Exclusive at command 0");
	    SUN[add_index].ways[hit_way].state = E;
	     MessagetoCache(SENDLINE,address);
        end
        else if(command == 1)
		begin
		        //$display("I am in tag hit Exclusive at command 1");
			    SUN[add_index].ways[hit_way].state = M;
	             MessagetoCache(SENDLINE,address);
        end
		else if(command == 2)
			begin
			//$display("I am in tag hit Exclusive at command 2");
	          SUN[add_index].ways[hit_way].state = E;
	          MessagetoCache(SENDLINE,address);
        end

        else if(command == 4)
		begin
         //$display("I am in tag hit Exclusive at command 4");
		 PutSnoopResult(address,HIT);
	     SUN[add_index].ways[hit_way].state = S;
		end
        else if(command == 6)
		  begin
		  //$display("I am in tag hit Exclusive at command 6");
		  MessagetoCache(INVALIDATELINE,address);
		  PutSnoopResult(address,HIT);
		  SUN[add_index].ways[hit_way].state = I;
          end
          end
  
  S  : begin
        //$display("command == %h",command);
       if(command == 0)
	   begin
	   
	    //$display("I am in tag hit Shared at command 0");
        SUN[add_index].ways[hit_way].state = S;
	     MessagetoCache(SENDLINE,address);
        end
	   else if(command == 1)
	   begin
	    //$display("I am in tag hit Shared at command 1");
           SUN[add_index].ways[hit_way].state = M;
		   BusOperation(INVALIDATE,address,HIT);
	       MessagetoCache(SENDLINE,address);
		
        end
		
		else if(command == 2)
		begin
		//$display("I am in tag hit Shared at command 2");
		 SUN[add_index].ways[hit_way].state = S;
	     MessagetoCache(SENDLINE,address);
		end
		else if(command == 3)
		 begin
		      //$display("I am in tag hit Shared at command 3");
			  MessagetoCache(INVALIDATELINE,address);
              SUN[add_index].ways[hit_way].state = I;
         end
        else if(command == 4)
		begin
		   //$display("I am in tag hit Shared at command 4");
		   PutSnoopResult(address,HIT);
		   SUN[add_index].ways[hit_way].state = S;
		end
        else if(command == 6)
		  begin
		  //$display("I am in tag hit Shared at command 6");
		  PutSnoopResult(address,HIT);
		  MessagetoCache(INVALIDATELINE,address);
		  SUN[add_index].ways[hit_way].state = I;
          end
   end
	I :  begin
	    if(command == 0)
		begin
		  //$display("I am in tag hit Invalid at command 0");
		  GetSnoopResult(address);
		  BusOperation(READ,address,SNOOPRESULT);
		  
		  if(SNOOPRESULT == 1 | 2)
		    SUN[add_index].ways[num].state = S ;
		  else if(SNOOPRESULT == 0 | 3)
		     SUN[add_index].ways[num].state = E;
		  MessagetoCache(SENDLINE,address);
	      end
	   else if(command == 1)
		   begin
		   //$display("I am in tag hit Invalid at command 1");
		    GetSnoopResult(address);
			BusOperation(RWIM,address,SNOOPRESULT);
		    
			SUN[add_index].ways[num].state = M;
			 MessagetoCache(SENDLINE,address);
			 
	      end
		
          end
	endcase
 end
	else
	    begin
		 if(conflict_miss)
		   num = temp;
		  else
		    num = hit_way;
		case(SUN[add_index].ways[num].state)
		
		
		 ////// dont write (same for M,E,S,I .NEED TO CHANGE STate outputs    ////// 
		 
		 
	M : begin
	if(command == 0 )
		begin
		 //$display("I am in tag miss Invalid at command 0");
		 //$display("%h",address);
		  GetSnoopResult(address);
		
		  BusOperation(READ,address,SNOOPRESULT);
		   //$display("snooped bits === %d",snoop_bits);
		 
		  if(SNOOPRESULT == 0)
		  begin
		 
		    SUN[add_index].ways[num].state = S;
			end
			else if(SNOOPRESULT == 1)
		  begin
		
		    SUN[add_index].ways[num].state = S;
			end
		  else if(SNOOPRESULT == 2)
		  begin
		 
		     SUN[add_index].ways[num].state = E;
			 end
			 else
			 begin
		      
		     SUN[add_index].ways[num].state = E;
			 end
	         MessagetoCache(SENDLINE,address);
			end
			
		else if(command == 1)
		   begin
		    //$display("I am in tag miss Invalid at command 1");
		    GetSnoopResult(address);
		    BusOperation(RWIM,address,SNOOPRESULT);
			SUN[add_index].ways[num].state = M;
			   MessagetoCache(SENDLINE,address);
	      end
        
		
		else if(command == 2 )
		begin
		 //$display("I am in tag miss Invalid at command 2");
		 //$display("%h",address);
		  GetSnoopResult(address);
		
		  BusOperation(READ,address,SNOOPRESULT);
		  // $display("snooped bits === %d",snoop_bits);
		 
		  if(SNOOPRESULT == 0)
		  begin
		 
		    SUN[add_index].ways[num].state = S;
			end
			else if(SNOOPRESULT == 1)
		  begin
		
		    SUN[add_index].ways[num].state = S;
			end
		  else if(SNOOPRESULT == 2)
		  begin
		 
		     SUN[add_index].ways[num].state = E;
			 end
			 else
			 begin
		      
		     SUN[add_index].ways[num].state = E;
			 end
	         MessagetoCache(SENDLINE,address);
			end
end
		
	E: begin
	if(command == 0 )
		begin
		// $display("I am in tag miss Invalid at command 0");
		// $display("%h",address);
		  GetSnoopResult(address);
		
		  BusOperation(READ,address,SNOOPRESULT);
		 //  $display("snooped bits === %d",snoop_bits);
		 
		  if(SNOOPRESULT == 0)
		  begin
		 
		    SUN[add_index].ways[num].state = S;
			end
			else if(SNOOPRESULT == 1)
		  begin
		
		    SUN[add_index].ways[num].state = S;
			end
		  else if(SNOOPRESULT == 2)
		  begin
		 
		     SUN[add_index].ways[num].state = E;
			 end
			 else
			 begin
		      
		     SUN[add_index].ways[num].state = E;
			 end
	         MessagetoCache(SENDLINE,address);
			end
			
		else if(command == 1)
		   begin
		   // $display("I am in tag miss Invalid at command 1");
		    GetSnoopResult(address);
		    BusOperation(RWIM,address,SNOOPRESULT);
			SUN[add_index].ways[num].state = M;
			   MessagetoCache(SENDLINE,address);
	      end
        
		
		else if(command == 2 )
		begin
		// $display("I am in tag miss Invalid at command 2");
		 //$display("%h",address);
		  GetSnoopResult(address);
		
		  BusOperation(READ,address,SNOOPRESULT);
		  // $display("snooped bits === %d",snoop_bits);
		 
		  if(SNOOPRESULT == 0)
		  begin
		 
		    SUN[add_index].ways[num].state = S;
			end
			else if(SNOOPRESULT == 1)
		  begin
		
		    SUN[add_index].ways[num].state = S;
			end
		  else if(SNOOPRESULT == 2)
		  begin
		 
		     SUN[add_index].ways[num].state = E;
			 end
			 else
			 begin
		      
		     SUN[add_index].ways[num].state = E;
			 end
	         MessagetoCache(SENDLINE,address);
			end
end
		
	
	S : 
	begin
	if(command == 0 )
		begin
		// $display("I am in tag miss Invalid at command 0");
		// $display("%h",address);
		  GetSnoopResult(address);
		
		  BusOperation(READ,address,SNOOPRESULT);
		   //$display("snooped bits === %d",snoop_bits);
		 
		  if(SNOOPRESULT == 0)
		  begin
		 
		    SUN[add_index].ways[num].state = S;
			end
			else if(SNOOPRESULT == 1)
		  begin
		
		    SUN[add_index].ways[num].state = S;
			end
		  else if(SNOOPRESULT == 2)
		  begin
		 
		     SUN[add_index].ways[num].state = E;
			 end
			 else
			 begin
		      
		     SUN[add_index].ways[num].state = E;
			 end
	         MessagetoCache(SENDLINE,address);
			end
			
		else if(command == 1)
		   begin
		   // $display("I am in tag miss Invalid at command 1");
		    GetSnoopResult(address);
		    BusOperation(RWIM,address,SNOOPRESULT);
			SUN[add_index].ways[num].state = M;
			   MessagetoCache(SENDLINE,address);
	      end
        
		
		else if(command == 2 )
		begin
		 //$display("I am in tag miss shared at command 2");
		 //$display("%h",address);
		  GetSnoopResult(address);
		
		  BusOperation(READ,address,SNOOPRESULT);
		   //$display("snooped bits === %d",snoop_bits);
		 
		  if(SNOOPRESULT == 0)
		  begin
		 
		    SUN[add_index].ways[num].state = S;
			end
			else if(SNOOPRESULT == 1)
		  begin
		
		    SUN[add_index].ways[num].state = S;
			end
		  else if(SNOOPRESULT == 2)
		  begin
		 
		     SUN[add_index].ways[num].state = E;
			 end
			 else
			 begin
		      
		     SUN[add_index].ways[num].state = E;
			 end
	         MessagetoCache(SENDLINE,address);
			end
end
		
	I : begin
	if(command == 0 )
		begin
		 //$display("I am in tag miss Invalid at command 0");
		 //$display("%h",address);
		  GetSnoopResult(address);
		
		  BusOperation(READ,address,SNOOPRESULT);
		   //$display("snooped bits === %d",snoop_bits);
		 
		  if(SNOOPRESULT == 0)
		  begin
		 
		    SUN[add_index].ways[num].state = E;
			end
			else if(SNOOPRESULT == 1)
		  begin
		
		    SUN[add_index].ways[num].state = S;
			end
		  else if(SNOOPRESULT == 2)
		  begin
		 
		     SUN[add_index].ways[num].state = S;
			 end
			 else
			 begin
		      
		     SUN[add_index].ways[num].state = E;
			 end
	         MessagetoCache(SENDLINE,address);
			end
			
		else if(command == 1)
		   begin
		    //$display("I am in tag miss Invalid at command 1");
		    GetSnoopResult(address);
		    BusOperation(RWIM,address,SNOOPRESULT);
			SUN[add_index].ways[num].state = M;
			   MessagetoCache(SENDLINE,address);
	      end
        
		
		else if(command == 2 )
		begin
		 //$display("I am in tag miss Invalid at command 2");
		 //$display("%h",address);
		  GetSnoopResult(address);
		
		  BusOperation(READ,address,SNOOPRESULT);
		  // $display("snooped bits === %d",snoop_bits);
		 
		  if(SNOOPRESULT == 0)
		  begin
		 
		    SUN[add_index].ways[num].state = E;
			end
			else if(SNOOPRESULT == 1)
		  begin
		
		    SUN[add_index].ways[num].state = S;
			end
		  else if(SNOOPRESULT == 2)
		  begin
		 
		     SUN[add_index].ways[num].state = S;
			 end
			 else
			 begin
		      
		     SUN[add_index].ways[num].state = E;
			 end
	         MessagetoCache(SENDLINE,address);
			end
end
		
	
	endcase
	end
	
	endtask

	                                  //////// MAIN PROGRAM /////////

initial begin
string file_name;
int fd,status;
logic [31:0] address;

if($value$plusargs("MODE_TR=%s",MODE)) begin
	if(MODE=="N")
		$display("Normal MODE");
	else if (MODE=="S")
		$display("SILENT MODE");

end

if($value$plusargs("FILE_NAME=%s",file_name)) begin
      fd = $fopen(file_name,"r");
      while(!$feof(fd)) begin // fscanf returns the number of matches
        status= $fscanf (fd, "%d %h", command, address);
        if(MODE == "N")
		$display ("command = %0h \t address = %h", command, address);
       byte_offset = address[5:0];
 add_index = address[20:6];
 add_tag = address[31:21];
 snoop_bits = address[1:0];
 case(command)
//if(command == 0)
0:
begin 
read = read + 1;
   void'(check_cache(address));
   if(CACHE_HIT)
   cache_hits = cache_hits + 1;
   else
   cache_misses = cache_misses +1;
   
  if(CACHE_HIT)
     begin
	 
	  LRU(add_index,hit_way);
	  mesi(address);
	  
	  end
     
	else if(conflict_miss)
		   begin
		   
		   
		    void'(get_LRU(add_index));
			temp=get_LRU(add_index);
			if(MODE == "N")
			$display("evicted way is %d",get_LRU(add_index));
			MessagetoCache(EVICTLINE,address);
				GetSnoopResult(address);
			BusOperation(WRITE,address,SNOOPRESULT);
		       LRU(add_index,temp) ;
			   SUN[add_index].ways[temp].tag = add_tag;
			   mesi(address);
	        end
		
		  else
		  begin
		    
		   LRU(add_index,hit_way);
		    
          	  SUN[add_index].ways[hit_way].tag = add_tag;
		   mesi(address);
          end
 end
1:
 begin
   write = write + 1;
     void'(check_cache(address));
     //$display("TAGHIT = %d",CACHE_HIT);
  //$display("TAGmiss = %d",CACHE_HIT);
   if(CACHE_HIT)
   cache_hits = cache_hits + 1;
   else
   cache_misses = cache_misses +1;
   
   if(CACHE_HIT == 1)
     begin
	  
	  LRU(add_index,hit_way);
	    mesi(address);
	  end
     
	else if(conflict_miss == 1)
		   begin
	
		    void'(get_LRU(add_index));
			temp = get_LRU(add_index);
			SUN[add_index].ways[temp].tag = add_tag;
			if(MODE == "N")
			$display("evicted way is %d",temp);
			MessagetoCache(EVICTLINE,address);
				GetSnoopResult(address);
			BusOperation(WRITE,address,SNOOPRESULT);
		       LRU(add_index,temp) ;
			   mesi(address);
			   
	        end
		
		  else
	
		   LRU(add_index,hit_way);
		   	  SUN[add_index].ways[hit_way].tag = add_tag;
		    mesi(address);
  
  
 end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
2 : 
begin 
read = read + 1;
   void'(check_cache(address));
    if(CACHE_HIT)
   cache_hits = cache_hits + 1;
   else
   cache_misses = cache_misses +1;
  if(CACHE_HIT)
     begin
	
	  LRU(add_index,hit_way);
	  mesi(address);
	  
	  end
     
	else if(conflict_miss)
		   begin
		 
		    void'(get_LRU(add_index));
			temp=get_LRU(add_index);
			if(MODE == "N")
			$display("evicted way is %d",get_LRU(add_index));
			MessagetoCache(EVICTLINE,address);
			GetSnoopResult(address);
			BusOperation(WRITE,address,SNOOPRESULT);
		       LRU(add_index,temp) ;
			   SUN[add_index].ways[temp].tag = add_tag;
			   mesi(address);
	        end
		
		  else
		  begin
		
		   LRU(add_index,hit_way);
		    
          	  SUN[add_index].ways[hit_way].tag = add_tag;
		   mesi(address);
          end
 end
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    3: begin //snoop invalid
	   void'(check_cache(address));
	   if(CACHE_HIT)
	    mesi(address);
	  end
////////////////////////////////////////////////////////////////////////////////////////////////////////////
    4: begin //snoop read
    void'(check_cache(address));
	   if(CACHE_HIT)
  mesi(address);
	   else
	   PutSnoopResult(address,NOHIT);
	   end
////////////////////////////////////////////////////////////////////////////////////////////////////////////
    5: begin //snoop write
    
   void'(check_cache(address));
	   if(CACHE_HIT)
  mesi(address);
	   else
	   PutSnoopResult(address,NOHIT);
	   end	   
////////////////////////////////////////////////////////////////////////////////////////////////////////////
    6: begin //snoop read with modify
	 
	    void'(check_cache(address));
	   if(CACHE_HIT)
  mesi(address);
	   else
	   PutSnoopResult(address,NOHIT);
	   end	   	
////////////////////////////////////////////////////////////////////////////////////////////////////////////
    8: clear; //clear cache 
///////////////////////////////////////////////////////////////////////////////////////////////////////////
    9: print; //print contents
 endcase
 
 hitratio= (cache_hits)/(cache_hits+(cache_misses/2));	
 // $display ("MESI STATE : %p",SUN[add_index].ways[].state);
 //$display("%p,%p,%p,%p,%p,%p ,%p ",SUN[add_index],CACHE_HIT,add_index,byte_offset, add_tag,CACHE_MISS,hit_way);
 $display("No of reads = %d,\t No of writes = %d,\t No of hits = %d,\t No of misses = %d,\t hit_ratio=%6.2f",read,write,cache_hits,cache_misses/2,hitratio);
  $display("===================================================================================================================="); 
 end
$fclose(fd); // Close this file handle
  end
end

endmodule