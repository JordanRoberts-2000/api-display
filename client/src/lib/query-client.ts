import { MutationCache, QueryCache, QueryClient } from "@tanstack/react-query";
import { queryKeys } from "./query-keys";
import { HTTPError } from "ky";

function isUnauthorized(error: unknown) {
  return error instanceof HTTPError && error.response.status === 401;
}

function handleUnauthorized(queryClient: QueryClient) {
  queryClient.setQueryData(queryKeys.session, { isAuth: false });
  // todo: router.navigate('/login')
  // todo: toast.error("Your session expired. Please sign in again.");
}

export const queryClient = new QueryClient({
  queryCache: new QueryCache({
    onError: (error) => {
      if (isUnauthorized(error)) {
        handleUnauthorized(queryClient);
      }
    },
  }),

  mutationCache: new MutationCache({
    onError: (error) => {
      if (isUnauthorized(error)) {
        handleUnauthorized(queryClient);
      }
    },
  }),

  defaultOptions: {
    queries: {
      retry: 2,
    },
    mutations: {
      retry: false,
    },
  },
});
