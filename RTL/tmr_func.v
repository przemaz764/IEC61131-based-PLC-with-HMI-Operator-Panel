//----------------------------------------------------------------------------------------------------------------------
// Functions
//----------------------------------------------------------------------------------------------------------------------  

function integer log2;
  input [31:0] value;
  integer      i;

  begin
    log2 = 0;
    for(i = 0; 2**i < value; i = i + 1)
      log2 = i + 1;
  end

endfunction