package com.avaty.helpdesk.bean;

import com.avaty.helpdesk.entity.Ticket;
import com.avaty.helpdesk.entity.User;
import com.avaty.helpdesk.repository.UserRepository;
import com.avaty.helpdesk.service.TicketService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Scope;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.PostConstruct;
import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;
import java.io.Serializable;
import java.util.List;

@Component
@Scope("view")
public class TicketBean implements Serializable {

    @Autowired
    private TicketService ticketService;

    @Autowired
    private UserRepository userRepository;

    private List<Ticket> tickets;
    private Ticket selectedTicket;
    private Ticket newTicket;

    @PostConstruct
    public void init() {
        newTicket = new Ticket();
        selectedTicket = new Ticket();
        loadTickets();
    }

    public void loadTickets() {
        User currentUser = getOrCreateCurrentUser();
        if (currentUser != null) {
            tickets = ticketService.findByUser(currentUser);
        } else {
            tickets = ticketService.findAll();
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_WARN, "Usuário não autenticado", "Listando todos os tickets"));
        }
    }

    @Transactional
    public void saveNewTicket() {
        User currentUser = getOrCreateCurrentUser();
        if (currentUser == null) {
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Usuário não autenticado", "Não foi possível criar o ticket."));
            return;
        }
        newTicket.setUser(currentUser);
        ticketService.save(newTicket);
        newTicket = new Ticket();
        loadTickets();
        FacesContext.getCurrentInstance().addMessage(null,
                new FacesMessage("Ticket criado com sucesso!"));
    }

    public void updateTicket() {
        if (selectedTicket != null && selectedTicket.getId() != null) {
            ticketService.save(selectedTicket);
            loadTickets();
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage("Ticket atualizado!"));
        }
    }

    public void deleteTicket(Long id) {
        ticketService.delete(id);
        loadTickets();
    }

    @Transactional
    private User getOrCreateCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
            return null;
        }
        String username = auth.getName();
        if (username == null || username.trim().isEmpty()) {
            return null;
        }
        String email = username + "@localhost";

        return userRepository.findByEmail(email).orElseGet(() -> {
            User newUser = new User();
            newUser.setEmail(email);
            newUser.setName(username);
            newUser.setPassword("temporary");
            newUser.setRole("USER");
            return userRepository.save(newUser);
        });
    }

    // Getters e Setters
    public List<Ticket> getTickets() {
        return tickets;
    }

    public void setTickets(List<Ticket> tickets) {
        this.tickets = tickets;
    }

    public Ticket getSelectedTicket() {
        return selectedTicket;
    }

    public void setSelectedTicket(Ticket selectedTicket) {
        this.selectedTicket = selectedTicket;
    }

    public Ticket getNewTicket() {
        return newTicket;
    }

    public void setNewTicket(Ticket newTicket) {
        this.newTicket = newTicket;
    }
}
