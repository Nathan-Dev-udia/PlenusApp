# PlenusApp

**PlenusApp** é um aplicativo Android desenvolvido em **Flutter** que permite aos clientes de empresas de contabilidade acessar e gerenciar suas guias de pagamento e documentos fiscais de forma simples e segura.  

O app se conecta ao **Firebase Realtime Database** e utiliza o **Firebase Authentication** para autenticação, exibindo os arquivos armazenados em pastas no **Google Drive** associadas a cada cliente.

---

## ⚡ Funcionalidades Principais

### 🔹 Login e Criação de Conta
- Autenticação via **Firebase Authentication**;  
- Criação automática de conta se o usuário não existir;  
- Feedback de sucesso ou erro no login;  
- Interface responsiva e agradável.

### 🔹 Listagem de Guias
- Visualização de guias **pendentes** e **concluídas** em abas separadas;  
- Ordenação das guias por **data de postagem**;  
- Indicadores visuais de status (pendente/concluída);  
- Interface clara com cards estilizados.

### 🔹 Detalhes da Guia
- Ao clicar em uma guia, o usuário acessa a **tela de detalhes**:
  - Data de vencimento (ou mensagem indicando ausência de data);  
  - Instruções da guia;  
  - Botão para abrir a **pasta no Google Drive** contendo os arquivos;  
  - Botão para marcar/desmarcar a guia como concluída.

### 🔹 Sincronização em Tempo Real
- Todos os dados (guias, status, instruções) são **sincronizados imediatamente** com o Firebase;  
- Atualização de status refletida instantaneamente no app e no painel administrativo.

---

## 📱 Fluxo de Uso do Cliente

1. Cliente abre o **PlenusApp**;  
2. Realiza login com e-mail e senha;  
3. Lista de guias pendentes e concluídas é carregada do Firebase;  
4. Cliente seleciona uma guia para ver detalhes;  
5. Na tela de detalhes, pode:
   - Visualizar a data de vencimento e instruções;  
   - Abrir a pasta no Google Drive;  
   - Marcar como concluída;  
6. O status é atualizado no Firebase em tempo real.

---

## 🧩 Tecnologias Utilizadas

| Camada | Tecnologia |
| :--- | :--- |
| **Mobile App** | Flutter |
| **Banco de Dados** | Firebase Realtime Database |
| **Autenticação** | Firebase Authentication |
| **Armazenamento de Arquivos** | Google Drive API |

---

## 🎨 Interface do Usuário

- **LoginPage:** Tela de login com campos de e-mail e senha, suporte à criação de conta automática;  
- **HomePage:** Exibe abas de guias pendentes e concluídas, com cards estilizados;  
- **GuiaPage:** Detalhes da guia, data de vencimento, instruções e botões de ação (abrir Drive, concluir guia);  
- Design responsivo, com cores consistentes e gradientes suaves.

---

## 🛠️ Funcionalidades Técnicas Extras

- **RouteObserver** global para controle de navegação e status bar;  
- Tratamento de exceções em login e abertura de links;  
- Ordenação automática de guias por data de postagem;  
- Feedback visual com SnackBars em todas as ações do usuário.

---

## 🚀 Aprendizados e Decisões Técnicas

- Primeiro aplicativo **Flutter** desenvolvido para uso empresarial real;  
- Integração prática com **Firebase Authentication** e **Realtime Database**;  
- Aprendizado na manipulação de links externos (**URL Launcher**) e sincronização em tempo real;  
- Estrutura de código modular e escalável, permitindo fácil manutenção e expansão;  
- Design de UX voltado para simplicidade e clareza na experiência do cliente.

---
## 🧑‍💻 Autor

**Nathan Fernandes Alves**
Desenvolvedor FullStack • Foco em sistemas integrados e soluções automatizadas  

| Contato | Link |
| :-- | :-- |
| 📧 **E-mail Profissional** | [nathan.dev.udia@gmail.com](mailto:nathan.dev.udia@gmail.com) |
| 🌐 **LinkedIn** | [linkedin.com/in/nathan-fernandes-alves](https://www.linkedin.com/in/nathan-fernandes-93761a179/) |
| 💼 **Porfólio** | [https://github.com/nathan-fernandes-alves](https://nathan-dev-udia.github.io/portfolio/) |
