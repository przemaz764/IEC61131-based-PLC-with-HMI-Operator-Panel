package com.programmer.orders;

import java.util.Comparator;

public class OrderComparator implements Comparator<Order> {

    @Override
    public int compare(Order o1, Order o2) {
        return o1.getType().compareTo(o2.getType());
    }
}
