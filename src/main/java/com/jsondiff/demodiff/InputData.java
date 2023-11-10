package com.jsondiff.demodiff;

import com.fasterxml.jackson.annotation.JsonProperty;

public class InputData {

    @JsonProperty("data")
    private String base64EncodedData;

    // Constructors, getters, and setters

    public InputData() {
        // Default constructor for JSON deserialization
    }

    public InputData(String base64EncodedData) {
        this.base64EncodedData = base64EncodedData;
    }

    public String getBase64EncodedData() {
        return base64EncodedData;
    }

    public void setBase64EncodedData(String base64EncodedData) {
        this.base64EncodedData = base64EncodedData;
    }
}
