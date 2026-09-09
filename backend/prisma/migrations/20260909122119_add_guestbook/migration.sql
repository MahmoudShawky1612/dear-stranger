-- CreateTable
CREATE TABLE "guestbook_entries" (
    "id" SERIAL NOT NULL,
    "host_id" INTEGER NOT NULL,
    "author_id" INTEGER NOT NULL,
    "message" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "guestbook_entries_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "guestbook_entries_host_id_created_at_idx" ON "guestbook_entries"("host_id", "created_at");

-- AddForeignKey
ALTER TABLE "guestbook_entries" ADD CONSTRAINT "guestbook_entries_host_id_fkey" FOREIGN KEY ("host_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "guestbook_entries" ADD CONSTRAINT "guestbook_entries_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
