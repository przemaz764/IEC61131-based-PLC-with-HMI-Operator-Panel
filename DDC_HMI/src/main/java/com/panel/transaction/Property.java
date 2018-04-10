package com.panel.transaction;

public class Property extends PanelField {

    private MyIntegerProperty property;

    public Property(String id, int address){
        super(id, address);
        property = new MyIntegerProperty(0);
    }

    public void setValue(int value) {
        property.set(value);
    }

    public MyIntegerProperty getProperty(){
        return property;
    }
}

