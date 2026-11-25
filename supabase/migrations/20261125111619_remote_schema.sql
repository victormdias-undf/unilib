DROP POLICY "Admin vê o próprio cadastro" ON "public"."admins";

ALTER TABLE "public"."admins"
  DROP CONSTRAINT "admins_user_id_fkey";

ALTER TABLE "public"."admins"
  DROP CONSTRAINT "admins_user_id_key";

ALTER TABLE "public"."admins"
  ALTER COLUMN "id" DROP DEFAULT;

ALTER TABLE "public"."admins"
  DROP COLUMN "user_id";

ALTER TABLE "public"."admins"
  ADD CONSTRAINT "admins_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER VIEW "public"."alunos_publicos" SET (security_invoker=on);

CREATE POLICY "Admin vê o próprio cadastro" ON "public"."admins"
  FOR SELECT
  TO "authenticated"
  USING ((id = auth.uid()));

COMMENT ON COLUMN "public"."admins"."id" IS 'Mesmo id do usuário em auth.users.';

