package com.avaty.helpdesk.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.util.Date;

@Entity
@Table(name = "tickets")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Ticket {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(length = 2000)
    private String description;

    private String status = "OPEN";

    @Temporal(TemporalType.TIMESTAMP)
    private Date createdAt = new Date();

    private String aiSuggestion;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    public Ticket(String title, String description, User user) {
        this.title = title;
        this.description = description;
        this.user = user;
        this.createdAt = new Date();
    }
}
