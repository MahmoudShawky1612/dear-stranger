-- CreateTable
CREATE TABLE "artwork_uploads" (
    "id" SERIAL NOT NULL,
    "letter_id" INTEGER NOT NULL,
    "artist_id" INTEGER NOT NULL,
    "storage_key" TEXT NOT NULL,
    "content_type" TEXT NOT NULL,
    "expected_size" INTEGER NOT NULL,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "artwork_uploads_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "artwork_uploads_storage_key_key" ON "artwork_uploads"("storage_key");

-- CreateIndex
CREATE INDEX "artwork_uploads_letter_id_artist_id_idx" ON "artwork_uploads"("letter_id", "artist_id");

-- CreateIndex
CREATE INDEX "artwork_uploads_expires_at_idx" ON "artwork_uploads"("expires_at");

-- AddForeignKey
ALTER TABLE "artwork_uploads" ADD CONSTRAINT "artwork_uploads_letter_id_fkey" FOREIGN KEY ("letter_id") REFERENCES "letters"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "artwork_uploads" ADD CONSTRAINT "artwork_uploads_artist_id_fkey" FOREIGN KEY ("artist_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
