-- =====================================================================
-- UniLib - Storage para imagens dos produtos
-- Caminho esperado: produtos/<auth.uid()>/<arquivo>
-- O valor salvo em produtos.imagem_path é "<auth.uid()>/<arquivo>".
-- =====================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('produtos', 'produtos', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

create policy "Leitura pública das imagens de produtos"
    on storage.objects for select
    using (bucket_id = 'produtos');

create policy "Aluno envia imagem na própria pasta"
    on storage.objects for insert
    to authenticated
    with check (
        bucket_id = 'produtos'
        and (storage.foldername(name))[1] = auth.uid()::text
    );

create policy "Aluno atualiza imagem da própria pasta"
    on storage.objects for update
    to authenticated
    using (
        bucket_id = 'produtos'
        and (storage.foldername(name))[1] = auth.uid()::text
    );

create policy "Aluno remove imagem da própria pasta"
    on storage.objects for delete
    to authenticated
    using (
        bucket_id = 'produtos'
        and (storage.foldername(name))[1] = auth.uid()::text
    );
