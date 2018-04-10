package com.programmer.tags;

import java.util.ArrayList;

public class List{

    static List tagsList = new List();

    private ArrayList<Tag> tagList = new ArrayList<>();

    private List(){}

    public void add(Tag tag){
        tagList.add(tag);
    }

    public void clear(){
        tagList.clear();
    }

    public void setTagList(ArrayList<Tag> tagList){
        this.tagList = tagList;
    }

    public String findTag(String tag) {
        if(!tagList.isEmpty()){
            for(Tag t_tag : tagList){
                if(tag.equals(t_tag.getTag())){
                    return t_tag.getAddress();
                }
            }
        }
        return null;
    }

    public static List getTagsList(){
        return tagsList;
    }
}
