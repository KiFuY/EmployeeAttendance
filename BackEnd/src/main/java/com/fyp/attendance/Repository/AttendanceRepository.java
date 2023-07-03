package com.fyp.attendance.Repository;

import com.fyp.attendance.entity.Attendance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface AttendanceRepository extends JpaRepository<Attendance, Long> {
    List<Attendance> findByUsernameAndTimeBetween(String username, LocalDateTime start, LocalDateTime end);
    List<Attendance> findByTimeBetween(LocalDateTime start, LocalDateTime end);

    List<Attendance> findByTimeBetweenAndStatus(LocalDateTime start, LocalDateTime end, int status);

    @Query("SELECT a FROM history a WHERE a.username = :username AND a.status = 1 ORDER BY a.time DESC")
    List<Attendance> findSignInRecordsByUsername(@Param("username") String username);

    default Attendance findLatestSignIn(String username) {
        List<Attendance> signInRecords = findSignInRecordsByUsername(username);
        return signInRecords.isEmpty() ? null : signInRecords.get(0);
    }
}



