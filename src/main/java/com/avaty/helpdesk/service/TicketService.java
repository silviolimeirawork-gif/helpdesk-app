package com.avaty.helpdesk.service;

import com.avaty.helpdesk.entity.Ticket;
import com.avaty.helpdesk.entity.User;
import com.avaty.helpdesk.repository.TicketRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class TicketService {

    @Autowired
    private TicketRepository ticketRepository;

    @Autowired
    private OpenAiService openAiService;

    public List<Ticket> findAll() {
        return ticketRepository.findAll();
    }

    public Optional<Ticket> findById(Long id) {
        return ticketRepository.findById(id);
    }

    public List<Ticket> findByUser(User user) {
        return ticketRepository.findByUser(user);
    }

    @Transactional
    public Ticket save(Ticket ticket) {
        // Se houver descrição, solicita sugestão da OpenAI
        if (ticket.getDescription() != null && !ticket.getDescription().isEmpty()) {
            String suggestion = openAiService.getSuggestion(ticket.getDescription());
            ticket.setAiSuggestion(suggestion);
        }
        return ticketRepository.save(ticket);
    }

    @Transactional
    public void delete(Long id) {
        ticketRepository.deleteById(id);
    }

    @Transactional
    public Ticket updateStatus(Long id, String status) {
        Ticket ticket = ticketRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Ticket não encontrado"));
        ticket.setStatus(status);
        return ticketRepository.save(ticket);
    }
}
