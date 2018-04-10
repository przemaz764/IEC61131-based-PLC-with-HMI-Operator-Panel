package com.panel.transaction;

import com.panel.memory.AccessType;

public abstract class BufferReaderWriter {

    public static final byte REG_POS = 8;
    public static final byte LITTLE_ADR_POS = 2;

    private static void setByte(int address, int value, int[] buffer) {
        int regNumber = (address >>> REG_POS) & 0x07;
        int byteNumber = (address >>> LITTLE_ADR_POS) & 0x07;

        int mask = 0xFF << (byteNumber * 8);
        int cleanedValue = buffer[regNumber] & ~(mask);
        buffer[regNumber] = cleanedValue | (value << (byteNumber * 8));
    }

    private static void setWord(int address, int value, int[] buffer) {
        int wordNumber = (address >>> LITTLE_ADR_POS) & 0x07;
        int regNumber = (address >>> REG_POS) & 0x07;

        int mask = 0xFFFF << (wordNumber * REG_POS);
        int cleanedValue = buffer[regNumber] & (~mask);
        buffer[regNumber] = cleanedValue | (value << (wordNumber * 8));
    }

    private static void setDoubleWord(int address, int value, int[] buffer) {
        int regNumber = (address >>> REG_POS) & 0x07;
        buffer[regNumber] = value;
    }

    private static void setBit(int address, int value, int[] buffer) {
        int bitNumber = ((address >>> LITTLE_ADR_POS) & 0x07);
        int regNumber = ((address >>> REG_POS) & 0x07);

        if (value == 0)
            buffer[regNumber] &= ~(1 << bitNumber);
        else
            buffer[regNumber] |= (1 << bitNumber);
    }

    private static int getBit(int[] buffer, int address) {
        int bitNumber = ((address >>> LITTLE_ADR_POS) & 0x07);
        int regNumber = ((address >>> REG_POS) & 0x07);

        return (buffer[regNumber] >>> bitNumber) & 0x01;
    }

    private static int getByte(int[] buffer, int address) {

        int byteNumber = ((address >>> LITTLE_ADR_POS) & 0x07);
        int regNumber = ((address >>> REG_POS) & 0x07);

        return ((buffer[regNumber] >>> (byteNumber * 8)) & 0xFF);
    }

    private static int getWord(int[] buffer, int address) {

        int wordNumber = ((address >>> LITTLE_ADR_POS) & 0x07);
        int regNumber = ((address >>> REG_POS) & 0x07);

        return ((buffer[regNumber] >>> (wordNumber * 16)) & 0xFFFF);
    }

    private static int getDoubleWord(int[] buffer, int address) {
        int regNumber = ((address >>> REG_POS) & 0x07);
        return buffer[regNumber];
    }

    public static void set(int address, int value, int[] buffer, AccessType accessType) {
        switch (accessType) {
            case BIT:
                setBit(address, value, buffer);
                break;
            case BYTE:
                setByte(address, value, buffer);
                break;
            case WORD:
                setWord(address, value, buffer);
                break;
            case DOUBLE_WORD:
                setDoubleWord(address, value, buffer);
                break;
        }
    }

    public static int get(int address, int[] buffer, AccessType accessType) {
        switch (accessType) {
            case BIT:
                return getBit(buffer, address);
            case BYTE:
                return getByte(buffer, address);
            case WORD:
                return getWord(buffer, address);
            case DOUBLE_WORD:
                return getDoubleWord(buffer, address);
        }
        return -1;
    }
}
