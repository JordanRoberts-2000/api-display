import { useMutation, useQueryClient } from "@tanstack/react-query";
import type { LoginInput } from "../types";
import { AuthApi } from "../auth-api";
import { queryKeys } from "@/lib/query-keys";

export function useLogin() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (input: LoginInput) => AuthApi.login(input),
    onSuccess: (session) => {
      queryClient.setQueryData(queryKeys.session, session);
    },
  });
}
