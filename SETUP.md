# Frequência — configuração do painel Supabase

Este projeto já contém um painel administrativo conectado ao Supabase (login, artigos, acordes, configurações básicas e upload de imagens). Para salvar dados de verdade, complete os passos abaixo.

## 1. Criar o Supabase
1. Entre em https://supabase.com e crie um projeto.
2. Abra **SQL Editor → New query**.
3. Abra `supabase-setup.sql`, copie todo o conteúdo e execute no SQL Editor.
4. Em **Project Settings → API** (ou Connect), copie o **Project URL** e a **Publishable key**. Use apenas a publishable/anon key no frontend; nunca use `service_role` ou outra chave secreta no código do navegador.

## 2. Criar sua conta e torná-la administradora
1. No Supabase, vá a **Authentication → Users → Add user / Create new user**.
2. Crie seu usuário com o e-mail e senha que usará no painel. Se houver opção de confirmação de e-mail, confirme a conta antes de entrar.
3. Copie o UUID desse usuário na lista de usuários.
4. No SQL Editor execute, substituindo o UUID pelo seu:

```sql
insert into public.admins (user_id)
values ('COLE-AQUI-O-UUID-DO-SEU-USUARIO');
```

Não crie uma opção pública de cadastro de administradores. Somente usuários inseridos manualmente nessa tabela terão permissão de edição.

## 3. Testar localmente
1. Abra a pasta do projeto no VS Code.
2. Copie `.env.example` para um arquivo chamado `.env.local`.
3. Preencha os valores:

```env
VITE_SUPABASE_URL=https://SEU-PROJETO.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=sua_publishable_key
```

4. No terminal do VS Code, execute:

```powershell
npm install
npm run dev
```

5. Abra a URL local mostrada no terminal. Clique em **Painel**, entre com a conta criada no Supabase e teste criar um artigo como rascunho, publicá-lo, cadastrar um acorde, alterar as configurações e enviar uma imagem.

## 4. Publicar no GitHub Pages
1. Crie um repositório no GitHub e envie o conteúdo desta pasta (não apenas o ZIP).
2. No repositório, abra **Settings → Secrets and variables → Actions → New repository secret**.
3. Crie estes dois secrets, com os valores do Supabase:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_PUBLISHABLE_KEY`
4. Abra **Settings → Pages** e selecione **GitHub Actions** como Build and deployment source.
5. Faça commit/push para a branch `main`. A workflow `.github/workflows/deploy.yml` fará o build e deploy. Acompanhe em **Actions**.

A chave publishable é projetada para uso público no frontend, mas a segurança depende das políticas RLS do SQL. Nunca publique `service_role`, senhas de banco, tokens pessoais ou segredos administrativos.

## Funcionalidades do painel
- Login por e-mail e senha do Supabase Auth.
- Criar/editar artigos, com status rascunho ou publicado.
- Criar/editar acordes de violão e guitarra, com categoria, nível e imagem.
- Upload de imagens no bucket `media` e cópia da URL pública.
- Alterar nome, título da página inicial, texto inicial e texto Sobre.
- A área pública consulta apenas artigos/acordes publicados; as políticas RLS restringem edição a usuários em `public.admins`.

## Limitações conhecidas
- Este é um painel funcional básico, não um construtor visual de arrastar-e-soltar. As configurações editáveis são os campos listados acima.
- Os diagramas de acordes podem ser cadastrados como imagem; o editor gráfico de posições no braço não está incluído ainda.
- O armazenamento do bucket `media` é público para leitura, adequado a imagens editoriais públicas. Não envie documentos privados ou imagens sensíveis.
- GitHub Pages é hospedagem estática: toda autenticação e persistência é feita pelo Supabase.
