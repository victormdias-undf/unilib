-- =====================================================================
-- UniLib - Fórum: tópicos, palavras relacionadas e comentários
-- =====================================================================

-- Palavras relacionadas (tags) disponíveis para os tópicos
create table public.palavras_relacionadas (
    id    smallint generated always as identity primary key,
    nome  text not null unique
);

insert into public.palavras_relacionadas (nome) values
    ('Reclamações'),
    ('Sugestões'),
    ('Dúvidas'),
    ('Elogios'),
    ('Biblioteca'),
    ('Empréstimos'),
    ('Infraestrutura'),
    ('Salas de Estudo'),
    ('Laboratórios'),
    ('Tecnologia e Wi-Fi'),
    ('Acessibilidade'),
    ('Segurança no Campus'),
    ('Transporte'),
    ('Bolsas e Auxílios'),
    ('Assistência Estudantil'),
    ('Saúde Mental'),
    ('Calendário Acadêmico'),
    ('Grade Curricular'),
    ('Professores e Didática'),
    ('Provas e Avaliações'),
    ('Grupos de Estudo'),
    ('Pesquisa e Iniciação Científica'),
    ('Extensão'),
    ('Estágios e Carreira'),
    ('Eventos'),
    ('Esportes e Lazer'),
    ('Cultura e Arte'),
    ('Sustentabilidade'),
    ('Diretório Acadêmico'),
    ('Compra e Troca de Materiais');

-- Tópicos
create table public.topicos_forum (
    id          uuid primary key default gen_random_uuid(),
    nome        text not null check (char_length(trim(nome)) > 0),
    aluno_id    uuid not null default auth.uid() references public.alunos (id) on delete cascade,
    created_at  timestamptz not null default now()
);

create index topicos_forum_aluno_id_idx on public.topicos_forum (aluno_id);

-- N:N tópico <-> palavras relacionadas
create table public.topico_palavras (
    topico_id  uuid     not null references public.topicos_forum (id) on delete cascade,
    palavra_id smallint not null references public.palavras_relacionadas (id) on delete cascade,
    primary key (topico_id, palavra_id)
);

create index topico_palavras_palavra_id_idx on public.topico_palavras (palavra_id);

-- Comentários (cada comentário pertence a um tópico)
create table public.comentarios (
    id          uuid primary key default gen_random_uuid(),
    topico_id   uuid not null references public.topicos_forum (id) on delete cascade,
    aluno_id    uuid not null default auth.uid() references public.alunos (id) on delete cascade,
    comentario  text not null check (char_length(trim(comentario)) > 0),
    created_at  timestamptz not null default now()
);

create index comentarios_topico_id_idx on public.comentarios (topico_id, created_at);
create index comentarios_aluno_id_idx  on public.comentarios (aluno_id);

-- ---------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------
alter table public.palavras_relacionadas enable row level security;
alter table public.topicos_forum         enable row level security;
alter table public.topico_palavras       enable row level security;
alter table public.comentarios           enable row level security;

-- Palavras: somente leitura para o app
create policy "Todos autenticados veem palavras"
    on public.palavras_relacionadas for select
    to authenticated
    using (true);

-- Tópicos
create policy "Todos autenticados veem tópicos"
    on public.topicos_forum for select
    to authenticated
    using (true);

create policy "Aluno cria tópico"
    on public.topicos_forum for insert
    to authenticated
    with check (aluno_id = auth.uid());

create policy "Autor edita tópico"
    on public.topicos_forum for update
    to authenticated
    using (aluno_id = auth.uid())
    with check (aluno_id = auth.uid());

create policy "Autor remove tópico"
    on public.topicos_forum for delete
    to authenticated
    using (aluno_id = auth.uid());

-- Palavras do tópico
create policy "Todos autenticados veem palavras dos tópicos"
    on public.topico_palavras for select
    to authenticated
    using (true);

create policy "Autor do tópico adiciona palavras"
    on public.topico_palavras for insert
    to authenticated
    with check (exists (
        select 1 from public.topicos_forum t
        where t.id = topico_id and t.aluno_id = auth.uid()
    ));

create policy "Autor do tópico remove palavras"
    on public.topico_palavras for delete
    to authenticated
    using (exists (
        select 1 from public.topicos_forum t
        where t.id = topico_id and t.aluno_id = auth.uid()
    ));

-- Comentários
create policy "Todos autenticados veem comentários"
    on public.comentarios for select
    to authenticated
    using (true);

create policy "Aluno comenta"
    on public.comentarios for insert
    to authenticated
    with check (aluno_id = auth.uid());

create policy "Autor edita comentário"
    on public.comentarios for update
    to authenticated
    using (aluno_id = auth.uid())
    with check (aluno_id = auth.uid());

create policy "Autor remove comentário"
    on public.comentarios for delete
    to authenticated
    using (aluno_id = auth.uid());

-- Realtime para comentários aparecerem ao vivo no tópico
alter publication supabase_realtime add table public.comentarios;
