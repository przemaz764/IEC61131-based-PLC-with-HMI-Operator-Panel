package com.programmer.logging;

import javafx.scene.control.TextArea;

import java.util.logging.LogRecord;

public class TextAreaHandler extends java.util.logging.Handler {

    TextArea logTextArea;

    public TextAreaHandler(TextArea logTextArea){
        this.logTextArea = logTextArea;
    }

    @Override
    public void publish(LogRecord record) {
        logTextArea.appendText(getFormatter().format(record));
    }

    @Override
    public void flush() {
        System.out.println("lol");
    }

    @Override
    public void close() throws SecurityException {

    }
}
