-- =====================================================================
-- UniLib - Protocolos (mensagens do aluno para a universidade)
-- =====================================================================

create table public.protocolos (
    id          uuid primary key default gen_random_uuid(),
    titulo      text not null check (char_length(trim(titulo)) > 0),
    mensagem    text not null check (char_length(trim(mensagem)) > 0),
    aluno_id    uuid not null default auth.uid() references public.alunos (id) on delete cascade,
    created_at  timestamptz not null default now()
);

create index protocolos_aluno_id_idx on public.protocolos (aluno_id, created_at desc);

alter table public.protocolos enable row level security;

-- O aluno vê e envia apenas os próprios protocolos.
-- A universidade lê todos pelo dashboard / service_role.
create policy "Aluno vê seus protocolos"
    on public.protocolos for select
    to authenticated
    using (aluno_id = auth.uid());

create policy "Aluno envia protocolo"
    on public.protocolos for insert
    to authenticated
    with check (aluno_id = auth.uid());
