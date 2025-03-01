import useData from "@/hooks/useData";
import { BarProps } from "@/types/BasicTypes";
import { hexToRgba } from "@/utils/misc";
import { useEffect, useRef, useState } from "react";

const Square = ({ children, occupancy, progressColor = "#2B2B2B", strokeWidth = 10 }: BarProps) => {
  const { ClientInfo } = useData();
  const clampedOccupancy = Math.min(Math.max(occupancy, 0), 100);
  const progressRef = useRef<SVGRectElement | null>(null);
  const [pathLength, setPathLength] = useState<number>(0);
  const filledLength = (clampedOccupancy / 100) * pathLength;
  const strokeDashoffsetValue = pathLength - filledLength;

  useEffect(() => {
    if (progressRef.current) {
      requestAnimationFrame(() => {
        if (progressRef.current) {
          const length = progressRef.current.getTotalLength();
          setPathLength(length);
        }
      });
    }
  }, []);

  const backgroundStyle =
    ClientInfo.time.gameHours < 9
      ? {
          backgroundImage: `radial-gradient(circle at center, ${hexToRgba(progressColor, 0)} 5%, ${hexToRgba(progressColor, 0.28)} 100%)`,
          width: 0,
          height: 0,
        }
      : { backgroundColor: "#0000004d", inset: 0 };

  return (
    <>
      <div className="absolute inset-0 flex items-center justify-center z-10">{children}</div>
      <div className="absolute z-0 rounded" style={backgroundStyle}></div>

      <svg className="z-10" width="100%" height="100%" viewBox="0 0 115 115">
        <path d="M 56.945618,8.5103502 H 107.49016 V 107.50024 H 8.5002594 V 8.5103502 H 56.945618" stroke={hexToRgba(progressColor, 0.2)} strokeWidth={strokeWidth} strokeLinecap="round" strokeLinejoin="round" fill="none" />
        <path
          className="progress"
          ref={progressRef}
          d="M 56.945618,8.5103502 H 107.49016 V 107.50024 H 8.5002594 V 8.5103502 H 56.945618"
          fill="none"
          stroke={progressColor}
          strokeWidth={strokeWidth}
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeDasharray={pathLength}
          strokeDashoffset={strokeDashoffsetValue}
          style={{
            transition: `stroke-dashoffset .3s linear`,
          }}
        />
      </svg>
    </>
  );
};

export default Square;
