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
