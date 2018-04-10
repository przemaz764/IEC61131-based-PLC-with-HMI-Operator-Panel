package com.programmer.logging;

import java.util.logging.Formatter;
import java.util.logging.LogRecord;

public class MyFormatter extends Formatter {

    @Override
    public String format(LogRecord record) {

        StringBuffer stringBuffer = new StringBuffer(50);
        stringBuffer.append(record.getLevel()+": ");
        stringBuffer.append(record.getMessage()+"\n");

        return stringBuffer.toString();
    }
}
