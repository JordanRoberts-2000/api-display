import { Button } from "@/components/ui/button";
import { Field, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import type { SubmitEvent } from "react";
import { toast } from "sonner";

function LoginForm() {
  function handleSubmit(event: SubmitEvent<HTMLFormElement>) {
    event.preventDefault();

    const formData = new FormData(event.currentTarget);

    const username = String(formData.get("username") ?? "").trim();
    const password = String(formData.get("password") ?? "");

    if (!username || !password) {
      toast.error("Fields cannot be empty");
      return;
    }

    // todo: loginMutation.mutate({ username, password });
  }

  return (
    <form className="flex flex-col gap-12 pt-8" onSubmit={handleSubmit}>
      <Field>
        <FieldLabel htmlFor="username" className="text-neutral-500">
          Username
        </FieldLabel>
        <Input
          id="username"
          name="username"
          type="text"
          autoComplete="username"
          className="rounded-none border-0 border-b-2 border-neutral-800"
          placeholder="StrawberryPrincess20"
        />
      </Field>

      <Field>
        <FieldLabel htmlFor="password" className="text-neutral-500">
          Password
        </FieldLabel>
        <Input
          id="password"
          name="password"
          type="password"
          autoComplete="current-password"
          className="rounded-none border-0 border-b-2 border-neutral-800"
        />
      </Field>

      <Button
        type="submit"
        className="mt-8 rounded-2xl bg-neutral-800 py-6 text-lg"
      >
        Log in
      </Button>
    </form>
  );
}

export default LoginForm;
