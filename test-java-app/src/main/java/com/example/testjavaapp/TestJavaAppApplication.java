package com.example.testjavaapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class TestJavaAppApplication {

  public static void main(String[] args) {
    System.out.println("HELLO WORLD");
    SpringApplication.run(TestJavaAppApplication.class, args);
  }

}
