
package com.example.employeeapp.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.example.employeeapp.entity.Employee;

public interface EmployeeRepository extends JpaRepository<Employee, Long> {
}
