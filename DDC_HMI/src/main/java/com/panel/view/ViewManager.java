package com.panel.view;

import com.panel.transaction.*;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ViewManager {

    /*
    TO DO: read config files from RasPi, not from .jar file
     */

    String[] regex = {"-? *(label): *(\\w+)$",
                      "-? *(address): *(\\d+.\\d+.\\w+)$"};

    private PropertyManager propertyManager;
    private BufferManager bufferManager;

    public ViewManager(String fileName){
        loadConfiguration(fileName);
    }

    private void loadConfiguration(String fileName){

        Matcher matcher;
        String line;
        int bufferSize = 0;

        ArrayList<Property> propertyList = new ArrayList<>();
        ArrayList<PanelField> bufferList = new ArrayList<>();

        try(InputStream inputStream = getClass().getResourceAsStream("/configs/" + fileName);
            InputStreamReader streamReader = new InputStreamReader(inputStream, StandardCharsets.UTF_8);
            BufferedReader br = new BufferedReader(streamReader))
        {
            String label = null;
            String mnemonic = null;
            String workman = null;

            line = br.readLine();

            while (line != null) {

                if(checkIfNewStructure(line)){
                    if(line.trim().matches("- *in:$"))
                        workman = "in";
                    else if(line.matches("- *out:$"))
                        workman = "out";

                    line = br.readLine();
                }
                else{

                    do{

                        matcher = checkMatches(line);

                        try {
                            String name = matcher.group(1);
                            if (name.equals("label"))
                                label = matcher.group(2);
                            else if (name.equals("address"))
                                mnemonic = matcher.group(2);
                        }
                        catch (IllegalArgumentException e){
                            System.out.println("Cannot match, check config!");
                        }

                        line = br.readLine();
                        if(line == null)
                            break;
                        line = line.trim();
                    }
                    while(line.startsWith("-") == false);

                    int address = AddressCreator.getAddress(mnemonic);

                    if(workman.equalsIgnoreCase("in"))
                        propertyList.add(new Property(label, address));
                    else if(workman.equalsIgnoreCase("out")){
                        int bufferNumber = AddressCreator.getBufferLine(address);

                        if(bufferNumber > bufferSize)
                            bufferSize = bufferNumber;

                        bufferList.add(new PanelField(label, address));
                    }

                }
            }
        }
        catch(IOException e){}

        System.out.println("BufferSize = "+(bufferSize+1));
        bufferManager = new BufferManager(bufferList, bufferSize + 1);
        propertyManager = new PropertyManager(propertyList);
    }

    private boolean checkIfNewStructure(String line){
        line = line.trim();
        if(line.startsWith("-") && line.endsWith(":"))
            return true;

        return false;
    }


    public BufferManager getBufferManager(){
        return bufferManager;
    }

    public PropertyManager getPropertyManager() {
        return propertyManager;
    }

    private Matcher checkMatches(String line){

        Pattern pattern;
        Matcher matcher;
        for(String rgx : regex) {
            pattern = Pattern.compile(rgx);
            matcher = pattern.matcher(line);
            if(matcher.find())
                return matcher;
        }
        return null;
    }
}
