import ReactDOM from "react-dom/client";
import App from "@/components/App";
import { VisibilityProvider } from "@/providers/VisibilityProvider";
import { DataProvider } from "@/providers/DataProvider";
import "@/services/i18n";
import "./index.css";

ReactDOM.createRoot(document.getElementById("root")!).render(
  <DataProvider>
    <VisibilityProvider>
      <App />
    </VisibilityProvider>
  </DataProvider>
);
