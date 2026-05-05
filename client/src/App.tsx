import AppError from "./components/feedback/AppError";
import AppLoading from "./components/feedback/AppLoading";
import { useSession } from "./features/auth";
import LoginPage from "./pages/LoginPage";
import UrlsPage from "./pages/UrlsPage";

function App() {
  const sessionQuery = useSession();

  if (sessionQuery.isPending) return <AppLoading />;
  if (sessionQuery.isError) return <AppError />;

  return sessionQuery.data.isAuth ? <UrlsPage /> : <LoginPage />;
}

export default App;
