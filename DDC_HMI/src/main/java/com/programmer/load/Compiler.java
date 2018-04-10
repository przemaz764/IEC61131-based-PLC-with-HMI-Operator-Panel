package com.programmer.load;

import com.programmer.instructions.Instruction;
import com.programmer.instructions.JumpControl;
import com.programmer.instructions.Label;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.logging.Logger;

import com.programmer.orders.Order;
import com.programmer.tags.List;

public class Compiler {

	private boolean error = false;
	private static final Logger LOGGER = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);

	private ArrayList<Order> orderList;

	public Compiler(ArrayList<Order> orderList){
		this.orderList = orderList;
	}

	public CodeList compile(String code) throws IOException{

		Segregation segregation = new Segregation(orderList);

		ArrayList<Instruction> codeLinesInInstructionList = makeCodeLineList(segregation, code);

		error = checkIfLabelsAreRepeated(codeLinesInInstructionList);

		if(!error)
			return generateBinaryCode(codeLinesInInstructionList);

		return null;
	}

	private ArrayList<Instruction> makeCodeLineList(Segregation segregation, String code) throws IOException{

		StringReader sr = new StringReader(code);
		BufferedReader br = new BufferedReader(sr);
		ArrayList<Instruction> instructions = new ArrayList<>();
		String line;
		int instructionNumber = 0;
        Instruction instruction;

		while((line = br.readLine()) != null){

        if(line.isEmpty())
            continue;

        instruction = segregation.getInstructionObject(line, instructionNumber++);

			if(instruction == null)
			    error = true;
			else
				instructions.add(instruction);
		}

		return instructions;
	}

	private boolean checkIfLabelsAreRepeated(ArrayList<Instruction> codeLines){

		int size = codeLines.size();
		for(int i = 0; i < size -1; i++){

			if(codeLines.get(i).isLabel()){
				String firstLabel = ((Label) codeLines.get(i)).getLabel();

				for(int j = i+1; j < size; j++){

					if(codeLines.get(j).isLabel()){
						String secondLabel = ((Label) codeLines.get(j)).getLabel();

						if(firstLabel.equals(secondLabel)) {
							LOGGER.warning("Repeated labels in lines " +
									codeLines.get(i).getInstructionLineNumber() + ""
									+ " and " + codeLines.get(j).getInstructionLineNumber());
							error = true;
						}
					}
				}
			}
		}
		return error;
	}

	private CodeList generateBinaryCode(ArrayList<Instruction> instructions){

		CodeList codeList = new CodeList();
		for(Instruction instruction : instructions){

			if(instruction.isJump())

				((JumpControl) instruction).whereShouldJump(instructions);

			ArrayList<Integer> codeLine = instruction.generateCodeForInstruction();

            if(codeLine != null)
				codeList.addCompiledCodeLine(codeLine);
			else
				error = true;
		}

		if(error)
		    return null;

		return codeList;
	}

}
