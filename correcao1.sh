# Atualizar pom.xml (adicionar plugin do Lombok)
sed -i '/<plugins>/a \
            <plugin>\
                <groupId>org.apache.maven.plugins<\/groupId>\
                <artifactId>maven-compiler-plugin<\/artifactId>\
                <version>3.10.1<\/version>\
                <configuration>\
                    <source>11<\/source>\
                    <target>11<\/target>\
                    <annotationProcessorPaths>\
                        <path>\
                            <groupId>org.projectlombok<\/groupId>\
                            <artifactId>lombok<\/artifactId>\
                            <version>1.18.24<\/version>\
                        <\/path>\
                    <\/annotationProcessorPaths>\
                <\/configuration>\
            <\/plugin>' pom.xml

# Substituir ViewScope.java
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
        // Not needed for view scope
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

# Adicionar o bean CustomScopeConfigurer no AppConfig.java (inserir após @Import)
sed -i '/@Import/i\
import org.springframework.beans.factory.config.CustomScopeConfigurer;\
import org.springframework.context.annotation.Bean;\
' src/main/java/com/avaty/helpdesk/config/AppConfig.java

# Inserir o método no AppConfig
sed -i '/public class AppConfig {/a \
    @Bean\
    public static CustomScopeConfigurer customScopeConfigurer() {\
        CustomScopeConfigurer configurer = new CustomScopeConfigurer();\
        configurer.addScope("view", new ViewScope());\
        return configurer;\
    }\
' src/main/java/com/avaty/helpdesk/config/AppConfig.java

# Atualizar Ticket.java (adicionar @NoArgsConstructor e @AllArgsConstructor)
sed -i 's/@Data/@Data @NoArgsConstructor @AllArgsConstructor/' src/main/java/com/avaty/helpdesk/entity/Ticket.java

# Atualizar User.java (adicionar @NoArgsConstructor)
sed -i 's/@Data/@Data @NoArgsConstructor/' src/main/java/com/avaty/helpdesk/entity/User.java

# Corrigir TicketBean.java (instâncias com new Ticket())
sed -i 's/new Ticket()/new Ticket()/' src/main/java/com/avaty/helpdesk/bean/TicketBean.java  # já está, mas pode garantir
# Adicionar reset de newTicket após salvar
sed -i '/ticketService.save(newTicket);/a \        newTicket = new Ticket();' src/main/java/com/avaty/helpdesk/bean/TicketBean.java
