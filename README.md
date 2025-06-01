# TechCare Support in Salesforce
## Informações do Responsável
- Nome: Anderson Carvalho
- Perfil Escolhido: **Desenvolvedor** com conhecimentos em Admin

## TechCare Support Project
TechCare support é uma solução para criação e administração de casos de suporte. A partir do app TechCare Support o usuário do suporte pode registrar casos, pegar casos da fila baseado na prioridade, verificar dashboards essenciais na Home do App, verificar SLA de forma rápida, visual e intuitiva dentre outras vantagens. O foco do TechCare Support é aumentar a produtividade e organização da equipe de suporte.

## 🔧 Tecnologias Utilizadas

- Salesforce (SFDX)
- Apex
- Triggers
- LWC (Lightning Web Components)
- Flows
- Permission Sets
- Validation Rules
- Git + GitHub

## 📁 Estrutura do Projeto

```bash
.
├── force-app/                  # Elementos principais da org
│   └── main/default/
│       ├── classes/            # Apex classes e testes
│       ├── triggers/           # Triggers Apex
│       ├── lwc/                # Componentes Lightning Web Components
│       ├── objects/            # Objetos customizados
│       ├── permissionsets/     # Permissões customizadas
│       └── messageChannels/    # Canais de mensagem (pubSub do LWC)
```

## 🛠️ Funcionalidades Implementadas

### 🔐 Profiles e Permission sets
Para gerenciar melhor os acessos e permissões da solução foi criado um profile chamado **Support** com permissões básicas essenciais para usuário do suporte. 

Para permissões mais específicas foram criados dois permission sets, o **Support Premium** e o **Support Standard.** Assim, facilitando a atribuição de permissões específicas para cada usuário específico. 

Foi utilizado esse modelo de permissionamento seguindo as **boas práticas** do Salesforce na utilização de Permission Sets. Assim, seguindo a lógica de perfis para permissões gerais e Permission Sets para permissões específicas.

---  

### 🧱 Custom Objects
#### Case_Request__c 
Para registrar os casos de suporte foi criado um objeto Case Request. O objeto Case Request armazena informações importantes para casos, nele, através de campos, é possível armazenar o assunto, descrição, status, prioridade e dentre outras informações importantes para a regra de negócio. 
#### 📘 Estrutura do Case_Request__c
| Label             | API Name              | Type                   | Required | Observações               |
|-------------------|-----------------------|------------------------|----------|--------------------------|
| Case Request Number | Name                  | Auto Number            | Sim      | Campo identificador único |
| Created By         | CreatedById           | Lookup(User)           | Não      | Usuário que criou o registro |
| Description        | Description__c        | Long Text Area (32.768) | Não      | Descrição detalhada do caso |
| Last Modified By   | LastModifiedById      | Lookup(User)           | Não      | Usuário que modificou por último |
| Owner              | OwnerId               | Lookup(User, Group)    | Sim      | Dono atual do registro (usuário ou grupo) |
| Priority           | Priority__c           | Picklist               | Não      | Nível de prioridade do caso |
| Record Type        | RecordTypeId          | Record Type            | Sim      | Tipo de registro configurado |
| Resolution Notes   | Resolution_Notes__c   | Long Text Area (32.768) | Não      | Notas sobre a resolução do caso |
| SLA Deadline       | SLA_Deadline__c       | Date/Time              | Não      | Data/hora limite para SLA |
| Status             | Status__c             | Picklist               | Sim      | Status atual do caso      |
| Subject            | Subject__c            | Text (255)             | Não      | Assunto do caso          |
#### Case_History__c
Para registrar o histórico do registro foi criado um objeto Case History. O objeto Case History é criado e armazena valores que são populados após o fechamento do Case. 
#### 📘 Estrutura do Objeto: Case_History

| Label             | API Name              | Type                        | Required | Observações                            |
|-------------------|------------------------|-----------------------------|----------|----------------------------------------|
| Name              | Name                   | Text (80)                   | Sim      | Nome identificador do histórico        |
| Case Request      | Case_Request__c        | Master-Detail (Case Request) | Sim      | Relacionamento obrigatório com o caso  |
| Created By        | CreatedById            | Lookup (User)               | Não      | Usuário que criou o registro           |
| Last Modified By  | LastModifiedById       | Lookup (User)               | Não      | Último usuário que modificou o registro|
| SLA Met           | SLA_Met__c             | Checkbox                    | Não      | Indica se o SLA foi atendido ou não    |
| Time Closed       | Time_Closed__c         | Date/Time                   | Não      | Momento em que o caso foi encerrado    |

### 🧾 RecordTypes do Case_Request__c
Para diferenciar as regras de negócios de cada Permission Set, fez-se necessário criar dois RecordTypes, fazendo com que o objeto Case_Request__c tenha regras diferentes para cada tipo de objeto. 

