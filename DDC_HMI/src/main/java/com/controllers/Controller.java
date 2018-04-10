package com.controllers;

import javafx.fxml.FXMLLoader;

import java.io.IOException;

public class Controller{

    public FXMLLoader getFXMLLoader(String name) {
        FXMLLoader loader = new FXMLLoader();
        loader.setLocation(getClass().getResource("/fxml/" + name));
        return loader;
    }

    public <T> T getPane(FXMLLoader loader) throws IOException{
        return loader.load();
    }

    public static <T> T getController(FXMLLoader loader){
        T controller = loader.getController();
        return controller;
    }
}
