package com.panel.connect;

public class Status {
    public final static int APB_EMPTY = 0x80;
    public final static int APB_FULL  = 0x40;
    public final static int SPI_EMPTY = 0x20;
    public final static int SPI_FULL  = 0x10;
    public final static int APB_ERROR = 0x08;
    public final static int SPI_ERROR = 0x04;
    public final static int APB_READY = 0x02;
    public final static int SPI_READY = 0x01;

}
