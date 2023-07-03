package com.fyp.attendance.Controller;

import com.fyp.attendance.Repository.AttendanceRepository;
import com.fyp.attendance.Repository.UserRepository;
import com.fyp.attendance.entity.Attendance;
import com.fyp.attendance.error.ResourceNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.UUID;

@RestController
@RequestMapping("/api")
public class AttendanceController {
    private final AttendanceRepository attendanceRepository;
    private final UserRepository userRepository;

    @Autowired
    public AttendanceController(AttendanceRepository attendanceRepository, UserRepository userRepository) {
        this.attendanceRepository = attendanceRepository;
        this.userRepository = userRepository;
    }


    @PostMapping("/attendance")
    public Attendance saveAttendance(@RequestBody Attendance attendance) {
        // Check if it's a sign-in
        if (attendance.getStatus() == 1) {
            // Generate a new sessionId for sign-in
            String sessionId = UUID.randomUUID().toString();
            attendance.setSessionId(sessionId);
        } else {
            // For sign-out, use the sessionId from the latest sign-in record of the user
            Attendance latestSignIn = attendanceRepository.findLatestSignIn(attendance.getUsername());
            if (latestSignIn != null) {
                attendance.setSessionId(latestSignIn.getSessionId());
            }
        }

        return attendanceRepository.save(attendance);
    }

    @PutMapping("/attendance/{id}")
    public Attendance updateAttendance(@PathVariable long id, @RequestBody Attendance attendanceDetails) {
        // Log the input parameters
        System.out.println("Updating attendance with ID: " + id);
        System.out.println("Received notice: " + attendanceDetails.getNotice());

        Attendance attendance = attendanceRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Attendance not exist with id :" + id));

        attendance.setNotice(attendanceDetails.getNotice());
        // update other fields if needed

        Attendance updatedAttendance = attendanceRepository.save(attendance);

        // Log the updated attendance
        System.out.println("Updated attendance: " + updatedAttendance);

        return updatedAttendance;
    }


    @GetMapping("/search")
    public List<Attendance> search(@RequestParam String username, @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        System.out.println("Username: " + username);
        System.out.println("Date: " + date);

        LocalDateTime start = date.atStartOfDay();
        LocalDateTime end = date.atTime(23, 59, 59);
        List<Attendance> results;

        if ("10086".equals(username)) {
            // 获取所有用户的记录，只根据日期过滤
            results = attendanceRepository.findByTimeBetween(start, end);
        } else {
            // 获取特定用户的记录，只根据用户名和日期过滤
            results = attendanceRepository.findByUsernameAndTimeBetween(username, start, end);
        }

        System.out.println("Query results: " + results);

        return results;
    }




    @GetMapping("/attendanceRate")
    public Map<String, Integer> getAttendanceRate(@RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        LocalDateTime start = date.atStartOfDay();
        LocalDateTime end = date.atTime(23, 59, 59);

        int totalUsers = userRepository.findAll().size();

        // Get all sign-in records for the day
        List<Attendance> signInRecords = attendanceRepository.findByTimeBetweenAndStatus(start, end, 1);
        // Group the sign-in records by username, and keep only the first record for each user
        Map<String, Attendance> firstSignInRecords = signInRecords.stream()
                .collect(Collectors.toMap(
                        Attendance::getUsername,
                        Function.identity(),
                        (existingValue, newValue) -> existingValue));

        int signedInUsers = firstSignInRecords.size();

        Map<String, Integer> result = new HashMap<>();
        result.put("totalUsers", totalUsers);
        result.put("signedInUsers", signedInUsers);

        return result;
    }




}


