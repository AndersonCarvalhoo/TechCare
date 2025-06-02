# 🧠 TechCare API 
A API do TechCare expõe um único endpoint público via Apex REST Resource Class, que permite consultar informações de um Case Request do suporte a partir do ID. Quando chamada a API retorna dois dados;
- Status
- Sla Met

Esse endpoint pode ser utilizado por sistemas externos que queiram consultar essas informações específicas de um Caso.

## Endpoint
`GET /services/apexrest/CaseRequest/{caseId}`

## Parâmetros
| Parâmetro | Tipo   | Obrigatório | Descrição                      |
|-----------|--------|-------------|-------------------------------|
| caseId    | string | Sim         | ID do Case_Request__c         |

## Respostas

### Sucesso (200)
```json
{
  "Status": "Em Análise",
  "Sla_Met": true
}
```
- Exemplo Body
```bash
{
  "Status": string,
  "Sla_Met": boolean
}
```
### Erro (400)
```json
{
  "error": "Invalid or missing CaseRequest Id"
}
```
- Exemplo Body
```bash
{
  "error": string,
}
```

### Erro (404)
```json
{
  "error": "Case request not found"
}
```
- Exemplo Body
```bash
{
  "error": string,
}
```

---

## Testes via POSTMAN

### Case Request Not Found
![image](https://github.com/user-attachments/assets/7ba9f3e6-2325-4f34-a7f1-d99e256daa01)

### Success
![image](https://github.com/user-attachments/assets/23b5459f-67ca-47fa-b20a-155f319f6390)

### Invalid Or Missing Case Request ID
![image](https://github.com/user-attachments/assets/7083f3cb-db1e-4325-94c2-02dc29504aed)


