package com.panel.transaction;

import com.panel.memory.AccessType;

public class PanelField {

    private int address;
    private String id;

    public PanelField(String id, int address){
        this.address = address;
        this.id = id;
    }

    public int getBufferLine(){
        return  this.address >> 5;
    }

    public int getLittleAddress(){
        return  (this.address >> 2) & 0x07;
    }

    public AccessType getAccessType(){
        switch(address & 0x03){
            case 0:
                return AccessType.BIT;
            case 1:
                return AccessType.BYTE;
            case 2:
                return AccessType.WORD;
            case 3:
                return AccessType.DOUBLE_WORD;
            default:
                return AccessType.ERROR;

        }
    }

    public int getAddress() {
        return address;
    }

    public String getId() {
        return id;
    }
}
