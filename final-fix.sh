#!/bin/bash
# Script definitivo – corrige páginas, remove referências a :growl e reinicia

echo "===== CORREÇÃO FINAL ====="

# 1. login.xhtml – formulário HTML puro para Spring Security
cat > src/main/webapp/login.xhtml << 'EOF'
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:h="http://java.sun.com/jsf/html"
      xmlns:p="http://primefaces.org/ui">
<h:head>
    <title>Login - Helpdesk</title>
</h:head>
<h:body>
    <form action="${pageContext.request.contextPath}/login" method="post">
        <p:panel header="Acesso ao Sistema" style="width:400px; margin:100px auto;">
            <p:messages id="messages" showDetail="true" autoUpdate="true" />
            <p:outputLabel for="username" value="Usuário"/>
            <p:inputText id="username" name="username" placeholder="Usuário" required="true"/>
            <p:outputLabel for="password" value="Senha"/>
            <p:password id="password" name="password" placeholder="Senha" required="true"/>
            <p:commandButton value="Entrar" type="submit" ajax="false" />
            <p:commandButton value="Sair" action="#{loginBean.logout}" immediate="true" />
        </p:panel>
    </form>
</h:body>
</html>
EOF

# 2. tickets.xhtml – sem :growl, com messages no formulário pai
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
        <p:growl id="growl" showDetail="true" life="3000"/>
        <p:messages id="messages" showDetail="true" autoUpdate="true"/>

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
                                 update="@form" oncomplete="PF('growl').show()"
                                 onclick="return confirm('Tem certeza?')"/>
            </p:column>
        </p:dataTable>
    </h:form>

    <!-- Dialog Novo Ticket -->
    <p:dialog header="Novo Ticket" widgetVar="newTicketDlg" modal="true" resizable="false">
        <h:form id="newTicketForm">
            <p:growl id="newGrowl" showDetail="true" life="3000"/>
            <p:panelGrid columns="2" style="width:100%;">
                <p:outputLabel value="Título" for="title"/>
                <p:inputText id="title" value="#{ticketBean.newTicket.title}" required="true"/>

                <p:outputLabel value="Descrição" for="desc"/>
                <p:inputTextarea id="desc" value="#{ticketBean.newTicket.description}" rows="5" cols="40"/>

                <p:commandButton value="Salvar" action="#{ticketBean.saveNewTicket}"
                                 update="@form" oncomplete="if(!args.validationFailed){PF('newTicketDlg').hide();PF('growl').show();}"/>
                <p:commandButton value="Cancelar" onclick="PF('newTicketDlg').hide();" immediate="true"/>
            </p:panelGrid>
        </h:form>
    </p:dialog>

    <!-- Dialog Detalhe -->
    <p:dialog header="Detalhe do Ticket" widgetVar="detailDlg" modal="true" width="600">
        <h:form id="detailForm">
            <p:growl id="detailGrowl" showDetail="true" life="3000"/>
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
                                 update="@form" oncomplete="PF('detailDlg').hide();PF('growl').show();"/>
                <p:commandButton value="Fechar" onclick="PF('detailDlg').hide();" immediate="true"/>
            </p:panelGrid>
        </h:form>
    </p:dialog>
</h:body>
</html>
EOF

# 3. ticket-detail.xhtml
cat > src/main/webapp/views/ticket-detail.xhtml << 'EOF'
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:h="http://java.sun.com/jsf/html"
      xmlns:p="http://primefaces.org/ui"
      xmlns:f="http://java.sun.com/jsf/core">
<h:head>
    <title>Detalhe do Ticket</title>
