package com.controllers;

import com.programmer.connect.LoadSaveData;
import javafx.beans.property.SimpleStringProperty;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;

public class FileChooserLayoutController {

    @FXML
    private ListView<String> fileListView;

    @FXML
    private TextField filename;

    @FXML
    private Label localization;

    @FXML
    private Label warning;

    private Path actualPath;
    private final Path START_PATH = Paths.get("");
    private ObservableList<String> pathList;
    private Operation operationToDo;
    private TextArea programTextField;
    private Runnable backToPrevious;
    private boolean saveFlag = false;


    private SimpleStringProperty localizationProperty;

    @FXML
    public void initialize(){

        actualPath = START_PATH;
        pathList = FXCollections.observableArrayList();
        refreshPathList();
        fileListView.setCellFactory(param -> new ListCell<String>(){
            private ImageView imageView = new ImageView();
            @Override
            public void updateItem(String name, boolean empty){
                super.updateItem(name, empty);
                fileListView.getSelectionModel().selectFirst();
                Image i;
                if(empty){
                    setText(null);
                    setGraphic(null);
                }
                else{
                    File f = Paths.get(actualPath.toAbsolutePath().toString() ,name).toFile();
                    if(f.isDirectory())
                        i = new Image(getClass().getResource("/icons/folder.png").toString());
                    else
                        i = new Image(getClass().getResource("/icons/file.png").toString());

                    imageView.setImage(i);

                    setText(name);
                    setGraphic(imageView);
                }
            }
        });

        fileListView.setItems(pathList);

        fileListView.getSelectionModel().selectedItemProperty().
                addListener((observable, oldValue, newValue) ->{
            filename.setText(newValue);
        } );

        localizationProperty = new SimpleStringProperty(actualPath.toAbsolutePath().toString());

        localization.textProperty().bind(localizationProperty);

    }

    private void refreshPathList(){
        pathList.clear();

        FilenameFilter filter = new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
                Path p = Paths.get(dir.getAbsolutePath(), name);
                if(name.endsWith(".txt") ||
                        (p.toFile().isDirectory() && !name.startsWith(".")))
                    return true;
                return false;
            }
        };

        File ff = new File(actualPath.toAbsolutePath().toString());
        for(File f : ff.listFiles(filter))
            pathList.add(f.getName());
    }

    @FXML
    private void goUpWithDirectory(){
        try {
            actualPath = actualPath.toAbsolutePath().getParent();
            localizationProperty.set(actualPath.toAbsolutePath().toString());
            saveFlag = false;
            warning.setVisible(false);
            refreshPathList();
        }
        catch(NullPointerException n){}
    }

    @FXML
    private void openButtonHandle(){
        File f = getSelectedFile();

        if(f.isDirectory()){
            actualPath = f.toPath();
            localizationProperty.set(actualPath.toAbsolutePath().toString());
            refreshPathList();
        }
        else{
            if(operationToDo == Operation.SAVE){
                if(f.exists()){
                    if(saveFlag == false){
                        warning.setVisible(true);
                        saveFlag = true;
                    }
                    else{
                        warning.setVisible(false);
                        saveFlag = false;
                        okButtonHandle();
                    }
                }
                else {
                    okButtonHandle();
                    warning.setVisible(false);
                }
            }
            else{
                System.out.println("load");
                try {
                    String programText = LoadSaveData.loadProject(f).toString();
                    programTextField.setText(programText);
                    closeChoosePane();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    @FXML
    private void okButtonHandle(){
        File f = getSelectedFile();
        try {
            LoadSaveData.saveProject(f, programTextField.getText());
            closeChoosePane();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private File getSelectedFile(){
        String name = filename.getText();
        return Paths.get(actualPath.toAbsolutePath().toString(), name).toFile();
    }

    public void setActualOperation(Operation o){
        operationToDo = o;
        if(operationToDo == Operation.LOAD)
            filename.setEditable(false);
        else
            filename.setEditable(true);
        refreshPathList();
    }

    public void setTextField(TextArea textArea){
        programTextField = textArea;
    }

    @FXML
    private void closeChoosePane(){
        backToPrevious.run();
    }

    public void setBackToPrevious(Runnable r){
        backToPrevious = r;
    }

}
