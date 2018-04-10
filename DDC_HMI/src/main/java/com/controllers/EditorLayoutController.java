package com.controllers;

import com.programmer.orders.Order;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.scene.control.*;

import javafx.event.ActionEvent;
import javafx.scene.control.cell.PropertyValueFactory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;


public class EditorLayoutController {

    /* TO DO:
    - validate of hex value
     */

    private ArrayList<Order> orderList;
    private ArrayList<Order> toDeleteList;
    private ArrayList<Order> toSaveList;

    private Comparator<Order> comparator;

    private Runnable backToStart;

    @FXML
    TextField newOrderName, newOrderCode;

    @FXML
    ChoiceBox newOrderType;

    @FXML
    ObservableList<Order> orderObservableList = FXCollections.observableArrayList();

    @FXML
    TableView<Order> table;

    @FXML
    TableColumn<Order, String> orderName, orderCode, orderType;

    @FXML
    private void initialize(){
        toDeleteList = new ArrayList<>();
        toSaveList = new ArrayList<>();
        comparator = (a,b) -> a.getType().compareToIgnoreCase(b.getType());
    }

    public void setOrderList(ArrayList<Order> orderList){

        toDeleteList.clear();
        toSaveList.clear();
        this.orderList = orderList;
        this.orderObservableList = FXCollections.observableArrayList();
        this.orderObservableList.addAll(orderList);
        Collections.sort(this.orderObservableList, comparator);
        table.setItems(this.orderObservableList);
        orderName.setCellValueFactory(new PropertyValueFactory<>("mnemonic"));
        orderCode.setCellValueFactory(new PropertyValueFactory<>("code"));
        orderType.setCellValueFactory(new PropertyValueFactory<>("type"));

    }

    @FXML
    private void addNewOrderHandler(ActionEvent event){

        String newOrderName = this.newOrderName.getText();
        String newOrderCode = this.newOrderCode.getText();
        String newOrderType = (String) this.newOrderType.getValue();

        boolean validateResult = newOrderValidator(newOrderName,
                                                   newOrderCode,
                                                   newOrderType);

        if(validateResult) {
            Order order = new Order(newOrderName, newOrderCode, newOrderType);
            orderObservableList.add(order);
            Collections.sort(this.orderObservableList, comparator);
            toSaveList.add(order);
            clearChoosePane();
        }
    }

    private boolean newOrderValidator(String newOrderName,
                                      String newOrderCode,
                                      String newOrderType){

        boolean nameChecker = true, codeChecker = true, typeChecker = true;
        boolean newOrderChecker = true;

        if(newOrderType == null){
            this.newOrderType.setStyle("-fx-border-color: red;");
            typeChecker = false;
        }

        if(newOrderName.isEmpty()){
            this.newOrderName.setStyle("fx-border-color: red;");
            nameChecker = false;
        }

        if(newOrderCode.isEmpty()){
            this.newOrderCode.setStyle("fx-border-color: red;");
            codeChecker = false;
        }


        if(nameChecker && codeChecker && newOrderChecker) {
            for (Order order : orderObservableList) {
                String orderName = order.getMnemonic();
                String orderCode = order.getCode();

                if (orderName.equals(newOrderName)) {
                    this.newOrderName.setStyle("-fx-text-inner-color: red;");
                    nameChecker = false;
                }
                
                if (orderCode.equals(newOrderCode)){
                    this.newOrderCode.setStyle("-fx-text-inner-color: red;");
                    codeChecker = false;
                }


                if (nameChecker && codeChecker)
                    break;
            }
        }
        System.out.println(newOrderChecker);
        return (nameChecker && codeChecker && typeChecker && newOrderChecker);
    }



    @FXML
    private void saveOrdersHandler(){
        orderList.addAll(toSaveList);
        orderList.removeAll(toDeleteList);
    }

    @FXML
    private void deleteOrderHandler(){
        Order selectedOrder = table.getSelectionModel().getSelectedItem();
        orderObservableList.remove(selectedOrder);
        toDeleteList.add(selectedOrder);
    }

    @FXML
    private void newOrderNameOnAction(){
        this.newOrderName.setStyle("-fx-text-inner-color: black");
    }

    @FXML
    private void newOrderCodeOnAction(){
        this.newOrderCode.setStyle("-fx-text-inner-color: black");
    }

    @FXML
    private void newOrderTypeOnAction(){
        this.newOrderType.setStyle("-fx-border-color: none");
    }

    @FXML
    private void backToStartScreen(){
        clearChoosePane();
        backToStart.run();
    }

    public void setBackToStart(Runnable r){
        backToStart = r;
    }

    private void clearChoosePane(){
        newOrderName.setText("");
        newOrderCode.setText("");
        newOrderType.setValue(null);
    }

}


