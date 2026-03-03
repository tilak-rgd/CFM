package com.example.employeeapp.service;


import com.example.employeeapp.entity.Employee;
import com.example.employeeapp.repository.EmployeeRepository;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

class EmployeeServiceTest {

    @Mock
    private EmployeeRepository repository;

    @InjectMocks
    private EmployeeServiceImpl service;

    public EmployeeServiceTest() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testSaveEmployee() {

        Employee emp = new Employee(1L, "Nani", "nani@gmail.com", 50000.0);

        when(repository.save(emp)).thenReturn(emp);

        Employee saved = service.saveEmployee(emp);

        assertThat(saved.getName()).isEqualTo("Nani");
        verify(repository, times(1)).save(emp);
    }

    @Test
    void testGetEmployeeById() {

        Employee emp = new Employee(1L, "Nani", "nani@gmail.com", 50000.0);

        when(repository.findById(1L)).thenReturn(Optional.of(emp));

        Employee found = service.getEmployeeById(1L);

        assertThat(found.getEmail()).isEqualTo("nani@gmail.com");
    }
}