import { Toaster } from "sonner";
import { QueryClientProvider } from "@tanstack/react-query";
import { queryClient } from "@/lib/query-client";
import { usePwaUpdateChecker } from "@/hooks/usePwaUpdateChecker";

export function AppProviders({ children }: { children: React.ReactNode }) {
  usePwaUpdateChecker();
  return (
    <QueryClientProvider client={queryClient}>
      <Toaster />
      {children}
    </QueryClientProvider>
  );
}
