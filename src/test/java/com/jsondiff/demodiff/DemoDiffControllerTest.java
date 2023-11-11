package com.jsondiff.demodiff;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;

@WebMvcTest(DemoDiffController.class)
class DemoDiffControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private DemoDiffController diffService; // Assuming you have a service for handling the diff logic

    @InjectMocks
    private DemoDiffController demoDiffController;

    @Test
    void testLeftEndpoint() throws Exception {
        InputData inputData = new InputData("SGVsbG8gd29ybGQh"); // Example base64 encoded binary data
        mockMvc.perform(MockMvcRequestBuilders.post("/v1/diff/left")
                .contentType(MediaType.APPLICATION_JSON)
                .content(new ObjectMapper().writeValueAsString(inputData)))
                .andExpect(MockMvcResultMatchers.status().isOk());
    }

    @Test
    void testRightEndpoint() throws Exception {
        InputData inputData = new InputData("SGVsbG8gd29ybGQh"); // Example base64 encoded binary data
        mockMvc.perform(MockMvcRequestBuilders.post("/v1/diff/right")
                .contentType(MediaType.APPLICATION_JSON)
                .content(new ObjectMapper().writeValueAsString(inputData)))
                .andExpect(MockMvcResultMatchers.status().isOk());
    }

    @Test
    void testPerformDiff() throws Exception {
        // Mock the diff result
        DiffResult mockDiffResult = new DiffResult(true, "Data is equal.");
        Mockito.when(diffService.performDiff()).thenReturn(mockDiffResult);

        mockMvc.perform(MockMvcRequestBuilders.get("/v1/diff"))
                .andExpect(MockMvcResultMatchers.status().isOk())
                .andExpect(MockMvcResultMatchers.jsonPath("$.equal").value(true))
                .andExpect(MockMvcResultMatchers.jsonPath("$.message").value("Data is equal."));
    }
}

