#!/bin/bash
# Script definitivo – corrige tickets.xhtml, TicketBean e LoginBean

echo "===== CORREÇÃO FINAL COMPLETA ====="

# 1. Substitui tickets.xhtml (remove referências a :messages e :growl)
cat > src/main/webapp/views/tickets.xhtml << 'EOF'
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:h="http://java.sun.com/jsf/html"
      xmlns:p="http://primefaces.org/ui"
      xmlns:f="http://java.sun.com/jsf/core">
<h:head>
    <title>Meus Tickets</title>
</h:head>
<h:body>
    <h:form id="ticketForm">
        <p:growl id="growl" showDetail="true" life="3000" autoUpdate="true"/>

        <p:toolbar>
            <p:toolbarGroup>
                <p:commandButton value="Novo Ticket" icon="pi pi-plus"
                                  onclick="PF('newTicketDlg').show();" update=":newTicketForm"/>
                <p:commandButton value="Sair" action="#{loginBean.logout}" icon="pi pi-sign-out"/>
            </p:toolbarGroup>
        </p:toolbar>

        <p:dataTable value="#{ticketBean.tickets}" var="t" paginator="true" rows="10"
                     selection="#{ticketBean.selectedTicket}" selectionMode="single"
                     rowKey="#{t.id}" style="margin-top:10px;">
            <p:column headerText="ID" sortBy="#{t.id}">
                #{t.id}
            </p:column>
            <p:column headerText="Título" sortBy="#{t.title}">
                #{t.title}
            </p:column>
            <p:column headerText="Status" sortBy="#{t.status}">
                <p:outputLabel value="#{t.status}" style="font-weight:bold;"
                               styleClass="#{t.status eq 'OPEN' ? 'ui-state-highlight' : ''}"/>
            </p:column>
            <p:column headerText="Criado em" sortBy="#{t.createdAt}">
                <h:outputText value="#{t.createdAt}">
                    <f:convertDateTime pattern="dd/MM/yyyy HH:mm" />
                </h:outputText>
            </p:column>
            <p:column headerText="Ações">
                <p:commandButton icon="pi pi-search" update=":detailForm"
                                 oncomplete="PF('detailDlg').show();"
                                 action="#{ticketBean.setSelectedTicket(t)}">
                    <f:setPropertyActionListener target="#{ticketBean.selectedTicket}" value="#{t}"/>
                </p:commandButton>
                <p:commandButton icon="pi pi-trash" action="#{ticketBean.deleteTicket(t.id)}"
                                 update="@form" onclick="return confirm('Tem certeza?')"/>
            </p:column>
        </p:dataTable>
    </h:form>

    <!-- Dialog Novo Ticket -->
    <p:dialog header="Novo Ticket" widgetVar="newTicketDlg" modal="true" resizable="false">
        <h:form id="newTicketForm">
            <p:growl id="newGrowl" showDetail="true" life="3000" autoUpdate="true"/>
            <p:panelGrid columns="2" style="width:100%;">
                <p:outputLabel value="Título" for="title"/>
                <p:inputText id="title" value="#{ticketBean.newTicket.title}" required="true"/>

                <p:outputLabel value="Descrição" for="desc"/>
                <p:inputTextarea id="desc" value="#{ticketBean.newTicket.description}" rows="5" cols="40"/>

                <p:commandButton value="Salvar" action="#{ticketBean.saveNewTicket}"
                                 update="@form" oncomplete="if(!args.validationFailed){PF('newTicketDlg').hide();}"/>
                <p:commandButton value="Cancelar" onclick="PF('newTicketDlg').hide();" immediate="true"/>
            </p:panelGrid>
        </h:form>
    </p:dialog>

    <!-- Dialog Detalhe -->
    <p:dialog header="Detalhe do Ticket" widgetVar="detailDlg" modal="true" width="600">
        <h:form id="detailForm">
            <p:growl id="detailGrowl" showDetail="true" life="3000" autoUpdate="true"/>
            <p:panelGrid columns="2" style="width:100%;">
                <p:outputLabel value="ID" for="detId"/>
                <p:inputText id="detId" value="#{ticketBean.selectedTicket.id}" disabled="true"/>

                <p:outputLabel value="Título" for="detTitle"/>
                <p:inputText id="detTitle" value="#{ticketBean.selectedTicket.title}" required="true"/>

                <p:outputLabel value="Descrição" for="detDesc"/>
                <p:inputTextarea id="detDesc" value="#{ticketBean.selectedTicket.description}" rows="5" cols="40"/>

                <p:outputLabel value="Status" for="detStatus"/>
                <p:selectOneMenu id="detStatus" value="#{ticketBean.selectedTicket.status}">
                    <f:selectItem itemValue="OPEN" itemLabel="Aberto"/>
                    <f:selectItem itemValue="IN_PROGRESS" itemLabel="Em Andamento"/>
                    <f:selectItem itemValue="RESOLVED" itemLabel="Resolvido"/>
                    <f:selectItem itemValue="CLOSED" itemLabel="Fechado"/>
                </p:selectOneMenu>

                <p:outputLabel value="Sugestão IA" for="detSug"/>
                <p:inputTextarea id="detSug" value="#{ticketBean.selectedTicket.aiSuggestion}"
                                 rows="3" cols="40" disabled="true"/>

                <p:commandButton value="Atualizar" action="#{ticketBean.updateTicket}"
                                 update="@form" oncomplete="PF('detailDlg').hide();"/>
                <p:commandButton value="Fechar" onclick="PF('detailDlg').hide();" immediate="true"/>
            </p:panelGrid>
        </h:form>
    </p:dialog>
