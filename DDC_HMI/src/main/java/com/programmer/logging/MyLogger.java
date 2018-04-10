package com.programmer.logging;

import javafx.scene.control.TextArea;

import java.io.IOException;
import java.util.logging.*;

public class MyLogger {

    static private TextAreaHandler textAreaHandler;

    static public void setup(TextArea logTextArea) throws IOException{

        Logger logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);

        logger.setUseParentHandlers(false);

        logger.setLevel(Level.INFO);
        textAreaHandler = new TextAreaHandler(logTextArea);
        textAreaHandler.setFormatter(new MyFormatter());
        logger.addHandler(textAreaHandler);



    }
}
