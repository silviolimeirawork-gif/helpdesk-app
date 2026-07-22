package com.avaty.helpdesk.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;

@Service
public class OpenAiService {

    @Value("${openai.api.key:}")
    private String apiKey;

    private com.theokanning.openai.service.OpenAiService service;

    @PostConstruct
    public void init() {
        if (apiKey != null && !apiKey.isEmpty()) {
            service = new com.theokanning.openai.service.OpenAiService(apiKey);
        }
    }

    /**
     * Obtém uma sugestão da OpenAI para o problema descrito.
     * Se a chave não estiver configurada, retorna uma mensagem padrão.
     */
    public String getSuggestion(String problemDescription) {
        if (service == null) {
            return "Sugestão automática: Verifique os logs e tente reiniciar o serviço.";
        }
        try {
            String prompt = "Forneça uma sugestão técnica para o seguinte problema:\n" + problemDescription;
            com.theokanning.openai.completion.CompletionRequest request =
                    com.theokanning.openai.completion.CompletionRequest.builder()
                            .model("text-davinci-003")
                            .prompt(prompt)
                            .maxTokens(150)
                            .temperature(0.7)
                            .build();
            return service.createCompletion(request).getChoices().get(0).getText().trim();
        } catch (Exception e) {
            return "Não foi possível obter sugestão da IA: " + e.getMessage();
        }
    }
}
