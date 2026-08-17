# Registro de Verificação e Correção de Backend — 2GO Mobile

> **AVISO IMPORTANTE DE AUDITORIA DE INTEGRAÇÃO**
>
> A documentação preliminar produzida na Fase 4 utilizou por equívoco um projeto web secundário.
> 
> O backend oficial e autêntico da plataforma **2GO Mobile / AppRoteiros** foi devidamente auditado e confirmado no repositório **`app-roteiros-core`**.

---

## 1. Identificação do Backend Oficial
* **Nome do Repositório**: `app-roteiros-core`
* **URL do Repositório Git**: `git@github.com:ronilsonbatista/app-roteiros-core.git`
* **Branch Principal**: `main`
* **Tecnologia**: NestJS 11 + TypeScript 5.7 + Prisma ORM 7.8 + PostgreSQL + JWT + Swagger / OpenAPI.

---

## 2. Decisão de Correção
Todas as especificações de API e contratos em `docs/api_contracts/` foram totalmente alinhadas com o código-fonte real do repositório `app-roteiros-core`.

As referências anteriores a tecnologias não presentes no backend oficial (como Supabase BaaS e PostgREST) foram descartadas e substituídas pelas rotas e contratos da API NestJS.
