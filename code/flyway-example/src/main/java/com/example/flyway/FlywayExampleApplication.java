package com.example.flyway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class FlywayExampleApplication {

    public static void main(String args[]) {
        SpringApplication.run(FlywayExampleApplication.class, args);
    }

    @RequestMapping(value = "/")
    public String hello() {
        return "Hello World!!";
    }

}
