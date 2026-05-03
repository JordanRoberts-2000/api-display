// src/hooks/usePwaUpdateChecker.ts
import { time } from "@/lib/time";
import { useEffect } from "react";
import { toast } from "sonner";
import { registerSW } from "virtual:pwa-register";

const UPDATE_TOAST_ID = "pwa-update";

type PwaUpdateCheckerConfig = {
  visibilityCheckMs: number;
  remindMeLaterMs: number;
};

const DEFAULT_CONFIG: PwaUpdateCheckerConfig = {
  visibilityCheckMs: time.minutes(15),
  remindMeLaterMs: time.hours(1),
};

export function usePwaUpdateChecker(
  config: PwaUpdateCheckerConfig = DEFAULT_CONFIG,
) {
  const { visibilityCheckMs, remindMeLaterMs } = config;
  useEffect(() => {
    if (!("serviceWorker" in navigator)) return;

    let remindLaterTimeout: ReturnType<typeof setTimeout> | null = null;
    let updateAvailable = false;

    function clearReminder() {
      if (remindLaterTimeout !== null) {
        clearTimeout(remindLaterTimeout);
        remindLaterTimeout = null;
      }
    }

    function showUpdateToast(
      updateSW: (reloadPage?: boolean) => Promise<void>,
    ) {
      if (!updateAvailable) return;

      toast("Update available", {
        id: UPDATE_TOAST_ID,
        position: "bottom-right",
        description: "A new version is ready.",
        duration: Infinity,
        action: {
          label: "Update",
          onClick: () => {
            clearReminder();
            updateSW(true);
          },
        },
        cancel: {
          label: "Later",
          onClick: () => {
            toast.dismiss(UPDATE_TOAST_ID);
          },
        },
        onDismiss: () => {
          clearReminder();
          remindLaterTimeout = setTimeout(() => {
            showUpdateToast(updateSW);
          }, remindMeLaterMs);
        },
      });
    }

    const updateSW = registerSW({
      onNeedRefresh() {
        updateAvailable = true;
        showUpdateToast(updateSW);
      },
    });

    let lastUpdateCheck = 0;

    async function checkForServiceWorkerUpdate() {
      if (updateAvailable) return;

      const now = Date.now();

      if (now - lastUpdateCheck < visibilityCheckMs) return;

      lastUpdateCheck = now;

      const registration = await navigator.serviceWorker.ready;
      await registration.update();
    }

    function handleVisibilityChange() {
      if (document.visibilityState === "visible") {
        checkForServiceWorkerUpdate();
      }
    }

    document.addEventListener("visibilitychange", handleVisibilityChange);

    return () => {
      document.removeEventListener("visibilitychange", handleVisibilityChange);
      clearReminder();
      toast.dismiss(UPDATE_TOAST_ID);
    };
  }, [remindMeLaterMs, visibilityCheckMs]);
}
