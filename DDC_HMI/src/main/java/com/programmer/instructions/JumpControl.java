package com.programmer.instructions;

import java.util.ArrayList;

/**
 * Created by bobaxix on 17.09.17.
 */
public class JumpControl extends Instruction {

    int lineNumberToJump = 0;

    public JumpControl(){
        isJump = true;
    }
    @Override
    public ArrayList<Integer> generateCodeForInstruction(){

        ArrayList<Integer> codeLine = new ArrayList<Integer>();
        int code = orderCode << 24 | lineNumberToJump;
        codeLine.add(code);
        return codeLine;
    }

    public void whereShouldJump(ArrayList<Instruction> codeLines){

        int lineNumber = 0;
        for(Instruction codeLine : codeLines){
            if(codeLine.isOpWithConst())
                lineNumber--;
            if(codeLine.isLabel()) {
                if (operand.equals(((Label) codeLine).getLabel())) {
                    lineNumberToJump = codeLine.getInstructionLineNumber() - lineNumber;
                }
                lineNumber++;
            }
        }
    }
}
