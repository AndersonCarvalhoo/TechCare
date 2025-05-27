# TechCare Support in Salesforce
## Informações do Responsável
- Nome: Anderson Carvalho
- Perfil Escolhido: Desenvolvedor com conhecimentos em Admin

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

### 🧱 Custom Objects
#### Case_Request__c 
Para registrar os casos de suporte foi criado um objeto Case Request. O objeto Case Request armazena importantes para chamado, nele pode colocar o assunto, descrição, status, prioridade e dentre outros. 
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

### ⚡ Page Layouts e Lightning Record Pages
- Foram criados Page Layouts e Lightning Record Pages específicas para cada record type.
- Na Page Layout e Lightning Record Page do Standard Premium foi configurado o campo Priority como obrigátorio.
- O campo SLA Deadline não deve aparecer para o Support Standard. Para isso foi garantido que Na Page Layout e na Lightning Record Page não apareca.
- No Lightning Record Page do Support Premium o campo SLA_Deadline__c só é exibido se o priority for diferente de 'Low'
- Para cada Record Type foi criado um layout e posicionamento diferente.

### Validações e Automações
#### Set SLA Deadline By RecordType (Record Triggered Flow)
Atribui o valor do SLA_Deadline__c baseado no RecordType do objeto. 

Caso o registro seja do tipo Support Premium o flow define o SLA_Deadline__c como DateTime atual + 24h. Support Standard define o SLA_Deadline__c como DateTime atual + 8h.

Foram criadas 2 condições pois, apenas um if-else após a adição futura de outro RecordType no Case_Request__c o flow iria quebrar, pois, o else iria para qualquer RecordType. Portanto, foram criados três caminhos, Support Premium, Standard e Default Outcome (Vazio).

![image](https://github.com/user-attachments/assets/5acc893a-75b5-4d91-b8dd-69e9db5451c7)

#### Assignment Case to Queue (Auto Launched Flow)
Com uma lógica semelhante ao flow Set SLA Deadline By RecordType, esse flow pega o recordId do Case_Request__c e define o Owner desse case a uma fila.

Foram criadas duas filas, a fila Support Premium Queue e Support Standard Queue. Com isso, baseado no RecordType o flow atribui o OwnerId a uma das respectivas filas.

#### Require ResolutionNotes Before Close (Validation Rule)
Impede que o Case Request seja fechado sem antes ter preenchido o campo Resolution_Notes__c do objeto.

```bash
AND (
  ISPICKVAL( Status__c , 'Closed'),
  ISBLANK( Resolution_Notes__c )
)
```
#### Case Reopen Permission Validation (Validation Rule)
Verifica se o usuário tem permissão para reabrir um caso.
```bash
AND(
  ISCHANGED( Status__c ),
  NOT(ISPICKVAL( Status__c , 'Closed')),
  NOT($Permission.canReopenCaseRequest)
)
```

### 🎨 Lightning Web Components ( LWC )
- 🪟 `caseCloseModal`: modal customizado para encerramento de casos com regras de validação.
Modal com um campo para inserir o resolution notes e encerrar o caso.
- 🧾 `caseRequestDetail`: SLA_Deadline__c em contagem regressiva dinâmica e botões para reabrir, avançar para In Progress e fechar caso. 
![image](https://github.com/user-attachments/assets/432ef146-dc37-4e4d-b2cc-b368531ccbe2)

### Apex classes
#### Classe `CaseRequestDetailController.cls`
Esta é a classe que interage com as requisições do componente `caseRequestDetail`, enviando dados específicos a partir de chamadas no LWC.
##### Método `getSLAInfo(Id caseRequestId)`
- 🧩 **Função**: Consulta os dados de Case_Request__c pelo Id retorna campos essênciais para criar a regra do timer regressivo do SLA.
- 🔁 **Chamado por**: Pelo @wire do LWC caseRequestDetail passando o recordId como parâmetro`.
##### Método `reopenCaseRequest(Id caseRequestId)`
- 🧩 **Função**: Reabre o Case Request alterando o Status__c para In progress.
- 🔁 **Chamado por**: Pelo @wire do LWC caseRequestDetail passando o recordId como parâmetro`.
- ✅ **Validações**:
  - Verifica se o usuário tem o Permission Set Support_Premium. Apenas usuários com o Permission Set Support Premium podem reabrir casos.
##### Método `SupportPremiumUser(String permissionSetName)`
- 🧩 **Função**: Consulta se o usuário atual possui a Permission set atribuída através de uma query em PermissionSetAssignment passando o Id do user e a Permission Set no WHERE.
- 🔁 **Chamado por**: Pela própria classe através dos métodos `getSLAInfo(Id caseRequestId)` e `reopenCaseRequest(Id caseRequestId)` `.

### Apex triggers
#### Case Request Trigger
Cria um registro de Case History vinculado ao Case Request. 

Sempre que o Objeto alterar o Status para Closed a trigger irá criar um registro de Case History, irá popular o Time_Closed__c com a DateTime Now e irá verificar se o SLA foi cumprido. Caso o SLA seja cumprido o campo SLA_Met__c será true, ao contrario será false.

#### 🧩 Arquitetura de Trigger - Case Request
```bash
📌 CaseRequestTrigger
│
└── 🧱 CaseRequestHandler
│
└── 🧠 CaseRequestService
```





