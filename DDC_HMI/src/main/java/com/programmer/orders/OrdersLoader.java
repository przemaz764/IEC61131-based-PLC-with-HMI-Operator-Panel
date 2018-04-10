package com.programmer.orders;

import java.io.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.regex.Pattern;

/**
 * Created by bobaxix on 16.09.17.
 */
public class OrdersLoader {

    private static OrdersLoader instance = new OrdersLoader();

    private ArrayList<Order> ordersList = new ArrayList<Order>();

    private OrdersLoader(){

    }

    public static OrdersLoader getInstance(){
        return instance;
    }

    public ArrayList<Order> loadOrdersFromTxtFile() throws IOException{
        BufferedReader br = new BufferedReader(new FileReader("orders.txt"));
        String line;
        br.readLine();

        while((line = br.readLine()) != null){
            String[] splittedLine = line.split(Pattern.quote("|"));
            String name = splittedLine[0].trim();
            String code = splittedLine[1].trim();
            String type = splittedLine[2].trim();

            Order order = new Order(name, code, type);

            ordersList.add(order);
        }
    return ordersList;
    }

    public void saveOrdersToTxtFile(ArrayList<Order> orderList) throws IOException{
        BufferedWriter bufferedWriter = new BufferedWriter(new FileWriter("orders.txt"));
        bufferedWriter.write("  ORDERS  | CODE | TYPE ");
        Collections.sort(orderList, (a,b) -> a.getType().compareToIgnoreCase(b.getType()));
        for(Order order : orderList){

            String newOrderName = order.getMnemonic();
            byte newOrderNameStringSize = (byte) newOrderName.length();

            String newOrderCode = order.getCode();
            byte newOrderCodeStringSize = (byte) newOrderCode.length();
            String newOrderType = order.getType();

            bufferedWriter.newLine();

            bufferedWriter.write(" "+newOrderName);

            for(byte b = 0; b < (OrderStringSize.NAME - newOrderNameStringSize) -1; b++)
                bufferedWriter.write(" ");

            bufferedWriter.write("|  "+newOrderCode);

            for(byte b = 0; b < (OrderStringSize.CODE - newOrderCodeStringSize) -2; b++)
                bufferedWriter.write(" ");

            bufferedWriter.write("| "+newOrderType);
        }

        bufferedWriter.close();
    }

    private class OrderStringSize{

        public static final byte NAME = 10;
        public static final byte CODE = 6;
    }
}
