package com.fyp.attendance.Repository;
import com.fyp.attendance.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserRepository extends JpaRepository<User, Long> {
    User findByUsernameAndPassword(String username, String password);
    List<User> findAll();
}

