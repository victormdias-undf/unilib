-- =====================================================================
-- UniLib - Admins (equipe da biblioteca)
-- A senha NÃO fica nesta tabela: ela é gerenciada pelo Supabase Auth
-- (auth.users). Cada admin é 1:1 com um usuário do Auth (mesmo id).
-- Diferente de public.alunos, não existe trigger de cadastro automático:
-- só vira administrador quem for explicitamente cadastrado como tal.
-- =====================================================================

create table public.admins (
    id      uuid primary key references auth.users (id) on delete cascade,
    cpf     char(11) not null unique check (cpf ~ '^[0-9]{11}$'),
    email   text not null unique
);

comment on table   public.admins       is 'Equipe da biblioteca. Senha fica em auth.users.';
comment on column  public.admins.id    is 'Mesmo id do usuário em auth.users.';
comment on column  public.admins.cpf   is 'CPF do administrador, somente os 11 dígitos.';
comment on column  public.admins.email is 'E-mail institucional do administrador.';

-- ---------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------
alter table public.admins enable row level security;

-- O admin enxerga apenas o próprio cadastro (serve para o painel conferir
-- se o usuário logado é administrador). Ninguém do app pode criar, editar
-- ou remover admins: isso é feito via service_role / SQL Editor.
create policy "Admin vê o próprio cadastro"
    on public.admins for select
    to authenticated
    using (id = auth.uid());

revoke all    on public.admins from anon, authenticated;
grant  select on public.admins to authenticated;

-- ---------------------------------------------------------------------
-- Como cadastrar um admin (fora do app, via service_role ou SQL Editor):
-- 1) crie o usuário no Supabase Auth (Authentication > Users > Add user);
-- 2) insira a linha usando o MESMO id gerado no Auth:
--
-- insert into public.admins (id, cpf, email)
-- values ('<uuid-do-auth>', '12345678901', 'biblioteca@universidade.edu.br');
-- ---------------------------------------------------------------------
