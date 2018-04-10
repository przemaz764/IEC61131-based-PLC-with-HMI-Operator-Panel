package com.programmer.connect;

public class MemoryMap {

    final static byte inputsBase   = (byte) 0x00;
    final static byte inputsTop    = (byte) 0x00;
    final static byte outputsBase  = (byte) 0x20;
    final static byte outputsTop   = (byte) 0x2F;
    final static byte makrkersBase = (byte) 0x30;
    final static byte markersTop   = (byte) 0xFF;

    public final static int APB_OUT = 0x00001801;
    public final static int APB_IN  = 0x00001800;

    public final static int BR_ADR =  0x00001000;
}
