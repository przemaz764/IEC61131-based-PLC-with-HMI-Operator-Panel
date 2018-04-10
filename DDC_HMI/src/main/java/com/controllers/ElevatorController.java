package com.controllers;

import com.panel.transaction.BufferManager;
import com.panel.transaction.MyIntegerProperty;
import com.panel.transaction.PropertyManager;
import com.panel.view.ViewManager;
import javafx.application.Platform;
import javafx.beans.property.SimpleIntegerProperty;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;

import java.util.ArrayList;

public class ElevatorController {

    @FXML
    ArrayList<Button> buttons;

    @FXML
    ArrayList<Rectangle> cabinPosition;

    @FXML
    ArrayList<Rectangle> controls;

    private Runnable backToStart;
    private ViewManager vw;

    @FXML
    private void initialize(){
        for(Rectangle r : controls) {
            r.getStyleClass().add("controls");
        }
        for(Button button : buttons)
            button.getStyleClass().add("buttonsInactive");
        System.out.println("Initialize elevator");
    }

    @FXML
    private void closeApp(){
        Platform.exit();
    }

    @FXML
    private void backToStart(){
        backToStart.run();
    }

    public void setBackToStart(Runnable r){
        backToStart = r;
    }

    private void recolorFloor(Rectangle floor, int value){
        if(value == 0)
            floor.setFill(Color.GREEN);
        else
            floor.setFill(Color.RED);
    }

    public void setViewManager(ViewManager vw){
        this.vw = vw;
    }

    public void setActionsForFloorIndicator(){
        for(Rectangle floor : cabinPosition){
            String id = floor.getId();
            MyIntegerProperty property = vw.getPropertyManager().getProperty(id);
            if(property != null){
                property.addValueListener(value -> {
                        recolorFloor(floor, value);
                } );
            }
        }
    }

    public void setActionsControls(){
        PropertyManager propertyManager = vw.getPropertyManager();
        for(Rectangle r : controls){
            String id = r.getId();
            SimpleIntegerProperty property = propertyManager.getProperty(id);
            if(property != null)
                property.addListener((observableValue, oldValue, newValue) -> {
                    if((int)newValue == 1)
                        r.setFill(Color.BLUE);
                    else
                        r.setFill(Color.valueOf("#353634"));
                });
        }
    }

    public void setActionsCabinRequests() {
        for (Button button : buttons) {

            String id = button.getId();

            button.setOnAction((value) -> {
                button.getStyleClass().removeAll("buttonsInactive");
                button.getStyleClass().add("buttonsActive");
                BufferManager bufferManager = vw.getBufferManager();
                try {
                    bufferManager.setParameter(id, 1);
                }
                catch(NullPointerException e){
                    System.out.println("Cannot find property! Check config!");
                }
            });
            PropertyManager propertyManager = vw.getPropertyManager();
            MyIntegerProperty property = propertyManager.getProperty(id);
            if (property != null) {
                property.addValueListener(newValue -> {
                    if (newValue == 0) {
                        button.getStyleClass().removeAll("buttonsActive");
                        button.getStyleClass().add("buttonsInactive");
                    }
                });
            }
        }
    }
}