</h:head>
<h:body>
    <h:form id="detailForm">
        <p:growl id="growl" showDetail="true"/>
        <p:toolbar>
            <p:toolbarGroup>
                <p:button value="Voltar" outcome="tickets.xhtml" icon="pi pi-arrow-left"/>
            </p:toolbarGroup>
        </p:toolbar>

        <p:panel header="Ticket #{ticketBean.selectedTicket.id}" style="margin-top:10px;">
            <p:panelGrid columns="2" style="width:100%;">
                <p:outputLabel value="Título" for="title"/>
                <p:inputText id="title" value="#{ticketBean.selectedTicket.title}" style="width:100%;"/>

                <p:outputLabel value="Descrição" for="desc"/>
                <p:inputTextarea id="desc" value="#{ticketBean.selectedTicket.description}" rows="5" style="width:100%;"/>

                <p:outputLabel value="Status" for="status"/>
                <p:selectOneMenu id="status" value="#{ticketBean.selectedTicket.status}">
                    <f:selectItem itemValue="OPEN" itemLabel="Aberto"/>
                    <f:selectItem itemValue="IN_PROGRESS" itemLabel="Em Andamento"/>
                    <f:selectItem itemValue="RESOLVED" itemLabel="Resolvido"/>
                    <f:selectItem itemValue="CLOSED" itemLabel="Fechado"/>
                </p:selectOneMenu>

                <p:outputLabel value="Sugestão IA" for="sugestao"/>
                <p:inputTextarea id="sugestao" value="#{ticketBean.selectedTicket.aiSuggestion}" rows="3" disabled="true" style="width:100%;"/>

                <p:commandButton value="Salvar" action="#{ticketBean.updateTicket}"
                                 update="@form" oncomplete="PF('growl').show();"/>
            </p:panelGrid>
        </p:panel>
    </h:form>
</h:body>
</html>
EOF

# 4. SecurityConfig (garantir redirecionamentos)
cat > src/main/java/com/avaty/helpdesk/config/SecurityConfig.java << 'EOF'
package com.avaty.helpdesk.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.crypto.factory.PasswordEncoderFactories;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        PasswordEncoder encoder = PasswordEncoderFactories.createDelegatingPasswordEncoder();
        auth.inMemoryAuthentication()
            .withUser("admin")
            .password(encoder.encode("admin"))
            .roles("ADMIN")
            .and()
            .withUser("user")
            .password(encoder.encode("user"))
            .roles("USER");
    }

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
            .authorizeRequests()
                .antMatchers("/login.xhtml", "/javax.faces.resource/**", "/resources/**").permitAll()
                .anyRequest().authenticated()
            .and()
            .formLogin()
                .loginPage("/login.xhtml")
                .loginProcessingUrl("/login")
                .defaultSuccessUrl("/views/tickets.xhtml", true)
                .failureUrl("/login.xhtml?error=true")
                .permitAll()
            .and()
            .logout()
                .logoutUrl("/logout")
                .logoutSuccessUrl("/login.xhtml")
                .permitAll()
            .and()
            .csrf().disable();
    }
}
EOF

# 5. LoginBean simplificado
cat > src/main/java/com/avaty/helpdesk/bean/LoginBean.java << 'EOF'
package com.avaty.helpdesk.bean;

import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

import javax.faces.context.FacesContext;
import javax.servlet.http.HttpServletRequest;
import java.io.Serializable;

@Component
@Scope("session")
public class LoginBean implements Serializable {

    public String logout() {
        HttpServletRequest request = (HttpServletRequest) FacesContext.getCurrentInstance()
                .getExternalContext().getRequest();
        try {
            request.logout();
            request.getSession().invalidate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "/login.xhtml?faces-redirect=true";
    }
}
EOF

# 6. Garantir que o TicketBean use @ViewScope (já está no código original)
# Se necessário, adicione a anotação @Scope("view") no TicketBean (já existe)

echo "===== CORREÇÕES APLICADAS ====="
echo "Parando a aplicação atual (se estiver rodando)..."
pkill -f "spring-boot:run" 2>/dev/null || true
sleep 2

echo "Limpando e recompilando..."
mvn clean compile

echo "Iniciando a aplicação com as opções JVM corretas..."
mvn spring-boot:run -Dspring-boot.run.jvmArguments="--add-opens java.base/java.lang=ALL-UNNAMED"
