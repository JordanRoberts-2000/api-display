import { config } from "@/app/config";
import ky from "ky";

export const apiClient = ky.create({
  prefix: config.apiBaseUrl,
  retry: 0,
});
