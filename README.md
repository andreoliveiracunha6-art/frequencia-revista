# Frequência — Revista Musical

Site editorial em React + Vite, com painel administrativo conectado ao Supabase e preparado para GitHub Pages.

**Comece por `SETUP.md`** para criar tabelas e políticas, cadastrar seu usuário administrador, configurar as variáveis de ambiente e publicar.

- `supabase-setup.sql`: tabelas, RLS e políticas do armazenamento.
- `.env.example`: variáveis necessárias para desenvolvimento local.
- `src/main.jsx`: site público e painel administrativo.
- `.github/workflows/deploy.yml`: compilação e publicação automática no GitHub Pages.

Segurança: use somente a chave publishable/anon no frontend e habilite as políticas RLS fornecidas. Nunca coloque `service_role` ou senhas no repositório.
