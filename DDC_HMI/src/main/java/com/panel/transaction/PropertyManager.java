package com.panel.transaction;

import com.panel.memory.AccessType;

import java.util.ArrayList;

public class PropertyManager {

    protected ArrayList<Property> propertyList;

    public PropertyManager(ArrayList<Property> propertyList) {
        this.propertyList = propertyList;
    }

    public void setProperties(int[] buffer){
        propertyList.forEach((element)->{
            int address = element.getAddress();
            AccessType accessType = element.getAccessType();
            int value = BufferReaderWriter.get(address, buffer, accessType);
            element.setValue(value);
        });
    }

    public MyIntegerProperty getProperty(String name){
        for(Property property : propertyList){
            String id = property.getId();
            if(name.equalsIgnoreCase(id))
                return property.getProperty();
        }
        return null;
    }
}
