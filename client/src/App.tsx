import { Button } from "@/components/ui/button";
import { LockKeyhole, Fingerprint } from "lucide-react";
import { Field, FieldLabel } from "./components/ui/field";
import { Input } from "./components/ui/input";
import { usePwaUpdateChecker } from "@/hooks/usePwaUpdateChecker";

function App() {
  usePwaUpdateChecker();

  return (
    <div className="max-w-xl mx-auto h-screen px-6">
      <div className="flex flex-col items-center pt-8 pb-6 gap-2">
        <div className="p-2 bg-neutral-800 size-fit rounded-lg">
          <LockKeyhole color="white" strokeWidth={1.5} />
        </div>
        <div className="font-serif text-3xl">Admin Log in</div>
      </div>
      <form className="flex flex-col gap-12 pt-8">
        <Field>
          <FieldLabel className="text-neutral-500">username</FieldLabel>
          <Input
            className="rounded-none border-0 border-b-2 border-neutral-800"
            placeholder="StrawberryPrincess20"
          />
        </Field>
        <Field>
          <FieldLabel className="text-neutral-500">password</FieldLabel>
          <Input className="rounded-none border-0 border-b-2 border-neutral-800" />
        </Field>
        <Button className="mt-8 py-6 text-lg rounded-2xl bg-neutral-800">
          Log in
        </Button>
      </form>
      <div className="flex items-center gap-4 my-8">
        <div className="flex-1 h-px bg-neutral-800" />
        <span className="text-xs text-muted-foreground">or</span>
        <div className="flex-1 h-px bg-neutral-800" />
      </div>
      <Button
        variant={"outline"}
        className={
          "border-neutral-800 flex gap-3 w-full py-6 text-lg rounded-2xl border-2"
        }
      >
        <Fingerprint className="size-6" /> Log in with Passkey
      </Button>
      <div>egg v20</div>
    </div>
  );
}

export default App;
