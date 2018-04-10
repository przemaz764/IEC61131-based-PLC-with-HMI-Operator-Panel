package com.programmer.load;

import java.util.ArrayList;

public class CodeList {

    private ArrayList<Integer> codeList;

    public CodeList() {

        this.codeList = new ArrayList<>();
        codeList.add(0);
    }

    public ArrayList<Integer> getCodeList() {
        return codeList;
    }

    public void addCompiledCodeLine(ArrayList<Integer> codeLine){

        codeList.addAll(codeLine);
        actualizePlcMemorySize(codeLine.size());
    }

    public int getCodeListIndexOf(int index){
        return codeList.get(index);
    }

    private void actualizePlcMemorySize(int size){
        codeList.set(0, codeList.get(0) + size);
    }
}
