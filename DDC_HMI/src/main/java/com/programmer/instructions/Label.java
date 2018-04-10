package com.programmer.instructions;

import java.util.ArrayList;

/**
 * Created by bobaxix on 17.09.17.
 */
public class Label extends Instruction{

    public Label(){
        isLabel = true;

    }
    @Override
    public ArrayList<Integer> generateCodeForInstruction(){
        return new ArrayList<>();
    }

    public String getLabel(){
        return  getOrder();
    }
}
