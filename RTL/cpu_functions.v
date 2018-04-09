//----------------------------------------------------------------------------------------------------------------------
// Functions
//----------------------------------------------------------------------------------------------------------------------  

// Calculate condition for an end of inputs refresh
function  [255:0] ref_in_cond ;
  input   [31:0] inputs_number;
  
  begin
    ref_in_cond = 0;
    while (inputs_number > 32)
    begin
      inputs_number = inputs_number - 32;
      ref_in_cond = ref_in_cond + 1;
    end
  end 
endfunction
  
// Calculate condition for an end of refresh instruction based on number of in/outs
function  [255:0] ref_out_cond ;
  input   [31:0] outputs_number;
  input   [31:0] inputs_number;
  
  begin
    ref_out_cond = 1;
    while (inputs_number > 32)
    begin
      inputs_number = inputs_number - 32;
      ref_out_cond = ref_out_cond + 1;
    end
    
    while (outputs_number > 32)
    begin
      outputs_number = outputs_number - 32;
      ref_out_cond = ref_out_cond + 1;
    end
  end
endfunction  

// Calculate a number of APB Read/Write transactions needed for completing Refresh instruction
function  [255:0] apb_transactions_n;
  input   [31:0] ports_n;
  
  begin
    apb_transactions_n = 1;
    while (ports_n > 32)
    begin
      ports_n = ports_n - 32;
      apb_transactions_n = apb_transactions_n + 1;
    end
  end 
endfunction