import i18n from "i18next";
import { initReactI18next } from "react-i18next";

/**
 * Initialize i18next with React integration.
 */
i18n.use(initReactI18next).init({
  lng: "en", // Default language
  fallbackLng: "en", // Fallback language if the chosen language is not available
  interpolation: {
    escapeValue: false, // React already escapes values, so no need to escape here
  },
});

export default i18n;
