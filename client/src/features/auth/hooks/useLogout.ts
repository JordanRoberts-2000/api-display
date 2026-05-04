import { useMutation, useQueryClient } from "@tanstack/react-query";
import { AuthApi } from "../auth-api";
import { queryKeys } from "@/lib/query-keys";

export function useLogout() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: AuthApi.logout,

    onSuccess: () => {
      queryClient.setQueryData(queryKeys.session, { isAuth: false });
      // todo: queryClient.removeQueries({ queryKey: ["urls"] });
    },
  });
}
