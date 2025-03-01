import { BarStyleType } from "@/types/BasicTypes";

/**
 * Will return whether the current environment is in a regular browser and not CEF.
 * @returns {boolean} True if the environment is a regular browser, false if CEF.
 */
export const isEnvBrowser = (): boolean => !window.invokeNative;

/**
 * Basic no operation function.
 */
export const noop = (): void => {};

/**
 * An array of color codes.
 */
export const BarColors: string[] = ["#CF4E5B", "#CF4E75", "#CF4EAB", "#A888DE", "#6b21a8", "#7FCF4E", "#C4FF48", "#FFC400", "#FF9900", "#CF654E", "#1d4ed8", "#00C2FF", "#4EB0CF", "#4ECFA1", "#00FFA3", "#A68A7B", "#FFFFFF", "#7A7A7A", "#4B4B4B", "#00000057"];

/**
 * Formats a number with commas as thousand separators.
 * @param {number} number - The number to format.
 * @returns {string} The formatted number with commas.
 */
export function formatNumberWithComma(number: number): string {
  number = number ?? 0;
  const roundedNumber = Math.round(number);
  return roundedNumber.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
}

/**
 * Pads a number with a leading zero if it's less than 10.
 * @param {number} number - The number to pad.
 * @returns {string} The padded number as a string.
 */
export const padNumber = (number: number): string => {
  return number ? (number < 10 ? `0${number}` : number.toString()) : "00";
};

/**
 * Creates a debounced version of a function that delays its execution until after a specified wait time
 * has elapsed since the last time it was invoked.
 *
 * @param func
 * @param wait
 * @returns - A debounced function.
 *
 */
export function debounce<T extends (...args: any[]) => void>(func: T, wait: number): (...args: Parameters<T>) => void {
  let timeout: NodeJS.Timeout | null = null;
  return function (this: any, ...args: Parameters<T>) {
    if (timeout) {
      clearTimeout(timeout);
    }
    timeout = setTimeout(() => {
      func.apply(this, args);
    }, wait);
  };
}

/**
 * Converts a hex color code to an RGBA color string with a specified opacity.
 *
 * @param hex - The hex color code (e.g., "#RRGGBB").
 * @param opacity - The desired opacity value (from 0 to 1).
 * @returns The RGBA color string
 */
export const hexToRgba = (hex: string, opacity: number): string => {
  const hexRegex = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i;
  const result = hexRegex.exec(hex);

  if (!result) {
    console.error("Invalid hex code format");
    return "#121212";
  }

  const [, r, g, b] = result;
  const rgba = `rgba(${parseInt(r, 16)}, ${parseInt(g, 16)}, ${parseInt(b, 16)}, ${opacity})`;

  return rgba;
};

/**
 * Get formatted current date
 * @returns Date
 */
export function getFormattedDate() {
  const currentDate = new Date();

  const year = currentDate.getFullYear();
  const month = String(currentDate.getMonth() + 1).padStart(2, "0");
  const day = String(currentDate.getDate()).padStart(2, "0");

  const hours = String(currentDate.getHours()).padStart(2, "0");
  const minutes = String(currentDate.getMinutes()).padStart(2, "0");

  return `${day}/${month}/${year} ${hours}:${minutes}`;
}

/**
 * Determines the icon color based on the style and the current color.
 *
 * @param style BarStyleType
 * @param color string
 *
 * @returns string Color code
 */
export const calcIconColor = (style: BarStyleType, color: string = "#FFFFFF", meta?: any): string => {
  const defaultColor = "#FFFFFF";
  const alternateColor = "#212121";

  if (meta && meta.isTalking) {
    return VOICE_TALKING_COLOR;
  }

  if (style == "circle" || style == "zarg" || style == "hexagon" || style == "classic") {
    return defaultColor;
  } else if (style == "hexagon-w" || style == "wave-c" || style == "wave-h" || style == "universal") {
    return color != defaultColor ? defaultColor : alternateColor;
  }

  return color;
};

export const VOICE_TALKING_COLOR = "#7FCF4E";
