import plugin from "tailwindcss/plugin";

/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        212121: "#212121",
        121212: "#121212",
        "0D0D0D": "#0D0D0D",
        "0C0C0C": "#0C0C0C",
        D9D9D9: "#D9D9D9",
        585858: "#585858",
        515151: "#515151",
        949494: "#949494",
        FF013D: "#FF013D",
        FF4163: "#FF4163",
        "01DEA7": "#01DEA7",
        FFB800: "#FFB800",
        FFA928: "#FFA928",
      },
      fontSize: { 9: "9px", 11: "11px", 13: "13px" },
      fontFamily: {
        "microgramma-d-extended": "microgramma-d-extended",
        "sentic-text-black": "sentic-text-black",
        "sentic-text-bold": "sentic-text-bold",
        "sentic-text-light": "sentic-text-light",
        "ticking-timebomb": "ticking-timebomb",
      },
      screens: {
        "2k": "2560px",
        "4k": "3840px",
      },
    },
  },
  plugins: [
    plugin(function ({ addUtilities }) {
      const newUtilities = {
        ".scrollbar-hide::-webkit-scrollbar": { display: "none" },
        ".scrollbar-hide": {
          "scrollbar-width": "none",
          "-ms-overflow-style": "none",
        },
      };
      addUtilities(newUtilities);
    }),
  ],
};
