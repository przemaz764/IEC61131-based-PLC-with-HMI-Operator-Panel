package com.panel.memory;

import javafx.beans.property.SimpleIntegerProperty;

public class MemoryWrapper {

    private final int  MEMORY_SIZE = 8;
    private final int ADR_BIT_MASK =  0x07;
    private final int ADR_CHIP_MASK = 0x03;
    private final int ADR_INT_MASK =  0x07;

    private final int WORD_MASK = 0x0000FFFF;
    private final int CHUNK_MASK = 0x000000FF;
    private final int BIT_MASK = 0x00000001;

    private final byte CHIP_POS   = 3;
    private final byte SEMI_CHIP_POS = 4;
    private final byte ADR_POS    = 5;

    private final byte BYTE_POS = 8;
    private final byte WORD_POS = 16;

    private int[] register;
    private SimpleIntegerProperty[] registerProperty;

    public MemoryWrapper(){
        register = new int[MEMORY_SIZE];
        registerProperty = new SimpleIntegerProperty[MEMORY_SIZE];
        for(int i = 0; i < MEMORY_SIZE; i++)
            registerProperty[i] = new SimpleIntegerProperty(0);
    }

    public byte getBit(byte address)
    {
        byte bitNumber    = (byte)(address & ADR_BIT_MASK);
        byte chipNumber   = (byte)((address >> CHIP_POS) & ADR_CHIP_MASK);
        byte regNumber  = (byte)((address >> ADR_POS) & ADR_INT_MASK);
        return (byte)(((register[regNumber] >> (chipNumber * BYTE_POS)) >> bitNumber) & BIT_MASK);
    }

    public byte getByte(byte address) {
        byte chipNumber   = (byte)((address >> CHIP_POS) & ADR_CHIP_MASK);
        byte regNumber  = (byte)((address >> ADR_POS) & ADR_INT_MASK);
        return (byte)((register[regNumber] >> (chipNumber * BYTE_POS)) & CHUNK_MASK);
    }

    public short getWord(byte address){
        byte semiChipNumber = (byte)((address  >> SEMI_CHIP_POS) & ADR_CHIP_MASK);
        byte regNumber  = (byte)((address >> ADR_POS) & ADR_INT_MASK);
        return (short)((register[regNumber] >> (semiChipNumber * WORD_POS)) & WORD_MASK);
    }

    public int getInt(byte address){
        byte regNumber = (byte)((address >> ADR_POS) & ADR_INT_MASK);
        return register[regNumber];
    }

    public void setInt(byte address, int number)
    {
        byte regNumber  = (byte)((address >> ADR_POS) & ADR_INT_MASK);
        System.out.println(regNumber);
        register[regNumber] = number;
        registerProperty[regNumber].setValue(number);
    }

    public SimpleIntegerProperty[] getRegisterProperty(){
        return registerProperty;
    }

}
