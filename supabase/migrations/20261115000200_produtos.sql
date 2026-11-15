-- =====================================================================
-- UniLib - Produtos e Favoritos
-- "Produtos emprestados" do aluno = produtos onde aluno_id = aluno.
-- "Emprestado por" = emprestado_por_aluno_id; NULL significa Universidade.
-- =====================================================================

create type public.produto_tipo   as enum ('livro', 'eletronico', 'itens_gerais', 'sala');
create type public.produto_estado as enum ('pessimo', 'mediano', 'bom');

create table public.produtos (
    id                       uuid primary key default gen_random_uuid(),
    nome                     text not null,
    tipo                     public.produto_tipo not null,
    descricao                text not null default '',
    estado                   public.produto_estado not null default 'bom',
    imagem_path              text,          -- caminho no bucket "produtos" do Storage

    -- Dono / quem disponibiliza o item (NULL = Universidade)
    emprestado_por_aluno_id  uuid references public.alunos (id) on delete cascade,

    -- Empréstimo atual
    emprestado               boolean not null default false,
    aluno_id                 uuid references public.alunos (id) on delete set null,
    data_entrega             date,

    created_at               timestamptz not null default now(),

    -- Se emprestado, precisa de aluno e data de devolução; se não, ambos nulos.
    constraint produtos_emprestimo_consistente check (
        (emprestado and aluno_id is not null and data_entrega is not null)
        or (not emprestado and aluno_id is null and data_entrega is null)
    )
);

-- Coluna de conveniência para exibir "Universidade" ou o id do aluno.
alter table public.produtos
    add column emprestado_por text
    generated always as (coalesce(emprestado_por_aluno_id::text, 'universidade')) stored;

create index produtos_aluno_id_idx              on public.produtos (aluno_id);
create index produtos_emprestado_por_aluno_idx  on public.produtos (emprestado_por_aluno_id);
create index produtos_tipo_idx                  on public.produtos (tipo);

-- ---------------------------------------------------------------------
-- Favoritos (N:N aluno <-> produto)
-- ---------------------------------------------------------------------
create table public.favoritos (
    aluno_id    uuid not null default auth.uid() references public.alunos (id) on delete cascade,
    produto_id  uuid not null references public.produtos (id) on delete cascade,
    created_at  timestamptz not null default now(),
    primary key (aluno_id, produto_id)
);

create index favoritos_produto_id_idx on public.favoritos (produto_id);

-- ---------------------------------------------------------------------
-- RLS - Produtos
-- ---------------------------------------------------------------------
alter table public.produtos enable row level security;

create policy "Todos autenticados veem produtos"
    on public.produtos for select
    to authenticated
    using (true);

create policy "Aluno cadastra produto próprio"
    on public.produtos for insert
    to authenticated
    with check (emprestado_por_aluno_id = auth.uid() and emprestado = false);

create policy "Aluno edita produto próprio"
    on public.produtos for update
    to authenticated
    using (emprestado_por_aluno_id = auth.uid())
    with check (emprestado_por_aluno_id = auth.uid());

create policy "Aluno remove produto próprio não emprestado"
    on public.produtos for delete
    to authenticated
    using (emprestado_por_aluno_id = auth.uid() and emprestado = false);

-- Campos de empréstimo só mudam pelas funções emprestar/devolver.
revoke update on public.produtos from authenticated, anon;
grant  update (nome, tipo, descricao, estado, imagem_path) on public.produtos to authenticated;

-- ---------------------------------------------------------------------
-- RLS - Favoritos
-- ---------------------------------------------------------------------
alter table public.favoritos enable row level security;

create policy "Aluno vê seus favoritos"
    on public.favoritos for select
    to authenticated
    using (aluno_id = auth.uid());

create policy "Aluno adiciona favorito"
    on public.favoritos for insert
    to authenticated
    with check (aluno_id = auth.uid());

create policy "Aluno remove favorito"
    on public.favoritos for delete
    to authenticated
    using (aluno_id = auth.uid());
