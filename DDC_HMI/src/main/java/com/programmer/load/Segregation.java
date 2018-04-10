package com.programmer.load;

import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.LogRecord;
import java.util.logging.Logger;

import com.programmer.instructions.*;
import com.programmer.instructions.Instruction;
import com.programmer.orders.Order;

public class Segregation {

	private ArrayList<Order> orderList;
	private boolean ifLabel = false;
	private final static Logger LOGGER = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);

	public Segregation(ArrayList<Order> orderList){
		this.orderList = orderList;
	}

	private String[] parseInstructionLine(String line){

		String codeLine = line.split(";")[0];
		String[] parsedCodeLine = codeLine.split(" ");

		String orderName = parsedCodeLine[0].trim();
		ifLabel = orderName.endsWith(":");
		orderName = orderName.split(":")[0];

		String operand;

		try{
			operand = parsedCodeLine[1].trim();
		}
		catch(ArrayIndexOutOfBoundsException e){
			operand = null;
		}

		String[] result = {orderName, operand};

		return result;
	}

	public Instruction getInstructionObject(String line, int lineNumber){

		String[] parsedCodeLine = parseInstructionLine(line);
		String orderName = parsedCodeLine[0];
		String operand = parsedCodeLine[1];

		if(!(orderName == null))
            orderName =orderName.trim();

		if(!(operand == null))
		    operand.trim();

		for(Order order : orderList){

			String mnemonic = order.getMnemonic();
			if(mnemonic.equals(orderName) && !ifLabel){
				String type = order.getType();
				int orderCode = Integer.decode(order.getCode());
				Instruction instruction = getInstructionObjectByType(type);
				instruction.set(orderName, orderCode, operand, lineNumber);
				return instruction;
			}
		}

		if(operand == null && ifLabel) {
            Instruction instruction = new Label();
            instruction.set(orderName,lineNumber);
            return instruction;
        }

        LOGGER.log(new LogRecord(Level.WARNING, "Line "+lineNumber+" : invalid order."));
		return null;
	}

	private Instruction getInstructionObjectByType(String type){
		switch(type){
			case("IOM INSTRUCTIONS"):
				return new InOutMem();
			case("NAO"):
				return new NoArgsOp();
			case("JUMP CONTROL"):
				return new JumpControl();
			case("OP WITH CONST"):
				return new WithConst();
			case("APB"):
				return new Apb();
			default:
				return null;
		}
	}
}
