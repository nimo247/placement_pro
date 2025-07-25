/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          50: "hsl(258 100% 97%)",
          100: "hsl(258 96% 93%)",
          200: "hsl(258 95% 87%)",
          300: "hsl(258 93% 79%)",
          400: "hsl(258 90% 66%)",
          500: "hsl(258 89% 58%)",
          600: "hsl(258 89% 50%)",
          700: "hsl(258 88% 42%)",
          800: "hsl(258 84% 34%)",
          900: "hsl(258 76% 29%)",
          950: "hsl(258 69% 19%)",
        },
      },
      borderRadius: {
        DEFAULT: "0.75rem",
      },
    },
  },
  plugins: [],
};
