package com.programmer.instructions;

import java.util.ArrayList;
import java.util.logging.Logger;

/**
 * Created by bobaxix on 16.09.17.
 */
public abstract class Instruction {

    protected String operand;
    protected String order;
    protected int orderCode;
    protected int instructionLineNumber;
    protected boolean isLabel = false;
    protected boolean isJump = false;
    protected boolean isOpWithConst = false;

    protected final static Logger LOGGER = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);

    abstract public ArrayList<Integer> generateCodeForInstruction();

    public void set(String order, int orderCode, String operand, int instructionLineNumber){
        this.operand = operand;
        this.orderCode = orderCode;
        this.order = order;
        this.instructionLineNumber = instructionLineNumber;
    }

    public void set(String order, int instructionLineNumber){
        set(order,0,null,instructionLineNumber);
    }

    public int getOrderCode(){
        return orderCode;
    }

    public int getInstructionLineNumber(){
        return  instructionLineNumber;
    }

    public String getOrder(){
        return order;
    }

    public boolean isLabel(){
        return isLabel;
    }

    public boolean isJump(){
        return isJump;
    }

    public boolean isOpWithConst(){
        return isOpWithConst;
    }

    @Override
    public String toString(){
        return operand+" "+order+" "+instructionLineNumber+" "+isOpWithConst;
    }
}
