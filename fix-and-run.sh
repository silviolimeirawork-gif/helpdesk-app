#!/bin/bash
# Script completo para corrigir e executar o helpdesk-app
# Compatível com JDK 21 e Spring Boot 2.7.0 + JoinFaces

set -e  # Para no primeiro erro

echo "===== INICIANDO CORREÇÃO COMPLETA DO PROJETO ====="

# 1. Remove arquivos de configuração manuais que conflitam com JoinFaces
echo "Removendo configurações manuais do JSF..."
rm -f src/main/java/com/avaty/helpdesk/config/FacesConfig.java
rm -f src/main/webapp/WEB-INF/web.xml
rm -f src/main/webapp/WEB-INF/faces-config.xml

# 2. Atualiza o pom.xml com dependências e plugins compatíveis
echo "Atualizando pom.xml..."
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
        <joinfaces.version>4.6.2</joinfaces.version>
        <lombok.version>1.18.36</lombok.version>
        <start-class>com.avaty.helpdesk.Application</start-class>
    </properties>

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

        <!-- JoinFaces: JSF + PrimeFaces -->
        <dependency>
            <groupId>org.joinfaces</groupId>
            <artifactId>jsf-spring-boot-starter</artifactId>
            <version>${joinfaces.version}</version>
        </dependency>
        <dependency>
            <groupId>org.joinfaces</groupId>
            <artifactId>primefaces-spring-boot-starter</artifactId>
            <version>${joinfaces.version}</version>
        </dependency>

        <!-- H2 Database -->
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>

        <!-- OpenAI -->
        <dependency>
            <groupId>com.theokanning.openai-gpt3-java</groupId>
            <artifactId>service</artifactId>
            <version>0.12.0</version>
        </dependency>

        <!-- Lombok atualizado -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>${lombok.version}</version>
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
                <version>3.13.0</version>
                <configuration>
                    <source>${java.version}</source>
                    <target>${java.version}</target>
                    <annotationProcessorPaths>
                        <path>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                            <version>${lombok.version}</version>
                        </path>
                    </annotationProcessorPaths>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <mainClass>${start-class}</mainClass>
                    <jvmArguments>
                        --add-opens java.base/java.lang=ALL-UNNAMED
                    </jvmArguments>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOF

# 3. Adiciona propriedade para desabilitar o bean FacesContext
echo "Adicionando configuração ao application.properties..."
if ! grep -q "joinfaces.jsf.faces-context-enabled" src/main/resources/application.properties; then
    echo "joinfaces.jsf.faces-context-enabled=false" >> src/main/resources/application.properties
else
    sed -i 's/joinfaces.jsf.faces-context-enabled=.*/joinfaces.jsf.faces-context-enabled=false/' src/main/resources/application.properties
fi

# 4. Limpa o cache do Lombok (força download da nova versão)
echo "Limpando cache do Lombok..."
rm -rf ~/.m2/repository/org/projectlombok/lombok

# 5. Compila o projeto
echo "Compilando o projeto..."
mvn clean compile

# 6. Executa a aplicação
echo "===== INICIANDO A APLICAÇÃO ====="
echo "Acesse: http://localhost:8080/login.xhtml"
echo "Credenciais: admin/admin  ou  user/user"
mvn spring-boot:run
