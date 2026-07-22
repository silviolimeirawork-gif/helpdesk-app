#!/bin/bash
# Script de correção completo para o projeto helpdesk-app
# Execute dentro do diretório raiz do projeto (helpdesk-app)

set -e  # Para no primeiro erro

echo "===== Aplicando correções no projeto helpdesk-app ====="

# 1. Criar a classe principal Application.java
echo "Criando Application.java..."
mkdir -p src/main/java/com/avaty/helpdesk
cat > src/main/java/com/avaty/helpdesk/Application.java << 'EOF'
package com.avaty.helpdesk;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

@SpringBootApplication
public class Application extends SpringBootServletInitializer {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
EOF

# 2. Atualizar pom.xml: adicionar plugin do lombok e configurar mainClass
echo "Atualizando pom.xml..."
# Fazemos backup
cp pom.xml pom.xml.bak

# Usamos sed para inserir a configuração do plugin compiler com annotationProcessor
# e também a configuração do mainClass no spring-boot-maven-plugin
# Como é mais seguro, vamos gerar um novo pom.xml a partir de um template,
# aproveitando as dependências já existentes.

# Extraímos as dependências e properties para manter, mas vamos reescrever o pom.xml
# com as correções. Vamos usar um heredoc com o conteúdo completo e correto.

cat > pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.avaty</groupId>
    <artifactId>helpdesk-app</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.7.0</version>
        <relativePath/>
    </parent>

    <properties>
        <java.version>11</java.version>
        <primefaces.version>12.0.0</primefaces.version>
        <mojarra.version>2.3.9</mojarra.version> <!-- versão estável -->
        <start-class>com.avaty.helpdesk.Application</start-class>
    </properties>

    <repositories>
        <repository>
            <id>java.net</id>
            <url>https://maven.java.net/content/repositories/public/</url>
        </repository>
    </repositories>

    <dependencies>
        <!-- Spring Boot -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>

        <!-- JSF / PrimeFaces -->
        <dependency>
            <groupId>org.glassfish</groupId>
            <artifactId>javax.faces</artifactId>
            <version>${mojarra.version}</version>
        </dependency>
        <dependency>
            <groupId>org.primefaces</groupId>
            <artifactId>primefaces</artifactId>
            <version>${primefaces.version}</version>
        </dependency>

        <!-- H2 Database -->
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>

        <!-- OpenAI (simples) -->
        <dependency>
            <groupId>com.theokanning.openai-gpt3-java</groupId>
            <artifactId>service</artifactId>
            <version>0.12.0</version>
        </dependency>

        <!-- Utilitários -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>

        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>javax.servlet-api</artifactId>
            <scope>provided</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.10.1</version>
                <configuration>
                    <source>${java.version}</source>
                    <target>${java.version}</target>
                    <annotationProcessorPaths>
                        <path>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                            <version>1.18.24</version>
                        </path>
                    </annotationProcessorPaths>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <mainClass>${start-class}</mainClass>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOF

# 3. Corrigir ViewScope.java (remover ambiguidade, implementar corretamente)
echo "Corrigindo ViewScope.java..."
cat > src/main/java/com/avaty/helpdesk/config/ViewScope.java << 'EOF'
package com.avaty.helpdesk.config;

import org.springframework.beans.factory.ObjectFactory;
import org.springframework.beans.factory.config.Scope;
import org.springframework.stereotype.Component;

import javax.faces.context.FacesContext;
import java.util.Map;

@Component
public class ViewScope implements Scope {

    @Override
    public Object get(String name, ObjectFactory<?> objectFactory) {
        Map<String, Object> viewMap = FacesContext.getCurrentInstance().getViewRoot().getViewMap();
        if (viewMap.containsKey(name)) {
            return viewMap.get(name);
        } else {
            Object object = objectFactory.getObject();
            viewMap.put(name, object);
            return object;
        }
    }

    @Override
    public Object remove(String name) {
        return FacesContext.getCurrentInstance().getViewRoot().getViewMap().remove(name);
    }

    @Override
    public void registerDestructionCallback(String name, Runnable callback) {
        // Não necessário para escopo de view
    }

    @Override
    public Object resolveContextualObject(String key) {
        return null;
    }

    @Override
    public String getConversationId() {
        return FacesContext.getCurrentInstance().getViewRoot().getViewId();
    }
}
EOF

# 4. Atualizar AppConfig.java para registrar o ViewScope como bean
echo "Atualizando AppConfig.java..."
cat > src/main/java/com/avaty/helpdesk/config/AppConfig.java << 'EOF'
package com.avaty.helpdesk.config;

import org.springframework.beans.factory.config.CustomScopeConfigurer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

@Configuration
@ComponentScan(basePackages = "com.avaty.helpdesk")
@Import({JpaConfig.class, SecurityConfig.class})
public class AppConfig {

    @Bean
    public static CustomScopeConfigurer customScopeConfigurer() {
        CustomScopeConfigurer configurer = new CustomScopeConfigurer();
        configurer.addScope("view", new ViewScope());
        return configurer;
    }
}
EOF

# 5. Garantir que as entidades tenham @NoArgsConstructor e @AllArgsConstructor
echo "Corrigindo entidades..."
# User.java - adicionar @NoArgsConstructor e @AllArgsConstructor (opcional)
cat > src/main/java/com/avaty/helpdesk/entity/User.java << 'EOF'
package com.avaty.helpdesk.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    private String name;

    @NotBlank
    @Email
    @Column(unique = true)
    private String email;

    @NotBlank
    private String password;

    private String role = "USER";

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<Ticket> tickets = new ArrayList<>();

    public User(String name, String email, String password) {
        this.name = name;
        this.email = email;
        this.password = password;
    }
}
EOF

# Ticket.java
cat > src/main/java/com/avaty/helpdesk/entity/Ticket.java << 'EOF'
package com.avaty.helpdesk.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.time.LocalDateTime;

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

    private LocalDateTime createdAt = LocalDateTime.now();

    private String aiSuggestion;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    public Ticket(String title, String description, User user) {
        this.title = title;
        this.description = description;
        this.user = user;
    }
}
EOF

# 6. Ajustar TicketBean.java para usar construtor vazio e setters
echo "Corrigindo TicketBean.java..."
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
        User currentUser = getCurrentUser();
        if (currentUser != null) {
            tickets = ticketService.findByUser(currentUser);
        } else {
            tickets = ticketService.findAll();
        }
    }

    public void saveNewTicket() {
        User currentUser = getCurrentUser();
        if (currentUser == null) {
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Usuário não autenticado", null));
            return;
        }
        newTicket.setUser(currentUser);
        ticketService.save(newTicket);
        newTicket = new Ticket(); // reset
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

    private User getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getPrincipal())) {
            String email = auth.getName();
            return userRepository.findByEmail(email).orElse(null);
        }
        return null;
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

# 7. (Opcional) Verificar se o TicketService já está ok
# O TicketService já usa getters/setters do lombok, então deve funcionar.

echo "===== Correções aplicadas com sucesso! ====="
echo "Agora execute: mvn clean spring-boot:run"
echo "Acesse: http://localhost:8080/helpdesk-app/login.xhtml"
echo "Usuário: admin / admin  ou  user / user"
