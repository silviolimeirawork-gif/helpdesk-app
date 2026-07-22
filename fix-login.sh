#!/bin/bash
# Corrige o login para funcionar com Spring Security

echo "===== CORRIGINDO LOGIN ====="

# Substitui login.xhtml
cat > src/main/webapp/login.xhtml << 'EOF'
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:h="http://java.sun.com/jsf/html"
      xmlns:p="http://primefaces.org/ui">
<h:head>
    <title>Login - Helpdesk</title>
</h:head>
<h:body>
    <h:form id="loginForm" action="/login" method="post">
        <p:growl id="growl" showDetail="true" life="3000"/>
        <p:panel header="Acesso ao Sistema" style="width:400px; margin:100px auto;">
            <p:messages id="messages" showDetail="true" autoUpdate="true" />
            <p:outputLabel for="username" value="Usuário"/>
            <p:inputText id="username" name="username" placeholder="Usuário" required="true"/>
            <p:outputLabel for="password" value="Senha"/>
            <p:password id="password" name="password" placeholder="Senha" required="true"/>
            <p:commandButton value="Entrar" type="submit" ajax="false" />
            <p:commandButton value="Sair" action="#{loginBean.logout}" immediate="true" />
        </p:panel>
    </h:form>
</h:body>
</html>
EOF

# Opcional: Ajusta o LoginBean para não interferir
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

echo "===== LOGIN CORRIGIDO ====="
echo "A aplicação já está rodando. Recarregue a página:"
echo "http://localhost:8080/login.xhtml"
echo "Usuário: admin / admin  ou  user / user"
