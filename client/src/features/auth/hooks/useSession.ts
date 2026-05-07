import { queryKeys } from "@/lib/query-keys";
import { useQuery } from "@tanstack/react-query";
import { AuthApi } from "../auth-api";

export function useSession() {
  return useQuery({
    queryKey: queryKeys.session,
    queryFn: AuthApi.session,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    staleTime: 60_000,
  });
}
