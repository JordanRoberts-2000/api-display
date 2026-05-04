import packageJson from "../../package.json";

export const config = {
  apiBaseUrl: "/api",
  appVersion: packageJson.version,
  isDev: import.meta.env.DEV,
  isProd: import.meta.env.PROD,
} as const;
