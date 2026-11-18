-- =====================================================================
-- UniLib - Funções de empréstimo (chamadas via supabase.rpc no app)
-- =====================================================================

-- Pega um produto emprestado para o aluno logado.
create or replace function public.emprestar_produto(p_produto_id uuid, p_data_entrega date)
returns public.produtos
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_status  public.aluno_status;
    v_produto public.produtos;
begin
    if auth.uid() is null then
        raise exception 'Não autenticado';
    end if;

    select status into v_status from public.alunos where id = auth.uid();
    if v_status is null then
        raise exception 'Aluno não encontrado';
    end if;
    if v_status = 'bloqueado' then
        raise exception 'Aluno bloqueado para empréstimos';
    end if;

    if p_data_entrega is null or p_data_entrega < current_date then
        raise exception 'Data de entrega inválida';
    end if;

    select * into v_produto from public.produtos where id = p_produto_id for update;
    if not found then
        raise exception 'Produto não encontrado';
    end if;
    if v_produto.emprestado then
        raise exception 'Produto já está emprestado';
    end if;
    if v_produto.emprestado_por_aluno_id = auth.uid() then
        raise exception 'Você não pode pegar emprestado o seu próprio produto';
    end if;

    update public.produtos
       set emprestado = true,
           aluno_id = auth.uid(),
           data_entrega = p_data_entrega
     where id = p_produto_id
    returning * into v_produto;

    return v_produto;
end;
$$;

-- Devolve um produto. Pode ser chamado por quem pegou ou pelo dono (aluno).
-- Produtos da universidade também podem ser devolvidos pelo dashboard/service_role.
create or replace function public.devolver_produto(p_produto_id uuid)
returns public.produtos
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_produto public.produtos;
begin
    if auth.uid() is null then
        raise exception 'Não autenticado';
    end if;

    select * into v_produto from public.produtos where id = p_produto_id for update;
    if not found then
        raise exception 'Produto não encontrado';
    end if;
    if not v_produto.emprestado then
        raise exception 'Produto não está emprestado';
    end if;
    if v_produto.aluno_id is distinct from auth.uid()
       and v_produto.emprestado_por_aluno_id is distinct from auth.uid() then
        raise exception 'Sem permissão para devolver este produto';
    end if;

    update public.produtos
       set emprestado = false,
           aluno_id = null,
           data_entrega = null
     where id = p_produto_id
    returning * into v_produto;

    return v_produto;
end;
$$;

revoke execute on function public.emprestar_produto(uuid, date) from public, anon;
revoke execute on function public.devolver_produto(uuid)        from public, anon;
grant  execute on function public.emprestar_produto(uuid, date) to authenticated;
grant  execute on function public.devolver_produto(uuid)        to authenticated;
