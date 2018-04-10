package com.panel.connect;

import com.common.SpiManager;
import com.panel.transaction.BufferManager;
import com.panel.view.ViewManager;
import javafx.concurrent.Service;
import javafx.concurrent.Task;


public class MyThread extends Service<Void>{

    private SpiManager spiManager;
    private int[] buffer;
    private ViewManager vm;
    private int control;

    public MyThread(){
        this.spiManager = SpiManager.getInstance();
        control = readControl();
        buffer = new int[control];
    }

    @Override
    protected Task<Void> createTask() {
        return new Task<Void>(){
            @Override
            protected Void call() throws Exception {

//                    BufferManager nbm = vm.getBufferManager();
//                    int[] buffers = nbm.getBuffers();
//                    synchronized (buffers) {
//                        for (int i = 0; i < control; i++)
//                            spiManager.sendDoubleWord(buffers[i]);
//                    }
//                nbm.clean();
//
//                for (int i = 0; i < control; i++) {
//                    buffer[i] = spiManager.sendDoubleWord(0);
//                    System.out.println("Received data " + i + ": " + buffer[i]);
//                }
//
//                buffer[0] = 0xFF;
//                vm.getPropertyManager().setProperties(buffer);
//                rest(1000);
//
//                System.out.println("TRANSMISSION");
//                return null;

                int status = readStatus();
                System.out.print("Status: ");
                for(int z = 7; z >= 0; z--){
                    if(((status >> z) & 0x01) == 1)
                        System.out.print("1");
                    else
                        System.out.print("0");
                }
                System.out.print("\n\r");

                // Send data to bridge
                if((status & Status.SPI_EMPTY) != 0 ) {
                    BufferManager nbm = vm.getBufferManager();
                    int[] buffers = nbm.getBuffers();
                    int i;
                    synchronized (buffers) {
                        int size;
                        if(control <= buffers.length)
                            size = control;
                        else
                            size = buffers.length;

                        for (i = 0; i < size; i++) {
                            sendData(buffers[i]);
                            System.out.println("Buffer["+i+"] = "+buffers[i]);
                        }
                        nbm.clean();
                    }
                    for(; i < control; i++){
                        sendData(0);
                        System.out.println("ZeroBuffer["+i+"] = 0");
                    }
                }

                // Receive data from bridge
                if((status & Status.APB_READY) != 0)
                    for(int i =0; i < control; i++) {
                        buffer[i] = receiveData();
                        System.out.println("Received data "+i+": "+buffer[i]);
                        System.out.println("Hex "+i+": "+Integer.toHexString(buffer[i]));
                        System.out.println("Bin "+i+": "+Integer.toBinaryString(buffer[i]));
                    }

                vm.getPropertyManager().setProperties(buffer);
                rest(100);

                System.out.println("------------");
                return null;
            }
        };
    }



    private int readStatus(){
        spiManager.sendAddress(Operation.READ, Register.STATUS);
        return spiManager.readRegister();
    }

    private int readControl(){
        spiManager.sendAddress(Operation.READ, Register.CTRL);
        return spiManager.readRegister();
    }

    private void sendData(int data){
        spiManager.sendAddress(Operation.WRITE, Register.RX_FIFO);
        spiManager.sendDoubleWord(data);
    }

    private int receiveData(){
        spiManager.sendAddress(Operation.READ, Register.TX_FIFO);
        return spiManager.readRegister();
    }


    public void setViewManager(ViewManager vm){this.vm = vm;}

    private void rest(long time){
        try {
            Thread.sleep(time);
        } catch (InterruptedException e) {
            System.out.println("Sleep interrupted");
        }
    }
}
