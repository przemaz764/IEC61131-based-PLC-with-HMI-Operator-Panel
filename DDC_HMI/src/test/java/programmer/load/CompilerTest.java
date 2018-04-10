package programmer.load;

import com.programmer.load.CodeList;
import com.programmer.load.Compiler;
import com.programmer.orders.Order;
import com.programmer.orders.OrdersLoader;
import org.junit.Test;

import java.io.IOException;
import java.util.ArrayList;

import static junit.framework.Assert.assertEquals;

/**
 * Created by bobaxix on 17.09.17.
 */
public class CompilerTest {

    @Test
    public void testLabels() throws IOException{

        String code = "AND M0.0 \n" +
                "JMP skok \n" +
                "AND M1.0 \n" +
                "\n"+
                "skok: \n" +
                "AND M2.0";
        ArrayList<Order> orderList = OrdersLoader.getInstance().loadOrdersFromTxtFile();
        Compiler compiler = new Compiler(orderList);

        CodeList codeList = compiler.compile(code);
        assertEquals(0x0C000003 ,(int) codeList.getCodeListIndexOf(2));
    }

    @Test
    public void tagsTest() throws IOException {

    }

    @Test
    public void anotherTestLabels() throws IOException{

        String code = "JMP skok1 \n" +
                "skok2: \n" +
                "JMP skok2 \n" +
                "AND MD2 \n" +
                "NOT \n" +
                "AND M2.0 \n" +
                "skok1: \n" +
                "OR MB2 \n" +
                "APB_WR C0.CU";

        ArrayList<Order> orderList = OrdersLoader.getInstance().loadOrdersFromTxtFile();
        Compiler compiler = new Compiler(orderList);

        CodeList codeList = compiler.compile(code);

        assertEquals(0x00000007, codeList.getCodeListIndexOf(0));
        assertEquals(0x0C000005, (int) codeList.getCodeListIndexOf(1));
        assertEquals(0x0C000001 ,(int) codeList.getCodeListIndexOf(2));
        assertEquals(0x010003C0, (int) codeList.getCodeListIndexOf(3));
        assertEquals(0x0B000000, (int) codeList.getCodeListIndexOf(4));
        assertEquals(0x1E000000, (int) codeList.getCodeListIndexOf(7));
    }

    @Test
    public void TestRepeatedLabels() throws IOException{

        String code = "JMP skok1 \n" +
                "skok2: \n" +
                "JMP skok2 \n" +
                "AND MD2 \n" +
                "NOT \n" +
                "AND M2.0 \n" +
                "skok2: \n" +
                "OR MB2 \n" +
                "skok2: \n"+
                "APB_WR C0.CU";

        ArrayList<Order> orderList = OrdersLoader.getInstance().loadOrdersFromTxtFile();
        Compiler compiler = new Compiler(orderList);

        CodeList codeList = compiler.compile(code);

        assertEquals(null, codeList);
    }

    @Test
    public void WrongArgumentTest() throws IOException{

        String code = "JMP skok1 \n" +
                "skok1: \n" +
                "JMP skok2 \n" +
                "AND AS2 \n" +
                "NOT \n" +
                "AND M2.0 \n" +
                "OR MxB2 \n" +
                "APB_WR C0.CU";

        ArrayList<Order> orderList = OrdersLoader.getInstance().loadOrdersFromTxtFile();
        System.out.println(orderList.get(1).getMnemonic());
        Compiler compiler = new Compiler(orderList);

        CodeList codeList = compiler.compile(code);

        assertEquals(null, codeList);

    }

    @Test
    public void InvalidOrderTest() throws IOException{

        String code = "JMP skok1 \n" +
                "skok1: \n" +
                "JMP skok2 \n" +
                "ANDXA A2 \n" +
                "NOT \n" +
                "AND M2.0 \n" +
                "OR MxB2 \n" +
                "APB_WR C0.CU";

        ArrayList<Order> orderList = OrdersLoader.getInstance().loadOrdersFromTxtFile();
        Compiler compiler = new Compiler(orderList);

        CodeList codeList = compiler.compile(code);

        assertEquals(null, codeList);

    }

}
