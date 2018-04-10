package com.programmer.orders;

import java.io.Serializable;

public class Order implements Serializable {

	private static final long serialVersionUID = -3867063355123488136L;
	private final String type;
	private final String code;
	private final String mnemonic;
	
	public Order(String mnemonic, String code, String type){
		this.type = type;
		this.code = code;
		this.mnemonic = mnemonic;
	}
	
	
	public String getType(){
		return type;
	}
	
	public String getMnemonic(){
		return mnemonic;
	}
	
	public String getCode(){
		return code;
	}

	}

