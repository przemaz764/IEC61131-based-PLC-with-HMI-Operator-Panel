package com.panel.transaction;

import javafx.beans.property.SimpleIntegerProperty;

public class MyIntegerProperty extends SimpleIntegerProperty {

    private ValueListener valueListener;

    public MyIntegerProperty(int initialValue) {
        super(initialValue);
    }

    public void set(int value){
        super.set(value);
        if(valueListener != null)
            valueListener.onSet(value);
    }

    public void addValueListener(ValueListener valueListener){
        this.valueListener = valueListener;
    }

    public interface ValueListener{
        void onSet(int value);
    }


}
