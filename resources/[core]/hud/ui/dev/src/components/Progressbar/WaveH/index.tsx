import React from "react";
import { BarProps } from "@/types/BasicTypes";

const WaveH: React.FC<BarProps> = ({ occupancy, progressColor = "#2B2B2B", children }) => {
  const clampedOccupancy = Math.min(Math.max(occupancy, 0), 100);

  const waveSVG = (color: string) => `
    <svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 120 60'>
      <path fill='${color}' d='M0 30 Q 30 15 60 30 T 120 30 V 60 H 0 Z'/>
    </svg>`;

  const bgImage = `url("data:image/svg+xml,${encodeURIComponent(waveSVG(progressColor))}")`;

  return (
    <div className="relative w-full h-full flex rounded-lg bg-black/50 overflow-hidden">
      <div className="absolute inset-0 flex items-center justify-center z-10">{children}</div>
      <div
        className="absolute bottom-0 w-full z-0"
        style={{
          height: `${clampedOccupancy}%`,
          background: progressColor,
          transition: `height .3s linear`,
          opacity: 0.8,
        }}
      >
        <div
          className="wave"
          style={{
            backgroundImage: bgImage,
          }}
        ></div>
        <div
          className="wave wave2"
          style={{
            backgroundImage: bgImage,
          }}
        ></div>
        <div
          className="wave wave3"
          style={{
            backgroundImage: bgImage,
          }}
        ></div>
      </div>
    </div>
  );
};

export default WaveH;
