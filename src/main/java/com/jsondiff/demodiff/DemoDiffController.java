package com.jsondiff.demodiff;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DemoDiffController {
    @RequestMapping("/hello")
    public String Hello(){
        return "Hello World";
    }
}
