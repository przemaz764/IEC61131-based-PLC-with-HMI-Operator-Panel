package panel.view;

import com.panel.view.AddressCreator;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import java.util.Arrays;
import java.util.Collection;

import static org.junit.Assert.assertEquals;

@RunWith(Parameterized.class)
public class AddressCreatorTest {

    private String tInput;
    private int tExpected;

    @Parameterized.Parameters
    public static Collection<Object[]> testData() {
        return Arrays.asList(new Object[][] {
                { "1.1.DW", 0x87 }, { "3.5.b", 0x194 },
                { "2.1.B", 0x105 }, { "0.1.W", 0x06 }
        });
    }

    public AddressCreatorTest(String input, int expected){
        tInput = input;
        tExpected = expected;
    }

    @org.junit.Test
    public void getAccessTest(){
        int result = AddressCreator.getAddress(tInput);
        assertEquals(tExpected, result);
    }
}