Com a criação do record type é possível fazer a regra de negócio através de Page layouts, Permission sets, Lightning pages e etc... Garantindo maior organização e consistência em toda regra de negócio. 
- Support Premium (Support_Premium)
- Support Standard (Support_Standard)

---  

### 🏗️ App Lightning TechCare Support
Para facilitar a gestão e organização da solução existe o App Lightning TechCare Support.
O App é visível apenas para usuários com o perfil Support criado para este fim, e também é visível para o Admin da ORG.

#### 🎨 Branding e Identidade
- 🖼️ **Ícone customizado** e nome amigável "TechCare Support" para facilitar a identificação do app.
- 🎯 O foco principal é a experiência do usuário de suporte, com navegação simplificada e componentes Lightning Web Components (LWC) aplicados na página do registro.

#### Tabs
- Home
- Case Request
- Dashboards
- Reports

---  

### 📊 Relatórios e Dashboard de Casos

#### a. 🔍 Relatório Tabular - Casos Abertos por Prioridade e Status
- **Nome:** Open Cases
- **Tipo:** Matriz tabular
- **Campos:**
  - **Prioridade:** High, Medium, Low, (sem valor)
  - **Status:** New, In Progress, Escalated, Closed
- **Totalização:** Soma por status e prioridade
- **Objetivo:** Visualizar rapidamente a quantidade de casos abertos por por prioridade e status.


#### 2. Dashboard: Análise de Casos

#### 1. Open Cases - Last 7 Days
- **Tipo:** Donut Chart
- **Métrica:** Contagem de casos
- **Segmentação:**
  - **Opened:** Casos com `Status__c` = *New*, *In Progress*, *Escalated*
  - **Closed:** Casos com `Status__c` = *Closed*
- **Filtro:** Casos criados nos últimos 7 dias
- **Objetivo:** Comparar visualmente a proporção de casos ainda em aberto versus casos encerrados recentemente.

#### 2. Average Resolution Time by Type
- **Tipo:** Gráfico de barras verticais
- **Métrica:** Tempo médio de resolução (em dias)
- **Fonte:** Campo `Time_Closed__c` do objeto **Case_History__c**
- **Cálculo:** Média do tempo de resolução, agrupada por **Record Type** do objeto **Case_Request__c**
- **Objetivo:** Avaliar a eficiência de resolução conforme o tipo de suporte.

---  

### ⚡ Page Layouts e Lightning Record Pages
- Foram criados Page Layouts e Lightning Record Pages específicas para cada record type.
- Na Page Layout e Lightning Record Page do Standard Premium foi configurado o campo Priority como obrigátorio.
- O campo SLA Deadline não deve aparecer para o Support Standard. Para isso foi garantido que Na Page Layout e na Lightning Record Page não apareca.
- No Lightning Record Page do Support Premium o campo SLA_Deadline__c só é exibido se o priority for diferente de 'Low'
- Para cada Record Type foi criado um layout e posicionamento diferente.

---  

### ⚙️ Validações e Automações  
#### ⏰ Set SLA Deadline By RecordType (Record Triggered Flow)  
Atribui o valor do SLA_Deadline__c baseado no RecordType do objeto.   

Caso o registro seja do tipo Support Premium o flow define o SLA_Deadline__c como DateTime atual + 24h. Support Standard define o SLA_Deadline__c como DateTime atual + 8h.  

Foram criadas 2 condições pois, apenas um if-else após a adição futura de outro RecordType no Case_Request__c o flow iria quebrar, pois, o else iria para qualquer RecordType. Portanto, foram criados três caminhos, Support Premium, Standard e Default Outcome (Vazio).  

