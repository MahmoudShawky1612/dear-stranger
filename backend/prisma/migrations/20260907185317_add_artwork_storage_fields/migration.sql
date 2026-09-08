/*
  Warnings:

  - You are about to drop the column `image_url` on the `artworks` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[storage_key]` on the table `artworks` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `content_type` to the `artworks` table without a default value. This is not possible if the table is not empty.
  - Added the required column `file_size_bytes` to the `artworks` table without a default value. This is not possible if the table is not empty.
  - Added the required column `storage_key` to the `artworks` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "artworks" DROP COLUMN "image_url",
ADD COLUMN     "content_type" TEXT NOT NULL,
ADD COLUMN     "file_size_bytes" INTEGER NOT NULL,
ADD COLUMN     "storage_key" TEXT NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "artworks_storage_key_key" ON "artworks"("storage_key");
