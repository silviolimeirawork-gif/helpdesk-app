package com.avaty.helpdesk.repository;

import com.avaty.helpdesk.entity.Ticket;
import com.avaty.helpdesk.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TicketRepository extends JpaRepository<Ticket, Long> {
    List<Ticket> findByUser(User user);
    List<Ticket> findByStatus(String status);
}
