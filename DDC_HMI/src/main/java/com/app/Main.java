package com.app;

import java.io.IOException;
import java.util.ArrayList;

import com.common.SpiManager;
import com.panel.connect.MyThread;
import com.controllers.RootLayout;
import com.programmer.orders.*;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.layout.*;
import javafx.stage.Stage;

public class Main extends Application {

    /*
    TO DO:
    - load tags from file
    - add standard masks (ex. for APB REGISTER)
    - comments on start line
     */
	public static ArrayList<Order> ordersList;
	private Stage primaryStage;

	@Override
	public void start(Stage primaryStage) {

		this.primaryStage = primaryStage;
		try{
			OrdersLoader loader = OrdersLoader.getInstance();
			ordersList = loader.loadOrdersFromTxtFile();

		}
		catch(IOException e){
			System.out.println("Err");
			e.printStackTrace();
		}

		stageStart();
	}

	@Override
	public void stop(){
		try{
			OrdersLoader loader = OrdersLoader.getInstance();
			loader.saveOrdersToTxtFile(ordersList);
			System.out.println("Stop app");
		}
		catch(IOException e){

		}

	}
	
	private void stageStart(){
		try {
			FXMLLoader loader = new FXMLLoader();
			loader.setLocation(getClass().getResource(
					"/fxml/root_layout.fxml"));
			BorderPane borderPane =  loader.load();
			borderPane.setFocusTraversable(false);
			RootLayout controller = loader.getController();
			controller.setCommandsList(ordersList);

			Scene scene = new Scene(borderPane);
			scene.getStylesheets().add(getClass().getResource(
					"/css/elevator.css").toExternalForm());

			primaryStage.setScene(scene);
			primaryStage.setFullScreen(true);
			primaryStage.setAlwaysOnTop(true);
			primaryStage.show();

		} catch(Exception e) {
			e.printStackTrace();
		}
	}


	public static void main(String[] args) {
		launch(args);
	}
}
