package com.programmer.tags;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

public class TagLoader {

    static public ArrayList<Tag> loadTags(String path, String name){
        ArrayList<Tag> tagList = new ArrayList<>();
        try(BufferedReader br = new BufferedReader(new FileReader(path+
                System.lineSeparator() + name+".tag"))) {
            String line = br.readLine();
            while(line != null){
                String[] splittedLine = line.split(" ");
                String tag = splittedLine[0].trim();
                String address = splittedLine[1].trim();
                tagList.add(new Tag(tag, address));
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return tagList;
    }
}
