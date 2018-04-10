package com.programmer.connect;

import java.io.*;

public abstract class LoadSaveData {

    public static StringBuilder loadProject(File file) throws IOException {

        String path = file.getAbsolutePath();
        BufferedReader br = new BufferedReader(new FileReader(path));
        StringBuilder sb = new StringBuilder();
        String line;
        while((line = br.readLine()) != null)
            sb.append(line+System.lineSeparator());

        br.close();
        return sb;
    }

    public static void saveProject(File file, String project) throws IOException {

        String path = file.getAbsolutePath();
        BufferedReader br = new BufferedReader(new StringReader(project));
        BufferedWriter bw = new BufferedWriter(new FileWriter(path));

        String line;
        while((line = br.readLine()) != null){
            bw.write(line);
            bw.newLine();
        }

        br.close();
        bw.close();
    }
}
