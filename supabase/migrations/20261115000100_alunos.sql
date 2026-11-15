-- =====================================================================
-- UniLib - Alunos
-- A senha NÃO fica nesta tabela: ela é gerenciada pelo Supabase Auth
-- (auth.users). Cada aluno é 1:1 com um usuário do Auth (mesmo id).
-- =====================================================================

create type public.aluno_status as enum ('disponivel', 'bloqueado');

create table public.alunos (
    id          uuid primary key references auth.users (id) on delete cascade,
    nome        text not null default '',
    cpf         char(11) not null unique check (cpf ~ '^[0-9]{11}$'),
    email       text not null unique,
    status      public.aluno_status not null default 'disponivel',
    created_at  timestamptz not null default now()
);

comment on table  public.alunos is 'Alunos da universidade. Senha fica em auth.users.';
comment on column public.alunos.status is 'disponivel = pode pegar empréstimo; bloqueado = não pode.';

-- ---------------------------------------------------------------------
-- Cria automaticamente a linha em public.alunos quando alguém se cadastra
-- no Auth. O app deve enviar cpf e nome em `data` no signUp.
-- ---------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
    insert into public.alunos (id, email, cpf, nome)
    values (
        new.id,
        new.email,
        regexp_replace(coalesce(new.raw_user_meta_data ->> 'cpf', ''), '[^0-9]', '', 'g'),
        coalesce(new.raw_user_meta_data ->> 'nome', '')
    );
    return new;
end;
$$;

create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------
alter table public.alunos enable row level security;

create policy "Aluno vê o próprio cadastro"
    on public.alunos for select
    to authenticated
    using (id = auth.uid());

create policy "Aluno edita o próprio cadastro"
    on public.alunos for update
    to authenticated
    using (id = auth.uid())
    with check (id = auth.uid());

-- O aluno só pode alterar o próprio nome. CPF, email e status
-- (bloqueio) só são alterados pela universidade (dashboard / service_role).
revoke update on public.alunos from authenticated, anon;
grant  update (nome) on public.alunos to authenticated;

-- ---------------------------------------------------------------------
-- Visão pública (só id e nome) para exibir autores no fórum
-- sem expor CPF/email de outros alunos.
-- ---------------------------------------------------------------------
create view public.alunos_publicos as
    select id, nome from public.alunos;

revoke all on public.alunos_publicos from anon;
grant select on public.alunos_publicos to authenticated;
