import { apiClient } from "@/lib/api-client";
import type { AuthSession, LoginInput } from "./types";

export const AuthApi = {
  async login(input: LoginInput): Promise<AuthSession> {
    return apiClient
      .post("auth/login", {
        json: input,
      })
      .json<AuthSession>();
  },

  async session(): Promise<AuthSession> {
    return apiClient.get("auth/session").json<AuthSession>();
  },

  async logout(): Promise<void> {
    await apiClient.post("auth/logout");
  },
} as const;
