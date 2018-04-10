package com.panel.memory;

public class MemoryMap {

    public final static byte INPUTS_BASE = (byte) 0x00;
    public final static byte INPUTS_TOP = (byte) 0x1F;
    public final static byte OUTPUTS_BASE = (byte) 0x20;
    public final static byte OUTPUTS_TOP = (byte) 0x3F;
    public final static byte MARKERS_BASE = (byte) 0x40;
    public final static byte MARKERS_TOP = (byte) 0xFF;

    public final static int TIMER_BASE = 0x00000800;
    public final static int TIMER_SIZE = 0x000007FF;

    public final static int COUNTER_BASE = 0x00000000;
    public final static int COUNTER_SIZE = 0x000007FF;

    public final static int APB_IN = 0x00001800;
    public final static int APB_OUT = 0x00001801;


    public final static int ADR_POS = 5;
}
