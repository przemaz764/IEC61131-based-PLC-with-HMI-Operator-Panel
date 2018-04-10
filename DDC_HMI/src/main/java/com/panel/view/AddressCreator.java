package com.panel.view;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class AddressCreator {

    private static final String pattern = "(\\d+).(\\d+).(DW|W|B|b)$";

    static public int getAddress(String addressLine){

        int bufferLine;
        int littleAddress;

        Pattern p = Pattern.compile(pattern);
        Matcher matcher = p.matcher(addressLine);

        if(matcher.matches()){
            int access = getAccess(matcher.group(3));
            try {
                bufferLine = Integer.parseInt(matcher.group(1));
                littleAddress = Integer.parseInt(matcher.group(2));
            }
            catch(NumberFormatException e){
                System.out.println("Number format exception!");
                return -1;
            }
            return access | littleAddress << 2 | bufferLine << 7;
        }

        return -1;
    }

    static private int getAccess(String access){
        switch(access){
            case "DW":
                return 0x03;
            case "W":
                return 0x02;
            case "B":
                return 0x01;
        }
        return 0;
    }

    static public int getBufferLine(int address){
        return address >>> 7;
    }
}
