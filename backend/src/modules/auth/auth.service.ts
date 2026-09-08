import {
  createUser,
  findUserByEmail,
  findUserByIdentifier,
  findUserByUsername,
} from "../users/user.repository.js";
import { hashPassword } from "./auth.password.js";
import { createUserSession } from "./auth.session.service.js";
import type { RegisterInput } from "./auth.schema.js";
import { verifyPassword } from "./auth.password.js";
import type { LoginInput } from "./auth.schema.js";


export class InvalidCredentialsError extends Error {
  constructor() {
    super("Invalid username or password");
    this.name = "InvalidCredentialsError";
  }
}

export class RegistrationConflictError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "RegistrationConflictError";
  }
}

export const registerUser = async (input: RegisterInput) => {
  const existingUsername = await findUserByUsername(input.username);

  if (existingUsername) {
    throw new RegistrationConflictError("Username is already taken");
  }

  const existingEmail = await findUserByEmail(input.email);

  if (existingEmail) {
    throw new RegistrationConflictError("Email is already registered");
  }

  const passwordHash = await hashPassword(input.password);

  const user = await createUser({
    username: input.username,
    email: input.email,
    passwordHash,
  });

  const session = await createUserSession(user.id);

  return {
    user,
    session,
  };
};

export const loginUser = async (input: LoginInput) => {
  const user = await findUserByIdentifier(input.identifier);

  if (!user) {
    throw new InvalidCredentialsError();
  }

  const passwordIsValid = await verifyPassword(
    user.passwordHash,
    input.password,
  );

  if (!passwordIsValid) {
    throw new InvalidCredentialsError();
  }

  const session = await createUserSession(user.id);

  return {
    user,
    session,
  };
};