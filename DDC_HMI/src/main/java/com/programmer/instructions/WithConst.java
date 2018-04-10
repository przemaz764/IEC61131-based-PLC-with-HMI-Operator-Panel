package com.programmer.instructions;

import java.util.ArrayList;
import java.util.logging.Logger;

/**
 * Created by bobaxix on 16.09.17.
 */
public class WithConst extends Instruction{

    ArrayList<Integer> codeList;

    public WithConst(){
        isOpWithConst = true;
    }
    @Override
    public ArrayList<Integer> generateCodeForInstruction(){

        try {
            Integer number = parseOperand();
            if(number == null)
                return null;

            codeList = new ArrayList<>();
            codeList.add(orderCode << 24);
            codeList.add(number);
        }
        catch(NullPointerException e){
            return null;
        }
        return codeList;
    }

    private Integer parseOperand() throws NumberFormatException{

        if(operand.startsWith("#")){
                String tempOperand = operand.substring(1);
                return Integer.parseInt(tempOperand);
        }
        else if(operand.startsWith("0x")){
            int number = 0;
            char[] tempOperand = operand.substring(2).toCharArray();
            if(tempOperand.length <= 8 ) {
                for (int i = 0; i < tempOperand.length; i++){
                    int part = Character.digit(tempOperand[i], 16);
                    if(part == -1){
                        LOGGER.warning("Bad hex!");
                        return null;
                    }
                    number |= (part) << ((tempOperand.length - 1 - i) * 4);
                }
                return number;
            }
            else
                LOGGER.warning("Number greater than max!");
        }
        return null;
    }
}
