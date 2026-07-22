#!/bin/bash
# Corrige o formulário de login para usar HTML puro + Spring Security

echo "===== CORRIGINDO FORMULÁRIO DE LOGIN ====="

cat > src/main/webapp/login.xhtml << 'EOF'
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:h="http://java.sun.com/jsf/html"
      xmlns:p="http://primefaces.org/ui"
      xmlns:pt="http://xmlns.jcp.org/jsf/passthrough">
<h:head>
    <title>Login - Helpdesk</title>
    <h:outputStylesheet library="primefaces" name="primefaces.css" />
    <h:outputStylesheet library="primefaces" name="theme.css" />
    <style>
        .login-panel {
            width: 400px;
            margin: 100px auto;
            padding: 20px;
            border: 1px solid #ccc;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            background: #fff;
        }
        .login-panel h2 {
            text-align: center;
            margin-top: 0;
        }
        .login-panel .field {
            margin-bottom: 15px;
        }
        .login-panel .field label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .login-panel .field input {
            width: 100%;
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .login-panel .field input:focus {
            border-color: #007ad9;
            outline: none;
            box-shadow: 0 0 5px rgba(0,122,217,0.5);
        }
        .login-panel .button {
            width: 100%;
            padding: 10px;
            background: #007ad9;
            color: #fff;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }
        .login-panel .button:hover {
            background: #005fb1;
        }
        .login-panel .error {
            color: #d32f2f;
            background: #ffebee;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 15px;
            display: block;
        }
    </style>
</h:head>
<h:body>
    <div class="login-panel">
        <h2>Acesso ao Sistema</h2>

        <!-- Exibe mensagem de erro se presente -->
        <span class="error" id="error-message" style="display:none;">#{param.error ? 'Usuário ou senha inválidos.' : ''}</span>

        <form action="${pageContext.request.contextPath}/login" method="post">
            <div class="field">
                <label for="username">Usuário</label>
                <input type="text" id="username" name="username" placeholder="Digite seu usuário" required="required" />
            </div>
            <div class="field">
                <label for="password">Senha</label>
                <input type="password" id="password" name="password" placeholder="Digite sua senha" required="required" />
            </div>
            <button type="submit" class="button">Entrar</button>
        </form>

        <p:commandButton value="Sair" action="#{loginBean.logout}" immediate="true" style="margin-top:10px; width:100%;" />
    </div>

    <!-- JavaScript para mostrar erro se houver -->
    <script>
        // Verifica se há parâmetro error na URL
        if (window.location.search.indexOf('error=true') > -1) {
            document.getElementById('error-message').style.display = 'block';
        }
    </script>
</h:body>
</html>
EOF

echo "===== LOGIN CORRIGIDO ====="
echo "Agora pare a aplicação (Ctrl+C) e reinicie com:"
echo "mvn clean spring-boot:run -Dspring-boot.run.jvmArguments=\"--add-opens java.base/java.lang=ALL-UNNAMED\""
