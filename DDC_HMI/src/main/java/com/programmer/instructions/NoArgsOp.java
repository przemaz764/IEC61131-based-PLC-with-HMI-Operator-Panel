package com.programmer.instructions;

import java.util.ArrayList;

/**
 * Created by bobaxix on 17.09.17.
 */
public class NoArgsOp extends Instruction {

    @Override
    public ArrayList<Integer> generateCodeForInstruction(){
        ArrayList<Integer> codeLine = new ArrayList<Integer>();
        if(operand == null) {
            int code = orderCode << 24;
            codeLine.add(code);
            return codeLine;
        }
        else
            LOGGER.warning("Line "+instructionLineNumber+": NAO need not argument.");

        return null;
    }
}
