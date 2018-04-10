package programmer.load;

import com.programmer.instructions.Instruction;
import com.programmer.orders.Order;
import com.programmer.orders.OrdersLoader;
import com.programmer.load.Segregation;
import org.junit.Test;

import java.io.IOException;
import java.util.ArrayList;

import static org.junit.Assert.assertEquals;

/**
 * Created by bobaxix on 16.09.17.
 */
public class SegregationTest {

    @Test
    public void forIomSegregatorShouldReturnIomObject() throws IOException{

        OrdersLoader ordersLoader = OrdersLoader.getInstance();
        ArrayList<Order> orderList = ordersLoader.loadOrdersFromTxtFile();
        Segregation segregation = new Segregation(orderList);
        Instruction instruction = segregation.getInstructionObject("AND M0.0", 10);

        assertEquals(instruction.getOrderCode(), (byte) 1);
    }

    @Test
    public void forWrongCommandShouldReturnNull() throws IOException{

        OrdersLoader ordersLoader = OrdersLoader.getInstance();
        ArrayList<Order> orderList = ordersLoader.loadOrdersFromTxtFile();
        Segregation segregation = new Segregation(orderList);
        Instruction instruction = segregation.getInstructionObject("ANS M0.0", 10);

        assertEquals(instruction, null);
    }
}
