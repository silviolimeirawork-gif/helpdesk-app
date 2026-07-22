#!/bin/bash
# Corrige os arquivos XHTML e reinicia a aplicação

echo "===== CORRIGINDO ARQUIVOS XHTML ====="

# 1. Substitui login.xhtml
cat > src/main/webapp/login.xhtml << 'EOF'
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:h="http://java.sun.com/jsf/html"
      xmlns:p="http://primefaces.org/ui">
<h:head>
    <title>Login - Helpdesk</title>
</h:head>
<h:body>
    <h:form id="loginForm">
        <p:growl id="growl" showDetail="true" life="3000"/>
        <p:panel header="Acesso ao Sistema" style="width:400px; margin:100px auto;">
            <p:messages id="messages" showDetail="true" autoUpdate="true" />
            <p:outputLabel for="username" value="Usuário"/>
            <p:inputText id="username" value="#{loginBean.username}" placeholder="Usuário" required="true"/>
            <p:outputLabel for="password" value="Senha"/>
            <p:password id="password" value="#{loginBean.password}" placeholder="Senha" required="true"/>
            <p:commandButton value="Entrar" action="#{loginBean.login}" update="@form" />
            <p:commandButton value="Logout" action="#{loginBean.logout}" immediate="true" />
        </p:panel>
    </h:form>
</h:body>
</html>
EOF

# 2. Substitui tickets.xhtml
cat > src/main/webapp/views/tickets.xhtml << 'EOF'
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:h="http://java.sun.com/jsf/html"
      xmlns:p="http://primefaces.org/ui">
<h:head>
    <title>Meus Tickets</title>
</h:head>
<h:body>
    <h:form id="ticketForm">
        <p:growl id="growl" showDetail="true" life="3000"/>

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
                                 update="@form :growl"
                                 onclick="return confirm('Tem certeza?')"/>
            </p:column>
        </p:dataTable>
    </h:form>

    <!-- Dialog Novo Ticket -->
    <p:dialog header="Novo Ticket" widgetVar="newTicketDlg" modal="true" resizable="false">
        <h:form id="newTicketForm">
            <p:panelGrid columns="2" style="width:100%;">
                <p:outputLabel value="Título" for="title"/>
                <p:inputText id="title" value="#{ticketBean.newTicket.title}" required="true"/>

                <p:outputLabel value="Descrição" for="desc"/>
                <p:inputTextarea id="desc" value="#{ticketBean.newTicket.description}" rows="5" cols="40"/>

                <p:commandButton value="Salvar" action="#{ticketBean.saveNewTicket}"
                                 update="@form :growl"
                                 oncomplete="if(!args.validationFailed) PF('newTicketDlg').hide();"/>
                <p:commandButton value="Cancelar" onclick="PF('newTicketDlg').hide();" immediate="true"/>
            </p:panelGrid>
        </h:form>
    </p:dialog>

    <!-- Dialog Detalhe -->
    <p:dialog header="Detalhe do Ticket" widgetVar="detailDlg" modal="true" width="600">
        <h:form id="detailForm">
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
                                 update="@form :growl" oncomplete="PF('detailDlg').hide();"/>
                <p:commandButton value="Fechar" onclick="PF('detailDlg').hide();" immediate="true"/>
            </p:panelGrid>
        </h:form>
    </p:dialog>
</h:body>
</html>
EOF

# 3. Substitui ticket-detail.xhtml
cat > src/main/webapp/views/ticket-detail.xhtml << 'EOF'
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:h="http://java.sun.com/jsf/html"
      xmlns:p="http://primefaces.org/ui">
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
                                 update="@form :growl" style="grid-column: span 2;"/>
            </p:panelGrid>
        </p:panel>
    </h:form>
</h:body>
</html>
EOF

echo "===== ARQUIVOS CORRIGIDOS ====="
echo "A aplicação já está rodando. Recarregue a página no navegador:"
echo "http://localhost:8080/login.xhtml"
echo "Credenciais: admin/admin  ou  user/user"
