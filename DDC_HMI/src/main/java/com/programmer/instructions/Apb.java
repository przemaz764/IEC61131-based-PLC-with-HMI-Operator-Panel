package com.programmer.instructions;

import com.programmer.connect.BridgeRegister;
import com.programmer.connect.MemoryMap;

import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by bobaxix on 20.09.17.
 */
public class Apb extends Instruction {

    private String[] parsedOperand;
    private Matcher matcher;
    private final String[] patterns ={
            "(OUT)$", "(IN)$",
            "(C)(\\d+)\\.(CV|CU|CD|R|S|PV|CV|QD|QU)$",
            "(T)(\\d+)\\.(TYPE|PT|IN|Q|ET)$",
            "(BR)\\.(STATUS|RESET|CTRL|APB_STATE|SPI_STATE|TX_FIFO|" +
                    "TX_FIFO_RA|TX_FIFO_WA|RX_FIFO|RX_FIFO_RA|RX_FIFO_WA)$"
    };
    ArrayList<Integer> codeLine;

    private static class CounterArgs{
        final static int CU = 0;
        final static int CD = 1;
        final static int R = 2;
        final static int S = 3;
        final static int PV = 4;
        final static int CV = 5;
        final static int QD = 6;
        final static int QU = 7;
    }

    private static class TimerArgs{
        final static int TYPE = 0;
        final static int PT = 1;
        final static int IN = 2;
        final static int Q = 3;
        final static int ET = 4;
    }

    private final int TIMER_BASE = 0x00000800;
    private final int TIMER_SIZE = 0x000007FF;

    private final int COUNTER_BASE = 0x00000000;
    private final int COUNTER_SIZE = 0x000007FF;


    public Apb(){
        parsedOperand = new String[3];
        codeLine = new ArrayList<>();
    }

    @Override
    public ArrayList<Integer> generateCodeForInstruction(){
        boolean result = parseOperand();
        if(result){
            int address = getAddress();

            if(checkAddress(address)) {
                codeLine.add(orderCode << 24 | address);
                return codeLine;
            }
        }
        else
            LOGGER.warning("Line "+instructionLineNumber+": invalid argument");

        return null;
    }

    public ArrayList<Integer> getCodeLine(){
        return codeLine;
    }

   private boolean parseOperand(){

        boolean result = matchOperand();
        if(result) {
            int numberOfGroups = matcher.groupCount();
            for (int i = 0; i < numberOfGroups; i++)
                parsedOperand[i] = matcher.group(i + 1);
        }
        return result;
   }
    private boolean matchOperand(){

       Pattern pattern;

        for(String regularExpr : patterns){
            pattern = Pattern.compile(regularExpr);
            matcher = pattern.matcher(operand);
            if(matcher.matches())
                return true;
        }

        return false;
    }

    private int getAddress(){
        String baseAddress = parsedOperand[0];

        if(baseAddress.equals("IN"))
            return MemoryMap.APB_IN;
        else if(baseAddress.equals("OUT"))
            return MemoryMap.APB_OUT;
        else if(baseAddress.equals("T")) {
            int address = getTimerRegisterAddress();
            return TIMER_BASE + address;
        }
        else if(baseAddress.equals("C")) {
            int address = getCounterRegisterAddress();
            return COUNTER_BASE + address;
        }
        else if(baseAddress.equals("BR")){
            int address = getBridgeRegisterAddress();
            return MemoryMap.BR_ADR + address;
        }
        return -1;
    }

    private boolean checkAddress(int address){

        String baseAddress = parsedOperand[0];
        boolean result = false;

        if(baseAddress.equals("IN"))
            result = address == MemoryMap.APB_IN;
        else if(baseAddress.equals("OUT"))
            result = address == MemoryMap.APB_OUT;
        else if(baseAddress.equals("T")) {
            result = address >= TIMER_BASE && address <= TIMER_BASE + TIMER_SIZE;
        }
        else if(baseAddress.equals("C")) {
            result = address >= COUNTER_BASE && address <= COUNTER_BASE + COUNTER_SIZE;
        }
        else if(baseAddress.equals("BR"))
            result = address >= MemoryMap.BR_ADR &&
                    address <= (MemoryMap.BR_ADR | BridgeRegister.RESET);
        if(!result)
            LOGGER.warning("Line "+instructionLineNumber+": address out of range");

        return result;
    }

    private int getTimerRegisterAddress(){

        int baseAddressOffset = Integer.parseInt(parsedOperand[1]) * 8;

        String bitAddress = parsedOperand[2];
        int address = 0;

        if(bitAddress.equals("TYPE"))
            address =  TimerArgs.TYPE;
        else if(bitAddress.equals("PT"))
            address = TimerArgs.PT;
        else if(bitAddress.equals("IN"))
            address = TimerArgs.IN;
        else if(bitAddress.equals("Q"))
            address = TimerArgs.Q;
        else if(bitAddress.equals("ET"))
            address = TimerArgs.ET;

        return baseAddressOffset | address;
    }

    private int getCounterRegisterAddress(){

        int baseAddressOffset = Integer.parseInt(parsedOperand[1]) * 8;

        String bitAddress = parsedOperand[2];
        int address = 0;

        if(bitAddress.equals("CU"))
            address =  CounterArgs.CU;
        else if(bitAddress.equals("CD"))
            address = CounterArgs.CD;
        else if(bitAddress.equals("R"))
            address = CounterArgs.R;
        else if(bitAddress.equals("S"))
            address = CounterArgs.S;
        else if(bitAddress.equals("CV"))
            address = CounterArgs.CV;
        else if(bitAddress.equals("PV"))
            address = CounterArgs.PV;
        else if(bitAddress.equals("QD"))
            address = CounterArgs.QD;
        else if(bitAddress.equals("QU"))
            address = CounterArgs.QU;

        return baseAddressOffset | address;
    }

    private int getBridgeRegisterAddress(){
        String registerAddress = parsedOperand[1];
        if(registerAddress.equals("STATUS"))
            return BridgeRegister.STATUS;
        else if(registerAddress.equals("CTRL"))
            return BridgeRegister.CTRL;
        else if(registerAddress.equals("APB_STATE"))
            return BridgeRegister.APB_STATE;
        else if(registerAddress.equals("SPI_STATE"))
            return BridgeRegister.SPI_STATE;
        else if(registerAddress.equals("TX_FIFO"))
            return BridgeRegister.TX_FIFO;
        else if(registerAddress.equals("TX_FIFO_RA"))
            return BridgeRegister.TX_FIFO_RA;
        else if(registerAddress.equals("RX_FIFO_RA"))
            return BridgeRegister.RX_FIFO_RA;
        else if(registerAddress.equals("TX_FIFO_WA"))
            return BridgeRegister.TX_FIFO_WA;
        else if(registerAddress.equals("RX_FIFO"))
            return BridgeRegister.RX_FIFO;
        else if(registerAddress.equals("RX_FIFO_WA"))
            return BridgeRegister.RX_FIFO_WA;
        else if (registerAddress.equals("RESET"))
            return BridgeRegister.RESET;
        return 0;
    }
}
