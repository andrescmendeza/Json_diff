package com.jsondiff.demodiff;

public class Difference {

    private int offset;
    private int length;

    public Difference(int offset, int length) {
        this.offset = offset;
        this.length = length;
    }

    public int getOffset() {
        return offset;
    }

    public int getLength() {
        return length;
    }
}
