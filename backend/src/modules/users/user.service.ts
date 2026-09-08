import { findUserById } from "./user.repository.js";

export const getUserById = async (userId: number) => {
  return findUserById(userId);
};