</h:body>
</html>
EOF

# 2. Substitui TicketBean para criar usuário se não existir
cat > src/main/java/com/avaty/helpdesk/bean/TicketBean.java << 'EOF'
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
        loadTickets();
        newTicket = new Ticket();
        selectedTicket = new Ticket();
    }

    public void loadTickets() {
        User currentUser = getOrCreateCurrentUser();
        if (currentUser != null) {
            tickets = ticketService.findByUser(currentUser);
        } else {
            tickets = ticketService.findAll();
        }
    }

    @Transactional
    public void saveNewTicket() {
        User currentUser = getOrCreateCurrentUser();
        if (currentUser == null) {
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Usuário não autenticado", null));
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

    private User getOrCreateCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
            return null;
        }
        String email = auth.getName();
        return userRepository.findByEmail(email).orElseGet(() -> {
            // Cria um novo usuário se não existir no banco
            User newUser = new User();
            newUser.setEmail(email);
            newUser.setName(email); // usa o email como nome
            newUser.setPassword(""); // não usado para autenticação (Spring Security)
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
EOF

# 3. (Opcional) Atualiza login.xhtml – já corrigido, mas garantimos
cat > src/main/webapp/login.xhtml << 'EOF'
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:h="http://java.sun.com/jsf/html"
      xmlns:p="http://primefaces.org/ui">
<h:head>
    <title>Login - Helpdesk</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f0f0f0; margin: 0; }
        .login-panel {
            width: 400px;
            margin: 100px auto;
            padding: 30px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 0 15px rgba(0,0,0,0.15);
        }
        .login-panel h2 {
            text-align: center;
            margin-top: 0;
            color: #333;
        }
        .login-panel label {
            display: block;
            margin-top: 15px;
            font-weight: bold;
        }
        .login-panel input {
            width: 100%;
            padding: 10px;
            margin-top: 5px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 14px;
        }
        .login-panel input:focus {
            border-color: #007ad9;
            outline: none;
            box-shadow: 0 0 5px rgba(0,122,217,0.5);
        }
        .login-panel button {
            width: 100%;
            padding: 12px;
            background: #007ad9;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
            margin-top: 20px;
        }
        .login-panel button:hover {
            background: #005fb1;
        }
        .error {
            color: #d32f2f;
            background: #ffebee;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 15px;
            display: none;
        }
        .logout-btn {
            margin-top: 10px;
            width: 100%;
        }
    </style>
</h:head>
<h:body>
    <div class="login-panel">
        <h2>Acesso ao Sistema</h2>

        <div class="error" id="errorMessage">
            Usuário ou senha inválidos.
        </div>

        <form action="${pageContext.request.contextPath}/login" method="post">
            <label for="username">Usuário</label>
            <input type="text" id="username" name="username" placeholder="Digite seu usuário" required="required" />

            <label for="password">Senha</label>
            <input type="password" id="password" name="password" placeholder="Digite sua senha" required="required" />

            <button type="submit">Entrar</button>
        </form>

        <p:commandButton value="Sair" action="#{loginBean.logout}" immediate="true"
                         style="width:100%; margin-top:10px;" />
    </div>

    <script>
        if (window.location.search.indexOf('error=true') > -1) {
            document.getElementById('errorMessage').style.display = 'block';
        }
    </script>
</h:body>
</html>
EOF

echo "===== CORREÇÕES APLICADAS ====="
echo "Reiniciando a aplicação..."
mvn clean spring-boot:run -Dspring-boot.run.jvmArguments="--add-opens java.base/java.lang=ALL-UNNAMED"