![image](https://github.com/user-attachments/assets/5acc893a-75b5-4d91-b8dd-69e9db5451c7)  

#### 📥 Assignment Case to Queue (Auto Launched Flow)  
Com uma lógica semelhante ao flow Set SLA Deadline By RecordType, esse flow pega o recordId do Case_Request__c e define o Owner desse case a uma fila.  

Foram criadas duas filas, a fila Support Premium Queue e Support Standard Queue. Com isso, baseado no RecordType o flow atribui o OwnerId a uma das respectivas filas.  

Além disso ao final desse flow é enviado um email para os usuários da fila informando que o case foi atribuido a fila.

---  

#### Create Case Request (Record triggered Flow)

Ao criar o Case request esse flow é acionado e chama o Assignment Case to Queue através de um subflow.

Esse flow foi criado para que o flow autolaunched funcione através de um botão e através de um record triggered flow como este também.

---

#### Flow Send Email
Flow responsável por enviar email para membros de uma fila específica, informando que um novo caso foi atribuído a fila.

Verifica se existe membro na fila, caso tenha membro na fila ele pega os membros e envia o email.

Este flow é chamado ao final do flow Assign to Queue.

#### 🚫 Require ResolutionNotes Before Close (Validation Rule)  
Impede que o Case Request seja fechado sem antes ter preenchido o campo Resolution_Notes__c do objeto.  

```bash
AND (
  ISPICKVAL( Status__c , 'Closed'),
  ISBLANK( Resolution_Notes__c )
)
```

---

#### 🔐 Case Reopen Permission Validation (Validation Rule)
Verifica se o usuário tem permissão para reabrir um caso.
```bash
AND(
  ISCHANGED( Status__c ),
  NOT(ISPICKVAL( Status__c , 'Closed')),
  NOT($Permission.canReopenCaseRequest)
)
```

---

### 🎨 Lightning Web Components ( LWC )
- 🪟 `caseCloseModal`: Componente de modal customizado para encerramento de casos com regras de validação.
Modal com um campo para inserir o resolution notes e encerrar o caso.
Este componente é filho do caseRequestDetail, onde possuí comunicação enviando informações para o pai, e recebendo informacoes do pai
- 🧾 `caseRequestDetail`: SLA_Deadline__c em contagem regressiva dinâmica e botões para reabrir, avançar para In Progress e fechar caso. 
![image](https://github.com/user-attachments/assets/432ef146-dc37-4e4d-b2cc-b368531ccbe2)
- `caseResolutionNotes`: Componente que funciona a partir de uma comunicação PubSub. ele é o subscriber e o componente caseRequestDetail é o publisher. Quando o Case é fechado no LWC, o publisher envia o pub e após isso o caseResolutionNotes se insreveve e exibe as informações.

---

### 🧠 Apex classes  
#### 📦 Classe `CaseRequestDetailController.cls` 
Esta é a classe que interage com as requisições do componente `caseRequestDetail`, enviando dados específicos a partir de chamadas no LWC.

#### 🧩 Arquitetura - CaseRequestDetailController
```bash
🧱 CaseRequestDetailController           # Classe que faz o contado direto com o FRONT, recebe as requisições do front e chama o service para realizar a regra.
│
└── 🧠 CaseRequestDetailService          # Classe que é chamada pelo Controller e faz toda a lógica da regra solicitada pelo LWC.
```
Foi utilizado essa arquitetura a fim de garantir mais Escalabilidade, Manutenibilidade, Reaproveitamento de código e boas práticas devido a separação de responsabilidades. 

##### 🧩 Método `getSLAInfo(Id caseRequestId)`  
- 🧩 **Função**: Consulta os dados de Case_Request__c pelo Id retorna campos essênciais para criar a regra do timer regressivo do SLA.  
- 🔁 **Chamado por**: Pelo @wire do LWC caseRequestDetail passando o recordId como parâmetro`.  

##### 🧩 Método `reopenCaseRequest(Id caseRequestId)`  
- 🧩 **Função**: Reabre o Case Request alterando o Status__c para In progress.  
- 🔁 **Chamado por**: Pelo @wire do LWC caseRequestDetail passando o recordId como parâmetro`.  
- ✅ **Validações**:  
  - 🛡️ Verifica se o usuário tem o Permission Set Support_Premium. Apenas usuários com o Permission Set Support Premium podem reabrir casos.  

##### 🧩 Método `SupportPremiumUser(String permissionSetName)`  
- 🧩 **Função**: Consulta se o usuário atual possui a Permission set atribuída através de uma query no PermissionSetAssignment, passando o Id do user e a Permission Set no WHERE.  
- 🔁 **Chamado por**: Pela própria classe através dos métodos getSLAInfo(Id caseRequestId) e reopenCaseRequest(Id caseRequestId) `.  

---
### 🧠 Apex REST Resource Class 
#### 🌐 Classe `CaseRequestRestResource.cls`  
Classe responsável por expor um endpoint REST que retorna informações sobre um Case Request específico, dado o seu `Id`.  

##### 🧩 Método `getCaseRequestInfo()`  
- 🧩 **Função**: Expõe um endpoint `GET` no caminho `/services/apexrest/CaseRequest/{id}` que retorna o `Status` e o `SLA_Met` do registro de `Case_Request__c`.  
- 🔁 **Chamado por**: Requisições externas via REST API (ex.: Postman, sistemas externos, integrações).  
- ✅ **Validações e comportamentos**:  
  - ❓ Verifica se o `caseId` está presente e é válido (15 caracteres ou mais).  
  - 🔎 Consulta o `Status__c` e o último `Case_History__c` relacionado, retornando seu campo `SLA_Met__c`.  

#### Endpoint
`GET /services/apexrest/CaseRequest/{caseId}`

#### Parâmetros
| Parâmetro | Tipo   | Obrigatório | Descrição                      |
|-----------|--------|-------------|-------------------------------|
| caseId    | string | Sim         | ID do Case_Request__c         |

#### Sucesso (200)
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
#### Erro (400)
```json
{
  "error": "Invalid or missing CaseRequest Id"
}
```
#### Erro (404)
```json
{
  "error": "Case request not found"
}
```

### ⚡ Apex triggers 
#### 📝 CaseRequestTrigger 
Cria um registro de Case History vinculado ao Case Request. 
- 🧩 **Função**: Sempre que o Objeto alterar o Status para Closed a trigger irá criar um registro de Case History, irá popular o `Time_Closed__c` com a DateTime Now e irá verificar se o SLA foi cumprido. Caso o SLA seja cumprido o campo `SLA_Met__c` será true, ao contrario será false.`.  
- 🔁 **Acionado**: O Trigger é acionado sempre que um objeto é alterado, o Helper verifica se o objeto teve o Campo `Status__c` mudado para 'Closed'.  

#### 🧩 Arquitetura de Trigger - Case Request
```bash
📌 CaseRequestTrigger                 # Trigger Verificando AFTER_UPDATE e chamando `CaseRequestHandler.afterUpdate(oldCases, newCases)`
│
└── 🧱 CaseRequestHandler             # Handler pegando os registros alterados, verificando se o status foi fechado, mandando para o Service criar o Case_History__c e inserindo no BD
│
└── 🧠 CaseRequestService             # Service que verifica se o `SLA_Deadline` foi cumprido e cria o objeto `Case_History__c` populando os campos de forma dinâmica
```

## 🚀 Instruções de Instalação e Deploy

### 📦 Pré-requisitos

- Salesforce CLI (SFDX)
- VS Code com Salesforce Extension Pack
- Conta DevHub, Scratch Org ou Sandbox
- Git instalado
- Acesso ao repositório do projeto

---

### 🔁 1. Clone o Repositório

```bash
git clone https://github.com/seu-usuario/seu-repositorio.git
cd seu-repositorio
```
### 🔐 2. Login na Org Salesforce
#### DevHub:
```bash
  sfdx auth:web:login --setalias DevHub --setdefaultdevhubusername
```
### 📤 3. Deploy do Projeto
```bash
sfdx force:source:deploy -p force-app/main/default -u TechCareSandbox
```
### 🌐 4. Abrir a Org e App Lightning
```bash
sfdx force:org:open
```
### ✅ 5. Rodar Testes Apex
```bash
sfdx force:apex:test:run --resultformat human --outputdir test-results --wait 10
```
### ⚙️ 6. Pós-Deploy Manual
- Criar filas: Support Premium Queue e Support Standard Queue
- Configurar Record Types com layouts e lightning pages
- Atribuir usuários ao perfil Support
- Atribuir Permission Set Support_Standard ou Support_Premium

## 🔍 Como Testar Manualmente a Aplicação

1. **Abra o App TechCare Support**
   - No App Launcher, selecione **TechCare Support**.
   - Verifique se os **dashboards** são exibidos corretamente na Home.

2. **Criar um novo Case Request**
   - Vá para a aba **Case Request**.
   - Clique em **Novo** (Record type será definido automaticamente de acordo com o user Premium ou Standard)
   - Preencha os campos obrigatórios
   - Salve o registro.

3. **Verificar cálculo do SLA Deadline**
   - Após salvar, abra o Case Request.
   - Verifique o campo **SLA Deadline**:
     - Deve ser preenchido automaticamente com +24h (Premium) ou +8h (Standard).
     - No perfil Standard SLA Deadline não aparece 
   - No LWC, o contador regressivo deve aparecer **somente para Premium**.

4. **Testar botão de atribuição à fila**
   - Clique no botão de **assign to queue** no LWC.
   - Confirme se o **OwnerId** do registro foi alterado para a fila correta (Premium ou Standard Queue).

5. **Fechar o caso**
   - No Lwc, Clique em **Marcar como Completed**.
   - O modal deve aparecer com campo de resolução.
   - Tente fechar sem preencher o campo **Resolution Notes** → deve exibir erro
   - No support Standard, apos fechar o caso tente abrir novamente. Deve exibir um erro de validation rule 
     

6. **Reabrir caso**
   - Após fechar um caso, no LWC clique em **Reabrir caso**.
   - Apenas usuários com permission set **Support_Premium** devem conseguir reabrir.
   - O status do caso deve voltar para **In Progress**.

7. **Verificar criação do histórico**
   - Após fechar um caso, acesse os **registros relacionados**.
   - Um novo **Case_History__c** deve ter sido criado.
   - Verifique se os campos **Time Closed** e **SLA Met** estão corretos.

---





