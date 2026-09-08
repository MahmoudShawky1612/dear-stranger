-- CreateTable
CREATE TABLE "artworks" (
    "id" SERIAL NOT NULL,
    "letter_id" INTEGER NOT NULL,
    "image_url" TEXT NOT NULL,
    "is_anonymous" BOOLEAN NOT NULL DEFAULT false,
    "is_published" BOOLEAN NOT NULL DEFAULT false,
    "published_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "artworks_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "artworks_letter_id_key" ON "artworks"("letter_id");

-- CreateIndex
CREATE INDEX "letters_status_created_at_idx" ON "letters"("status", "created_at");

-- CreateIndex
CREATE INDEX "letters_sender_id_created_at_idx" ON "letters"("sender_id", "created_at");

-- CreateIndex
CREATE INDEX "letters_artist_id_status_idx" ON "letters"("artist_id", "status");

-- AddForeignKey
ALTER TABLE "artworks" ADD CONSTRAINT "artworks_letter_id_fkey" FOREIGN KEY ("letter_id") REFERENCES "letters"("id") ON DELETE CASCADE ON UPDATE CASCADE;
