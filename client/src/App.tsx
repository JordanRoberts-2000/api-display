import { useSession } from "./features/auth";
import LoginPage from "./pages/LoginPage";
import UrlsPage from "./pages/UrlsPage";

function App() {
  const sessionQuery = useSession();

  if (sessionQuery.isPending) return <div>loading</div>;
  if (sessionQuery.isError) return <div>error</div>;

  if (!sessionQuery.data.isAuth) return <LoginPage />;

  return <UrlsPage />;
}

export default App;
