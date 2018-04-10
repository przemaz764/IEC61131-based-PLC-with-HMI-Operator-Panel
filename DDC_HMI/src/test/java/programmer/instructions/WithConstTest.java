package programmer.instructions;

import com.programmer.instructions.Instruction;
import com.programmer.instructions.WithConst;
import org.junit.Test;

import java.util.ArrayList;

import static junit.framework.Assert.assertEquals;

/**
 * Created by bobaxix on 16.09.17.
 */
public class WithConstTest {

    @Test
    public void generatedCodeIsEqualCodeForConst353(){
        Instruction wc = new WithConst();
        wc.set("ANDI", 10, "#353", 10);
        ArrayList<Integer> code = wc.generateCodeForInstruction();
        assertEquals(0x0A000000, (int) code.get(0));
        assertEquals(0x00000161, (int) code.get(1));
    }

    @Test
    public void generateCodeForHex(){
        Instruction i = new WithConst();
        i.set("ANDI", 10, "0x10", 10);
        ArrayList<Integer> code = i.generateCodeForInstruction();
        assertEquals(0x0A000000, (int) code.get(0));
        assertEquals(0x00000010, (int) code.get(1));

    }

    @Test
    public void generateCodeForHexGreaterThanMax(){
        Instruction i = new WithConst();
        i.set("ANDI", 10, "0x1FAAAAFFF", 10);
        ArrayList<Integer> code = i.generateCodeForInstruction();
        assertEquals(null, code);
    }

    @Test
    public void generateCodeForBadHex(){
        Instruction i = new WithConst();
        i.set("ANDI", 10, "0x1FAAAAFG", 10);
        ArrayList<Integer> code = i.generateCodeForInstruction();
        assertEquals(null, code);
    }
}
