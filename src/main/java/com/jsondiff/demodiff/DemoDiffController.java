package com.jsondiff.demodiff;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Base64;



@RestController
@RequestMapping("/v1/diff")
public class DemoDiffController {

    private byte[] leftData;
    private byte[] rightData;

    @PostMapping("/left")
    public ResponseEntity<String> leftEndpoint(@RequestBody InputData inputData) {
        leftData = Base64.getDecoder().decode(inputData.getBase64EncodedData());
        return ResponseEntity.ok("Left data received successfully: "+leftData);
    }

    @PostMapping("/right")
    public ResponseEntity<String> rightEndpoint(@RequestBody InputData inputData) {
        rightData = Base64.getDecoder().decode(inputData.getBase64EncodedData());
        return ResponseEntity.ok("Right data received successfully: "+rightData);
    }

    @GetMapping
    public DiffResult performDiff() {
        if (leftData == null || rightData == null) {
            return new DiffResult(false, "Data is missing for one or both sides.");
        }

        if (leftData.length != rightData.length) {
            return new DiffResult(false, "Data size is different.");
        }

        DiffResult result = new DiffResult(true, "Data is equal.");

        for (int i = 0; i < leftData.length; i++) {
            if (leftData[i] != rightData[i]) {
                result.setEqual(false);
                result.addDifference(i, 1);
            }
        }

        return result;
    }
}