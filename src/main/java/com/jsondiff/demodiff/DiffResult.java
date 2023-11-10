package com.jsondiff.demodiff;

import java.util.ArrayList;
import java.util.List;

public class DiffResult {

    private boolean equal;
    private String message;
    private List<Difference> differences;

    public DiffResult(boolean equal, String message) {
        this.equal = equal;
        this.message = message;
        this.differences = new ArrayList<>();
    }

    public boolean isEqual() {
        return equal;
    }

    public void setEqual(boolean equal) {
        this.equal = equal;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public List<Difference> getDifferences() {
        return differences;
    }

    public void addDifference(int offset, int length) {
        this.differences.add(new Difference(offset, length));
    }
}
