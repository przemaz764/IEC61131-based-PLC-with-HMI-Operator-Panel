package programmer.instructions;

import com.programmer.instructions.InOutMem;
import com.programmer.instructions.Instruction;
import org.junit.Test;

import java.util.ArrayList;

import static junit.framework.Assert.assertEquals;

/**
 * Created by bobaxix on 16.09.17.
 */
public class InOutMemTest {

    @Test
    public void generatedCodeIsEqualCodeForMemoryBitAccess(){
        Instruction iom = new InOutMem();
        iom.set("AND",16, "M0.3", 10);
        ArrayList<Integer> code = iom.generateCodeForInstruction();

        assertEquals(0x10000083, (int) code.get(0));
    }

    @Test
    public void generatedCodeIsEqualCodeForInputByteAccess(){
        Instruction iom = new InOutMem();
        iom.set("AND",2, "IB3",5);
        ArrayList<Integer> code = iom.generateCodeForInstruction();

        assertEquals(0x02000118, (int) code.get(0));
    }

    @Test
    public void generatedCodeIsEqualCodeForOutputWordAccess(){
        Instruction iom = new InOutMem();
        iom.set("OR",20, "OW1", 6);
        ArrayList<Integer> code = iom.generateCodeForInstruction();

        assertEquals(0x14000250, (int) code.get(0));
    }

    @Test
    public void generatedCodeIsEqualCodeForMemoryDoubleWordAccess(){
        Instruction iom = new InOutMem();
        iom.set("AND",1, "MD2", 1);
        ArrayList<Integer> code = iom.generateCodeForInstruction();

        assertEquals(0x010003C0, (int) code.get(0));
    }

    @Test
    public void cannotGeneratedCodeForInvaildArg(){

        Instruction iom = new InOutMem();
        iom.set("AND", 5, "MZ.2", 10);
        ArrayList<Integer> codeLine = iom.generateCodeForInstruction();
        assertEquals(null ,codeLine);
    }

}
