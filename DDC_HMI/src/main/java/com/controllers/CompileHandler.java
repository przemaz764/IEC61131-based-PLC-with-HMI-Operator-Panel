package com.controllers;

import com.programmer.load.CodeList;
import com.programmer.load.Compiler;

import java.io.IOException;
import java.util.logging.Logger;

public class CompileHandler {

    private Compiler compiler;
    CodeList fullCode;
    private static final Logger LOGGER = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);

    public CompileHandler(Compiler compiler){
        this.compiler = compiler;
    }

    public CodeList handle(String code) {

        if(code.isEmpty()) {
            LOGGER.warning("Any code to compile!");
            fullCode = null;
        }
        else {
            try {
                fullCode = compiler.compile(code);
            } catch (IOException e) {
                e.printStackTrace();
            }

            if (fullCode != null)
                LOGGER.info("Valid compilation!");
            else
                LOGGER.warning("Cannot compile program.");
        }
        return fullCode;
    }

}
